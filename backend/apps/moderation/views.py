from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.destinations.models import Attraction, Destination, Transport
from apps.destinations.serializers import (
    AttractionSerializer,
    DestinationListSerializer,
    TransportSerializer,
)
from apps.experiences.annotations import annotate_experience_list_metrics
from apps.experiences.models import Experience
from apps.experiences.serializers import ExperienceListSerializer
from apps.interactions.models import Report
from apps.notifications.models import Notification
from core.permissions import IsModeratorOrAdmin

from .serializers import ModerationActionSerializer


class ModerationQueueView(APIView):
    """List all pending content for review."""

    permission_classes = [IsModeratorOrAdmin]

    def get(self, request):
        content_type = request.query_params.get("type", "all")
        data = {}

        if content_type in ("all", "destinations"):
            destinations = Destination.objects.filter(status="PENDING").select_related(
                "district__division"
            )
            data["destinations"] = DestinationListSerializer(destinations, many=True).data

        if content_type in ("all", "attractions"):
            attractions = Attraction.objects.filter(
                status="PENDING", is_public_submission=True
            ).select_related("submitted_by")
            data["attractions"] = AttractionSerializer(attractions, many=True).data

        if content_type in ("all", "transports"):
            transports = Transport.objects.filter(status="PENDING")
            data["transports"] = TransportSerializer(transports, many=True).data

        if content_type in ("all", "experiences"):
            experiences = annotate_experience_list_metrics(
                Experience.objects.filter(status="PENDING_REVIEW")
                .select_related("author", "destination")
                .prefetch_related("tags", "votes")
            )
            data["experiences"] = ExperienceListSerializer(
                experiences, many=True, context={"request": request}
            ).data

        if content_type in ("all", "reports"):
            reports = Report.objects.select_related(
                "comment__author", "reporter"
            ).order_by("-created_at")[:50]
            data["reports"] = [
                {
                    "id": r.id,
                    "comment_id": r.comment_id,
                    "comment_text": r.comment.text[:200],
                    "comment_author": r.comment.author.username,
                    "reporter": r.reporter.username,
                    "reason": r.reason,
                    "created_at": r.created_at.isoformat(),
                }
                for r in reports
            ]

        return Response(data)


class ModerateDestinationView(APIView):
    permission_classes = [IsModeratorOrAdmin]

    def post(self, request, pk):
        serializer = ModerationActionSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        try:
            destination = Destination.objects.get(pk=pk)
        except Destination.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)

        action = serializer.validated_data["action"]
        if action == "approve":
            destination.status = Destination.Status.APPROVED
            destination.rejection_reason = None
            Notification.objects.create(
                recipient=destination.submitted_by,
                type=Notification.Type.DESTINATION_APPROVED,
                message=f'Your destination "{destination.name}" has been approved!',
                destination=destination,
            )
        else:
            destination.status = Destination.Status.REJECTED
            destination.rejection_reason = serializer.validated_data["rejection_reason"]
            Notification.objects.create(
                recipient=destination.submitted_by,
                type=Notification.Type.DESTINATION_REJECTED,
                message=(
                    f'Your destination "{destination.name}" was rejected: '
                    f"{destination.rejection_reason}"
                ),
                destination=destination,
            )

        destination.save(update_fields=["status", "rejection_reason"])
        return Response({"status": destination.status})


class ModerateAttractionView(APIView):
    permission_classes = [IsModeratorOrAdmin]

    def post(self, request, pk):
        serializer = ModerationActionSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        try:
            attraction = Attraction.objects.get(pk=pk)
        except Attraction.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)

        action = serializer.validated_data["action"]
        if action == "approve":
            attraction.status = Attraction.Status.APPROVED
            attraction.rejection_reason = None
            Notification.objects.create(
                recipient=attraction.submitted_by,
                type=Notification.Type.ATTRACTION_APPROVED,
                message=f'Your attraction "{attraction.name}" has been approved!',
                attraction=attraction,
            )
        else:
            attraction.status = Attraction.Status.REJECTED
            attraction.rejection_reason = serializer.validated_data["rejection_reason"]
            Notification.objects.create(
                recipient=attraction.submitted_by,
                type=Notification.Type.ATTRACTION_REJECTED,
                message=(
                    f'Your attraction "{attraction.name}" was rejected: '
                    f"{attraction.rejection_reason}"
                ),
                attraction=attraction,
            )

        attraction.save(update_fields=["status", "rejection_reason"])
        return Response({"status": attraction.status})


class ModerateTransportView(APIView):
    permission_classes = [IsModeratorOrAdmin]

    def post(self, request, pk):
        serializer = ModerationActionSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        try:
            transport = Transport.objects.get(pk=pk)
        except Transport.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)

        action = serializer.validated_data["action"]
        if action == "approve":
            transport.status = Transport.Status.APPROVED
            transport.rejection_reason = None
        else:
            transport.status = Transport.Status.REJECTED
            transport.rejection_reason = serializer.validated_data["rejection_reason"]

        transport.save(update_fields=["status", "rejection_reason"])
        return Response({"status": transport.status})


class ModerateExperienceView(APIView):
    permission_classes = [IsModeratorOrAdmin]

    def post(self, request, pk):
        serializer = ModerationActionSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        try:
            experience = Experience.objects.get(pk=pk)
        except Experience.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)

        action = serializer.validated_data["action"]
        if action == "approve":
            experience.status = Experience.Status.PUBLISHED
            experience.rejection_reason = None
            Notification.objects.create(
                recipient=experience.author,
                type=Notification.Type.EXPERIENCE_APPROVED,
                message=f'Your experience "{experience.title}" has been published!',
                experience=experience,
            )
        else:
            experience.status = Experience.Status.REJECTED
            experience.rejection_reason = serializer.validated_data["rejection_reason"]
            Notification.objects.create(
                recipient=experience.author,
                type=Notification.Type.EXPERIENCE_REJECTED,
                message=(
                    f'Your experience "{experience.title}" was rejected: '
                    f"{experience.rejection_reason}"
                ),
                experience=experience,
            )

        experience.save(update_fields=["status", "rejection_reason"])
        return Response({"status": experience.status})


class ModerationStatsView(APIView):
    permission_classes = [IsModeratorOrAdmin]

    def get(self, request):
        return Response(
            {
                "pending_destinations": Destination.objects.filter(status="PENDING").count(),
                "pending_attractions": Attraction.objects.filter(
                    status="PENDING", is_public_submission=True
                ).count(),
                "pending_transports": Transport.objects.filter(status="PENDING").count(),
                "pending_experiences": Experience.objects.filter(status="PENDING_REVIEW").count(),
                "pending_reports": Report.objects.filter(status="PENDING").count(),
            }
        )
