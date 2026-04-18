from django.urls import path

from . import views

app_name = "interactions"

urlpatterns = [
    # Votes
    path("vote/<int:experience_id>/", views.ExperienceVoteView.as_view(), name="experience-vote"),
    # Comments
    path("comments/<int:experience_id>/", views.CommentListCreateView.as_view(), name="comment-list"),
    path("comments/<int:pk>/delete/", views.CommentDeleteView.as_view(), name="comment-delete"),
    path("comments/<int:comment_id>/vote/", views.CommentVoteView.as_view(), name="comment-vote"),
    # Reports
    path("reports/", views.ReportCreateView.as_view(), name="report-create"),
    # Bookmarks
    path("bookmarks/destination/<int:destination_id>/", views.DestinationBookmarkToggleView.as_view(), name="bookmark-destination"),
    path("bookmarks/experience/<int:experience_id>/", views.ExperienceBookmarkToggleView.as_view(), name="bookmark-experience"),
    path("bookmarks/destinations/", views.MyDestinationBookmarksView.as_view(), name="my-destination-bookmarks"),
    path("bookmarks/experiences/", views.MyExperienceBookmarksView.as_view(), name="my-experience-bookmarks"),
]
