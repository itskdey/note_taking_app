import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_taking_app/core/localization/translation_service.dart';
import 'package:note_taking_app/core/theme/theme_service.dart';
import 'package:note_taking_app/core/values/app_colors.dart';
import 'package:note_taking_app/core/values/app_fonts.dart';
import 'package:note_taking_app/widget/animation/animated_widget.dart';
import 'package:note_taking_app/widget/app_bar/app_bar_custom.dart';

part 'setting_screen_binding.dart';
part 'setting_screen_controller.dart';

class SettingScreenView extends GetView<SettingScreenViewController> {
  const SettingScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBarCustom(
        title: 'settings_title',
        upText: 'komnottra.setting',
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
          children: [
            _SettingsSection(
              title: 'settings_preferences',
              delay: 150,
              children: [
                Obx(
                  () => _SettingsTile(
                    icon: Icons.dark_mode_outlined,
                    iconColor: AppColors.honey,
                    title: 'dark_mode',
                    subtitle: 'dark_mode_subtitle',
                    trailing: Switch.adaptive(
                      value: controller.isDarkMode.value,
                      activeTrackColor: AppColors.accent,
                      onChanged: controller.setDarkMode,
                    ),
                    onTap: () =>
                        controller.setDarkMode(!controller.isDarkMode.value),
                  ),
                ),
                _SettingsDivider(colors: colors),
                Obx(
                  () => _SettingsTile(
                    icon: Icons.translate_rounded,
                    iconColor: AppColors.sage,
                    title: 'language',
                    subtitle: 'language_subtitle',
                    value: controller.languageLabel,
                    onTap: () => _showLanguageSheet(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _SettingsSection(
              title: 'settings_diary',
              delay: 220,
              children: [
                const _SettingsTile(
                  icon: Icons.cloud_done_outlined,
                  iconColor: AppColors.sage,
                  title: 'settings_autosave',
                  subtitle: 'settings_autosave_subtitle',
                  valueKey: 'settings_on',
                ),
                _SettingsDivider(colors: colors),
                const _SettingsTile(
                  icon: Icons.mic_none_rounded,
                  iconColor: AppColors.accent,
                  title: 'settings_voice_notes',
                  subtitle: 'settings_voice_notes_subtitle',
                  valueKey: 'settings_ready',
                ),
                _SettingsDivider(colors: colors),
                const _SettingsTile(
                  icon: Icons.lock_outline_rounded,
                  iconColor: AppColors.primaryColor,
                  title: 'settings_private',
                  subtitle: 'settings_private_subtitle',
                ),
              ],
            ),
            const SizedBox(height: 22),
            _SettingsSection(
              title: 'about_title',
              delay: 290,
              children: [
                _SettingsTile(
                  icon: Icons.shield_outlined,
                  iconColor: AppColors.sage,
                  title: 'privacy_policy',
                  subtitle: 'privacy_policy_subtitle',
                  onTap: () => _showInformationSheet(
                    context,
                    icon: Icons.shield_outlined,
                    titleKey: 'privacy_policy',
                    bodyKey: 'settings_privacy_body',
                  ),
                ),
                _SettingsDivider(colors: colors),
                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: AppColors.accent,
                  title: 'settings_about_app',
                  subtitle: 'settings_about_app_subtitle',
                  onTap: () => _showInformationSheet(
                    context,
                    icon: Icons.auto_stories_outlined,
                    titleKey: 'settings_about_app',
                    bodyKey: 'settings_about_body',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Text(
              'settings_version'.trParams({'version': '0.1.0'}),
              textAlign: TextAlign.center,
              style: AppFonts.appStyle(
                fontSize: 11,
                color: colors.onSurface.withValues(alpha: 0.42),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    Get.bottomSheet<void>(
      SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.outline.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'settings_choose_language'.tr,
                style: AppFonts.appStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 14),
              Obx(
                () => Column(
                  children: [
                    _LanguageOption(
                      label: 'English',
                      nativeLabel: 'English',
                      selected: controller.languageCode.value == 'en',
                      onTap: () {
                        controller.setLanguage('en');
                        Get.back<void>();
                      },
                    ),
                    const SizedBox(height: 8),
                    _LanguageOption(
                      label: 'Khmer',
                      nativeLabel: 'ភាសាខ្មែរ',
                      selected: controller.languageCode.value == 'km',
                      onTap: () {
                        controller.setLanguage('km');
                        Get.back<void>();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: colors.surface,
      isScrollControlled: true,
    );
  }

  void _showInformationSheet(
    BuildContext context, {
    required IconData icon,
    required String titleKey,
    required String bodyKey,
  }) {
    final colors = Theme.of(context).colorScheme;
    Get.bottomSheet<void>(
      SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.outline.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(icon, color: AppColors.accent, size: 27),
              ),
              const SizedBox(height: 16),
              Text(
                titleKey.tr,
                textAlign: TextAlign.center,
                style: AppFonts.appStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                bodyKey.tr,
                textAlign: TextAlign.center,
                style: AppFonts.appStyle(
                  fontSize: 14,
                  height: 1.55,
                  color: colors.onSurface.withValues(alpha: 0.62),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: colors.surface,
      isScrollControlled: true,
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
    required this.delay,
  });

  final String title;
  final List<Widget> children;
  final int delay;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return CustomAnimatedWidget(
      delay: delay,
      from: SlideFrom.bottom,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5, bottom: 9),
            child: Text(
              title.tr,
              style: AppFonts.appStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
                color: colors.onSurface.withValues(alpha: 0.52),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.value,
    this.valueKey,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final String? value;
  final String? valueKey;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final resolvedValue = value ?? valueKey?.tr;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.tr,
                      style: AppFonts.appStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle.tr,
                      style: AppFonts.appStyle(
                        fontSize: 11.5,
                        color: colors.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else ...[
                if (resolvedValue != null)
                  Text(
                    resolvedValue,
                    style: AppFonts.appStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                if (onTap != null) ...[
                  const SizedBox(width: 5),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: colors.onSurface.withValues(alpha: 0.3),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.7,
      indent: 67,
      color: colors.outline.withValues(alpha: 0.45),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.nativeLabel,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String nativeLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selected
          ? AppColors.accent.withValues(alpha: 0.1)
          : colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.accent
                      : colors.onSurface.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  label.substring(0, 2).toUpperCase(),
                  style: AppFonts.appStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : colors.onSurface,
                    keepEnglish: true,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  nativeLabel,
                  style: AppFonts.appStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 21,
                height: 21,
                decoration: BoxDecoration(
                  color: selected ? AppColors.accent : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.accent : colors.outline,
                    width: 1.5,
                  ),
                ),
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
