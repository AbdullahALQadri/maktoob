import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/services/excel_parser_service.dart';
import '../../../data/services/whatsapp_service.dart';
import '../../../domain/repositories/event_wizard_repository.dart';
import '../invitation_state.dart';

/// What every group of wizard actions works with. Without a repository
/// (previews, tests) the wizard keeps everything on the device.
mixin WizardDeps on Cubit<InvitationState> {
  EventWizardRepository? get repository;
  ExcelParserService? get excelParserService;
  WhatsAppService? get whatsAppService;
}
