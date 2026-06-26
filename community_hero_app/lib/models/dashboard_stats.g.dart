// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DashboardStatsImpl _$$DashboardStatsImplFromJson(Map<String, dynamic> json) =>
    _$DashboardStatsImpl(
      totalIssues: (json['total_issues'] as num?)?.toInt() ?? 0,
      verifiedIssues: (json['verified_issues'] as num?)?.toInt() ?? 0,
      resolvedIssues: (json['resolved_issues'] as num?)?.toInt() ?? 0,
      pendingIssues: (json['pending_issues'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$DashboardStatsImplToJson(
        _$DashboardStatsImpl instance) =>
    <String, dynamic>{
      'total_issues': instance.totalIssues,
      'verified_issues': instance.verifiedIssues,
      'resolved_issues': instance.resolvedIssues,
      'pending_issues': instance.pendingIssues,
    };
