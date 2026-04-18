from django.contrib.auth.models import AbstractUser
from django.db import models

from core.models import TimestampedModel


class User(AbstractUser):
    class Role(models.TextChoices):
        USER = "USER", "User"
        MODERATOR = "MODERATOR", "Moderator"
        ADMIN = "ADMIN", "Admin"

    email = models.EmailField(unique=True)
    role = models.CharField(
        max_length=10,
        choices=Role.choices,
        default=Role.USER,
    )

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = ["username"]

    class Meta:
        db_table = "users"

    def __str__(self):
        return self.username

    @property
    def is_moderator(self):
        return self.role == self.Role.MODERATOR

    @property
    def is_admin_user(self):
        return self.role == self.Role.ADMIN

    @property
    def is_moderator_or_admin(self):
        return self.role in (self.Role.MODERATOR, self.Role.ADMIN)


class UserProfile(TimestampedModel):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="profile")
    bio = models.TextField(blank=True, default="")
    avatar = models.ImageField(upload_to="avatars/", blank=True, null=True)

    class Meta:
        db_table = "user_profiles"

    def __str__(self):
        return f"Profile of {self.user.username}"
