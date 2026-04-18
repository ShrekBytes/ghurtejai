from django.db.models import Sum
from rest_framework import serializers

from .models import (
    Comment,
    CommentVote,
    DestinationBookmark,
    ExperienceBookmark,
    Report,
    Vote,
)


class VoteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Vote
        fields = ("id", "experience", "value", "created_at", "updated_at")
        read_only_fields = ("id", "created_at", "updated_at")


class CommentSerializer(serializers.ModelSerializer):
    author_username = serializers.CharField(source="author.username", read_only=True)
    author_avatar = serializers.ImageField(
        source="author.profile.avatar", read_only=True
    )
    score = serializers.IntegerField(read_only=True)
    replies = serializers.SerializerMethodField()
    user_vote = serializers.SerializerMethodField()

    class Meta:
        model = Comment
        fields = (
            "id", "experience", "author", "author_username", "author_avatar",
            "text", "parent", "score", "replies", "user_vote",
            "created_at", "updated_at",
        )
        read_only_fields = ("id", "author", "created_at", "updated_at")

    def get_replies(self, obj):
        if obj.parent is not None:
            return []
        replies = obj.replies.filter(is_deleted=False).select_related("author__profile")
        return CommentSerializer(replies, many=True, context=self.context).data

    def get_user_vote(self, obj):
        request = self.context.get("request")
        if request and request.user.is_authenticated:
            vote = obj.comment_votes.filter(user=request.user).first()
            return vote.value if vote else 0
        return 0


class CommentWriteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Comment
        fields = ("experience", "text", "parent")

    def validate_text(self, value):
        if len(value) > 1000:
            raise serializers.ValidationError("Comment must be at most 1000 characters.")
        return value

    def validate_parent(self, value):
        if value and value.parent is not None:
            raise serializers.ValidationError("Replies to replies are not allowed.")
        return value


class CommentVoteSerializer(serializers.Serializer):
    value = serializers.ChoiceField(choices=[1, -1])


class ReportSerializer(serializers.ModelSerializer):
    class Meta:
        model = Report
        fields = ("id", "comment", "reason", "status", "created_at")
        read_only_fields = ("id", "created_at", "status")


class DestinationBookmarkSerializer(serializers.ModelSerializer):
    destination_name = serializers.CharField(
        source="destination.name", read_only=True
    )
    destination_slug = serializers.CharField(
        source="destination.slug", read_only=True
    )
    destination_cover = serializers.ImageField(
        source="destination.cover_image", read_only=True
    )

    class Meta:
        model = DestinationBookmark
        fields = (
            "id", "destination", "destination_name",
            "destination_slug", "destination_cover", "created_at",
        )
        read_only_fields = ("id", "created_at")


class ExperienceBookmarkSerializer(serializers.ModelSerializer):
    experience_title = serializers.CharField(
        source="experience.title", read_only=True
    )
    experience_slug = serializers.CharField(
        source="experience.slug", read_only=True
    )
    experience_cover = serializers.ImageField(
        source="experience.cover_image", read_only=True
    )

    class Meta:
        model = ExperienceBookmark
        fields = (
            "id", "experience", "experience_title",
            "experience_slug", "experience_cover", "created_at",
        )
        read_only_fields = ("id", "created_at")
