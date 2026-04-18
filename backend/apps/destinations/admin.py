from django.contrib import admin

from .models import Attraction, Destination, District, Division, Transport


@admin.register(Division)
class DivisionAdmin(admin.ModelAdmin):
    list_display = ("name", "name_bn")


@admin.register(District)
class DistrictAdmin(admin.ModelAdmin):
    list_display = ("name", "name_bn", "division")
    list_filter = ("division",)


@admin.register(Destination)
class DestinationAdmin(admin.ModelAdmin):
    list_display = ("name", "slug", "district", "status", "submitted_by", "created_at")
    list_filter = ("status", "district__division")
    search_fields = ("name", "slug")
    prepopulated_fields = {"slug": ("name",)}


@admin.register(Attraction)
class AttractionAdmin(admin.ModelAdmin):
    list_display = ("name", "type", "destination", "status", "submitted_by")
    list_filter = ("type", "status")
    search_fields = ("name", "normalized_name")


@admin.register(Transport)
class TransportAdmin(admin.ModelAdmin):
    list_display = ("from_location", "to_location", "type", "operator", "status", "submitted_by", "image")
    list_filter = ("type", "status")
