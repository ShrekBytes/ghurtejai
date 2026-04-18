# Generated manually for plan alignment

from django.db import migrations, models
from django.db.models import Q


class Migration(migrations.Migration):

    dependencies = [
        ("experiences", "0001_initial"),
    ]

    operations = [
        migrations.AddField(
            model_name="experience",
            name="cover_image_pending",
            field=models.BooleanField(default=False),
        ),
        migrations.AddConstraint(
            model_name="entry",
            constraint=models.CheckConstraint(
                condition=Q(attraction__isnull=False) | ~Q(name=""),
                name="entry_custom_requires_nonblank_name",
            ),
        ),
    ]
