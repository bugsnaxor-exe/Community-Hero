// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IssueImpl _$$IssueImplFromJson(Map<String, dynamic> json) => _$IssueImpl(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Unknown Title',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      severity: json['severity'] as String? ?? 'Low',
      status: json['status'] as String? ?? 'Open',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      verificationCount: (json['verification_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      imageUrl: json['image_url'] as String?,
    );

Map<String, dynamic> _$$IssueImplToJson(_$IssueImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'severity': instance.severity,
      'status': instance.status,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'verification_count': instance.verificationCount,
      'created_at': instance.createdAt?.toIso8601String(),
      'image_url': instance.imageUrl,
    };
