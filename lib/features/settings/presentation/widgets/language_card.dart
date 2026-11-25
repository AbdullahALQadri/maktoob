import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/l10n_context.dart';
import '../../../../core/widgets/page/page_kit.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

/// The app's language: each one named in its own words, the chosen one ticked.
class LanguageCard extends StatelessWidget {
  const LanguageCard({super.key});

  static const _languages = [
    (AppLanguage.ar, 'العربية', 'Arabic'),
    (AppLanguage.en, 'English', 'الإنجليزية'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) => PageCard.rows(
        title: context.tr('settings_language'),
        rows: [
          for (final (language, name, other) in _languages)
            PageRow(
              key: Key('language_${language.name}'),
              icon: Icons.language,
              title: name,
              subtitle: other,
              selected: state.language == language,
              onTap: () => context.read<SettingsCubit>().setLanguage(language),
            ),
        ],
      ),
    );
  }
}
