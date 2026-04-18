// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NotificationDto _$NotificationDtoFromJson(Map<String, dynamic> json) {
  return _NotificationDto.fromJson(json);
}

/// @nodoc
mixin _$NotificationDto {
  int get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_read')
  bool get isRead => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  int? get experience => throw _privateConstructorUsedError;
  @JsonKey(name: 'experience_slug')
  String? get experienceSlug => throw _privateConstructorUsedError;
  int? get comment => throw _privateConstructorUsedError;
  int? get attraction => throw _privateConstructorUsedError;
  int? get destination => throw _privateConstructorUsedError;
  @JsonKey(name: 'destination_slug')
  String? get destinationSlug => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;

  /// Serializes this NotificationDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationDtoCopyWith<NotificationDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationDtoCopyWith<$Res> {
  factory $NotificationDtoCopyWith(
          NotificationDto value, $Res Function(NotificationDto) then) =
      _$NotificationDtoCopyWithImpl<$Res, NotificationDto>;
  @useResult
  $Res call(
      {int id,
      String type,
      @JsonKey(name: 'is_read') bool isRead,
      String message,
      int? experience,
      @JsonKey(name: 'experience_slug') String? experienceSlug,
      int? comment,
      int? attraction,
      int? destination,
      @JsonKey(name: 'destination_slug') String? destinationSlug,
      @JsonKey(name: 'created_at') String createdAt});
}

/// @nodoc
class _$NotificationDtoCopyWithImpl<$Res, $Val extends NotificationDto>
    implements $NotificationDtoCopyWith<$Res> {
  _$NotificationDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? isRead = null,
    Object? message = null,
    Object? experience = freezed,
    Object? experienceSlug = freezed,
    Object? comment = freezed,
    Object? attraction = freezed,
    Object? destination = freezed,
    Object? destinationSlug = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      experience: freezed == experience
          ? _value.experience
          : experience // ignore: cast_nullable_to_non_nullable
              as int?,
      experienceSlug: freezed == experienceSlug
          ? _value.experienceSlug
          : experienceSlug // ignore: cast_nullable_to_non_nullable
              as String?,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as int?,
      attraction: freezed == attraction
          ? _value.attraction
          : attraction // ignore: cast_nullable_to_non_nullable
              as int?,
      destination: freezed == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as int?,
      destinationSlug: freezed == destinationSlug
          ? _value.destinationSlug
          : destinationSlug // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationDtoImplCopyWith<$Res>
    implements $NotificationDtoCopyWith<$Res> {
  factory _$$NotificationDtoImplCopyWith(_$NotificationDtoImpl value,
          $Res Function(_$NotificationDtoImpl) then) =
      __$$NotificationDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String type,
      @JsonKey(name: 'is_read') bool isRead,
      String message,
      int? experience,
      @JsonKey(name: 'experience_slug') String? experienceSlug,
      int? comment,
      int? attraction,
      int? destination,
      @JsonKey(name: 'destination_slug') String? destinationSlug,
      @JsonKey(name: 'created_at') String createdAt});
}

/// @nodoc
class __$$NotificationDtoImplCopyWithImpl<$Res>
    extends _$NotificationDtoCopyWithImpl<$Res, _$NotificationDtoImpl>
    implements _$$NotificationDtoImplCopyWith<$Res> {
  __$$NotificationDtoImplCopyWithImpl(
      _$NotificationDtoImpl _value, $Res Function(_$NotificationDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? isRead = null,
    Object? message = null,
    Object? experience = freezed,
    Object? experienceSlug = freezed,
    Object? comment = freezed,
    Object? attraction = freezed,
    Object? destination = freezed,
    Object? destinationSlug = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$NotificationDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      experience: freezed == experience
          ? _value.experience
          : experience // ignore: cast_nullable_to_non_nullable
              as int?,
      experienceSlug: freezed == experienceSlug
          ? _value.experienceSlug
          : experienceSlug // ignore: cast_nullable_to_non_nullable
              as String?,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as int?,
      attraction: freezed == attraction
          ? _value.attraction
          : attraction // ignore: cast_nullable_to_non_nullable
              as int?,
      destination: freezed == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as int?,
      destinationSlug: freezed == destinationSlug
          ? _value.destinationSlug
          : destinationSlug // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationDtoImpl implements _NotificationDto {
  const _$NotificationDtoImpl(
      {required this.id,
      required this.type,
      @JsonKey(name: 'is_read') this.isRead = false,
      this.message = '',
      this.experience,
      @JsonKey(name: 'experience_slug') this.experienceSlug,
      this.comment,
      this.attraction,
      this.destination,
      @JsonKey(name: 'destination_slug') this.destinationSlug,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$NotificationDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationDtoImplFromJson(json);

  @override
  final int id;
  @override
  final String type;
  @override
  @JsonKey(name: 'is_read')
  final bool isRead;
  @override
  @JsonKey()
  final String message;
  @override
  final int? experience;
  @override
  @JsonKey(name: 'experience_slug')
  final String? experienceSlug;
  @override
  final int? comment;
  @override
  final int? attraction;
  @override
  final int? destination;
  @override
  @JsonKey(name: 'destination_slug')
  final String? destinationSlug;
  @override
  @JsonKey(name: 'created_at')
  final String createdAt;

  @override
  String toString() {
    return 'NotificationDto(id: $id, type: $type, isRead: $isRead, message: $message, experience: $experience, experienceSlug: $experienceSlug, comment: $comment, attraction: $attraction, destination: $destination, destinationSlug: $destinationSlug, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.experience, experience) ||
                other.experience == experience) &&
            (identical(other.experienceSlug, experienceSlug) ||
                other.experienceSlug == experienceSlug) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.attraction, attraction) ||
                other.attraction == attraction) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.destinationSlug, destinationSlug) ||
                other.destinationSlug == destinationSlug) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      isRead,
      message,
      experience,
      experienceSlug,
      comment,
      attraction,
      destination,
      destinationSlug,
      createdAt);

  /// Create a copy of NotificationDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationDtoImplCopyWith<_$NotificationDtoImpl> get copyWith =>
      __$$NotificationDtoImplCopyWithImpl<_$NotificationDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationDtoImplToJson(
      this,
    );
  }
}

abstract class _NotificationDto implements NotificationDto {
  const factory _NotificationDto(
          {required final int id,
          required final String type,
          @JsonKey(name: 'is_read') final bool isRead,
          final String message,
          final int? experience,
          @JsonKey(name: 'experience_slug') final String? experienceSlug,
          final int? comment,
          final int? attraction,
          final int? destination,
          @JsonKey(name: 'destination_slug') final String? destinationSlug,
          @JsonKey(name: 'created_at') required final String createdAt}) =
      _$NotificationDtoImpl;

  factory _NotificationDto.fromJson(Map<String, dynamic> json) =
      _$NotificationDtoImpl.fromJson;

  @override
  int get id;
  @override
  String get type;
  @override
  @JsonKey(name: 'is_read')
  bool get isRead;
  @override
  String get message;
  @override
  int? get experience;
  @override
  @JsonKey(name: 'experience_slug')
  String? get experienceSlug;
  @override
  int? get comment;
  @override
  int? get attraction;
  @override
  int? get destination;
  @override
  @JsonKey(name: 'destination_slug')
  String? get destinationSlug;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;

  /// Create a copy of NotificationDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationDtoImplCopyWith<_$NotificationDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
