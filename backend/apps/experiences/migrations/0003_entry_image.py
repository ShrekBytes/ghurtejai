from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("experiences", "0002_align_plan_v1"),
    ]

    operations = [
        migrations.AddField(
            model_name="entry",
            name="image",
            field=models.ImageField(
                blank=True,
                null=True,
                upload_to="experience_entries/",
            ),
        ),
    ]
