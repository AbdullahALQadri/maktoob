import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

/// Language selection card widget.
class LanguageCard extends StatelessWidget {
  const LanguageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return AppCard.elevated(
          elevation: 2,
          child: Column(
            children: [
              _LanguageOption(
                title: 'العربية',
                subtitle: 'Arabic',
                isSelected: state.language == AppLanguage.ar,
                onTap: () => context.read<SettingsCubit>().setLanguage(AppLanguage.ar),
              ),
              Divider(color: AppColors.gray100, height: context.dynamicHeight(0.02)),
              _LanguageOption(
                title: 'English',
                subtitle: 'الإنجليزية',
                isSelected: state.language == AppLanguage.en,
                onTap: () => context.read<SettingsCubit>().setLanguage(AppLanguage.en),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: context.dynamicHeight(0.015),
          horizontal: context.dynamicWidth(0.021),
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purple50 : Colors.transparent,
          borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
        ),
        child: Row(
          children: [
            _LanguageIcon(isSelected: isSelected),
            SizedBox(width: context.dynamicWidth(0.04)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: isSelected ? AppColors.primaryColor : AppColors.gray900,
                    ),
                  ),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            if (isSelected) const _CheckIcon(),
          ],
        ),
      ),
    );
  }
}

class _LanguageIcon extends StatelessWidget {
  final bool isSelected;

  const _LanguageIcon({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.dynamicWidth(0.12),
      height: context.dynamicWidth(0.12),
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [AppColors.primaryColor, AppColors.tertiaryColor],
              )
            : null,
        color: isSelected ? null : AppColors.gray100,
        borderRadius: BorderRadius.circular(context.dynamicWidth(0.029)),
      ),
      child: Icon(
        Icons.language,
        color: isSelected ? Colors.white : AppColors.gray400,
        size: context.dynamicWidth(0.061),
      ),
    );
  }
}

class _CheckIcon extends StatelessWidget {
  const _CheckIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.dynamicWidth(0.061),
      height: context.dynamicWidth(0.061),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryColor, AppColors.tertiaryColor],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check,
        color: Colors.white,
        size: context.dynamicWidth(0.035),
      ),
    );
  }
}
