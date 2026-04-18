from django.contrib import admin

from .models import (
    Comment,
    CommentVote,
    DestinationBookmark,
    ExperienceBookmark,
    Report,
    Vote,
)


@admin.register(Vote)
class VoteAdmin(admin.ModelAdmin):
    list_display = ("user", "experience", "created_at")


@admin.register(Comment)
class CommentAdmin(admin.ModelAdmin):
    list_display = ("author", "experience", "text_preview", "parent", "is_deleted", "created_at")
    list_filter = ("is_deleted",)

    @admin.display(description="Text")
    def text_preview(self, obj):
        return obj.text[:80]


@admin.register(CommentVote)
class CommentVoteAdmin(admin.ModelAdmin):
    list_display = ("user", "comment", "value", "created_at")


@admin.register(Report)
class ReportAdmin(admin.ModelAdmin):
    list_display = ("reporter", "comment", "reason_preview", "created_at")

    @admin.display(description="Reason")
    def reason_preview(self, obj):
        return obj.reason[:80]


@admin.register(DestinationBookmark)
class DestinationBookmarkAdmin(admin.ModelAdmin):
    list_display = ("user", "destination", "created_at")


@admin.register(ExperienceBookmark)
class ExperienceBookmarkAdmin(admin.ModelAdmin):
    list_display = ("user", "experience", "created_at")
