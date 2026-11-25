import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/loading/mk_spinner.dart';
import '../../../../injection_container.dart' as di;
import '../cubit/staff_session_cubit.dart';
import 'staff_login_screen.dart';
import 'staff_shell.dart';

/// The way into the staff mode: the sign-in kept on this phone, else the
/// sign-in screen. Leaving it goes back to where the app was.
class StaffGate extends StatelessWidget {
  const StaffGate({super.key, this.onExit});

  /// Leaves the staff mode from its sign-in screen. Null when the gate is a
  /// page of its own (Back does it).
  final VoidCallback? onExit;

  /// The gate with its own session, for the app's entry on a staff phone.
  static Widget embedded({required VoidCallback onExit}) => BlocProvider(
        create: (_) => di.sl<StaffSessionCubit>()..open(),
        child: StaffGate(onExit: onExit),
      );

  static Route<void> route() => MaterialPageRoute(
        settings: const RouteSettings(name: '/r/staff'),
        builder: (_) => BlocProvider(
          create: (_) => di.sl<StaffSessionCubit>()..open(),
          child: const StaffGate(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StaffSessionCubit, StaffSessionState>(
      builder: (context, state) {
        if (state.checking) {
          return Scaffold(backgroundColor: context.scaffoldBg, body: const Center(child: MkSpinner()));
        }
        return state.user == null ? StaffLoginScreen(onExit: onExit) : StaffShell(user: state.user!);
      },
    );
  }
}
