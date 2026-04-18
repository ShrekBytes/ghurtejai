from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from core.permissions import IsAuthenticatedUser

from .models import (
    Comment,
    CommentVote,
    DestinationBookmark,
    ExperienceBookmark,
    Report,
    Vote,
)
from .serializers import (
    CommentSerializer,
    CommentVoteSerializer,
    CommentWriteSerializer,
    DestinationBookmarkSerializer,
    ExperienceBookmarkSerializer,
    ReportSerializer,
)


class ExperienceVoteView(APIView):
    """Reddit-style experience vote: POST {\"value\": 1|-1}; same value again removes."""

    permission_classes = [IsAuthenticatedUser]

    def post(self, request, experience_id):
        serializer = CommentVoteSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        value = serializer.validated_data["value"]

        existing = Vote.objects.filter(
            user=request.user, experience_id=experience_id
        ).first()

        if existing:
            if existing.value == value:
                existing.delete()
                return Response({"status": "removed"}, status=status.HTTP_200_OK)
            existing.value = value
            existing.save(update_fields=["value", "updated_at"])
            return Response({"status": "changed"}, status=status.HTTP_200_OK)

        Vote.objects.create(
            user=request.user, experience_id=experience_id, value=value
        )
        return Response({"status": "added"}, status=status.HTTP_201_CREATED)


class CommentListCreateView(generics.ListCreateAPIView):
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_serializer_class(self):
        if self.request.method == "POST":
            return CommentWriteSerializer
        return CommentSerializer

    def get_queryset(self):
        experience_id = self.kwargs["experience_id"]
        return (
            Comment.objects
            .filter(experience_id=experience_id, parent__isnull=True)
            .select_related("author__profile")
            .prefetch_related("replies__author__profile", "comment_votes")
        )

    def perform_create(self, serializer):
        serializer.save(
            author=self.request.user,
            experience_id=self.kwargs["experience_id"],
        )


class CommentDeleteView(generics.DestroyAPIView):
    permission_classes = [IsAuthenticatedUser]
    queryset = Comment.objects.all()

    def get_queryset(self):
        return Comment.objects.filter(author=self.request.user)


class CommentVoteView(APIView):
    """Toggle or change vote on a comment."""
    permission_classes = [IsAuthenticatedUser]

    def post(self, request, comment_id):
        serializer = CommentVoteSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        value = serializer.validated_data["value"]

        existing = CommentVote.objects.filter(
            user=request.user, comment_id=comment_id
        ).first()

        if existing:
            if existing.value == value:
                existing.delete()
                return Response({"status": "removed"})
            existing.value = value
            existing.save(update_fields=["value"])
            return Response({"status": "changed"})

        CommentVote.objects.create(
            user=request.user, comment_id=comment_id, value=value
        )
        return Response({"status": "added"}, status=status.HTTP_201_CREATED)


class ReportCreateView(generics.CreateAPIView):
    serializer_class = ReportSerializer
    permission_classes = [IsAuthenticatedUser]

    def perform_create(self, serializer):
        serializer.save(reporter=self.request.user)


class DestinationBookmarkToggleView(APIView):
    permission_classes = [IsAuthenticatedUser]

    def post(self, request, destination_id):
        bookmark, created = DestinationBookmark.objects.get_or_create(
            user=request.user, destination_id=destination_id
        )
        if not created:
            bookmark.delete()
            return Response({"status": "removed"})
        return Response({"status": "added"}, status=status.HTTP_201_CREATED)


class ExperienceBookmarkToggleView(APIView):
    permission_classes = [IsAuthenticatedUser]

    def post(self, request, experience_id):
        bookmark, created = ExperienceBookmark.objects.get_or_create(
            user=request.user, experience_id=experience_id
        )
        if not created:
            bookmark.delete()
            return Response({"status": "removed"})
        return Response({"status": "added"}, status=status.HTTP_201_CREATED)


class MyDestinationBookmarksView(generics.ListAPIView):
    serializer_class = DestinationBookmarkSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return (
            DestinationBookmark.objects
            .filter(user=self.request.user)
            .select_related("destination")
            .order_by("-created_at")
        )


class MyExperienceBookmarksView(generics.ListAPIView):
    serializer_class = ExperienceBookmarkSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return (
            ExperienceBookmark.objects
            .filter(user=self.request.user)
            .select_related("experience")
            .order_by("-created_at")
        )
