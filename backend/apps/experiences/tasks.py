import io
import logging

from celery import shared_task
from django.core.files.base import ContentFile

logger = logging.getLogger(__name__)


@shared_task(bind=True, max_retries=3, default_retry_delay=30)
def generate_cover_collage(self, experience_id):
    """Generate a 2x2 collage from the destination's top attraction images."""
    try:
        from PIL import Image

        from apps.destinations.models import Attraction
        from apps.experiences.models import Experience

        experience = Experience.all_objects.get(pk=experience_id)
        if experience.cover_image:
            experience.cover_image_pending = False
            experience.save(update_fields=["cover_image_pending"])
            return

        attractions = (
            Attraction.objects.filter(
                destination=experience.destination,
                status=Attraction.Status.APPROVED,
                image__isnull=False,
            )
            .exclude(image="")
            .order_by("-created_at")[:4]
        )

        images = []
        for attraction in attractions:
            try:
                img = Image.open(attraction.image)
                images.append(img)
            except Exception:
                continue

        if len(images) < 2:
            experience.cover_image_pending = False
            experience.save(update_fields=["cover_image_pending"])
            return

        tile_size = 400
        for i, img in enumerate(images):
            images[i] = img.resize((tile_size, tile_size), Image.LANCZOS)

        while len(images) < 4:
            images.append(images[0].copy())

        collage = Image.new("RGB", (tile_size * 2, tile_size * 2))
        collage.paste(images[0], (0, 0))
        collage.paste(images[1], (tile_size, 0))
        collage.paste(images[2], (0, tile_size))
        collage.paste(images[3], (tile_size, tile_size))

        buffer = io.BytesIO()
        collage.save(buffer, format="JPEG", quality=85)
        buffer.seek(0)

        filename = f"collage_{experience.id}.jpg"
        experience.cover_image.save(
            filename, ContentFile(buffer.read()), save=True
        )
        experience.cover_image_pending = False
        experience.save(update_fields=["cover_image_pending"])
        logger.info("Generated collage for experience %s", experience_id)

    except Exception as exc:
        logger.error("Collage generation failed for %s: %s", experience_id, exc)
        raise self.retry(exc=exc)
