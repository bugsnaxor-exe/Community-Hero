// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_stats.freezed.dart';
part 'dashboard_stats.g.dart';

@freezed
class DashboardStats with _$DashboardStats {
  const factory DashboardStats({
    @JsonKey(name: 'total_issues') @Default(0) int totalIssues,
    @JsonKey(name: 'verified_issues') @Default(0) int verifiedIssues,
    @JsonKey(name: 'resolved_issues') @Default(0) int resolvedIssues,
    @JsonKey(name: 'pending_issues') @Default(0) int pendingIssues,
    @JsonKey(name: 'total_volunteers') @Default(0) int totalVolunteers,
  }) = _DashboardStats;

  factory DashboardStats.fromJson(Map<String, dynamic> json) => _$DashboardStatsFromJson(json);
}
