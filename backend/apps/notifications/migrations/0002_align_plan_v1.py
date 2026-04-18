# Generated manually for plan alignment

import django.db.models.deletion
from django.db import migrations, models


def copy_notification_fks(apps, schema_editor):
    Notification = apps.get_model("notifications", "Notification")
    for n in Notification.objects.all():
        reid = getattr(n, "related_experience_id", None)
        rcid = getattr(n, "related_comment_id", None)
        updates = []
        if reid:
            n.experience_id = reid
            updates.append("experience_id")
        if rcid:
            n.comment_id = rcid
            updates.append("comment_id")
        if updates:
            n.save(update_fields=updates)


def noop_reverse(apps, schema_editor):
    pass


class Migration(migrations.Migration):

    dependencies = [
        ("notifications", "0001_initial"),
        ("experiences", "0001_initial"),
        ("interactions", "0001_initial"),
        ("destinations", "0001_initial"),
    ]

    operations = [
        migrations.AddField(
            model_name="notification",
            name="experience",
            field=models.ForeignKey(
                blank=True,
                null=True,
                on_delete=django.db.models.deletion.CASCADE,
                related_name="+",
                to="experiences.experience",
            ),
        ),
        migrations.AddField(
            model_name="notification",
            name="comment",
            field=models.ForeignKey(
                blank=True,
                null=True,
                on_delete=django.db.models.deletion.CASCADE,
                related_name="+",
                to="interactions.comment",
            ),
        ),
        migrations.AddField(
            model_name="notification",
            name="attraction",
            field=models.ForeignKey(
                blank=True,
                null=True,
                on_delete=django.db.models.deletion.CASCADE,
                related_name="+",
                to="destinations.attraction",
            ),
        ),
        migrations.AddField(
            model_name="notification",
            name="destination",
            field=models.ForeignKey(
                blank=True,
                null=True,
                on_delete=django.db.models.deletion.CASCADE,
                related_name="+",
                to="destinations.destination",
            ),
        ),
        migrations.RunPython(copy_notification_fks, noop_reverse),
        migrations.RemoveField(
            model_name="notification",
            name="related_experience_id",
        ),
        migrations.RemoveField(
            model_name="notification",
            name="related_comment_id",
        ),
        migrations.AlterField(
            model_name="notification",
            name="type",
            field=models.CharField(
                choices=[
                    ("UPVOTE_EXPERIENCE", "Upvote on Experience"),
                    ("COMMENT_ON_EXPERIENCE", "Comment on Experience"),
                    ("REPLY_TO_COMMENT", "Reply to Comment"),
                    ("ATTRACTION_APPROVED", "Attraction Approved"),
                    ("ATTRACTION_REJECTED", "Attraction Rejected"),
                    ("DESTINATION_APPROVED", "Destination Approved"),
                    ("DESTINATION_REJECTED", "Destination Rejected"),
                    ("EXPERIENCE_APPROVED", "Experience Approved"),
                    ("EXPERIENCE_REJECTED", "Experience Rejected"),
                ],
                max_length=30,
            ),
        ),
    ]
