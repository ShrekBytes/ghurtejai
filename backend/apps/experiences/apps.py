from django.apps import AppConfig


class ExperiencesConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "apps.experiences"
    verbose_name = "Experiences"

    def ready(self):
        from . import signals  # noqa: F401

