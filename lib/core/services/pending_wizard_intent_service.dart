/// What a signed-out visitor picked while browsing (occasion type and,
/// optionally, a starter design) before being asked to sign up.
class PendingWizardIntent {
  final int? eventTypeId;
  final int? templateId;

  const PendingWizardIntent({this.eventTypeId, this.templateId});

  bool get isEmpty => eventTypeId == null && templateId == null;
}

/// In-memory hand-off from Explore to the invitation wizard across the
/// sign-up / sign-in step. Holds at most one intent; [consume] returns it
/// once and clears it. Nothing is persisted.
class PendingWizardIntentService {
  PendingWizardIntent? _pending;

  bool get hasPending => _pending != null;

  void set(PendingWizardIntent intent) {
    _pending = intent.isEmpty ? null : intent;
  }

  void clear() => _pending = null;

  /// Returns the pending intent (if any) and clears it.
  PendingWizardIntent? consume() {
    final p = _pending;
    _pending = null;
    return p;
  }
}
