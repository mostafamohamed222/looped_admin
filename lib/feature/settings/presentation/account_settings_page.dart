import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:looped_admin/feature/settings/cubit/app_locale_cubit.dart';
import 'package:looped_admin/feature/settings/widget/account_settings_app_bar.dart';
import 'package:looped_admin/feature/settings/widget/account_settings_colors.dart';
import 'package:looped_admin/feature/settings/widget/account_settings_title_block.dart';
import 'package:looped_admin/feature/settings/widget/assistant_learning_card.dart';
import 'package:looped_admin/feature/settings/widget/language_preferences_card.dart';
import 'package:looped_admin/feature/settings/widget/notification_settings_card.dart';
import 'package:looped_admin/feature/settings/widget/profile_settings_card.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _jobTitleController;

  bool _notifyEmail = true;
  bool _notifyBrowser = true;
  bool _notifyAi = false;

  void _resetNotificationDefaults() {
    setState(() {
      _notifyEmail = true;
      _notifyBrowser = true;
      _notifyAi = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: 'أحمد منصور');
    _emailController = TextEditingController(text: 'a.mansour@looped.ai');
    _phoneController = TextEditingController(text: '+966 50 123 4567');
    _jobTitleController = TextEditingController(text: 'مدير العمليات');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _jobTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AccountSettingsColors.pageBackground,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AccountSettingsAppBar(
              onMenuTap: () {},
              onHelpTap: () {},
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AccountSettingsTitleBlock(
                      title: 'settings_account_title'.tr(),
                      subtitle: 'settings_account_subtitle'.tr(),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: ProfileSettingsCard(
                        displayName: 'profile_demo_display_name'.tr(),
                        fullNameController: _fullNameController,
                        emailController: _emailController,
                        phoneController: _phoneController,
                        jobTitleController: _jobTitleController,
                        onSave: () {
                          FocusScope.of(context).unfocus();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('settings_snackbar_saved'.tr()),
                            ),
                          );
                        },
                        onEditPhoto: () {},
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                      child: BlocBuilder<AppLocaleCubit, Locale>(
                        buildWhen: (p, c) => p != c,
                        builder: (context, locale) {
                          final ar = locale.languageCode == 'ar';
                          return LanguagePreferencesCard(
                            selectedIndex: ar ? 0 : 1,
                            onSelect: (index) {
                              final cubit = context.read<AppLocaleCubit>();
                              if (index == 0) {
                                cubit.setArabic();
                              } else {
                                cubit.setEnglish();
                              }
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                      child: NotificationSettingsCard(
                        emailEnabled: _notifyEmail,
                        browserEnabled: _notifyBrowser,
                        aiReportsEnabled: _notifyAi,
                        onEmailChanged: (v) =>
                            setState(() => _notifyEmail = v),
                        onBrowserChanged: (v) =>
                            setState(() => _notifyBrowser = v),
                        onAiReportsChanged: (v) =>
                            setState(() => _notifyAi = v),
                        onResetAll: _resetNotificationDefaults,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                      child: AssistantLearningCard(
                        onCustomizeData: () {},
                        onChatHistory: () {},
                        onHelpFab: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
