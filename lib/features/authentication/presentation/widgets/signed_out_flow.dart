import 'package:flutter/material.dart';

import '../../../../core/services/pending_wizard_intent_service.dart';
import '../../../explore/presentation/screens/explore_screen.dart';
import '../../../scanner/domain/entities/door_entities.dart';
import '../../../scanner/presentation/screens/door_staff_entry_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';

enum SignedOutPage { explore, login, register }

/// Before signing in: browse occasions and designs without an account, then
/// sign in or sign up when the host wants to create something. Back from
/// sign-in or sign-up returns to browsing when the host came from there.
class SignedOutFlow extends StatefulWidget {
  const SignedOutFlow({
    super.key,
    required this.intents,
    required this.onAuthSuccess,
    required this.onStaffSession,
    this.start = SignedOutPage.explore,
  });

  /// A design picked while browsing, continued in the wizard after sign-up.
  final PendingWizardIntentService intents;
  final VoidCallback onAuthSuccess;

  /// A staff phone joined a door (door code, scanner account or venue hub).
  final ValueChanged<DoorSession> onStaffSession;
  final SignedOutPage start;

  @override
  State<SignedOutFlow> createState() => _SignedOutFlowState();
}

class _SignedOutFlowState extends State<SignedOutFlow> {
  late var _page = widget.start;
  var _cameFromExplore = false;

  void _go(SignedOutPage page) {
    setState(() {
      if (page == SignedOutPage.explore) {
        _cameFromExplore = false;
      } else if (_page == SignedOutPage.explore) {
        _cameFromExplore = true;
      }
      _page = page;
    });
  }

  void _openDoorStaff() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (route) => DoorStaffEntryScreen(
          onSession: (session) {
            Navigator.of(route).pop();
            widget.onStaffSession(session);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final page = switch (_page) {
      SignedOutPage.explore => ExploreScreen(
        onStartTap: () {
          // A plain "start" drops any earlier design pick.
          widget.intents.clear();
          _go(SignedOutPage.register);
        },
        onLoginTap: () => _go(SignedOutPage.login),
        onDesignTap: (eventTypeId, templateId) {
          widget.intents.set(PendingWizardIntent(eventTypeId: eventTypeId, templateId: templateId));
          _go(SignedOutPage.register);
        },
      ),
      SignedOutPage.register => RegisterScreen(
        onLoginTap: () => _go(SignedOutPage.login),
        onRegisterSuccess: widget.onAuthSuccess,
      ),
      SignedOutPage.login => LoginScreen(
        onRegisterTap: () => _go(SignedOutPage.register),
        onLoginSuccess: widget.onAuthSuccess,
        onBrowseTap: () => _go(SignedOutPage.explore),
        onDoorStaffTap: _openDoorStaff,
      ),
    };
    if (!_cameFromExplore) return page;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _go(SignedOutPage.explore);
      },
      child: page,
    );
  }
}
