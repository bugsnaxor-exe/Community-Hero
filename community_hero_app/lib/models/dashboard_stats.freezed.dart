// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DashboardStats _$DashboardStatsFromJson(Map<String, dynamic> json) {
  return _DashboardStats.fromJson(json);
}

/// @nodoc
mixin _$DashboardStats {
  @JsonKey(name: 'total_issues')
  int get totalIssues => throw _privateConstructorUsedError;
  @JsonKey(name: 'verified_issues')
  int get verifiedIssues => throw _privateConstructorUsedError;
  @JsonKey(name: 'resolved_issues')
  int get resolvedIssues => throw _privateConstructorUsedError;
  @JsonKey(name: 'pending_issues')
  int get pendingIssues => throw _privateConstructorUsedError;

  /// Serializes this DashboardStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardStatsCopyWith<DashboardStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardStatsCopyWith<$Res> {
  factory $DashboardStatsCopyWith(
          DashboardStats value, $Res Function(DashboardStats) then) =
      _$DashboardStatsCopyWithImpl<$Res, DashboardStats>;
  @useResult
  $Res call(
      {@JsonKey(name: 'total_issues') int totalIssues,
      @JsonKey(name: 'verified_issues') int verifiedIssues,
      @JsonKey(name: 'resolved_issues') int resolvedIssues,
      @JsonKey(name: 'pending_issues') int pendingIssues});
}

/// @nodoc
class _$DashboardStatsCopyWithImpl<$Res, $Val extends DashboardStats>
    implements $DashboardStatsCopyWith<$Res> {
  _$DashboardStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalIssues = null,
    Object? verifiedIssues = null,
    Object? resolvedIssues = null,
    Object? pendingIssues = null,
  }) {
    return _then(_value.copyWith(
      totalIssues: null == totalIssues
          ? _value.totalIssues
          : totalIssues // ignore: cast_nullable_to_non_nullable
              as int,
      verifiedIssues: null == verifiedIssues
          ? _value.verifiedIssues
          : verifiedIssues // ignore: cast_nullable_to_non_nullable
              as int,
      resolvedIssues: null == resolvedIssues
          ? _value.resolvedIssues
          : resolvedIssues // ignore: cast_nullable_to_non_nullable
              as int,
      pendingIssues: null == pendingIssues
          ? _value.pendingIssues
          : pendingIssues // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DashboardStatsImplCopyWith<$Res>
    implements $DashboardStatsCopyWith<$Res> {
  factory _$$DashboardStatsImplCopyWith(_$DashboardStatsImpl value,
          $Res Function(_$DashboardStatsImpl) then) =
      __$$DashboardStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'total_issues') int totalIssues,
      @JsonKey(name: 'verified_issues') int verifiedIssues,
      @JsonKey(name: 'resolved_issues') int resolvedIssues,
      @JsonKey(name: 'pending_issues') int pendingIssues});
}

/// @nodoc
class __$$DashboardStatsImplCopyWithImpl<$Res>
    extends _$DashboardStatsCopyWithImpl<$Res, _$DashboardStatsImpl>
    implements _$$DashboardStatsImplCopyWith<$Res> {
  __$$DashboardStatsImplCopyWithImpl(
      _$DashboardStatsImpl _value, $Res Function(_$DashboardStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalIssues = null,
    Object? verifiedIssues = null,
    Object? resolvedIssues = null,
    Object? pendingIssues = null,
  }) {
    return _then(_$DashboardStatsImpl(
      totalIssues: null == totalIssues
          ? _value.totalIssues
          : totalIssues // ignore: cast_nullable_to_non_nullable
              as int,
      verifiedIssues: null == verifiedIssues
          ? _value.verifiedIssues
          : verifiedIssues // ignore: cast_nullable_to_non_nullable
              as int,
      resolvedIssues: null == resolvedIssues
          ? _value.resolvedIssues
          : resolvedIssues // ignore: cast_nullable_to_non_nullable
              as int,
      pendingIssues: null == pendingIssues
          ? _value.pendingIssues
          : pendingIssues // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardStatsImpl implements _DashboardStats {
  const _$DashboardStatsImpl(
      {@JsonKey(name: 'total_issues') this.totalIssues = 0,
      @JsonKey(name: 'verified_issues') this.verifiedIssues = 0,
      @JsonKey(name: 'resolved_issues') this.resolvedIssues = 0,
      @JsonKey(name: 'pending_issues') this.pendingIssues = 0});

  factory _$DashboardStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardStatsImplFromJson(json);

  @override
  @JsonKey(name: 'total_issues')
  final int totalIssues;
  @override
  @JsonKey(name: 'verified_issues')
  final int verifiedIssues;
  @override
  @JsonKey(name: 'resolved_issues')
  final int resolvedIssues;
  @override
  @JsonKey(name: 'pending_issues')
  final int pendingIssues;

  @override
  String toString() {
    return 'DashboardStats(totalIssues: $totalIssues, verifiedIssues: $verifiedIssues, resolvedIssues: $resolvedIssues, pendingIssues: $pendingIssues)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardStatsImpl &&
            (identical(other.totalIssues, totalIssues) ||
                other.totalIssues == totalIssues) &&
            (identical(other.verifiedIssues, verifiedIssues) ||
                other.verifiedIssues == verifiedIssues) &&
            (identical(other.resolvedIssues, resolvedIssues) ||
                other.resolvedIssues == resolvedIssues) &&
            (identical(other.pendingIssues, pendingIssues) ||
                other.pendingIssues == pendingIssues));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, totalIssues, verifiedIssues, resolvedIssues, pendingIssues);

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardStatsImplCopyWith<_$DashboardStatsImpl> get copyWith =>
      __$$DashboardStatsImplCopyWithImpl<_$DashboardStatsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardStatsImplToJson(
      this,
    );
  }
}

abstract class _DashboardStats implements DashboardStats {
  const factory _DashboardStats(
          {@JsonKey(name: 'total_issues') final int totalIssues,
          @JsonKey(name: 'verified_issues') final int verifiedIssues,
          @JsonKey(name: 'resolved_issues') final int resolvedIssues,
          @JsonKey(name: 'pending_issues') final int pendingIssues}) =
      _$DashboardStatsImpl;

  factory _DashboardStats.fromJson(Map<String, dynamic> json) =
      _$DashboardStatsImpl.fromJson;

  @override
  @JsonKey(name: 'total_issues')
  int get totalIssues;
  @override
  @JsonKey(name: 'verified_issues')
  int get verifiedIssues;
  @override
  @JsonKey(name: 'resolved_issues')
  int get resolvedIssues;
  @override
  @JsonKey(name: 'pending_issues')
  int get pendingIssues;

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardStatsImplCopyWith<_$DashboardStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
