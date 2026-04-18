from django.db.models import Q
from rest_framework import generics, permissions, status
from rest_framework.parsers import FormParser, MultiPartParser
from rest_framework.response import Response
from rest_framework.views import APIView

from core.permissions import IsAuthenticatedUser, IsOwner
from core.throttles import UploadRateThrottle
from core.validators import validate_image_file

from .filters import AttractionFilter, DestinationFilter, TransportFilter
from .models import Attraction, Destination, District, Division, Transport
from .serializers import (
    AttractionSerializer,
    DestinationDetailSerializer,
    DestinationListSerializer,
    DestinationWriteSerializer,
    DistrictSerializer,
    DivisionSerializer,
    TransportSerializer,
)


class DivisionListView(generics.ListAPIView):
    queryset = Division.objects.prefetch_related("districts")
    serializer_class = DivisionSerializer
    permission_classes = [permissions.AllowAny]
    pagination_class = None


class DistrictListView(generics.ListAPIView):
    serializer_class = DistrictSerializer
    permission_classes = [permissions.AllowAny]
    pagination_class = None

    def get_queryset(self):
        qs = District.objects.select_related("division")
        division_id = self.request.query_params.get("division")
        if division_id:
            qs = qs.filter(division_id=division_id)
        return qs


class DestinationListCreateView(generics.ListCreateAPIView):
    filterset_class = DestinationFilter
    ordering_fields = ["name", "created_at"]

    def get_serializer_class(self):
        if self.request.method == "POST":
            return DestinationWriteSerializer
        return DestinationListSerializer

    def get_permissions(self):
        if self.request.method == "POST":
            return [IsAuthenticatedUser()]
        return [permissions.AllowAny()]

    def get_queryset(self):
        qs = Destination.objects.select_related("district__division").prefetch_related("tags")
        if not (self.request.user.is_authenticated and self.request.user.is_moderator_or_admin):
            qs = qs.filter(status=Destination.Status.APPROVED)
        return qs

    def perform_create(self, serializer):
        serializer.save(submitted_by=self.request.user)


class DestinationDetailView(generics.RetrieveUpdateDestroyAPIView):
    lookup_field = "slug"

    def get_serializer_class(self):
        if self.request.method in ("PUT", "PATCH"):
            return DestinationWriteSerializer
        return DestinationDetailSerializer

    def get_permissions(self):
        if self.request.method in ("PUT", "PATCH", "DELETE"):
            return [IsOwner()]
        return [permissions.AllowAny()]

    def get_queryset(self):
        return (
            Destination.objects
            .select_related("district__division", "submitted_by")
            .prefetch_related("tags")
        )

    def get_object(self):
        obj = super().get_object()
        obj.approved_attractions = obj.attractions.filter(status="APPROVED")
        obj.approved_transports = obj.transports.filter(status="APPROVED")
        return obj


class AttractionListCreateView(generics.ListCreateAPIView):
    serializer_class = AttractionSerializer
    filterset_class = AttractionFilter

    def get_permissions(self):
        if self.request.method == "POST":
            return [IsAuthenticatedUser()]
        return [permissions.AllowAny()]

    def get_queryset(self):
        qs = Attraction.objects.select_related("submitted_by")
        user = self.request.user
        if user.is_authenticated and user.is_moderator_or_admin:
            return qs
        if user.is_authenticated:
            return qs.filter(
                Q(status=Attraction.Status.APPROVED) | Q(submitted_by=user)
            )
        return qs.filter(status=Attraction.Status.APPROVED)

    def perform_create(self, serializer):
        is_public = serializer.validated_data.get("is_public_submission", False)
        status = (
            Attraction.Status.PENDING
            if is_public
            else Attraction.Status.APPROVED
        )
        serializer.save(submitted_by=self.request.user, status=status)


class AttractionDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = AttractionSerializer

    def get_permissions(self):
        if self.request.method in ("PUT", "PATCH", "DELETE"):
            return [IsOwner()]
        return [permissions.AllowAny()]

    def get_queryset(self):
        return Attraction.objects.select_related("submitted_by")


class TransportListCreateView(generics.ListCreateAPIView):
    serializer_class = TransportSerializer
    filterset_class = TransportFilter

    def get_permissions(self):
        if self.request.method == "POST":
            return [IsAuthenticatedUser()]
        return [permissions.AllowAny()]

    def get_queryset(self):
        qs = Transport.objects.all()
        if not (self.request.user.is_authenticated and self.request.user.is_moderator_or_admin):
            qs = qs.filter(status=Transport.Status.APPROVED)
        return qs

    def perform_create(self, serializer):
        serializer.save(submitted_by=self.request.user)


class TransportDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = TransportSerializer

    def get_permissions(self):
        if self.request.method == "GET":
            return [permissions.AllowAny()]
        return [permissions.IsAuthenticated(), IsOwner()]

    def get_queryset(self):
        qs = Transport.objects.select_related("submitted_by", "destination")
        user = self.request.user
        if user.is_authenticated and user.is_moderator_or_admin:
            return qs
        if user.is_authenticated:
            return qs.filter(
                Q(status=Transport.Status.APPROVED) | Q(submitted_by=user)
            )
        return qs.filter(status=Transport.Status.APPROVED)


class ImageUploadView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]
    throttle_classes = [UploadRateThrottle]

    def post(self, request):
        file = request.FILES.get("image")
        if not file:
            return Response(
                {"detail": "No image file provided."},
                status=status.HTTP_400_BAD_REQUEST,
            )
        try:
            validate_image_file(file)
        except Exception as e:
            return Response({"detail": str(e)}, status=status.HTTP_400_BAD_REQUEST)

        from django.core.files.storage import default_storage

        path = default_storage.save(f"uploads/{file.name}", file)
        url = default_storage.url(path)
        return Response({"url": url}, status=status.HTTP_201_CREATED)
