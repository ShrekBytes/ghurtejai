from django.urls import path

from . import views

app_name = "moderation"

urlpatterns = [
    path("queue/", views.ModerationQueueView.as_view(), name="queue"),
    path("stats/", views.ModerationStatsView.as_view(), name="stats"),
    path("destination/<int:pk>/", views.ModerateDestinationView.as_view(), name="moderate-destination"),
    path("attraction/<int:pk>/", views.ModerateAttractionView.as_view(), name="moderate-attraction"),
    path("transport/<int:pk>/", views.ModerateTransportView.as_view(), name="moderate-transport"),
    path("experience/<int:pk>/", views.ModerateExperienceView.as_view(), name="moderate-experience"),
]
