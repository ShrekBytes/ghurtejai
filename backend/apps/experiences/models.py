from decimal import Decimal

from django.conf import settings
from django.db import models
from django.db.models import Q, Sum
from django.utils import timezone
from django.utils.text import slugify

from core.models import SoftDeleteModel, TimestampedModel


class Experience(SoftDeleteModel, TimestampedModel):
    class Status(models.TextChoices):
        # DB value stays DRAFT; user-facing label is "Private" (not public / in progress).
        DRAFT = "DRAFT", "Private"
        PENDING_REVIEW = "PENDING_REVIEW", "Pending Review"
        PUBLISHED = "PUBLISHED", "Published"
        REJECTED = "REJECTED", "Rejected"

    class Visibility(models.TextChoices):
        PRIVATE = "PRIVATE", "Private"
        PUBLIC = "PUBLIC", "Public"

    title = models.CharField(max_length=255)
    slug = models.SlugField(max_length=300, unique=True, blank=True)
    description = models.TextField(blank=True, default="")
    destination = models.ForeignKey(
        "destinations.Destination",
        on_delete=models.CASCADE,
        related_name="experiences",
    )
    cover_image = models.ImageField(
        upload_to="experiences/covers/", blank=True, null=True
    )
    cover_image_pending = models.BooleanField(default=False)
    estimated_cost = models.DecimalField(
        max_digits=10, decimal_places=2, null=True, blank=True
    )
    user_cost = models.DecimalField(
        max_digits=10, decimal_places=2, null=True, blank=True
    )
    status = models.CharField(
        max_length=20, choices=Status.choices, default=Status.DRAFT
    )
    visibility = models.CharField(
        max_length=10, choices=Visibility.choices, default=Visibility.PRIVATE
    )
    rejection_reason = models.TextField(blank=True, null=True)
    author = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="experiences",
    )
    cloned_from = models.ForeignKey(
        "self", on_delete=models.SET_NULL, null=True, blank=True, related_name="clones"
    )
    tags = models.ManyToManyField("tags.Tag", blank=True, related_name="experiences")

    class Meta:
        db_table = "experiences"
        ordering = ["-created_at"]

    def __str__(self):
        return self.title

    def save(self, *args, **kwargs):
        if not self.slug:
            base_slug = slugify(self.title)
            if not base_slug:
                base_slug = "experience"
            slug = base_slug
            counter = 1
            while Experience.all_objects.filter(slug=slug).exclude(pk=self.pk).exists():
                slug = f"{base_slug}-{counter}"
                counter += 1
            self.slug = slug
        super().save(*args, **kwargs)

    def compute_estimated_cost(self):
        total = Decimal("0")
        has_cost = False
        for day in self.days.filter(is_deleted=False):
            for entry in day.entries.filter(is_deleted=False):
                if entry.cost and entry.cost > 0:
                    total += entry.cost
                    has_cost = True
        self.estimated_cost = total if has_cost else None
        self.save(update_fields=["estimated_cost"])

    def get_upvote_count(self):
        """Net vote score (sum of +1 / −1). Legacy name from upvote-only era."""
        total = self.votes.aggregate(t=Sum("value"))["t"]
        return int(total or 0)

    def get_comment_count(self):
        return self.comments.filter(is_deleted=False).count()

    def delete(self, using=None, keep_parents=False):
        exp_id = self.pk
        day_ids = list(
            Day.all_objects.filter(experience_id=exp_id).values_list("id", flat=True)
        )
        now = timezone.now()
        super().delete(using=using, keep_parents=keep_parents)
        Day.all_objects.filter(id__in=day_ids).update(is_deleted=True, deleted_at=now)
        Entry.all_objects.filter(day_id__in=day_ids).update(is_deleted=True, deleted_at=now)


class Day(SoftDeleteModel):
    experience = models.ForeignKey(
        Experience, on_delete=models.CASCADE, related_name="days"
    )
    date = models.DateField(null=True, blank=True)
    position = models.PositiveIntegerField(default=0)

    class Meta:
        db_table = "experience_days"
        ordering = ["position"]

    def __str__(self):
        return f"Day {self.position + 1} of {self.experience.title}"

    def delete(self, using=None, keep_parents=False):
        day_id = self.pk
        now = timezone.now()
        super().delete(using=using, keep_parents=keep_parents)
        Entry.all_objects.filter(day_id=day_id).update(is_deleted=True, deleted_at=now)


class Entry(SoftDeleteModel):
    day = models.ForeignKey(Day, on_delete=models.CASCADE, related_name="entries")
    name = models.CharField(max_length=255)
    time = models.TimeField(null=True, blank=True)
    cost = models.DecimalField(
        max_digits=10, decimal_places=2, null=True, blank=True
    )
    notes = models.TextField(blank=True, default="")
    image = models.ImageField(upload_to="experience_entries/", blank=True, null=True)
    attraction = models.ForeignKey(
        "destinations.Attraction",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="entries",
    )
    position = models.PositiveIntegerField(default=0)

    class Meta:
        db_table = "experience_entries"
        ordering = ["position"]
        constraints = [
            models.CheckConstraint(
                condition=Q(attraction__isnull=False) | ~Q(name=""),
                name="entry_custom_requires_nonblank_name",
            ),
        ]

    def __str__(self):
        return self.name
