import 'package:flutter_bloc/flutter_bloc.dart';

import '../invitation_state.dart';
import 'wizard_deps.dart';

/// Step 3: the invitation's design.
mixin WizardDesignActions on Cubit<InvitationState>, WizardDeps {
  /// A link that opens the invitation editor for this event, or null.
  Future<String?> editorUrl() async {
    final eventId = state.draftEventId;
    if (repository == null || eventId == null) return null;
    final result = await repository!.editorUrl(eventId);
    return result.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.toString()));
        return null;
      },
      (url) => url,
    );
  }

  /// Reads the event's design again, after the editor saved one. On a
  /// failure the design already shown stays.
  Future<void> refreshDesign() async {
    final eventId = state.draftEventId;
    if (repository == null || eventId == null) return;
    final url = (await repository!.designUrl(eventId)).getOrElse(() => null);
    if (url != null && !isClosed) emit(state.copyWith(generatedImageUrl: url, previewImageUrl: url));
  }
}
