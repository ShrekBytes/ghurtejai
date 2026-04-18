from rest_framework import serializers

from apps.experiences.serializers import attach_file_from_media_upload_url

from .models import Attraction, Destination, District, Division, Transport


class DivisionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Division
        fields = ("id", "name", "name_bn")


class DistrictSerializer(serializers.ModelSerializer):
    division = DivisionSerializer(read_only=True)

    class Meta:
        model = District
        fields = ("id", "name", "name_bn", "division")


class DistrictWriteSerializer(serializers.ModelSerializer):
    class Meta:
        model = District
        fields = ("id",)


class AttractionSearchSerializer(serializers.ModelSerializer):
    destination_name = serializers.CharField(source="destination.name", read_only=True)
    destination_slug = serializers.SlugField(source="destination.slug", read_only=True)

    class Meta:
        model = Attraction
        fields = (
            "id",
            "name",
            "type",
            "destination",
            "destination_name",
            "destination_slug",
        )


class AttractionSerializer(serializers.ModelSerializer):
    submitted_by_username = serializers.CharField(
        source="submitted_by.username", read_only=True
    )
    image = serializers.SerializerMethodField()
    image_url = serializers.CharField(
        write_only=True,
        required=False,
        allow_blank=True,
        help_text="URL from image upload endpoint — copied into image",
    )

    class Meta:
        model = Attraction
        fields = (
            "id",
            "destination",
            "type",
            "name",
            "normalized_name",
            "image",
            "image_url",
            "notes",
            "address",
            "price_range",
            "latitude",
            "longitude",
            "is_public_submission",
            "status",
            "rejection_reason",
            "submitted_by",
            "submitted_by_username",
            "created_at",
            "updated_at",
        )
        read_only_fields = (
            "id",
            "normalized_name",
            "image",
            "status",
            "rejection_reason",
            "submitted_by",
            "created_at",
            "updated_at",
        )

    def get_image(self, obj):
        if not obj.image:
            return None
        request = self.context.get("request")
        url = obj.image.url
        if request:
            return request.build_absolute_uri(url)
        return url

    def create(self, validated_data):
        image_url = validated_data.pop("image_url", None)
        attraction = Attraction.objects.create(**validated_data)
        if image_url:
            attach_file_from_media_upload_url(attraction, "image", image_url)
        return attraction

    def update(self, instance, validated_data):
        image_url = validated_data.pop("image_url", None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        if image_url:
            attach_file_from_media_upload_url(instance, "image", image_url)
        return instance


class TransportSerializer(serializers.ModelSerializer):
    image = serializers.SerializerMethodField()
    image_url = serializers.CharField(
        write_only=True,
        required=False,
        allow_blank=True,
        help_text="URL from image upload endpoint — copied into image",
    )

    class Meta:
        model = Transport
        fields = (
            "id",
            "destination",
            "from_location",
            "to_location",
            "type",
            "operator",
            "cost",
            "duration",
            "departure_time",
            "start_point",
            "image",
            "image_url",
            "status",
            "rejection_reason",
            "submitted_by",
            "created_at",
            "updated_at",
        )
        read_only_fields = (
            "id",
            "image",
            "status",
            "rejection_reason",
            "submitted_by",
            "created_at",
            "updated_at",
        )

    def get_image(self, obj):
        if not obj.image:
            return None
        request = self.context.get("request")
        url = obj.image.url
        if request:
            return request.build_absolute_uri(url)
        return url

    def create(self, validated_data):
        image_url = validated_data.pop("image_url", None)
        transport = Transport.objects.create(**validated_data)
        if image_url:
            attach_file_from_media_upload_url(transport, "image", image_url)
        return transport

    def update(self, instance, validated_data):
        image_url = validated_data.pop("image_url", None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        if image_url:
            attach_file_from_media_upload_url(instance, "image", image_url)
        return instance


class DestinationListSerializer(serializers.ModelSerializer):
    district_name = serializers.CharField(source="district.name", read_only=True, default=None)
    division_name = serializers.CharField(
        source="district.division.name", read_only=True, default=None
    )
    attraction_count = serializers.SerializerMethodField()
    experience_count = serializers.SerializerMethodField()
    tags = serializers.StringRelatedField(many=True, read_only=True)

    class Meta:
        model = Destination
        fields = (
            "id", "name", "slug", "description", "cover_image",
            "district_name", "division_name",
            "attraction_count", "experience_count",
            "tags",
            "status", "created_at",
        )

    def get_attraction_count(self, obj):
        return getattr(obj, "_attraction_count", obj.attractions.filter(status="APPROVED").count())

    def get_experience_count(self, obj):
        return getattr(obj, "_experience_count", obj.experiences.filter(status="PUBLISHED").count())


class DestinationDetailSerializer(serializers.ModelSerializer):
    district = DistrictSerializer(read_only=True)
    attractions = AttractionSerializer(many=True, read_only=True, source="approved_attractions")
    transports = TransportSerializer(many=True, read_only=True, source="approved_transports")
    submitted_by_username = serializers.CharField(
        source="submitted_by.username", read_only=True
    )
    tags = serializers.StringRelatedField(many=True, read_only=True)

    class Meta:
        model = Destination
        fields = (
            "id",
            "name",
            "slug",
            "description",
            "cover_image",
            "district",
            "latitude",
            "longitude",
            "tags",
            "attractions",
            "transports",
            "status",
            "rejection_reason",
            "submitted_by",
            "submitted_by_username",
            "created_at",
            "updated_at",
        )
        read_only_fields = (
            "id",
            "slug",
            "status",
            "rejection_reason",
            "submitted_by",
            "created_at",
            "updated_at",
        )


class DestinationWriteSerializer(serializers.ModelSerializer):
    tag_ids = serializers.ListField(
        child=serializers.IntegerField(), write_only=True, required=False
    )
    cover_image_url = serializers.CharField(
        write_only=True,
        required=False,
        allow_blank=True,
        help_text="URL from image upload endpoint — copied into cover_image",
    )

    class Meta:
        model = Destination
        fields = (
            "name",
            "description",
            "cover_image",
            "cover_image_url",
            "district",
            "latitude",
            "longitude",
            "tag_ids",
        )

    def create(self, validated_data):
        cover_image_url = validated_data.pop("cover_image_url", None)
        tag_ids = validated_data.pop("tag_ids", [])
        destination = Destination.objects.create(**validated_data)
        if cover_image_url:
            attach_file_from_media_upload_url(
                destination, "cover_image", cover_image_url
            )
        if tag_ids:
            destination.tags.set(tag_ids)
        return destination

    def update(self, instance, validated_data):
        cover_image_url = validated_data.pop("cover_image_url", None)
        tag_ids = validated_data.pop("tag_ids", None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        if cover_image_url:
            attach_file_from_media_upload_url(
                instance, "cover_image", cover_image_url
            )
        if tag_ids is not None:
            instance.tags.set(tag_ids)
        return instance
