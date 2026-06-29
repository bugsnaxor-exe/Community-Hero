import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/issue.dart';
import '../../data/issue_details_repository.dart';
import '../../../../services/location_service.dart';

class IssueDetailsState {
  final Issue? issue;
  final List<Map<String, dynamic>> timeline;
  final bool isVerifying;

  IssueDetailsState({
    this.issue,
    this.timeline = const [],
    this.isVerifying = false,
  });

  IssueDetailsState copyWith({
    Issue? issue,
    List<Map<String, dynamic>>? timeline,
    bool? isVerifying,
  }) {
    return IssueDetailsState(
      issue: issue ?? this.issue,
      timeline: timeline ?? this.timeline,
      isVerifying: isVerifying ?? this.isVerifying,
    );
  }
}

final issueDetailsProvider = AsyncNotifierProvider.family<IssueDetailsController, IssueDetailsState, String>(() {
  return IssueDetailsController();
});

class IssueDetailsController extends FamilyAsyncNotifier<IssueDetailsState, String> {
  late final IssueDetailsRepository _repository;
  late final LocationService _locationService;

  @override
  FutureOr<IssueDetailsState> build(String arg) async {
    _repository = ref.watch(issueDetailsRepositoryProvider);
    _locationService = ref.watch(locationServiceProvider);

    final issue = await _repository.getIssueDetails(arg);
    final timeline = await _repository.getIssueTimeline(arg);

    return IssueDetailsState(
      issue: issue,
      timeline: timeline,
    );
  }

  Future<String?> verifyIssue() async {
    final currentState = state.value;
    if (currentState == null || currentState.issue == null) return "Issue data not loaded.";

    state = AsyncValue.data(currentState.copyWith(isVerifying: true));

    try {
      final position = await _locationService.getCurrentLocation();
      final success = await _repository.verifyIssue(arg, position.latitude, position.longitude);

      if (success) {
        // Optimistically update the UI
        final updatedIssue = currentState.issue!.copyWith(
          verificationCount: currentState.issue!.verificationCount + 1,
        );
        state = AsyncValue.data(currentState.copyWith(
          issue: updatedIssue,
          isVerifying: false,
        ));
        return null;
      } else {
        state = AsyncValue.data(currentState.copyWith(isVerifying: false));
        return "Verification failed.";
      }
    } catch (e) {
      state = AsyncValue.data(currentState.copyWith(isVerifying: false));
      final msg = e.toString().replaceAll("Exception: ", "").replaceAll("AppException: ", "").replaceAll("NetworkException: ", "");
      return msg;
    }
  }
}

