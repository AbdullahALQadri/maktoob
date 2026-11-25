import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/staff_review_entities.dart';
import '../../domain/usecases/staff_review_usecases.dart';
import '../cubit/staff_item_cubit.dart';
import '../cubit/staff_load_cubit.dart';
import '../widgets/staff_facts.dart';
import '../widgets/staff_file_viewer.dart';
import '../widgets/staff_page.dart';
import 'staff_review_scaffold.dart';

typedef _Queue = StaffLoadCubit<List<StaffIdentity>>;

/// The identities waiting for review.
class StaffIdentitiesScreen extends StatelessWidget {
  const StaffIdentitiesScreen({super.key});

  static Route<void> route() => MaterialPageRoute(
        settings: const RouteSettings(name: '/r/staff-identities'),
        builder: (_) => BlocProvider<_Queue>(
          create: (_) => _Queue((_) => di.sl<GetStaffIdentitiesUseCase>()(const NoParams()))..load(),
          child: const StaffIdentitiesScreen(),
        ),
      );

  Future<void> _open(BuildContext context, StaffIdentity identity) async {
    final queue = context.read<_Queue>();
    await Navigator.of(context).push(StaffIdentityScreen.route(identity.id));
    await queue.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(title: Text(context.tr('staff_today_identities'))),
      body: BlocBuilder<_Queue, StaffLoadState<List<StaffIdentity>>>(
        builder: (context, state) => StaffPage<StaffIdentity>(
          state: state,
          onRefresh: context.read<_Queue>().load,
          rows: state.value ?? const [],
          emptyText: context.tr('staff_identities_empty'),
          rowBuilder: (context, identity) => StaffRowCard(
            key: Key('staff_identity_${identity.id}'),
            title: identity.nameAr.isEmpty ? (identity.clientName ?? '#${identity.id}') : identity.nameAr,
            lines: [
              identity.clientPhone,
              if (identity.documentLast4 != null) '•••• ${identity.documentLast4}',
            ],
            trailing: Icon(Icons.chevron_right, color: context.textSecondary),
            onTap: () => _open(context, identity),
          ),
        ),
      ),
    );
  }
}

/// One identity: the legal name as printed, the document, its photos.
class StaffIdentityScreen extends StatelessWidget {
  const StaffIdentityScreen({super.key});

  static Route<void> route(int id) => MaterialPageRoute(
        settings: const RouteSettings(name: '/r/staff-identity'),
        builder: (_) => BlocProvider<StaffItemCubit<StaffIdentity>>(
          create: (_) => StaffItemCubit<StaffIdentity>(
            read: di.sl<GetStaffIdentityUseCase>().call,
            review: di.sl<ReviewStaffIdentityUseCase>().call,
            id: id,
          )..load(),
          child: const StaffIdentityScreen(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return StaffReviewScaffold<StaffIdentity>(
      title: context.tr('staff_identity_title'),
      isPending: (identity) => identity.isPending,
      confirmKey: 'staff_identity_confirm',
      mustConfirmKey: 'staff_identity_match',
      builder: (context, identity) => [
        if (identity.sameIdElsewhere) StaffWarning(context.tr('staff_identity_same_id')),
        if (identity.sameNameAccounts > 0)
          StaffWarning(context.tr('staff_identity_same_name', {'count': identity.sameNameAccounts})),
        StaffFact('staff_identity_name_ar', identity.nameAr),
        StaffFact('staff_identity_name_latin', identity.nameLatin, ltr: true),
        StaffFact('staff_fact_client', identity.clientName),
        StaffFact('staff_fact_phone', identity.clientPhone, ltr: true),
        StaffFact(
          'staff_identity_document',
          [
            if (identity.documentType != null) context.tr('staff_document_${identity.documentType}'),
            ?identity.documentCountry,
            if (identity.documentLast4 != null) '•••• ${identity.documentLast4}',
          ].join(' · '),
        ),
        StaffFact('staff_identity_birth', identity.birthDate, ltr: true),
        StaffFact('staff_identity_expires', identity.expiresOn, ltr: true),
        if (!identity.isPending) StaffFact('staff_fact_decision', identity.rejectionReason),
        const SizedBox(height: 8),
        Text(
          context.tr('staff_identity_photos'),
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: context.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          context.tr('staff_identity_photos_note'),
          style: TextStyle(fontSize: 12.5, height: 1.5, color: context.textSecondary),
        ),
        const SizedBox(height: 10),
        for (final (side, has) in [('front', identity.hasFront), ('back', identity.hasBack)])
          if (has)
            StaffFileButton(
              key: Key('staff_identity_$side'),
              label: context.tr('staff_identity_$side'),
              onOpen: () => showStaffFile(
                context,
                StaffFile.identity(identity.id, side),
                title: context.tr('staff_identity_$side'),
              ),
            ),
      ],
    );
  }
}
