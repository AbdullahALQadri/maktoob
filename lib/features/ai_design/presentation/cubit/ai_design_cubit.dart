import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/fcm_service.dart';
import '../../data/models/ai_image_model.dart';
import '../../data/repositories/ai_design_repository.dart';
import 'ai_design_state.dart';

class AiDesignCubit extends Cubit<AiDesignState> {
  final AiDesignRepository _repo;
  final FcmService? _fcm;
  final int eventId;
  final int eventTypeId;

  Timer? _pollingTimer;
  int  _elapsedSeconds   = 0;
  bool _waitingForPrompt = true;
  bool _isFetching       = false; // guard against overlapping poll requests
  StreamSubscription<Map<String, dynamic>>? _fcmSub;
  int? _trackedImageId; // the imageId the FCM listener should watch for

  AiDesignCubit({
    required AiDesignRepository repository,
    required this.eventId,
    required this.eventTypeId,
    FcmService? fcmService,
  })  : _repo = repository,
        _fcm  = fcmService,
        super(const AiDesignInitial()) {
    // Subscribe once for the lifetime of this cubit. The listener is a no-op
    // unless _trackedImageId matches the incoming push.
    _fcmSub = _fcm?.messageStream.listen(_onFcmPayload);
  }

  void _onFcmPayload(Map<String, dynamic> data) {
    dev.log('FCM payload received: $data', name: 'AiDesignCubit');
    final type = data['type']?.toString();
    if (type == null) return;

    final pushImageId = int.tryParse(data['image_id']?.toString() ?? '');
    dev.log('FCM tracked=$_trackedImageId push=$pushImageId type=$type waitingForPrompt=$_waitingForPrompt',
        name: 'AiDesignCubit');
    if (_trackedImageId == null || pushImageId != _trackedImageId) return;

    if (type == 'prompt.ready' && _waitingForPrompt) {
      _cancelPolling();
      final inlinePrompt = data['prompt_text']?.toString() ?? '';
      if (inlinePrompt.isNotEmpty) {
        emit(AiPromptReady(imageId: pushImageId!, promptText: inlinePrompt));
      } else {
        // FCM data payload is capped at ~4KB; long Arabic prompts get dropped.
        // Fetch the full prompt from the status endpoint as a fallback.
        _fetchPromptThenEmit(pushImageId!);
      }
    } else if (type == 'image.completed' && !_waitingForPrompt) {
      _cancelPolling();
      final inlineUrl = data['image_url']?.toString() ?? '';
      if (inlineUrl.isNotEmpty) {
        emit(AiImageCompleted(
          imageId:  pushImageId!,
          imageUrl: inlineUrl,
          provider: data['provider']?.toString(),
          model:    data['model']?.toString(),
        ));
      } else {
        _fetchImageThenEmit(pushImageId!);
      }
    } else if (type == 'image.failed') {
      _cancelPolling();
      _handleError(data['error']?.toString() ?? 'Generation failed');
    }
  }

  Future<void> _fetchPromptThenEmit(int imageId) async {
    try {
      final s = await _repo.getStatus(eventId, imageId);
      if (isClosed) return;
      // Reject the result if the user moved on to a different image in the meantime.
      if (_trackedImageId != null && _trackedImageId != imageId) return;
      if (s.isPromptReady && (s.promptText ?? '').isNotEmpty) {
        emit(AiPromptReady(imageId: s.imageId, promptText: s.promptText!));
      } else if (s.isFailed) {
        _handleError(s.error ?? 'Generation failed');
      } else {
        // prompt_ready but empty text, OR still processing — keep waiting
        _startPolling(imageId, waitForPrompt: true);
      }
    } catch (e) {
      dev.log('Fetch prompt fallback failed: $e', name: 'AiDesignCubit');
      _startPolling(imageId, waitForPrompt: true);
    }
  }

  Future<void> _fetchImageThenEmit(int imageId) async {
    try {
      final s = await _repo.getStatus(eventId, imageId);
      if (isClosed) return;
      if (_trackedImageId != null && _trackedImageId != imageId) return;
      if (s.isCompleted && (s.imageUrl ?? '').isNotEmpty) {
        emit(AiImageCompleted(
          imageId:  s.imageId,
          imageUrl: s.imageUrl!,
          provider: s.provider,
          model:    s.model,
        ));
      } else if (s.isFailed) {
        _handleError(s.error ?? 'Generation failed');
      } else {
        _startPolling(imageId, waitForPrompt: false);
      }
    } catch (e) {
      dev.log('Fetch image fallback failed: $e', name: 'AiDesignCubit');
      _startPolling(imageId, waitForPrompt: false);
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Load
  // ──────────────────────────────────────────────────────────────

  Future<void> load() async {
    emit(const AiDesignLoading());
    try {
      final gallery = await _repo.getGalleryImages(eventTypeId);
      final fields  = await _repo.getFormFields(eventTypeId);
      emit(AiDesignReady(galleryImages: gallery, formFields: fields));
    } catch (e) {
      emit(AiDesignError(e.toString()));
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Page 1 interactions
  // ──────────────────────────────────────────────────────────────

  void selectImage(AiImageModel image) {
    final s = _ready;
    if (s == null) return;
    if (s.selectedImageId == image.id) {
      // Deselect
      emit(s.copyWith(clearSelectedImage: true));
    } else {
      emit(s.copyWith(selectedImageId: image.id, selectedBasePrompt: image.prompt));
    }
  }

  void switchTab(int tab) {
    final s = _ready;
    if (s == null) return;
    emit(s.copyWith(
      activeTab:          tab,
      clearSelectedImage: tab == 1, // switching to freeform: clear gallery selection
      clearFreeformPrompt: tab == 0, // switching to gallery: clear freeform text
      clearError:         true,
    ));
  }

  void updateFormValue(String key, String value) {
    final s = _ready;
    if (s == null) return;
    final updated = Map<String, String>.from(s.formValues)..[key] = value;
    emit(s.copyWith(formValues: updated));
  }

  void updateFreeformPrompt(String text) {
    final s = _ready;
    if (s == null) return;
    emit(s.copyWith(freeformPromptText: text));
  }

  void updateCustomPrompt(String text) {
    final s = _ready;
    if (s == null) return;
    final trimmed = text.trim();
    emit(s.copyWith(customPrompt: trimmed.isEmpty ? null : trimmed));
  }

  // ──────────────────────────────────────────────────────────────
  // Step 1: Generate Prompt
  // ──────────────────────────────────────────────────────────────

  Future<void> generatePrompt() async {
    final s = _ready;
    if (s == null) return;
    _cancelPolling();
    emit(s.copyWith(isGenerating: true, clearError: true));

    try {
      final imageId = await _repo.generatePrompt(
        eventId,
        basePrompt:     s.activeTab == 0 ? s.selectedBasePrompt : null,
        freeformPrompt: s.activeTab == 1 ? s.freeformPromptText : null,
        eventTypeId:    eventTypeId,
        formValues:     s.formValues,
        customPrompt:   s.customPrompt,
      );
      _startPolling(imageId, waitForPrompt: true);
    } catch (e) {
      emit((_ready ?? s).copyWith(isGenerating: false, generationError: e.toString()));
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Step 2: Confirm and Generate Image
  // ──────────────────────────────────────────────────────────────

  Future<void> confirmGenerate(int imageId, String promptText) async {
    emit(AiImageGenerating(imageId: imageId, promptText: promptText));
    try {
      final confirmedImageId = await _repo.confirmGenerate(
        eventId,
        imageId:    imageId,
        promptText: promptText,
      );
      _startPolling(confirmedImageId, waitForPrompt: false);
    } catch (e) {
      // Re-enter Page 2 state with error flag — caller handles display
      emit(AiDesignError(e.toString()));
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Save to event
  // ──────────────────────────────────────────────────────────────

  Future<void> saveImage(int imageId, String imageUrl) async {
    try {
      await _repo.saveImageToEvent(eventId, imageId);
      emit(AiImageSaved(imageUrl));
    } catch (e) {
      emit(AiDesignError(e.toString()));
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Polling
  // ──────────────────────────────────────────────────────────────

  void _startPolling(int imageId, {required bool waitForPrompt}) {
    _cancelPolling();
    _elapsedSeconds   = 0;
    _waitingForPrompt = waitForPrompt;
    _trackedImageId   = imageId; // tells the FCM listener what to react to
    final timeoutSeconds = waitForPrompt ? 180 : 300;

    // FCM is the primary mechanism; this Timer is a fallback that runs every
    // 8 seconds in case the push notification never arrives.
    _isFetching = false;

    _pollingTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      _elapsedSeconds += 8;
      if (_elapsedSeconds > timeoutSeconds) {
        _cancelPolling();
        _handleTimeout();
        return;
      }
      if (_isFetching) return; // previous request still in flight — skip tick
      _isFetching = true;
      _repo.getStatus(eventId, imageId).then((status) {
        _isFetching = false;
        if (isClosed) return;
        if (status.isPromptReady && waitForPrompt) {
          _cancelPolling();
          emit(AiPromptReady(imageId: status.imageId, promptText: status.promptText ?? ''));
        } else if (status.isCompleted && !waitForPrompt) {
          _cancelPolling();
          emit(AiImageCompleted(
            imageId:  status.imageId,
            imageUrl: status.imageUrl ?? '',
            provider: status.provider,
            model:    status.model,
          ));
        } else if (status.isFailed) {
          _cancelPolling();
          _handleError(status.error ?? 'Generation failed');
        }
      }).catchError((e) {
        _isFetching = false;
        // Network hiccup — log and keep polling; real errors will surface via timeout
        dev.log('AI polling error (will retry): $e', name: 'AiDesignCubit');
      });
    });
  }

  void _cancelPolling() {
    _pollingTimer?.cancel();
    _pollingTimer    = null;
    _elapsedSeconds  = 0;
    _isFetching      = false;
    _trackedImageId  = null;
  }

  void _handleTimeout() {
    final s = _ready;
    if (s != null) {
      emit(s.copyWith(isGenerating: false, generationError: 'timeout'));
    } else {
      emit(const AiDesignError('timeout'));
    }
  }

  void _handleError(String message) {
    final s = _ready;
    if (s != null) {
      emit(s.copyWith(isGenerating: false, generationError: message));
    } else {
      emit(AiDesignError(message));
    }
  }

  AiDesignReady? get _ready =>
      state is AiDesignReady ? state as AiDesignReady : null;

  @override
  Future<void> close() {
    _cancelPolling();
    _fcmSub?.cancel();
    return super.close();
  }
}
