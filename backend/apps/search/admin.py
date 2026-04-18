from django.contrib import admin

from .models import PopularSearch, RecentSearch


@admin.register(RecentSearch)
class RecentSearchAdmin(admin.ModelAdmin):
    list_display = ("user", "query", "created_at")


@admin.register(PopularSearch)
class PopularSearchAdmin(admin.ModelAdmin):
    list_display = ("query", "count")
    ordering = ("-count",)
