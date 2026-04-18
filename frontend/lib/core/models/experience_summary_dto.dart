// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'experience_summary_dto.freezed.dart';
part 'experience_summary_dto.g.dart';

/// List card / feed row for experiences (API list serializer shape).
@freezed
class ExperienceSummaryDto with _$ExperienceSummaryDto {
  const factory ExperienceSummaryDto({
    required int id,
    required String title,
    required String slug,
    @Default('') String description,
    int? destination,
    @JsonKey(name: 'destination_name') @Default('') String destinationName,
    @JsonKey(name: 'cover_image') String? coverImage,
    @JsonKey(name: 'cover_image_pending') @Default(false) bool coverImagePending,
    @JsonKey(name: 'estimated_cost') num? estimatedCost,
    @JsonKey(name: 'user_cost') num? userCost,
    required String status,
    required String visibility,
    int? author,
    @JsonKey(name: 'author_username') @Default('') String authorUsername,
    @Default(0) int score,
    @JsonKey(name: 'user_vote') @Default(0) int userVote,
    @JsonKey(name: 'comment_count') @Default(0) int commentCount,
    @JsonKey(name: 'day_count') @Default(0) int dayCount,
    @Default(<String>[]) List<String> tags,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _ExperienceSummaryDto;

  factory ExperienceSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$ExperienceSummaryDtoFromJson(json);
}
