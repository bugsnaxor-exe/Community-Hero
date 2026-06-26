// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'issue.freezed.dart';
part 'issue.g.dart';

@freezed
class Issue with _$Issue {
  const factory Issue({
    required String id,
    @Default('Unknown Title') String title,
    @Default('') String description,
    @Default('General') String category,
    @Default('Low') String severity,
    @Default('Open') String status,
    @Default(0.0) double latitude,
    @Default(0.0) double longitude,
    @JsonKey(name: 'verification_count') @Default(0) int verificationCount,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'image_url') String? imageUrl,
  }) = _Issue;

  factory Issue.fromJson(Map<String, dynamic> json) => _$IssueFromJson(json);
}
