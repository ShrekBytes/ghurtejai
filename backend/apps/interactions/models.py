from django.conf import settings
from django.db import models

from core.models import SoftDeleteModel, TimestampedModel


class Vote(models.Model):
    """Experience vote: +1 (up) or -1 (down), one row per user per experience."""

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="votes"
    )
    experience = models.ForeignKey(
        "experiences.Experience", on_delete=models.CASCADE, related_name="votes"
    )
    value = models.SmallIntegerField(choices=[(1, "Upvote"), (-1, "Downvote")])
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "votes"
        unique_together = ("user", "experience")

    def __str__(self):
        return f"{self.user} voted {self.value:+d} on {self.experience}"


class Comment(SoftDeleteModel, TimestampedModel):
    experience = models.ForeignKey(
        "experiences.Experience", on_delete=models.CASCADE, related_name="comments"
    )
    author = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="comments"
    )
    text = models.CharField(max_length=1000)
    parent = models.ForeignKey(
        "self", on_delete=models.CASCADE, null=True, blank=True, related_name="replies"
    )

    class Meta:
        db_table = "comments"
        ordering = ["-created_at"]

    def __str__(self):
        return f"Comment by {self.author} on {self.experience}"

    def delete(self, **kwargs):
        super().delete(**kwargs)
        Comment.all_objects.filter(parent_id=self.pk).update(
            is_deleted=True,
            deleted_at=self.deleted_at,
        )

    @property
    def score(self):
        up = self.comment_votes.filter(value=1).count()
        down = self.comment_votes.filter(value=-1).count()
        return up - down


class CommentVote(models.Model):
    """Reddit-style comment voting: +1 or -1."""
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="comment_votes"
    )
    comment = models.ForeignKey(
        Comment, on_delete=models.CASCADE, related_name="comment_votes"
    )
    value = models.SmallIntegerField(choices=[(1, "Upvote"), (-1, "Downvote")])
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "comment_votes"
        unique_together = ("user", "comment")


class Report(models.Model):
    class Status(models.TextChoices):
        PENDING = "PENDING", "Pending"
        REVIEWED = "REVIEWED", "Reviewed"
        DISMISSED = "DISMISSED", "Dismissed"

    comment = models.ForeignKey(
        Comment, on_delete=models.CASCADE, related_name="reports"
    )
    reporter = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="reports"
    )
    reason = models.TextField()
    status = models.CharField(
        max_length=10,
        choices=Status.choices,
        default=Status.PENDING,
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "reports"
        unique_together = ("comment", "reporter")

    def __str__(self):
        return f"Report on comment {self.comment_id} by {self.reporter}"


class DestinationBookmark(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE,
        related_name="destination_bookmarks",
    )
    destination = models.ForeignKey(
        "destinations.Destination", on_delete=models.CASCADE,
        related_name="bookmarks",
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "bookmark_destinations"
        unique_together = ("user", "destination")


class ExperienceBookmark(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE,
        related_name="experience_bookmarks",
    )
    experience = models.ForeignKey(
        "experiences.Experience", on_delete=models.CASCADE,
        related_name="experience_bookmarks",
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "bookmark_experiences"
        unique_together = ("user", "experience")
