from django.conf import settings
from django.core.exceptions import ValidationError


def validate_image_file(file):
    max_size = settings.MAX_IMAGE_SIZE_MB * 1024 * 1024
    if file.size > max_size:
        raise ValidationError(
            f"Image file too large. Maximum size is {settings.MAX_IMAGE_SIZE_MB}MB."
        )
    if file.content_type not in settings.ALLOWED_IMAGE_TYPES:
        allowed = ", ".join(settings.ALLOWED_IMAGE_TYPES)
        raise ValidationError(
            f"Unsupported image type '{file.content_type}'. Allowed: {allowed}"
        )
