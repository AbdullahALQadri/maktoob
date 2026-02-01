// Core module exports for Maktoob app.
// This barrel file exports all core utilities, widgets, and services
// for easy importing throughout the application.
//
// Usage:
// import 'package:maktoob/core/core.dart';

// =============================================================================
// UTILITIES
// =============================================================================

export 'utils/app_colors.dart';
export 'utils/app_strings.dart';
export 'utils/app_text_styles.dart';
export 'utils/app_spacing.dart';
export 'utils/app_extensions.dart';
export 'utils/responsive.dart';

// =============================================================================
// WIDGETS - ANIMATIONS
// =============================================================================

export 'widgets/animations/staggered_slide_fade.dart';

// =============================================================================
// WIDGETS - BUTTONS
// =============================================================================

export 'widgets/buttons/primary_button.dart';
export 'widgets/buttons/secondary_button.dart';
export 'widgets/buttons/gradient_button.dart';
export 'widgets/buttons/app_text_button.dart';
export 'widgets/buttons/app_icon_button.dart';

// =============================================================================
// WIDGETS - INPUTS
// =============================================================================

export 'widgets/inputs/app_text_field.dart';

// =============================================================================
// WIDGETS - CARDS
// =============================================================================

export 'widgets/cards/app_card.dart';

// =============================================================================
// WIDGETS - IMAGES
// =============================================================================

export 'widgets/images/app_image.dart';

// =============================================================================
// WIDGETS - SCAFFOLD
// =============================================================================

export 'widgets/scaffold/app_scaffold.dart';

// =============================================================================
// WIDGETS - DIALOGS
// =============================================================================

export 'widgets/dialogs/app_dialog.dart';

// =============================================================================
// WIDGETS - SHEETS
// =============================================================================

export 'widgets/sheets/app_bottom_sheet.dart';

// =============================================================================
// WIDGETS - SNACKBAR
// =============================================================================

export 'widgets/snackbar/app_snackbar.dart';

// =============================================================================
// WIDGETS - LOADING
// =============================================================================

export 'widgets/loading/app_loader.dart';
export 'widgets/loading/shimmer_loading.dart';
export 'widgets/loading/scanning_indicator.dart';
export 'widgets/loading/skeleton_widgets.dart';

// =============================================================================
// WIDGETS - NETWORK
// =============================================================================

export 'widgets/network/offline_wrapper.dart';

// =============================================================================
// ERROR HANDLING
// =============================================================================

export 'error/exceptions.dart';
export 'error/failures.dart';

// =============================================================================
// NETWORK
// =============================================================================

export 'network/network_info.dart';

// =============================================================================
// USECASES
// =============================================================================

export 'usecases/usecase.dart';

// =============================================================================
// STORAGE
// =============================================================================

export 'utils/storage/secure_storage_service.dart';
export 'utils/storage/shared_preferences.dart';

// =============================================================================
// SECURITY
// =============================================================================

export 'services/security/device_security_service.dart';
