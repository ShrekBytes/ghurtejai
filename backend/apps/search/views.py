from django.core.cache import cache
from django.utils import timezone
from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from .backends import PgSearchBackend
from .models import PopularSearch, RecentSearch

search_backend = PgSearchBackend()

POPULAR_CACHE_KEY = "popular_searches_top10"


class SearchView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        query = request.query_params.get("q", "").strip()
        search_type = request.query_params.get("type", "all")

        if not query:
            return Response(
                {"detail": "Query parameter 'q' is required."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if search_type not in ("all", "destinations", "experiences", "attractions"):
            search_type = "all"

        results = search_backend.search(query, search_type=search_type, request=request)

        normalized = query.lower().strip()
        if request.user.is_authenticated:
            RecentSearch.objects.create(user=request.user, query=normalized)

        popular, _ = PopularSearch.objects.get_or_create(query=normalized)
        popular.count += 1
        popular.last_searched_at = timezone.now()
        popular.save(update_fields=["count", "last_searched_at"])
        cache.delete(POPULAR_CACHE_KEY)

        return Response(results)


class SearchSuggestionsView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        data = {}

        if request.user.is_authenticated:
            seen = set()
            recent = []
            for row in RecentSearch.objects.filter(user=request.user).order_by(
                "-created_at"
            ):
                if row.query in seen:
                    continue
                seen.add(row.query)
                recent.append(
                    {
                        "query": row.query,
                        "searched_at": row.created_at.isoformat(),
                    }
                )
                if len(recent) >= 10:
                    break
            data["recent"] = recent
        else:
            data["recent"] = []

        popular = cache.get(POPULAR_CACHE_KEY)
        if popular is None:
            popular = list(
                PopularSearch.objects.order_by("-count").values_list("query", flat=True)[:10]
            )
            cache.set(POPULAR_CACHE_KEY, popular, 300)
        data["popular"] = popular

        return Response(data)
