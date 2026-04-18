from rest_framework.permissions import BasePermission


class IsOwner(BasePermission):
    """Object-level permission: only the object's owner can modify it."""

    def has_object_permission(self, request, view, obj):
        owner_field = getattr(view, "owner_field", None)
        if owner_field:
            return getattr(obj, owner_field) == request.user
        for field in ("author", "user", "submitted_by", "reporter"):
            if hasattr(obj, field):
                return getattr(obj, field) == request.user
        return False


class IsModerator(BasePermission):
    def has_permission(self, request, view):
        return (
            request.user.is_authenticated
            and request.user.role == "MODERATOR"
        )


class IsAdmin(BasePermission):
    def has_permission(self, request, view):
        return (
            request.user.is_authenticated
            and request.user.role == "ADMIN"
        )


class IsModeratorOrAdmin(BasePermission):
    def has_permission(self, request, view):
        return (
            request.user.is_authenticated
            and request.user.role in ("MODERATOR", "ADMIN")
        )


class IsAuthenticatedUser(BasePermission):
    """Authenticated user (guests use anonymous Django user, not persisted role)."""

    def has_permission(self, request, view):
        return request.user.is_authenticated
