from django.db.models.signals import post_save
from django.dispatch import receiver

from apps.interactions.models import Comment, Vote

from .models import Notification


@receiver(post_save, sender=Vote)
def notify_on_upvote(sender, instance, created, **kwargs):
    if not created or instance.value != 1:
        return
    experience = instance.experience
    if instance.user == experience.author:
        return
    Notification.objects.create(
        recipient=experience.author,
        type=Notification.Type.UPVOTE_EXPERIENCE,
        message=f'{instance.user.username} upvoted your experience "{experience.title}"',
        experience=experience,
    )


@receiver(post_save, sender=Comment)
def notify_on_comment(sender, instance, created, **kwargs):
    if not created:
        return

    experience = instance.experience

    if instance.parent:
        parent_author = instance.parent.author
        if instance.author != parent_author:
            Notification.objects.create(
                recipient=parent_author,
                type=Notification.Type.REPLY_TO_COMMENT,
                message=f"{instance.author.username} replied to your comment",
                experience=experience,
                comment=instance,
            )
    else:
        if instance.author != experience.author:
            Notification.objects.create(
                recipient=experience.author,
                type=Notification.Type.COMMENT_ON_EXPERIENCE,
                message=f'{instance.author.username} commented on "{experience.title}"',
                experience=experience,
                comment=instance,
            )
