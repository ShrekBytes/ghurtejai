from django.db.models.signals import post_save
from django.dispatch import receiver

from .models import RecentSearch


@receiver(post_save, sender=RecentSearch)
def trim_recent_searches(sender, instance, **kwargs):
    """Keep at most 10 recent searches per user."""
    qs = RecentSearch.objects.filter(user=instance.user).order_by("-created_at")
    keep = list(qs[:10].values_list("id", flat=True))
    RecentSearch.objects.filter(user=instance.user).exclude(id__in=keep).delete()
