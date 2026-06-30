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
    @JsonKey(name: 'lat') @Default(0.0) double latitude,
    @JsonKey(name: 'lng') @Default(0.0) double longitude,
    @JsonKey(name: 'verification_count') @Default(0) int verificationCount,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    // Single image_url for list views (from feed/home endpoints)
    @JsonKey(name: 'image_url') String? imageUrl,
    // Full images array for detail view
    @Default([]) List<IssueImage> images,
  }) = _Issue;

  factory Issue.fromJson(Map<String, dynamic> json) => _$IssueFromJson(json);
}

@freezed
class IssueImage with _$IssueImage {
  const factory IssueImage({
    required String id,
    @JsonKey(name: 'image_url') required String imageUrl,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _IssueImage;

  factory IssueImage.fromJson(Map<String, dynamic> json) => _$IssueImageFromJson(json);
}
