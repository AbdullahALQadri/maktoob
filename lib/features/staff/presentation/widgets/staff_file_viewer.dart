import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/loading/mk_spinner.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/usecases/staff_review_usecases.dart';

/// Opens a private file of a review (an ID photo, a certificate) full
/// screen. It is fetched when asked for, shown from memory and gone when
/// the page closes; the server records who opened an ID photo.
Future<void> showStaffFile(BuildContext context, StaffFile file, {required String title, OpenStaffFileUseCase? open}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => StaffFileViewer(file: file, title: title, open: open ?? di.sl<OpenStaffFileUseCase>()),
    ),
  );
}

class StaffFileViewer extends StatefulWidget {
  const StaffFileViewer({super.key, required this.file, required this.title, required this.open});

  final StaffFile file;
  final String title;
  final OpenStaffFileUseCase open;

  @override
  State<StaffFileViewer> createState() => _StaffFileViewerState();
}

class _StaffFileViewerState extends State<StaffFileViewer> {
  Uint8List? _bytes;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    final result = await widget.open(widget.file);
    if (!mounted) return;
    setState(() {
      _bytes = result.fold((_) => null, (bytes) => bytes);
      _failed = _bytes == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _bytes;
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: _failed
            ? OutlinedButton(onPressed: _load, child: Text(context.tr('common_retry')))
            : bytes == null
                ? const MkSpinner()
                : InteractiveViewer(
                    maxScale: 6,
                    child: Image.memory(
                      bytes,
                      fit: BoxFit.contain,
                      // A PDF or a damaged file: say so instead of a broken picture.
                      errorBuilder: (context, _, _) => Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          context.tr('staff_file_not_image'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.white, fontSize: 15, height: 1.6),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
