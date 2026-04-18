"""Custom ordering for experience list: null estimated_cost last when sorting by cost."""

from django.db.models import F
from rest_framework.filters import OrderingFilter


class ExperienceOrderingFilter(OrderingFilter):
    """Apply NULLS LAST for ascending `estimated_cost` (Budget tab)."""

    def filter_queryset(self, request, queryset, view):
        param = request.query_params.get(self.ordering_param, "").strip()
        if param == "estimated_cost":
            return queryset.order_by(F("estimated_cost").asc(nulls_last=True))
        if param == "-estimated_cost":
            return queryset.order_by(F("estimated_cost").desc(nulls_first=True))
        return super().filter_queryset(request, queryset, view)
