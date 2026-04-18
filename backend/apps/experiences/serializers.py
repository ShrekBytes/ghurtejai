import os
from urllib.parse import urlparse

from django.conf import settings
from django.core.files.base import ContentFile
from django.core.files.storage import default_storage
from rest_framework import serializers

from .models import Day, Entry, Experience


def attach_file_from_media_upload_url(instance, field_name: str, url: str) -> None:
    """Copy a file from default_storage (uploads/...) into a model FileField."""
    if not url or not str(url).strip():
        return
    url = str(url).strip()
    if url.startswith("http://") or url.startswith("https://"):
        raw_path = urlparse(url).path.lstrip("/")
    else:
        raw_path = url.lstrip("/")

    media_prefix = settings.MEDIA_URL.strip("/") + "/"
    if raw_path.startswith(media_prefix):
        storage_path = raw_path[len(media_prefix) :]
    elif raw_path.startswith("media/"):
        storage_path = raw_path[6:]
    else:
        storage_path = raw_path

    if not storage_path or not default_storage.exists(storage_path):
        return

    with default_storage.open(storage_path, "rb") as handle:
        raw = handle.read()
    base = os.path.basename(storage_path) or "image.jpg"
    field = getattr(instance, field_name)
    field.save(base, ContentFile(raw), save=True)


class EntrySerializer(serializers.ModelSerializer):
    attraction_name = serializers.CharField(
        source="attraction.name", read_only=True, default=None
    )
    image = serializers.SerializerMethodField()
    image_url = serializers.CharField(
        write_only=True,
        required=False,
        allow_blank=True,
        help_text="URL from POST …/upload/image/ — copied into image",
    )

    class Meta:
        model = Entry
        fields = (
            "id",
            "name",
            "time",
            "cost",
            "notes",
            "image",
            "image_url",
            "attraction",
            "attraction_name",
            "position",
        )
        read_only_fields = ("id", "image")

    def get_image(self, obj):
        if not obj.image:
            return None
        request = self.context.get("request")
        url = obj.image.url
        if request:
            return request.build_absolute_uri(url)
        return url

    def validate(self, attrs):
        attraction = attrs.get("attraction", getattr(self.instance, "attraction", None))
        name = attrs.get("name", getattr(self.instance, "name", "") if self.instance else "")
        if attraction is None and not (name or "").strip():
            raise serializers.ValidationError(
                {"name": "Name is required when no attraction is linked."}
            )
        return attrs


class DaySerializer(serializers.ModelSerializer):
    entries = EntrySerializer(many=True)

    class Meta:
        model = Day
        fields = ("id", "date", "position", "entries")
        read_only_fields = ("id",)


class ExperienceListSerializer(serializers.ModelSerializer):
    author_username = serializers.CharField(source="author.username", read_only=True)
    destination_name = serializers.CharField(source="destination.name", read_only=True)
    score = serializers.IntegerField(read_only=True)
    comment_count = serializers.IntegerField(read_only=True)
    day_count = serializers.SerializerMethodField()
    tags = serializers.StringRelatedField(many=True, read_only=True)
    cover_image = serializers.SerializerMethodField()
    user_vote = serializers.SerializerMethodField()
    is_bookmarked = serializers.SerializerMethodField()

    class Meta:
        model = Experience
        fields = (
            "id",
            "title",
            "slug",
            "description",
            "destination",
            "destination_name",
            "cover_image",
            "cover_image_pending",
            "estimated_cost",
            "user_cost",
            "status",
            "visibility",
            "author",
            "author_username",
            "score",
            "comment_count",
            "day_count",
            "tags",
            "created_at",
            "user_vote",
            "is_bookmarked",
        )

    def get_cover_image(self, obj):
        if not obj.cover_image:
            return None
        request = self.context.get("request")
        url = obj.cover_image.url
        if request:
            return request.build_absolute_uri(url)
        return url

    def get_day_count(self, obj):
        return obj.days.filter(is_deleted=False).count()

    def get_user_vote(self, obj):
        request = self.context.get("request")
        if request and request.user.is_authenticated:
            v = obj.votes.filter(user=request.user).first()
            return v.value if v else 0
        return 0

    def get_is_bookmarked(self, obj):
        request = self.context.get("request")
        if request and request.user.is_authenticated:
            return obj.experience_bookmarks.filter(user=request.user).exists()
        return False


class ExperienceDetailSerializer(serializers.ModelSerializer):
    author_username = serializers.CharField(source="author.username", read_only=True)
    destination_name = serializers.CharField(source="destination.name", read_only=True)
    destination_slug = serializers.CharField(source="destination.slug", read_only=True)
    destination_status = serializers.CharField(
        source="destination.status", read_only=True
    )
    days = DaySerializer(many=True, read_only=True)
    score = serializers.IntegerField(read_only=True)
    comment_count = serializers.IntegerField(read_only=True)
    tags = serializers.StringRelatedField(many=True, read_only=True)
    user_vote = serializers.SerializerMethodField()
    is_bookmarked = serializers.SerializerMethodField()
    cover_image = serializers.SerializerMethodField()

    class Meta:
        model = Experience
        fields = (
            "id",
            "title",
            "slug",
            "description",
            "destination",
            "destination_name",
            "destination_slug",
            "destination_status",
            "cover_image",
            "cover_image_pending",
            "estimated_cost",
            "user_cost",
            "days",
            "status",
            "visibility",
            "rejection_reason",
            "author",
            "author_username",
            "score",
            "comment_count",
            "user_vote",
            "is_bookmarked",
            "tags",
            "created_at",
            "updated_at",
        )

    def get_cover_image(self, obj):
        if not obj.cover_image:
            return None
        request = self.context.get("request")
        url = obj.cover_image.url
        if request:
            return request.build_absolute_uri(url)
        return url

    def get_user_vote(self, obj):
        request = self.context.get("request")
        if request and request.user.is_authenticated:
            v = obj.votes.filter(user=request.user).first()
            return v.value if v else 0
        return 0

    def get_is_bookmarked(self, obj):
        request = self.context.get("request")
        if request and request.user.is_authenticated:
            return obj.experience_bookmarks.filter(user=request.user).exists()
        return False


class ExperienceWriteSerializer(serializers.ModelSerializer):
    days = DaySerializer(many=True)
    tag_ids = serializers.ListField(
        child=serializers.IntegerField(), write_only=True, required=False
    )
    cover_image_url = serializers.CharField(
        write_only=True,
        required=False,
        allow_blank=True,
        help_text="URL from POST /destinations/upload/image/ — copied into cover_image",
    )

    class Meta:
        model = Experience
        fields = (
            "title",
            "description",
            "destination",
            "cover_image",
            "cover_image_url",
            "user_cost",
            "visibility",
            "days",
            "tag_ids",
        )

    @staticmethod
    def _create_entry_for_day(day, entry_data):
        if isinstance(entry_data, dict):
            image_url = entry_data.pop("image_url", None)
        else:
            image_url = None
        entry = Entry.objects.create(day=day, **entry_data)
        if image_url:
            attach_file_from_media_upload_url(entry, "image", image_url)
        return entry

    def create(self, validated_data):
        cover_image_url = validated_data.pop("cover_image_url", None)
        days_data = validated_data.pop("days")
        tag_ids = validated_data.pop("tag_ids", [])
        experience = Experience.objects.create(**validated_data)
        if cover_image_url:
            attach_file_from_media_upload_url(experience, "cover_image", cover_image_url)
        if tag_ids:
            experience.tags.set(tag_ids)
        for day_data in days_data:
            entries_data = day_data.pop("entries", [])
            day = Day.objects.create(experience=experience, **day_data)
            for entry_data in entries_data:
                self._create_entry_for_day(day, entry_data)
        experience.compute_estimated_cost()
        return experience

    def update(self, instance, validated_data):
        cover_image_url = validated_data.pop("cover_image_url", None)
        days_data = validated_data.pop("days", None)
        tag_ids = validated_data.pop("tag_ids", None)

        if instance.status == Experience.Status.PENDING_REVIEW:
            instance.status = Experience.Status.DRAFT

        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()

        if cover_image_url:
            attach_file_from_media_upload_url(instance, "cover_image", cover_image_url)
            instance.cover_image_pending = False
            instance.save(update_fields=["cover_image_pending"])

        if tag_ids is not None:
            instance.tags.set(tag_ids)

        if days_data is not None:
            for day in list(instance.days.all()):
                day.delete()
            for day_data in days_data:
                entries_data = day_data.pop("entries", [])
                day = Day.objects.create(experience=instance, **day_data)
                for entry_data in entries_data:
                    self._create_entry_for_day(day, entry_data)

        if instance.cover_image and instance.cover_image_pending:
            instance.cover_image_pending = False
            instance.save(update_fields=["cover_image_pending"])

        instance.compute_estimated_cost()
        return instance
