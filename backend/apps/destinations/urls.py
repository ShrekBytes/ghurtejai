from django.urls import path

from . import views

app_name = "destinations"

# IMPORTANT: static paths (attractions, transports, upload) MUST come before
# <slug:slug>/ — otherwise "attractions" is parsed as a destination slug → 404.
urlpatterns = [
    path("divisions/", views.DivisionListView.as_view(), name="division-list"),
    path("districts/", views.DistrictListView.as_view(), name="district-list"),
    path("attractions/", views.AttractionListCreateView.as_view(), name="attraction-list"),
    path("attractions/<int:pk>/", views.AttractionDetailView.as_view(), name="attraction-detail"),
    path("transports/", views.TransportListCreateView.as_view(), name="transport-list"),
    path("transports/<int:pk>/", views.TransportDetailView.as_view(), name="transport-detail"),
    path("upload/image/", views.ImageUploadView.as_view(), name="image-upload"),
    path("", views.DestinationListCreateView.as_view(), name="destination-list"),
    path("<slug:slug>/", views.DestinationDetailView.as_view(), name="destination-detail"),
]
