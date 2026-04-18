from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("interactions", "0003_align_spec_v1"),
    ]

    operations = [
        migrations.AddField(
            model_name="vote",
            name="value",
            field=models.SmallIntegerField(
                choices=[(1, "Upvote"), (-1, "Downvote")],
                default=1,
            ),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name="vote",
            name="updated_at",
            field=models.DateTimeField(auto_now=True),
        ),
    ]
