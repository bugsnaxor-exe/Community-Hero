// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'issue.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Issue _$IssueFromJson(Map<String, dynamic> json) {
  return _Issue.fromJson(json);
}

/// @nodoc
mixin _$Issue {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String get severity => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'lat')
  double get latitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'lng')
  double get longitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'verification_count')
  int get verificationCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt =>
      throw _privateConstructorUsedError; // Single image_url for list views (from feed/home endpoints)
  @JsonKey(name: 'image_url')
  String? get imageUrl =>
      throw _privateConstructorUsedError; // Full images array for detail view
  List<IssueImage> get images => throw _privateConstructorUsedError;

  /// Serializes this Issue to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Issue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IssueCopyWith<Issue> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IssueCopyWith<$Res> {
  factory $IssueCopyWith(Issue value, $Res Function(Issue) then) =
      _$IssueCopyWithImpl<$Res, Issue>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String category,
      String severity,
      String status,
      @JsonKey(name: 'lat') double latitude,
      @JsonKey(name: 'lng') double longitude,
      @JsonKey(name: 'verification_count') int verificationCount,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'image_url') String? imageUrl,
      List<IssueImage> images});
}

/// @nodoc
class _$IssueCopyWithImpl<$Res, $Val extends Issue>
    implements $IssueCopyWith<$Res> {
  _$IssueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Issue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? category = null,
    Object? severity = null,
    Object? status = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? verificationCount = null,
    Object? createdAt = freezed,
    Object? imageUrl = freezed,
    Object? images = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      verificationCount: null == verificationCount
          ? _value.verificationCount
          : verificationCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<IssueImage>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IssueImplCopyWith<$Res> implements $IssueCopyWith<$Res> {
  factory _$$IssueImplCopyWith(
          _$IssueImpl value, $Res Function(_$IssueImpl) then) =
      __$$IssueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String category,
      String severity,
      String status,
      @JsonKey(name: 'lat') double latitude,
      @JsonKey(name: 'lng') double longitude,
      @JsonKey(name: 'verification_count') int verificationCount,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'image_url') String? imageUrl,
      List<IssueImage> images});
}

/// @nodoc
class __$$IssueImplCopyWithImpl<$Res>
    extends _$IssueCopyWithImpl<$Res, _$IssueImpl>
    implements _$$IssueImplCopyWith<$Res> {
  __$$IssueImplCopyWithImpl(
      _$IssueImpl _value, $Res Function(_$IssueImpl) _then)
      : super(_value, _then);

  /// Create a copy of Issue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? category = null,
    Object? severity = null,
    Object? status = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? verificationCount = null,
    Object? createdAt = freezed,
    Object? imageUrl = freezed,
    Object? images = null,
  }) {
    return _then(_$IssueImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      verificationCount: null == verificationCount
          ? _value.verificationCount
          : verificationCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<IssueImage>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IssueImpl implements _Issue {
  const _$IssueImpl(
      {required this.id,
      this.title = 'Unknown Title',
      this.description = '',
      this.category = 'General',
      this.severity = 'Low',
      this.status = 'Open',
      @JsonKey(name: 'lat') this.latitude = 0.0,
      @JsonKey(name: 'lng') this.longitude = 0.0,
      @JsonKey(name: 'verification_count') this.verificationCount = 0,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'image_url') this.imageUrl,
      final List<IssueImage> images = const []})
      : _images = images;

  factory _$IssueImpl.fromJson(Map<String, dynamic> json) =>
      _$$IssueImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey()
  final String title;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final String category;
  @override
  @JsonKey()
  final String severity;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey(name: 'lat')
  final double latitude;
  @override
  @JsonKey(name: 'lng')
  final double longitude;
  @override
  @JsonKey(name: 'verification_count')
  final int verificationCount;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
// Single image_url for list views (from feed/home endpoints)
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
// Full images array for detail view
  final List<IssueImage> _images;
// Full images array for detail view
  @override
  @JsonKey()
  List<IssueImage> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  String toString() {
    return 'Issue(id: $id, title: $title, description: $description, category: $category, severity: $severity, status: $status, latitude: $latitude, longitude: $longitude, verificationCount: $verificationCount, createdAt: $createdAt, imageUrl: $imageUrl, images: $images)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IssueImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.verificationCount, verificationCount) ||
                other.verificationCount == verificationCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality().equals(other._images, _images));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      category,
      severity,
      status,
      latitude,
      longitude,
      verificationCount,
      createdAt,
      imageUrl,
      const DeepCollectionEquality().hash(_images));

  /// Create a copy of Issue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IssueImplCopyWith<_$IssueImpl> get copyWith =>
      __$$IssueImplCopyWithImpl<_$IssueImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IssueImplToJson(
      this,
    );
  }
}

abstract class _Issue implements Issue {
  const factory _Issue(
      {required final String id,
      final String title,
      final String description,
      final String category,
      final String severity,
      final String status,
      @JsonKey(name: 'lat') final double latitude,
      @JsonKey(name: 'lng') final double longitude,
      @JsonKey(name: 'verification_count') final int verificationCount,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      @JsonKey(name: 'image_url') final String? imageUrl,
      final List<IssueImage> images}) = _$IssueImpl;

  factory _Issue.fromJson(Map<String, dynamic> json) = _$IssueImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get category;
  @override
  String get severity;
  @override
  String get status;
  @override
  @JsonKey(name: 'lat')
  double get latitude;
  @override
  @JsonKey(name: 'lng')
  double get longitude;
  @override
  @JsonKey(name: 'verification_count')
  int get verificationCount;
  @override
  @JsonKey(name: 'created_at')
  DateTime?
      get createdAt; // Single image_url for list views (from feed/home endpoints)
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl; // Full images array for detail view
  @override
  List<IssueImage> get images;

  /// Create a copy of Issue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IssueImplCopyWith<_$IssueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

IssueImage _$IssueImageFromJson(Map<String, dynamic> json) {
  return _IssueImage.fromJson(json);
}

/// @nodoc
mixin _$IssueImage {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this IssueImage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of IssueImage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IssueImageCopyWith<IssueImage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IssueImageCopyWith<$Res> {
  factory $IssueImageCopyWith(
          IssueImage value, $Res Function(IssueImage) then) =
      _$IssueImageCopyWithImpl<$Res, IssueImage>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'image_url') String imageUrl,
      @JsonKey(name: 'created_at') DateTime? createdAt});
}

/// @nodoc
class _$IssueImageCopyWithImpl<$Res, $Val extends IssueImage>
    implements $IssueImageCopyWith<$Res> {
  _$IssueImageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IssueImage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? imageUrl = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IssueImageImplCopyWith<$Res>
    implements $IssueImageCopyWith<$Res> {
  factory _$$IssueImageImplCopyWith(
          _$IssueImageImpl value, $Res Function(_$IssueImageImpl) then) =
      __$$IssueImageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'image_url') String imageUrl,
      @JsonKey(name: 'created_at') DateTime? createdAt});
}

/// @nodoc
class __$$IssueImageImplCopyWithImpl<$Res>
    extends _$IssueImageCopyWithImpl<$Res, _$IssueImageImpl>
    implements _$$IssueImageImplCopyWith<$Res> {
  __$$IssueImageImplCopyWithImpl(
      _$IssueImageImpl _value, $Res Function(_$IssueImageImpl) _then)
      : super(_value, _then);

  /// Create a copy of IssueImage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? imageUrl = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$IssueImageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IssueImageImpl implements _IssueImage {
  const _$IssueImageImpl(
      {required this.id,
      @JsonKey(name: 'image_url') required this.imageUrl,
      @JsonKey(name: 'created_at') this.createdAt});

  factory _$IssueImageImpl.fromJson(Map<String, dynamic> json) =>
      _$$IssueImageImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'image_url')
  final String imageUrl;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'IssueImage(id: $id, imageUrl: $imageUrl, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IssueImageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, imageUrl, createdAt);

  /// Create a copy of IssueImage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IssueImageImplCopyWith<_$IssueImageImpl> get copyWith =>
      __$$IssueImageImplCopyWithImpl<_$IssueImageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IssueImageImplToJson(
      this,
    );
  }
}

abstract class _IssueImage implements IssueImage {
  const factory _IssueImage(
          {required final String id,
          @JsonKey(name: 'image_url') required final String imageUrl,
          @JsonKey(name: 'created_at') final DateTime? createdAt}) =
      _$IssueImageImpl;

  factory _IssueImage.fromJson(Map<String, dynamic> json) =
      _$IssueImageImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'image_url')
  String get imageUrl;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of IssueImage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IssueImageImplCopyWith<_$IssueImageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
