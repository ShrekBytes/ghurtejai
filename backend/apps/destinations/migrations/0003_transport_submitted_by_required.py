import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


def backfill_transport_submitted_by(apps, schema_editor):
    Transport = apps.get_model("destinations", "Transport")
    User = apps.get_model("accounts", "User")
    fallback_uid = (
        User.objects.filter(is_superuser=True).values_list("pk", flat=True).first()
        or User.objects.order_by("pk").values_list("pk", flat=True).first()
    )
    for t in Transport.objects.filter(submitted_by__isnull=True).select_related("destination"):
        sid = None
        if t.destination_id and getattr(t.destination, "submitted_by_id", None):
            sid = t.destination.submitted_by_id
        elif fallback_uid:
            sid = fallback_uid
        if sid:
            t.submitted_by_id = sid
            t.save(update_fields=["submitted_by_id"])


def noop_reverse(apps, schema_editor):
    pass


class Migration(migrations.Migration):

    dependencies = [
        ("destinations", "0002_align_plan_v1"),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.RunPython(backfill_transport_submitted_by, noop_reverse),
        migrations.AlterField(
            model_name="transport",
            name="submitted_by",
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.CASCADE,
                related_name="submitted_transports",
                to=settings.AUTH_USER_MODEL,
            ),
        ),
    ]
