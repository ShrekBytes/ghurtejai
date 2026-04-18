from django.contrib import admin

from .models import Day, Entry, Experience


class DayInline(admin.TabularInline):
    model = Day
    extra = 0
    show_change_link = True


class EntryInline(admin.TabularInline):
    model = Entry
    extra = 0


@admin.register(Experience)
class ExperienceAdmin(admin.ModelAdmin):
    list_display = ("title", "slug", "destination", "author", "status", "visibility", "created_at")
    list_filter = ("status", "visibility")
    search_fields = ("title", "slug")
    inlines = [DayInline]


@admin.register(Day)
class DayAdmin(admin.ModelAdmin):
    list_display = ("experience", "position", "date")
    inlines = [EntryInline]
