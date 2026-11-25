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

typedef _Queue = StaffLoadCubit<List<StaffInstitution>>;

/// The institutions waiting for approval.
class StaffInstitutionsScreen extends StatelessWidget {
  const StaffInstitutionsScreen({super.key});

  static Route<void> route() => MaterialPageRoute(
        settings: const RouteSettings(name: '/r/staff-institutions'),
        builder: (_) => BlocProvider<_Queue>(
          create: (_) => _Queue((_) => di.sl<GetStaffInstitutionsUseCase>()(const NoParams()))..load(),
          child: const StaffInstitutionsScreen(),
        ),
      );

  Future<void> _open(BuildContext context, StaffInstitution institution) async {
    final queue = context.read<_Queue>();
    await Navigator.of(context).push(StaffInstitutionScreen.route(institution.id));
    await queue.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(title: Text(context.tr('staff_today_institutions'))),
      body: BlocBuilder<_Queue, StaffLoadState<List<StaffInstitution>>>(
        builder: (context, state) => StaffPage<StaffInstitution>(
          state: state,
          onRefresh: context.read<_Queue>().load,
          rows: state.value ?? const [],
          emptyText: context.tr('staff_institutions_empty'),
          rowBuilder: (context, institution) => StaffRowCard(
            key: Key('staff_institution_${institution.id}'),
            title: institution.name,
            lines: [institution.ownerName, institution.ownerPhone],
            trailing: Icon(Icons.chevron_right, color: context.textSecondary),
            onTap: () => _open(context, institution),
          ),
        ),
      ),
    );
  }
}

/// One institution: its official details, what approval still needs, and
/// the documents it sent.
class StaffInstitutionScreen extends StatelessWidget {
  const StaffInstitutionScreen({super.key});

  static Route<void> route(int id) => MaterialPageRoute(
        settings: const RouteSettings(name: '/r/staff-institution'),
        builder: (_) => BlocProvider<StaffItemCubit<StaffInstitution>>(
          create: (_) => StaffItemCubit<StaffInstitution>(
            read: di.sl<GetStaffInstitutionUseCase>().call,
            review: di.sl<ReviewStaffInstitutionUseCase>().call,
            id: id,
          )..load(),
          child: const StaffInstitutionScreen(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return StaffReviewScaffold<StaffInstitution>(
      title: context.tr('staff_institution_title'),
      isPending: (institution) => institution.isPending,
      confirmKey: 'staff_institution_confirm',
      builder: (context, institution) => [
        StaffFact('staff_institution_name', institution.nameAr),
        StaffFact('staff_institution_name_en', institution.nameEn, ltr: true),
        StaffFact('staff_institution_trade', institution.tradeName),
        StaffFact('staff_institution_legal', institution.legalForm),
        StaffFact(
          'staff_institution_registration',
          [?institution.registrationNumber, ?institution.registrationCountry].join(' · '),
          ltr: true,
        ),
        StaffFact('staff_institution_owner', institution.ownerName),
        StaffFact('staff_fact_phone', institution.ownerPhone, ltr: true),
        StaffFact('staff_institution_role', institution.representativeRole),
        if (!institution.isPending) StaffFact('staff_fact_decision', institution.rejectionReason),
        const SizedBox(height: 8),
        Text(
          context.tr('staff_institution_checklist'),
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: context.textPrimary),
        ),
        const SizedBox(height: 8),
        for (final entry in institution.checklist.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Icon(
                  entry.value ? Icons.check_circle : Icons.cancel_outlined,
                  size: 18,
                  color: entry.value ? AppColors.green600 : AppColors.red500,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.tr('staff_check_${entry.key}'),
                    style: TextStyle(fontSize: 14, color: context.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Text(
          context.tr('staff_institution_documents'),
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: context.textPrimary),
        ),
        const SizedBox(height: 8),
        if (institution.documents.isEmpty)
          Text(context.tr('staff_institution_no_documents'), style: TextStyle(color: context.textSecondary)),
        for (final document in institution.documents)
          StaffFileButton(
            key: Key('staff_document_${document.id}'),
            icon: document.isImage ? Icons.image_outlined : Icons.description_outlined,
            label: document.name,
            onOpen: () => showStaffFile(
              context,
              StaffFile.institution(institution.id, document.id),
              title: document.name,
            ),
          ),
      ],
    );
  }
}
