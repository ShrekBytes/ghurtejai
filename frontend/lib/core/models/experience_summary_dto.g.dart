// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experience_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExperienceSummaryDtoImpl _$$ExperienceSummaryDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$ExperienceSummaryDtoImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String? ?? '',
      destination: (json['destination'] as num?)?.toInt(),
      destinationName: json['destination_name'] as String? ?? '',
      coverImage: json['cover_image'] as String?,
      coverImagePending: json['cover_image_pending'] as bool? ?? false,
      estimatedCost: json['estimated_cost'] as num?,
      userCost: json['user_cost'] as num?,
      status: json['status'] as String,
      visibility: json['visibility'] as String,
      author: (json['author'] as num?)?.toInt(),
      authorUsername: json['author_username'] as String? ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      userVote: (json['user_vote'] as num?)?.toInt() ?? 0,
      commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
      dayCount: (json['day_count'] as num?)?.toInt() ?? 0,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const <String>[],
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$$ExperienceSummaryDtoImplToJson(
        _$ExperienceSummaryDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'slug': instance.slug,
      'description': instance.description,
      'destination': instance.destination,
      'destination_name': instance.destinationName,
      'cover_image': instance.coverImage,
      'cover_image_pending': instance.coverImagePending,
      'estimated_cost': instance.estimatedCost,
      'user_cost': instance.userCost,
      'status': instance.status,
      'visibility': instance.visibility,
      'author': instance.author,
      'author_username': instance.authorUsername,
      'score': instance.score,
      'user_vote': instance.userVote,
      'comment_count': instance.commentCount,
      'day_count': instance.dayCount,
      'tags': instance.tags,
      'created_at': instance.createdAt,
    };
