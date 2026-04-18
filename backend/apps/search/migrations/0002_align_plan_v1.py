# Generated manually for plan alignment

import django.utils.timezone
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("search", "0001_initial"),
    ]

    operations = [
        migrations.AddField(
            model_name="popularsearch",
            name="last_searched_at",
            field=models.DateTimeField(default=django.utils.timezone.now),
        ),
    ]
