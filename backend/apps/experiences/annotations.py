"""Shared queryset annotations for list/detail API responses."""

from django.db.models import Count, IntegerField, Sum, Value
from django.db.models.functions import Coalesce


def annotate_experience_list_metrics(queryset):
    """Net vote score (can be negative) and comment count."""
    return queryset.annotate(
        score=Coalesce(Sum("votes__value", output_field=IntegerField()), Value(0)),
        comment_count=Count("comments", distinct=True),
    )
