import '../../../../config/locale/app_localizations.dart';
import '../cubit/ai_design_cubit.dart';

/// Turns the cubit's error codes ('timeout', [AiDesignCubit.notFoundError])
/// into user text; any other message (already from the server) is shown as is.
String localizeAiDesignError(String error, AppLocalizations? loc) {
  if (error == 'timeout') {
    return loc?.translate('ai_timeout_error') ??
        'انتهت المهلة. يرجى المحاولة مجدداً.';
  }
  if (error == AiDesignCubit.notFoundError) {
    return loc?.translate('ai_design_not_found_error') ??
        'لم يعد هذا التصميم متاحاً. يرجى البدء من جديد.';
  }
  return error;
}
