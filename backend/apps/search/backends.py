from abc import ABC, abstractmethod

from django.contrib.postgres.search import SearchQuery, SearchRank, SearchVector
from django.db.models import Q

from apps.destinations.models import Attraction, Destination
from apps.destinations.serializers import AttractionSearchSerializer, DestinationListSerializer
from apps.experiences.annotations import annotate_experience_list_metrics
from apps.experiences.models import Experience
from apps.experiences.serializers import ExperienceListSerializer


class SearchBackend(ABC):
    """Abstract search backend — swap implementation without changing API contract."""

    @abstractmethod
    def search(self, query, search_type="all", limit=20, request=None):
        pass


class PgSearchBackend(SearchBackend):
    """PostgreSQL full-text search with substring fallback for weak or partial matches."""

    _min_rank = 0.001

    @staticmethod
    def _top_up(base_qs, fts_qs, icontains_q, limit):
        rows = list(fts_qs[:limit])
        if len(rows) >= limit:
            return rows
        ids = {r.pk for r in rows}
        need = limit - len(rows)
        extra_qs = base_qs.filter(icontains_q).exclude(pk__in=ids).distinct()[:need]
        rows.extend(list(extra_qs))
        return rows

    def search(self, query, search_type="all", limit=20, request=None):
        results = {"destinations": [], "experiences": [], "attractions": []}
        exp_ctx = {"request": request} if request is not None else {}
        search_query = SearchQuery(query)

        if search_type in ("all", "destinations"):
            vector = SearchVector("name", weight="A") + SearchVector("description", weight="B")
            base = Destination.objects.filter(status=Destination.Status.APPROVED).select_related(
                "district__division"
            ).prefetch_related("tags")
            fts = (
                base.annotate(rank=SearchRank(vector, search_query))
                .filter(rank__gte=self._min_rank)
                .order_by("-rank")
            )
            icontains = Q(name__icontains=query) | Q(description__icontains=query)
            merged = self._top_up(base, fts, icontains, limit)
            results["destinations"] = DestinationListSerializer(merged, many=True).data

        if search_type in ("all", "experiences"):
            vector = SearchVector("title", weight="A") + SearchVector("description", weight="B")
            base = annotate_experience_list_metrics(
                Experience.objects.filter(status=Experience.Status.PUBLISHED)
                .select_related("author", "destination")
                .prefetch_related("tags", "votes")
            )
            fts = (
                base.annotate(rank=SearchRank(vector, search_query))
                .filter(rank__gte=self._min_rank)
                .order_by("-rank")
            )
            icontains = Q(title__icontains=query) | Q(description__icontains=query)
            merged = self._top_up(base, fts, icontains, limit)
            results["experiences"] = ExperienceListSerializer(
                merged, many=True, context=exp_ctx
            ).data

        if search_type in ("all", "attractions"):
            vector = SearchVector("name", weight="A") + SearchVector("notes", weight="B")
            base = Attraction.objects.filter(status=Attraction.Status.APPROVED).select_related(
                "destination"
            )
            fts = (
                base.annotate(rank=SearchRank(vector, search_query))
                .filter(rank__gte=self._min_rank)
                .order_by("-rank")
            )
            icontains = Q(name__icontains=query) | Q(notes__icontains=query)
            merged = self._top_up(base, fts, icontains, limit)
            results["attractions"] = AttractionSearchSerializer(merged, many=True).data

        return results
