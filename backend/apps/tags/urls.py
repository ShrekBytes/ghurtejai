from django.urls import path

from . import views

app_name = "tags"

urlpatterns = [
    path("", views.TagListCreateView.as_view(), name="tag-list"),
    path("<slug:slug>/", views.TagDetailView.as_view(), name="tag-detail"),
]
