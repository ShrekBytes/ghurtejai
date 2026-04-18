from django.conf import settings
from django.db import models
from django.utils import timezone


class RecentSearch(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="recent_searches",
    )
    query = models.CharField(max_length=255)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "recent_searches"
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.user}: {self.query}"


class PopularSearch(models.Model):
    query = models.CharField(max_length=255, unique=True)
    count = models.PositiveIntegerField(default=0)
    last_searched_at = models.DateTimeField(default=timezone.now)

    class Meta:
        db_table = "popular_searches"
        ordering = ["-count"]

    def __str__(self):
        return f"{self.query} ({self.count})"
