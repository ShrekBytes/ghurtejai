import django_filters

from .models import Attraction, Destination, Transport


class DestinationFilter(django_filters.FilterSet):
    division = django_filters.NumberFilter(field_name="district__division__id")
    district = django_filters.NumberFilter(field_name="district__id")
    tag = django_filters.CharFilter(field_name="tags__slug")
    name = django_filters.CharFilter(lookup_expr="icontains")

    class Meta:
        model = Destination
        fields = ["division", "district", "tag", "name", "status"]


class AttractionFilter(django_filters.FilterSet):
    destination = django_filters.NumberFilter(field_name="destination__id")
    search = django_filters.CharFilter(field_name="name", lookup_expr="icontains")

    class Meta:
        model = Attraction
        fields = ["destination", "type", "status", "search"]


class TransportFilter(django_filters.FilterSet):
    destination = django_filters.NumberFilter(field_name="destination__id")
    from_location = django_filters.CharFilter(lookup_expr="icontains")
    to_location = django_filters.CharFilter(lookup_expr="icontains")

    class Meta:
        model = Transport
        fields = ["destination", "type", "from_location", "to_location"]
