from rest_framework import serializers

from .models import Notification


class NotificationSerializer(serializers.ModelSerializer):
    experience_slug = serializers.SerializerMethodField()
    destination_slug = serializers.SlugField(
        source="destination.slug", read_only=True, allow_null=True
    )
    attraction_destination_slug = serializers.SerializerMethodField()

    class Meta:
        model = Notification
        fields = (
            "id",
            "type",
            "is_read",
            "message",
            "experience",
            "experience_slug",
            "comment",
            "attraction",
            "attraction_destination_slug",
            "destination",
            "destination_slug",
            "created_at",
        )
        read_only_fields = fields

    def get_attraction_destination_slug(self, obj):
        if obj.attraction_id and getattr(obj, "attraction", None):
            return obj.attraction.destination.slug
        return None

    def get_experience_slug(self, obj):
        if obj.experience_id and getattr(obj, "experience", None):
            return obj.experience.slug
        if obj.comment_id and getattr(obj, "comment", None):
            return obj.comment.experience.slug
        return None
