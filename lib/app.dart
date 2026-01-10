import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/routes/app_routes.dart';
import 'config/themes/app_theme.dart';
import 'core/utils/app_strings.dart';
import 'features/events/presentation/cubit/events_list/events_list_cubit.dart';
import 'features/events/presentation/cubit/event_details/event_details_cubit.dart';
import 'features/events/presentation/cubit/create_event/create_event_cubit.dart';
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
        // Home is the first screen, load eagerly
        BlocProvider<HomeCubit>(
          lazy: false,
          create: (_) => di.sl<HomeCubit>()..loadHomeData(),
        ),
        // Events list is accessed from bottom nav, load eagerly
        BlocProvider<EventsListCubit>(
          lazy: false,
          create: (_) => di.sl<EventsListCubit>()..loadEvents(),
        ),
        // Lazy load - only create when event details screen is accessed
        BlocProvider<EventDetailsCubit>(
          lazy: true,
          create: (_) => di.sl<EventDetailsCubit>(),
        ),
        // Lazy load - only create when create event screen is accessed
        BlocProvider<CreateEventCubit>(
          lazy: true,
          create: (_) => di.sl<CreateEventCubit>(),
        ),
        // Lazy load - only create when venues screen is accessed
        BlocProvider<VenuesCubit>(
          lazy: true,
          create: (_) => di.sl<VenuesCubit>(),
        ),
        // Lazy load - only create when scanner screen is accessed
        BlocProvider<ScannerCubit>(
          lazy: true,
          create: (_) => di.sl<ScannerCubit>(),
        ),
        // Lazy load - only create when payment screen is accessed
        BlocProvider<PaymentCubit>(
          lazy: true,
          create: (_) => di.sl<PaymentCubit>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: kDebugMode ? DevicePreview.appBuilder : null,
        title: AppStrings.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
