// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_dto.freezed.dart';
part 'notification_dto.g.dart';

@freezed
class NotificationDto with _$NotificationDto {
  const factory NotificationDto({
    required int id,
    required String type,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
    @Default('') String message,
    int? experience,
    @JsonKey(name: 'experience_slug') String? experienceSlug,
    int? comment,
    int? attraction,
    int? destination,
    @JsonKey(name: 'destination_slug') String? destinationSlug,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _NotificationDto;

  factory NotificationDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationDtoFromJson(json);
}
