import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/core/error/exceptions.dart';
import 'package:maktoob/features/ai_design/data/models/ai_form_field_model.dart';
import 'package:maktoob/features/ai_design/data/models/ai_image_model.dart';
import 'package:maktoob/features/ai_design/data/models/generation_status_model.dart';
import 'package:maktoob/features/ai_design/data/repositories/ai_design_repository.dart';
import 'package:maktoob/features/ai_design/presentation/cubit/ai_design_cubit.dart';
import 'package:maktoob/features/ai_design/presentation/cubit/ai_design_state.dart';

/// Every status poll answers with [statusError] (or `processing`).
class _Repo implements AiDesignRepository {
  Object? statusError;
  int statusCalls = 0;
  _Repo(this.statusError);

  @override
  Future<GenerationStatusModel> getStatus(int eventId, int imageId) async {
    statusCalls++;
    if (statusError != null) throw statusError!;
    return GenerationStatusModel(status: 'processing', imageId: imageId);
  }

  @override
  Future<List<AiImageModel>> getGalleryImages(int eventTypeId) async => const [];
  @override
  Future<List<AiFormFieldModel>> getFormFields(int eventTypeId) async => const [];

  @override
  Future<int> generatePrompt(int eventId,
          {String? basePrompt,
          String? freeformPrompt,
          required int eventTypeId,
          required Map<String, String> formValues,
          String? customPrompt,
          List<String>? moodTags}) async =>
      42;

  @override
  Future<int> confirmGenerate(int eventId,
          {required int imageId, required String promptText}) async =>
      imageId;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('a 404 while polling the image stops polling and surfaces the error',
      (tester) async {
    final repo = _Repo(const NotFoundException());
    final cubit = AiDesignCubit(repository: repo, eventId: 1, eventTypeId: 1);

    await cubit.confirmGenerate(42, 'prompt');
    expect(cubit.state, isA<AiImageGenerating>());

    await tester.pump(const Duration(seconds: 9));
    expect(cubit.state, const AiDesignError(AiDesignCubit.notFoundError));
    expect(repo.statusCalls, 1);

    // No more polls, and no later 'timeout' overwrites the error.
    await tester.pump(const Duration(seconds: 400));
    expect(repo.statusCalls, 1);
    expect(cubit.state, const AiDesignError(AiDesignCubit.notFoundError));
    await cubit.close();
  });

  testWidgets('a 404 while polling the prompt ends generation on the form',
      (tester) async {
    final repo = _Repo(const NotFoundException());
    final cubit = AiDesignCubit(repository: repo, eventId: 1, eventTypeId: 1);
    await cubit.load();
    await cubit.generatePrompt();
    expect((cubit.state as AiDesignReady).isGenerating, isTrue);

    await tester.pump(const Duration(seconds: 9));
    final s = cubit.state as AiDesignReady;
    expect(s.isGenerating, isFalse);
    expect(s.generationError, AiDesignCubit.notFoundError);

    await tester.pump(const Duration(seconds: 60));
    expect(repo.statusCalls, 1);
    await cubit.close();
  });

  testWidgets('other polling errors keep retrying', (tester) async {
    final repo = _Repo(const NetworkException(message: 'offline'));
    final cubit = AiDesignCubit(repository: repo, eventId: 1, eventTypeId: 1);

    await cubit.confirmGenerate(42, 'prompt');
    await tester.pump(const Duration(seconds: 9));
    await tester.pump(const Duration(seconds: 8));
    await tester.pump(const Duration(seconds: 8));
    expect(repo.statusCalls, 3);
    expect(cubit.state, isA<AiImageGenerating>());
    await cubit.close();
  });
}
