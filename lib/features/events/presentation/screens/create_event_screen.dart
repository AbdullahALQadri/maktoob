import 'dart:io';

import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
import '../../data/models/event_models.dart';
import '../widgets/step_header_widget.dart';
import '../widgets/package_card_widget.dart';
import '../widgets/venue_card_widget.dart';
import '../widgets/event_type_card_widget.dart';
import '../widgets/template_card_widget.dart';
import '../widgets/event_details_widget.dart';
import '../widgets/guest_method_widget.dart';
import '../widgets/summary_widget.dart';

class CreateEventScreen extends StatefulWidget {
  final Function(String eventId)? onComplete;

  const CreateEventScreen({super.key, this.onComplete});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  int _currentStep = 1;
  static const int _totalSteps = 7;

  // Step 1: Package
  String? _selectedPackage;

  // Step 2: Venue
  String? _selectedVenue;
  bool _showCustomVenue = false;
  CustomVenue _customVenue = CustomVenue();

  // Step 3: Event Type
  String? _selectedEventType;
  bool _showCustomEventType = false;
  String _customEventType = '';

  // Step 4: Template
  String? _selectedTemplate;
  bool _requestCustomTemplate = false;

  // Step 5: Event Details
  EventDetails _eventDetails = EventDetails();

  // Step 6: Guests
  GuestMethod? _guestMethod;
  List<GuestInfo> _manualGuests = [];
  GuestInfo _currentGuest = GuestInfo();
  File? _excelFile;

  // Data
  final List<PackageModel> _packages = [
    PackageModel(
      id: 'silver',
      name: 'Silver',
      price: '299',
      invitations: 100,
      features: ['Basic Templates', 'WhatsApp Delivery', 'QR Code Check-in', 'Email Support'],
      gradientColors: [AppColors.gray400, AppColors.gray500],
      icon: Icons.auto_awesome,
    ),
    PackageModel(
      id: 'gold',
      name: 'Gold',
      price: '599',
      invitations: 300,
      features: ['Premium Templates', 'WhatsApp + SMS', 'QR Code Check-in', 'Analytics Dashboard', 'Priority Support'],
      gradientColors: [AppColors.yellow400, AppColors.amber500],
      icon: Icons.flash_on,
      recommended: true,
    ),
    PackageModel(
      id: 'platinum',
      name: 'Platinum',
      price: '999',
      invitations: -1, // Unlimited
      features: ['Custom Templates', 'All Channels', 'Advanced Analytics', 'Custom Branding', '24/7 Support', 'API Access'],
      gradientColors: [AppColors.purple500, AppColors.pink500],
      icon: Icons.workspace_premium,
    ),
  ];

  final List<VenueModel> _venues = [
    const VenueModel(id: '1', name: 'Grand Hotel Ballroom', capacity: 300, icon: '🏨'),
    const VenueModel(id: '2', name: 'Convention Center', capacity: 500, icon: '🏢'),
    const VenueModel(id: '3', name: 'Beach Resort', capacity: 150, icon: '🏖️'),
    const VenueModel(id: '4', name: 'University Hall', capacity: 400, icon: '🎓'),
  ];

  final List<EventTypeModel> _eventTypes = [
    EventTypeModel(id: 'wedding', name: 'Wedding', icon: '💒', gradientColors: [AppColors.pink500, AppColors.rose500]),
    EventTypeModel(id: 'corporate', name: 'Corporate', icon: '🏢', gradientColors: [AppColors.blue500, AppColors.cyan500]),
    EventTypeModel(id: 'birthday', name: 'Birthday', icon: '🎂', gradientColors: [AppColors.amber500, AppColors.orange500]),
    EventTypeModel(id: 'graduation', name: 'Graduation', icon: '🎓', gradientColors: [AppColors.green600, AppColors.emerald500]),
    EventTypeModel(id: 'conference', name: 'Conference', icon: '🎤', gradientColors: [AppColors.purple500, AppColors.indigo500]),
    EventTypeModel(id: 'charity', name: 'Charity', icon: '❤️', gradientColors: [AppColors.red500, AppColors.pink500]),
  ];

  final List<TemplateModel> _templates = [
    TemplateModel(id: 'elegant', name: 'Elegant Gold', preview: '✨', gradientColors: [AppColors.amber600, AppColors.amber600]),
    TemplateModel(id: 'modern', name: 'Modern Minimal', preview: '▫️', gradientColors: [AppColors.gray700, AppColors.gray900]),
    TemplateModel(id: 'floral', name: 'Floral Dream', preview: '🌸', gradientColors: [AppColors.pink500, AppColors.rose500]),
    TemplateModel(id: 'classic', name: 'Classic White', preview: '⬜', gradientColors: [AppColors.gray100, AppColors.gray300]),
    TemplateModel(id: 'luxury', name: 'Luxury Black', preview: '⬛', gradientColors: [AppColors.black, AppColors.gray700]),
    TemplateModel(id: 'colorful', name: 'Colorful Joy', preview: '🎨', gradientColors: [AppColors.purple500, AppColors.pink500]),
  ];

  int get _packageLimit {
    final pkg = _packages.firstWhere(
      (p) => p.id == _selectedPackage,
      orElse: () => _packages.first,
    );
    return pkg.invitations;
  }

  bool get _canProceedStep1 => _selectedPackage != null;
  bool get _canProceedStep2 => _selectedVenue != null || (_showCustomVenue && _customVenue.isValid);
  bool get _canProceedStep3 => _selectedEventType != null || (_showCustomEventType && _customEventType.isNotEmpty);
  bool get _canProceedStep4 => _selectedTemplate != null || _requestCustomTemplate;
  bool get _canProceedStep5 => _eventDetails.isValid;
  bool get _canProceedStep6 => _guestMethod != null;

  bool get _canProceed {
    switch (_currentStep) {
      case 1: return _canProceedStep1;
      case 2: return _canProceedStep2;
      case 3: return _canProceedStep3;
      case 4: return _canProceedStep4;
      case 5: return _canProceedStep5;
      case 6: return _canProceedStep6;
      case 7: return true;
      default: return false;
    }
  }

  void _handleNext() {
    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
    }
  }

  void _handleBack() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  void _handleSaveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event saved as draft!')),
    );
  }

  void _handleSubmit() {
    widget.onComplete?.call('event-123');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event submitted successfully!')),
    );
  }

  void _handleAddGuest() {
    final packageLimit = _packageLimit;
    final currentGuestCount = _manualGuests.length;

    if (packageLimit != -1 && currentGuestCount >= packageLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have reached your package limit of $packageLimit guests!')),
      );
      return;
    }

    if (_currentGuest.isValid) {
      setState(() {
        _manualGuests.add(_currentGuest.copy());
        _currentGuest = GuestInfo();
      });
    }
  }

  void _handleRemoveGuest(int index) {
    setState(() {
      _manualGuests.removeAt(index);
    });
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return PackageSelectionWidget(
          packages: _packages,
          selectedPackage: _selectedPackage,
          onPackageSelected: (id) => setState(() => _selectedPackage = id),
        );
      case 2:
        return VenueSelectionWidget(
          venues: _venues,
          selectedVenue: _selectedVenue,
          showCustomVenue: _showCustomVenue,
          customVenue: _customVenue,
          onVenueSelected: (id) => setState(() {
            _selectedVenue = id;
            _showCustomVenue = false;
          }),
          onToggleCustomVenue: () => setState(() {
            _showCustomVenue = !_showCustomVenue;
            _selectedVenue = null;
          }),
          onCustomVenueChanged: (venue) => setState(() => _customVenue = venue),
        );
      case 3:
        return EventTypeSelectionWidget(
          eventTypes: _eventTypes,
          selectedEventType: _selectedEventType,
          showCustomEventType: _showCustomEventType,
          customEventType: _customEventType,
          onEventTypeSelected: (id) => setState(() {
            _selectedEventType = id;
            _showCustomEventType = false;
          }),
          onToggleCustomEventType: () => setState(() {
            _showCustomEventType = !_showCustomEventType;
            _selectedEventType = null;
          }),
          onCustomEventTypeChanged: (value) => setState(() => _customEventType = value),
        );
      case 4:
        return TemplateSelectionWidget(
          templates: _templates,
          selectedTemplate: _selectedTemplate,
          requestCustomTemplate: _requestCustomTemplate,
          onTemplateSelected: (id) => setState(() {
            _selectedTemplate = id;
            _requestCustomTemplate = false;
          }),
          onToggleCustomTemplate: () => setState(() {
            _requestCustomTemplate = !_requestCustomTemplate;
            _selectedTemplate = null;
          }),
        );
      case 5:
        return EventDetailsWidget(
          eventDetails: _eventDetails,
          onDetailsChanged: (details) => setState(() => _eventDetails = details),
        );
      case 6:
        return GuestMethodWidget(
          packageLimit: _packageLimit,
          guestMethod: _guestMethod,
          manualGuests: _manualGuests,
          currentGuest: _currentGuest,
          excelFile: _excelFile,
          onGuestMethodSelected: (method) => setState(() => _guestMethod = method),
          onAddGuest: _handleAddGuest,
          onRemoveGuest: _handleRemoveGuest,
          onCurrentGuestChanged: (guest) => setState(() => _currentGuest = guest),
          onExcelFileSelected: (file) => setState(() => _excelFile = file),
        );
      case 7:
        return SummaryWidget(
          selectedPackage: _packages.firstWhere(
            (p) => p.id == _selectedPackage,
            orElse: () => _packages.first,
          ),
          selectedVenue: _selectedVenue != null
              ? _venues.firstWhere((v) => v.id == _selectedVenue)
              : null,
          customVenue: _showCustomVenue ? _customVenue : null,
          selectedEventType: _selectedEventType != null
              ? _eventTypes.firstWhere((t) => t.id == _selectedEventType)
              : null,
          customEventType: _showCustomEventType ? _customEventType : null,
          selectedTemplate: _selectedTemplate != null
              ? _templates.firstWhere((t) => t.id == _selectedTemplate)
              : null,
          requestCustomTemplate: _requestCustomTemplate,
          eventDetails: _eventDetails,
          guestMethod: _guestMethod,
          manualGuests: _manualGuests,
          excelFile: _excelFile,
        );
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: Column(
        children: [
          StepHeaderWidget(
            currentStep: _currentStep,
            totalSteps: _totalSteps,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildStepContent(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _currentStep == _totalSteps
              ? Row(
                  children: [
                    Expanded(
                      child: _buildButton(
                        'Save as Draft',
                        onTap: _handleSaveDraft,
                        isPrimary: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildButton(
                        'Submit & Pay',
                        onTap: _handleSubmit,
                        isPrimary: true,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    if (_currentStep > 1)
                      Container(
                        width: 56,
                        height: 56,
                        margin: const EdgeInsets.only(right: 12),
                        child: Material(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _handleBack,
                            child: Icon(
                              Icons.arrow_back,
                              color: AppColors.gray700,
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: _buildButton(
                        'Continue',
                        onTap: _canProceed ? _handleNext : null,
                        isPrimary: true,
                        trailing: Icons.arrow_forward,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildButton(
    String text, {
    VoidCallback? onTap,
    bool isPrimary = true,
    IconData? trailing,
  }) {
    final enabled = onTap != null;

    return Material(
      color: enabled
          ? (isPrimary ? null : AppColors.gray200)
          : AppColors.gray200,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 56,
          decoration: enabled && isPrimary
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [AppColors.purple600, AppColors.pink600],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.purple600.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                )
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: enabled
                      ? (isPrimary ? Colors.white : AppColors.gray700)
                      : AppColors.gray400,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                Icon(
                  trailing,
                  color: enabled ? Colors.white : AppColors.gray400,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
