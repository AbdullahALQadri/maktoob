import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/core.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/usecases/billing_usecases.dart';

/// Opens the sheet that prepares a pro-forma invoice for a funder or a head
/// office, before the event is paid.
Future<void> showProformaSheet(BuildContext context, {required String eventId}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => ProformaSheet(eventId: eventId, getProformaUrl: di.sl<GetProformaUrlUseCase>()),
  );
}

class ProformaSheet extends StatefulWidget {
  const ProformaSheet({super.key, required this.eventId, required this.getProformaUrl, this.open});

  final String eventId;
  final GetProformaUrlUseCase getProformaUrl;

  /// Opens the link (the browser by default; replaced in tests).
  final Future<bool> Function(Uri url)? open;

  @override
  State<ProformaSheet> createState() => _ProformaSheetState();
}

class _ProformaSheetState extends State<ProformaSheet> {
  final _funder = TextEditingController();
  final _reference = TextEditingController();
  bool _busy = false;
  bool _failed = false;

  @override
  void dispose() {
    _funder.dispose();
    _reference.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    setState(() {
      _busy = true;
      _failed = false;
    });
    final result = await widget.getProformaUrl(ProformaParams(
      eventId: widget.eventId,
      funder: _funder.text.trim(),
      reference: _reference.text.trim(),
    ));
    final uri = result.fold((_) => null, Uri.tryParse);
    final launch = widget.open ?? (Uri url) => launchUrl(url, mode: LaunchMode.externalApplication);
    final opened = uri != null && await launch(uri);
    if (!mounted) return;
    if (opened) return Navigator.of(context).pop();
    setState(() {
      _busy = false;
      _failed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final optional = context.tr('proforma_optional');
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.tr('proforma_title'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: context.textPrimary),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('proforma_funder'),
              controller: _funder,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: context.tr('proforma_funder'), helperText: optional),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('proforma_reference'),
              controller: _reference,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(labelText: context.tr('proforma_reference'), helperText: optional),
            ),
            if (_failed) ...[
              const SizedBox(height: 12),
              Text(
                context.tr('proforma_failed'),
                key: const Key('proforma_failed'),
                style: const TextStyle(fontSize: 13, color: AppColors.red500),
              ),
            ],
            const SizedBox(height: 16),
            PrimaryButton(
              key: const Key('proforma_open'),
              text: context.tr('proforma_open'),
              icon: Icons.description_outlined,
              isLoading: _busy,
              onPressed: _busy ? null : _open,
            ),
          ],
        ),
      ),
    );
  }
}
