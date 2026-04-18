# Generated manually for plan alignment

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


def backfill_transport_submitted_by(apps, schema_editor):
    Transport = apps.get_model("destinations", "Transport")
    for t in Transport.objects.filter(submitted_by__isnull=True).select_related(
        "destination"
    ):
        if t.destination_id and t.destination.submitted_by_id:
            t.submitted_by_id = t.destination.submitted_by_id
            t.save(update_fields=["submitted_by_id"])


def noop_reverse(apps, schema_editor):
    pass


class Migration(migrations.Migration):

    dependencies = [
        ("destinations", "0001_initial"),
    ]

    operations = [
        migrations.RenameField(
            model_name="destination",
            old_name="created_by",
            new_name="submitted_by",
        ),
        migrations.RenameField(
            model_name="attraction",
            old_name="created_by",
            new_name="submitted_by",
        ),
        migrations.AddField(
            model_name="attraction",
            name="is_public_submission",
            field=models.BooleanField(default=False),
        ),
        migrations.AddField(
            model_name="attraction",
            name="latitude",
            field=models.DecimalField(
                blank=True, decimal_places=6, max_digits=9, null=True
            ),
        ),
        migrations.AddField(
            model_name="attraction",
            name="longitude",
            field=models.DecimalField(
                blank=True, decimal_places=6, max_digits=9, null=True
            ),
        ),
        migrations.AddField(
            model_name="transport",
            name="submitted_by",
            field=models.ForeignKey(
                blank=True,
                null=True,
                on_delete=django.db.models.deletion.CASCADE,
                related_name="submitted_transports",
                to=settings.AUTH_USER_MODEL,
            ),
        ),
        migrations.RunPython(backfill_transport_submitted_by, noop_reverse),
    ]
