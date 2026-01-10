import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/routes/app_routes.dart';
import 'config/themes/app_theme.dart';
import 'core/utils/app_strings.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/payment/presentation/cubit/payment_cubit.dart';
import 'features/scanner/presentation/cubit/scanner_cubit.dart';
import 'features/venues/presentation/cubit/venues_cubit.dart';
import 'injection_container.dart' as di;

class Maktoob extends StatelessWidget {
  const Maktoob({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>(
          create: (_) => di.sl<HomeCubit>()..loadHomeData(),
        ),
        BlocProvider<VenuesCubit>(
          create: (_) => di.sl<VenuesCubit>()..loadVenues(),
        ),
        BlocProvider<ScannerCubit>(
          create: (_) => di.sl<ScannerCubit>()..loadGuestList(),
        ),
        BlocProvider<PaymentCubit>(
          create: (_) => di.sl<PaymentCubit>()..loadBankDetails(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: DevicePreview.appBuilder,
        title: AppStrings.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
