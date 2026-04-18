from django.db.models import F
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import generics, permissions, status
from rest_framework.filters import SearchFilter
from rest_framework.response import Response
from rest_framework.views import APIView

from core.experience_ordering import ExperienceOrderingFilter
from core.permissions import IsAuthenticatedUser, IsOwner

from .annotations import annotate_experience_list_metrics
from .filters import ExperienceFilter
from .models import Day, Entry, Experience
from .serializers import (
    ExperienceDetailSerializer,
    ExperienceListSerializer,
    ExperienceWriteSerializer,
)
from .tasks import generate_cover_collage


class ExperienceListCreateView(generics.ListCreateAPIView):
    filter_backends = [
        DjangoFilterBackend,
        SearchFilter,
        ExperienceOrderingFilter,
    ]
    filterset_class = ExperienceFilter
    ordering_fields = ["created_at", "estimated_cost", "score"]
    search_fields = ("title", "description")

    def get_serializer_class(self):
        if self.request.method == "POST":
            return ExperienceWriteSerializer
        return ExperienceListSerializer

    def get_permissions(self):
        if self.request.method == "POST":
            return [IsAuthenticatedUser()]
        return [permissions.AllowAny()]

    def get_queryset(self):
        qs = annotate_experience_list_metrics(
            Experience.objects.select_related("author", "destination").prefetch_related("tags")
        )
        # Public profile (§9.8): only PUBLISHED for an author's profile, even for the author.
        pub = self.request.query_params.get("published_only", "").lower()
        if pub in ("1", "true", "yes"):
            return qs.filter(status=Experience.Status.PUBLISHED)
        if self.request.user.is_authenticated:
            from django.db.models import Q

            qs = qs.filter(
                Q(status=Experience.Status.PUBLISHED)
                | Q(author=self.request.user)
            )
        else:
            qs = qs.filter(status=Experience.Status.PUBLISHED)
        return qs

    def perform_create(self, serializer):
        visibility = self.request.data.get("visibility", "PRIVATE")
        if visibility == "PUBLIC":
            experience = serializer.save(
                author=self.request.user,
                status=Experience.Status.PENDING_REVIEW,
            )
        else:
            experience = serializer.save(
                author=self.request.user,
                status=Experience.Status.DRAFT,
            )
        if experience.cover_image:
            experience.cover_image_pending = False
            experience.save(update_fields=["cover_image_pending"])
        else:
            experience.cover_image_pending = True
            experience.save(update_fields=["cover_image_pending"])
            generate_cover_collage.delay(experience.id)


class ExperienceDetailView(generics.RetrieveUpdateDestroyAPIView):
    lookup_field = "slug"

    def get_serializer_class(self):
        if self.request.method in ("PUT", "PATCH"):
            return ExperienceWriteSerializer
        return ExperienceDetailSerializer

    def get_permissions(self):
        if self.request.method in ("PUT", "PATCH", "DELETE"):
            return [IsOwner()]
        return [permissions.AllowAny()]

    def get_queryset(self):
        return annotate_experience_list_metrics(
            Experience.objects.select_related("author", "destination").prefetch_related(
                "days__entries__attraction", "tags", "votes"
            )
        )


class ExperienceCloneView(APIView):
    permission_classes = [IsAuthenticatedUser]

    def post(self, request, slug):
        try:
            original = Experience.objects.get(slug=slug, status=Experience.Status.PUBLISHED)
        except Experience.DoesNotExist:
            return Response(
                {"detail": "Experience not found."},
                status=status.HTTP_404_NOT_FOUND,
            )

        clone = Experience.objects.create(
            title=f"{original.title} (Copy)",
            description=original.description,
            destination=original.destination,
            user_cost=original.user_cost,
            status=Experience.Status.DRAFT,
            visibility=Experience.Visibility.PRIVATE,
            author=request.user,
            cloned_from=original,
        )
        clone.tags.set(original.tags.all())

        for day in original.days.filter(is_deleted=False).order_by("position"):
            new_day = Day.objects.create(
                experience=clone,
                date=day.date,
                position=day.position,
            )
            for entry in day.entries.filter(is_deleted=False).order_by("position"):
                Entry.objects.create(
                    day=new_day,
                    name=entry.name,
                    time=entry.time,
                    cost=entry.cost,
                    notes=entry.notes,
                    image=entry.image,
                    attraction=entry.attraction,
                    position=entry.position,
                )

        if original.cover_image:
            from django.core.files.base import ContentFile

            clone.cover_image.save(
                original.cover_image.name.split("/")[-1],
                ContentFile(original.cover_image.read()),
                save=True,
            )

        clone.compute_estimated_cost()
        return Response(
            {"slug": clone.slug, "id": clone.id},
            status=status.HTTP_201_CREATED,
        )


class MyExperiencesView(generics.ListAPIView):
    serializer_class = ExperienceListSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        qs = annotate_experience_list_metrics(
            Experience.objects.filter(author=self.request.user).select_related(
                "author", "destination"
            )
        )
        scope = (self.request.query_params.get("scope") or "all").strip().lower()
        if scope == "published":
            qs = qs.filter(status=Experience.Status.PUBLISHED)
        elif scope == "private":
            qs = qs.filter(visibility=Experience.Visibility.PRIVATE)

        ordering = (self.request.query_params.get("ordering") or "-created_at").strip()
        allowed = {
            "-created_at",
            "created_at",
            "-comment_count",
            "comment_count",
            "-score",
            "score",
            "estimated_cost",
            "-estimated_cost",
            "title",
            "-title",
        }
        if ordering not in allowed:
            ordering = "-created_at"
        if ordering == "estimated_cost":
            qs = qs.order_by(F("estimated_cost").asc(nulls_last=True))
        elif ordering == "-estimated_cost":
            qs = qs.order_by(F("estimated_cost").desc(nulls_first=True))
        else:
            qs = qs.order_by(ordering)
        return qs
