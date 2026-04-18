from django.conf import settings
from django.db import models


class Notification(models.Model):
    class Type(models.TextChoices):
        UPVOTE_EXPERIENCE = "UPVOTE_EXPERIENCE", "Upvote on Experience"
        COMMENT_ON_EXPERIENCE = "COMMENT_ON_EXPERIENCE", "Comment on Experience"
        REPLY_TO_COMMENT = "REPLY_TO_COMMENT", "Reply to Comment"
        ATTRACTION_APPROVED = "ATTRACTION_APPROVED", "Attraction Approved"
        ATTRACTION_REJECTED = "ATTRACTION_REJECTED", "Attraction Rejected"
        DESTINATION_APPROVED = "DESTINATION_APPROVED", "Destination Approved"
        DESTINATION_REJECTED = "DESTINATION_REJECTED", "Destination Rejected"
        EXPERIENCE_APPROVED = "EXPERIENCE_APPROVED", "Experience Approved"
        EXPERIENCE_REJECTED = "EXPERIENCE_REJECTED", "Experience Rejected"

    recipient = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="notifications",
    )
    type = models.CharField(max_length=30, choices=Type.choices)
    is_read = models.BooleanField(default=False)
    message = models.TextField(blank=True, default="")
    experience = models.ForeignKey(
        "experiences.Experience",
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name="notifications",
    )
    comment = models.ForeignKey(
        "interactions.Comment",
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name="notifications",
    )
    attraction = models.ForeignKey(
        "destinations.Attraction",
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name="notifications",
    )
    destination = models.ForeignKey(
        "destinations.Destination",
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name="notifications",
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "notifications"
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.get_type_display()} → {self.recipient}"
