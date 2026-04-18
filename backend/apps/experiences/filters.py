import django_filters

from .models import Experience


class ExperienceFilter(django_filters.FilterSet):
    destination = django_filters.NumberFilter(field_name="destination__id")
    destination_slug = django_filters.CharFilter(field_name="destination__slug")
    tag = django_filters.CharFilter(field_name="tags__slug")
    min_cost = django_filters.NumberFilter(field_name="estimated_cost", lookup_expr="gte")
    max_cost = django_filters.NumberFilter(field_name="estimated_cost", lookup_expr="lte")
    author = django_filters.CharFilter(field_name="author__username")

    class Meta:
        model = Experience
        fields = ["destination", "destination_slug", "tag", "author"]
