from django.urls import path

from . import views

app_name = "experiences"

urlpatterns = [
    path("", views.ExperienceListCreateView.as_view(), name="experience-list"),
    path("mine/", views.MyExperiencesView.as_view(), name="my-experiences"),
    path("<slug:slug>/", views.ExperienceDetailView.as_view(), name="experience-detail"),
    path("<slug:slug>/clone/", views.ExperienceCloneView.as_view(), name="experience-clone"),
]
