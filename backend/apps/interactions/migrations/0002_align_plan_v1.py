# Generated manually for plan alignment

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("interactions", "0001_initial"),
    ]

    operations = [
        migrations.AddField(
            model_name="report",
            name="status",
            field=models.CharField(
                choices=[
                    ("PENDING", "Pending"),
                    ("REVIEWED", "Reviewed"),
                    ("DISMISSED", "Dismissed"),
                ],
                default="PENDING",
                max_length=10,
            ),
        ),
    ]
