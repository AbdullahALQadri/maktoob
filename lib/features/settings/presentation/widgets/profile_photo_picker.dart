import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/core.dart';
import '../../../authentication/domain/entities/user_entity.dart';
import '../cubit/profile_cubit.dart';

/// The profile photo with a way to change it: from the gallery, with the
/// camera, or removed. The change is saved at once, before the form.
class ProfilePhotoPicker extends StatelessWidget {
  const ProfilePhotoPicker({super.key, required this.user, required this.enabled});

  final UserEntity user;
  final bool enabled;

  Future<void> _choose(BuildContext context) async {
    final cubit = context.read<ProfileCubit>();
    final hasPhoto = (user.avatar ?? '').isNotEmpty;
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(context.tr('edit_profile_photo_gallery')),
              onTap: () => Navigator.pop(sheet, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(context.tr('edit_profile_photo_camera')),
              onTap: () => Navigator.pop(sheet, 'camera'),
            ),
            if (hasPhoto)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: AppColors.red500),
                title: Text(
                  context.tr('edit_profile_photo_remove'),
                  style: const TextStyle(color: AppColors.red500),
                ),
                onTap: () => Navigator.pop(sheet, 'remove'),
              ),
          ],
        ),
      ),
    );
    if (choice == null) return;
    if (choice == 'remove') return cubit.removeAvatar();
    final picked = await ImagePicker().pickImage(
      source: choice == 'camera' ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.front,
    );
    if (picked != null) await cubit.uploadAvatar(picked.path);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppAvatar(
          imageUrl: user.avatar,
          initials: user.initials,
          size: 72,
          backgroundColor: context.primaryWash,
          textColor: context.primaryText,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            key: const Key('edit_profile_photo'),
            onPressed: enabled ? () => _choose(context) : null,
            icon: const Icon(Icons.photo_camera_outlined, size: 18),
            label: Text(context.tr('edit_profile_change_photo'), maxLines: 1, overflow: TextOverflow.ellipsis),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          ),
        ),
      ],
    );
  }
}
