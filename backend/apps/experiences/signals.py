from django.db.models.signals import post_save
from django.dispatch import receiver

from .models import Entry


@receiver(post_save, sender=Entry)
def recompute_experience_cost(sender, instance, **kwargs):
    if instance.day_id:
        instance.day.experience.compute_estimated_cost()
