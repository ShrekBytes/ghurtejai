// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'experience_summary_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ExperienceSummaryDto _$ExperienceSummaryDtoFromJson(Map<String, dynamic> json) {
  return _ExperienceSummaryDto.fromJson(json);
}

/// @nodoc
mixin _$ExperienceSummaryDto {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  int? get destination => throw _privateConstructorUsedError;
  @JsonKey(name: 'destination_name')
  String get destinationName => throw _privateConstructorUsedError;
  @JsonKey(name: 'cover_image')
  String? get coverImage => throw _privateConstructorUsedError;
  @JsonKey(name: 'cover_image_pending')
  bool get coverImagePending => throw _privateConstructorUsedError;
  @JsonKey(name: 'estimated_cost')
  num? get estimatedCost => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_cost')
  num? get userCost => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get visibility => throw _privateConstructorUsedError;
  int? get author => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_username')
  String get authorUsername => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_vote')
  int get userVote => throw _privateConstructorUsedError;
  @JsonKey(name: 'comment_count')
  int get commentCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'day_count')
  int get dayCount => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ExperienceSummaryDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExperienceSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExperienceSummaryDtoCopyWith<ExperienceSummaryDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExperienceSummaryDtoCopyWith<$Res> {
  factory $ExperienceSummaryDtoCopyWith(ExperienceSummaryDto value,
          $Res Function(ExperienceSummaryDto) then) =
      _$ExperienceSummaryDtoCopyWithImpl<$Res, ExperienceSummaryDto>;
  @useResult
  $Res call(
      {int id,
      String title,
      String slug,
      String description,
      int? destination,
      @JsonKey(name: 'destination_name') String destinationName,
      @JsonKey(name: 'cover_image') String? coverImage,
      @JsonKey(name: 'cover_image_pending') bool coverImagePending,
      @JsonKey(name: 'estimated_cost') num? estimatedCost,
      @JsonKey(name: 'user_cost') num? userCost,
      String status,
      String visibility,
      int? author,
      @JsonKey(name: 'author_username') String authorUsername,
      int score,
      @JsonKey(name: 'user_vote') int userVote,
      @JsonKey(name: 'comment_count') int commentCount,
      @JsonKey(name: 'day_count') int dayCount,
      List<String> tags,
      @JsonKey(name: 'created_at') String? createdAt});
}

/// @nodoc
class _$ExperienceSummaryDtoCopyWithImpl<$Res,
        $Val extends ExperienceSummaryDto>
    implements $ExperienceSummaryDtoCopyWith<$Res> {
  _$ExperienceSummaryDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExperienceSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? slug = null,
    Object? description = null,
    Object? destination = freezed,
    Object? destinationName = null,
    Object? coverImage = freezed,
    Object? coverImagePending = null,
    Object? estimatedCost = freezed,
    Object? userCost = freezed,
    Object? status = null,
    Object? visibility = null,
    Object? author = freezed,
    Object? authorUsername = null,
    Object? score = null,
    Object? userVote = null,
    Object? commentCount = null,
    Object? dayCount = null,
    Object? tags = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      destination: freezed == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as int?,
      destinationName: null == destinationName
          ? _value.destinationName
          : destinationName // ignore: cast_nullable_to_non_nullable
              as String,
      coverImage: freezed == coverImage
          ? _value.coverImage
          : coverImage // ignore: cast_nullable_to_non_nullable
              as String?,
      coverImagePending: null == coverImagePending
          ? _value.coverImagePending
          : coverImagePending // ignore: cast_nullable_to_non_nullable
              as bool,
      estimatedCost: freezed == estimatedCost
          ? _value.estimatedCost
          : estimatedCost // ignore: cast_nullable_to_non_nullable
              as num?,
      userCost: freezed == userCost
          ? _value.userCost
          : userCost // ignore: cast_nullable_to_non_nullable
              as num?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      visibility: null == visibility
          ? _value.visibility
          : visibility // ignore: cast_nullable_to_non_nullable
              as String,
      author: freezed == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as int?,
      authorUsername: null == authorUsername
          ? _value.authorUsername
          : authorUsername // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      userVote: null == userVote
          ? _value.userVote
          : userVote // ignore: cast_nullable_to_non_nullable
              as int,
      commentCount: null == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      dayCount: null == dayCount
          ? _value.dayCount
          : dayCount // ignore: cast_nullable_to_non_nullable
              as int,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExperienceSummaryDtoImplCopyWith<$Res>
    implements $ExperienceSummaryDtoCopyWith<$Res> {
  factory _$$ExperienceSummaryDtoImplCopyWith(_$ExperienceSummaryDtoImpl value,
          $Res Function(_$ExperienceSummaryDtoImpl) then) =
      __$$ExperienceSummaryDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String title,
      String slug,
      String description,
      int? destination,
      @JsonKey(name: 'destination_name') String destinationName,
      @JsonKey(name: 'cover_image') String? coverImage,
      @JsonKey(name: 'cover_image_pending') bool coverImagePending,
      @JsonKey(name: 'estimated_cost') num? estimatedCost,
      @JsonKey(name: 'user_cost') num? userCost,
      String status,
      String visibility,
      int? author,
      @JsonKey(name: 'author_username') String authorUsername,
      int score,
      @JsonKey(name: 'user_vote') int userVote,
      @JsonKey(name: 'comment_count') int commentCount,
      @JsonKey(name: 'day_count') int dayCount,
      List<String> tags,
      @JsonKey(name: 'created_at') String? createdAt});
}

/// @nodoc
class __$$ExperienceSummaryDtoImplCopyWithImpl<$Res>
    extends _$ExperienceSummaryDtoCopyWithImpl<$Res, _$ExperienceSummaryDtoImpl>
    implements _$$ExperienceSummaryDtoImplCopyWith<$Res> {
  __$$ExperienceSummaryDtoImplCopyWithImpl(_$ExperienceSummaryDtoImpl _value,
      $Res Function(_$ExperienceSummaryDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ExperienceSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? slug = null,
    Object? description = null,
    Object? destination = freezed,
    Object? destinationName = null,
    Object? coverImage = freezed,
    Object? coverImagePending = null,
    Object? estimatedCost = freezed,
    Object? userCost = freezed,
    Object? status = null,
    Object? visibility = null,
    Object? author = freezed,
    Object? authorUsername = null,
    Object? score = null,
    Object? userVote = null,
    Object? commentCount = null,
    Object? dayCount = null,
    Object? tags = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$ExperienceSummaryDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      destination: freezed == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as int?,
      destinationName: null == destinationName
          ? _value.destinationName
          : destinationName // ignore: cast_nullable_to_non_nullable
              as String,
      coverImage: freezed == coverImage
          ? _value.coverImage
          : coverImage // ignore: cast_nullable_to_non_nullable
              as String?,
      coverImagePending: null == coverImagePending
          ? _value.coverImagePending
          : coverImagePending // ignore: cast_nullable_to_non_nullable
              as bool,
      estimatedCost: freezed == estimatedCost
          ? _value.estimatedCost
          : estimatedCost // ignore: cast_nullable_to_non_nullable
              as num?,
      userCost: freezed == userCost
          ? _value.userCost
          : userCost // ignore: cast_nullable_to_non_nullable
              as num?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      visibility: null == visibility
          ? _value.visibility
          : visibility // ignore: cast_nullable_to_non_nullable
              as String,
      author: freezed == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as int?,
      authorUsername: null == authorUsername
          ? _value.authorUsername
          : authorUsername // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      userVote: null == userVote
          ? _value.userVote
          : userVote // ignore: cast_nullable_to_non_nullable
              as int,
      commentCount: null == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      dayCount: null == dayCount
          ? _value.dayCount
          : dayCount // ignore: cast_nullable_to_non_nullable
              as int,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExperienceSummaryDtoImpl implements _ExperienceSummaryDto {
  const _$ExperienceSummaryDtoImpl(
      {required this.id,
      required this.title,
      required this.slug,
      this.description = '',
      this.destination,
      @JsonKey(name: 'destination_name') this.destinationName = '',
      @JsonKey(name: 'cover_image') this.coverImage,
      @JsonKey(name: 'cover_image_pending') this.coverImagePending = false,
      @JsonKey(name: 'estimated_cost') this.estimatedCost,
      @JsonKey(name: 'user_cost') this.userCost,
      required this.status,
      required this.visibility,
      this.author,
      @JsonKey(name: 'author_username') this.authorUsername = '',
      this.score = 0,
      @JsonKey(name: 'user_vote') this.userVote = 0,
      @JsonKey(name: 'comment_count') this.commentCount = 0,
      @JsonKey(name: 'day_count') this.dayCount = 0,
      final List<String> tags = const <String>[],
      @JsonKey(name: 'created_at') this.createdAt})
      : _tags = tags;

  factory _$ExperienceSummaryDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExperienceSummaryDtoImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String slug;
  @override
  @JsonKey()
  final String description;
  @override
  final int? destination;
  @override
  @JsonKey(name: 'destination_name')
  final String destinationName;
  @override
  @JsonKey(name: 'cover_image')
  final String? coverImage;
  @override
  @JsonKey(name: 'cover_image_pending')
  final bool coverImagePending;
  @override
  @JsonKey(name: 'estimated_cost')
  final num? estimatedCost;
  @override
  @JsonKey(name: 'user_cost')
  final num? userCost;
  @override
  final String status;
  @override
  final String visibility;
  @override
  final int? author;
  @override
  @JsonKey(name: 'author_username')
  final String authorUsername;
  @override
  @JsonKey()
  final int score;
  @override
  @JsonKey(name: 'user_vote')
  final int userVote;
  @override
  @JsonKey(name: 'comment_count')
  final int commentCount;
  @override
  @JsonKey(name: 'day_count')
  final int dayCount;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;

  @override
  String toString() {
    return 'ExperienceSummaryDto(id: $id, title: $title, slug: $slug, description: $description, destination: $destination, destinationName: $destinationName, coverImage: $coverImage, coverImagePending: $coverImagePending, estimatedCost: $estimatedCost, userCost: $userCost, status: $status, visibility: $visibility, author: $author, authorUsername: $authorUsername, score: $score, userVote: $userVote, commentCount: $commentCount, dayCount: $dayCount, tags: $tags, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExperienceSummaryDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.destinationName, destinationName) ||
                other.destinationName == destinationName) &&
            (identical(other.coverImage, coverImage) ||
                other.coverImage == coverImage) &&
            (identical(other.coverImagePending, coverImagePending) ||
                other.coverImagePending == coverImagePending) &&
            (identical(other.estimatedCost, estimatedCost) ||
                other.estimatedCost == estimatedCost) &&
            (identical(other.userCost, userCost) ||
                other.userCost == userCost) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.visibility, visibility) ||
                other.visibility == visibility) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.authorUsername, authorUsername) ||
                other.authorUsername == authorUsername) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.userVote, userVote) ||
                other.userVote == userVote) &&
            (identical(other.commentCount, commentCount) ||
                other.commentCount == commentCount) &&
            (identical(other.dayCount, dayCount) ||
                other.dayCount == dayCount) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        title,
        slug,
        description,
        destination,
        destinationName,
        coverImage,
        coverImagePending,
        estimatedCost,
        userCost,
        status,
        visibility,
        author,
        authorUsername,
        score,
        userVote,
        commentCount,
        dayCount,
        const DeepCollectionEquality().hash(_tags),
        createdAt
      ]);

  /// Create a copy of ExperienceSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExperienceSummaryDtoImplCopyWith<_$ExperienceSummaryDtoImpl>
      get copyWith =>
          __$$ExperienceSummaryDtoImplCopyWithImpl<_$ExperienceSummaryDtoImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExperienceSummaryDtoImplToJson(
      this,
    );
  }
}

abstract class _ExperienceSummaryDto implements ExperienceSummaryDto {
  const factory _ExperienceSummaryDto(
          {required final int id,
          required final String title,
          required final String slug,
          final String description,
          final int? destination,
          @JsonKey(name: 'destination_name') final String destinationName,
          @JsonKey(name: 'cover_image') final String? coverImage,
          @JsonKey(name: 'cover_image_pending') final bool coverImagePending,
          @JsonKey(name: 'estimated_cost') final num? estimatedCost,
          @JsonKey(name: 'user_cost') final num? userCost,
          required final String status,
          required final String visibility,
          final int? author,
          @JsonKey(name: 'author_username') final String authorUsername,
          final int score,
          @JsonKey(name: 'user_vote') final int userVote,
          @JsonKey(name: 'comment_count') final int commentCount,
          @JsonKey(name: 'day_count') final int dayCount,
          final List<String> tags,
          @JsonKey(name: 'created_at') final String? createdAt}) =
      _$ExperienceSummaryDtoImpl;

  factory _ExperienceSummaryDto.fromJson(Map<String, dynamic> json) =
      _$ExperienceSummaryDtoImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String get slug;
  @override
  String get description;
  @override
  int? get destination;
  @override
  @JsonKey(name: 'destination_name')
  String get destinationName;
  @override
  @JsonKey(name: 'cover_image')
  String? get coverImage;
  @override
  @JsonKey(name: 'cover_image_pending')
  bool get coverImagePending;
  @override
  @JsonKey(name: 'estimated_cost')
  num? get estimatedCost;
  @override
  @JsonKey(name: 'user_cost')
  num? get userCost;
  @override
  String get status;
  @override
  String get visibility;
  @override
  int? get author;
  @override
  @JsonKey(name: 'author_username')
  String get authorUsername;
  @override
  int get score;
  @override
  @JsonKey(name: 'user_vote')
  int get userVote;
  @override
  @JsonKey(name: 'comment_count')
  int get commentCount;
  @override
  @JsonKey(name: 'day_count')
  int get dayCount;
  @override
  List<String> get tags;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;

  /// Create a copy of ExperienceSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExperienceSummaryDtoImplCopyWith<_$ExperienceSummaryDtoImpl>
      get copyWith => throw _privateConstructorUsedError;
}
