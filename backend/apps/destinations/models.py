from django.conf import settings
from django.db import models
from django.utils.text import slugify

from core.models import SoftDeleteModel, TimestampedModel


class Division(models.Model):
    name = models.CharField(max_length=100, unique=True)
    name_bn = models.CharField(max_length=100, blank=True, default="")

    class Meta:
        db_table = "divisions"
        ordering = ["name"]

    def __str__(self):
        return self.name


class District(models.Model):
    name = models.CharField(max_length=100, unique=True)
    name_bn = models.CharField(max_length=100, blank=True, default="")
    division = models.ForeignKey(
        Division, on_delete=models.CASCADE, related_name="districts"
    )

    class Meta:
        db_table = "districts"
        ordering = ["name"]

    def __str__(self):
        return self.name


class Destination(SoftDeleteModel, TimestampedModel):
    class Status(models.TextChoices):
        PENDING = "PENDING", "Pending"
        APPROVED = "APPROVED", "Approved"
        REJECTED = "REJECTED", "Rejected"

    name = models.CharField(max_length=255, db_index=True)
    slug = models.SlugField(max_length=300, unique=True, blank=True)
    description = models.TextField(blank=True, default="")
    cover_image = models.ImageField(upload_to="destinations/covers/", blank=True, null=True)
    district = models.ForeignKey(
        District, on_delete=models.SET_NULL, null=True, blank=True, related_name="destinations"
    )
    latitude = models.DecimalField(
        max_digits=9, decimal_places=6, null=True, blank=True
    )
    longitude = models.DecimalField(
        max_digits=9, decimal_places=6, null=True, blank=True
    )
    tags = models.ManyToManyField("tags.Tag", blank=True, related_name="destinations")
    status = models.CharField(
        max_length=10, choices=Status.choices, default=Status.PENDING
    )
    rejection_reason = models.TextField(blank=True, null=True)
    submitted_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="submitted_destinations",
    )

    class Meta:
        db_table = "destinations"
        ordering = ["-created_at"]

    def __str__(self):
        return self.name

    def save(self, *args, **kwargs):
        if not self.slug:
            base_slug = slugify(self.name)
            slug = base_slug
            counter = 1
            while Destination.all_objects.filter(slug=slug).exclude(pk=self.pk).exists():
                slug = f"{base_slug}-{counter}"
                counter += 1
            self.slug = slug
        super().save(*args, **kwargs)


class Attraction(SoftDeleteModel, TimestampedModel):
    class Type(models.TextChoices):
        PLACE = "PLACE", "Place"
        FOOD = "FOOD", "Food"
        ACTIVITY = "ACTIVITY", "Activity"

    class Status(models.TextChoices):
        PENDING = "PENDING", "Pending"
        APPROVED = "APPROVED", "Approved"
        REJECTED = "REJECTED", "Rejected"

    destination = models.ForeignKey(
        Destination, on_delete=models.CASCADE, related_name="attractions"
    )
    type = models.CharField(max_length=10, choices=Type.choices)
    name = models.CharField(max_length=255)
    normalized_name = models.CharField(max_length=255, blank=True, db_index=True)
    image = models.ImageField(upload_to="attractions/", blank=True, null=True)
    notes = models.TextField(blank=True, default="")
    address = models.CharField(max_length=500, blank=True, default="")
    price_range = models.CharField(max_length=100, blank=True, default="")
    latitude = models.DecimalField(
        max_digits=9, decimal_places=6, null=True, blank=True
    )
    longitude = models.DecimalField(
        max_digits=9, decimal_places=6, null=True, blank=True
    )
    is_public_submission = models.BooleanField(default=False)
    status = models.CharField(
        max_length=10, choices=Status.choices, default=Status.PENDING
    )
    rejection_reason = models.TextField(blank=True, null=True)
    submitted_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="submitted_attractions",
    )

    class Meta:
        db_table = "attractions"
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.name} ({self.get_type_display()})"

    def save(self, *args, **kwargs):
        self.normalized_name = self.name.lower().strip()
        super().save(*args, **kwargs)


class Transport(SoftDeleteModel, TimestampedModel):
    class Type(models.TextChoices):
        BUS = "BUS", "Bus"
        AC_BUS = "AC_BUS", "AC Bus"
        TRAIN = "TRAIN", "Train"
        FLIGHT = "FLIGHT", "Flight"
        OTHER = "OTHER", "Other"

    class Status(models.TextChoices):
        PENDING = "PENDING", "Pending"
        APPROVED = "APPROVED", "Approved"
        REJECTED = "REJECTED", "Rejected"

    destination = models.ForeignKey(
        Destination, on_delete=models.CASCADE, related_name="transports"
    )
    from_location = models.CharField(max_length=255)
    to_location = models.CharField(max_length=255)
    type = models.CharField(max_length=10, choices=Type.choices)
    operator = models.CharField(max_length=255, blank=True, default="")
    cost = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    duration = models.DurationField(null=True, blank=True)
    departure_time = models.TimeField(null=True, blank=True)
    start_point = models.CharField(max_length=500, blank=True, default="")
    image = models.ImageField(upload_to="transports/", blank=True, null=True)
    status = models.CharField(
        max_length=10, choices=Status.choices, default=Status.PENDING
    )
    rejection_reason = models.TextField(blank=True, null=True)
    submitted_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="submitted_transports",
    )

    class Meta:
        db_table = "transports"
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.from_location} → {self.to_location} ({self.get_type_display()})"
