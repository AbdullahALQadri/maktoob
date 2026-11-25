import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/services/excel_parser_service.dart';
import '../../data/services/whatsapp_service.dart';
import '../../domain/repositories/event_wizard_repository.dart';
import 'actions/wizard_deps.dart';
import 'actions/wizard_design_actions.dart';
import 'actions/wizard_details_actions.dart';
import 'actions/wizard_details_edits.dart';
import 'actions/wizard_guests_actions.dart';
import 'actions/wizard_invoice_actions.dart';
import 'actions/wizard_package_actions.dart';
import 'actions/wizard_services_actions.dart';
import 'actions/wizard_start_actions.dart';
import 'actions/wizard_step_saves.dart';
import 'actions/wizard_submit_actions.dart';
import 'actions/wizard_type_actions.dart';
import 'invitation_state.dart';

/// The event wizard: five screens (details, guests, design, settings and
/// extras, package and payment), then the event page for sending. Each group
/// of actions lives in its own file under `actions/`.
class InvitationCubit extends Cubit<InvitationState>
    with
        WizardDeps,
        WizardTypeActions,
        WizardStartActions,
        WizardDetailsActions,
        WizardDetailsEdits,
        WizardGuestsActions,
        WizardDesignActions,
        WizardServicesActions,
        WizardStepSaves,
        WizardPackageActions,
        WizardInvoiceActions,
        WizardSubmitActions {
  InvitationCubit({
    this.repository,
    this.excelParserService,
    this.whatsAppService,
  }) : super(InvitationState.initial());

  @override
  final EventWizardRepository? repository;
  @override
  final ExcelParserService? excelParserService;
  @override
  final WhatsAppService? whatsAppService;

  @override
  void nextStep() => _moveBy(1);

  void previousStep() => _moveBy(-1);

  void goToStep(InvitationStep step) => emit(state.copyWith(currentStep: step));

  void _moveBy(int delta) {
    const steps = InvitationStep.values;
    final target = (state.currentStep.index + delta).clamp(0, steps.length - 1);
    if (target != state.currentStep.index) emit(state.copyWith(currentStep: steps[target]));
  }

  void reset() => emit(InvitationState.initial());

  void clearError() => emit(state.copyWith(clearError: true));

  bool get isLoading => state.status == InvitationStatus.loading;

  /// The design the host chose (a ready one, their own upload or a new one).
  void setAiGeneratedImage(String url, {int? imageId}) {
    emit(state.copyWith(generatedImageUrl: url, generatingImageId: imageId, previewImageUrl: url));
  }
}
