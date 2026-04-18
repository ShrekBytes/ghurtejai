// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationDtoImpl _$$NotificationDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationDtoImpl(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String,
      isRead: json['is_read'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      experience: (json['experience'] as num?)?.toInt(),
      experienceSlug: json['experience_slug'] as String?,
      comment: (json['comment'] as num?)?.toInt(),
      attraction: (json['attraction'] as num?)?.toInt(),
      destination: (json['destination'] as num?)?.toInt(),
      destinationSlug: json['destination_slug'] as String?,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$$NotificationDtoImplToJson(
        _$NotificationDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'is_read': instance.isRead,
      'message': instance.message,
      'experience': instance.experience,
      'experience_slug': instance.experienceSlug,
      'comment': instance.comment,
      'attraction': instance.attraction,
      'destination': instance.destination,
      'destination_slug': instance.destinationSlug,
      'created_at': instance.createdAt,
    };
