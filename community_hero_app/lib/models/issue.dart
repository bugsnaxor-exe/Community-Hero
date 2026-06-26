import 'package:freezed_annotation/freezed_annotation.dart';

part 'issue.freezed.dart';
part 'issue.g.dart';

@freezed
class Issue with _$Issue {
  const factory Issue({
    required int id,
    required String title,
    required String description,
    required String category,
    required String severity,
    required String status,
    required double latitude,
    required double longitude,
    @JsonKey(name: 'verification_count') @Default(0) int verificationCount,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'image_url') String? imageUrl,
  }) = _Issue;

  factory Issue.fromJson(Map<String, dynamic> json) => _$IssueFromJson(json);
}
