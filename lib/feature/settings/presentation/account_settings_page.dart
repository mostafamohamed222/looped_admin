import 'dart:convert';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:looped_admin/core/di/injection.dart';
import 'package:looped_admin/core/data_scource/remote/dio_consumer.dart';
import 'package:looped_admin/feature/nav_bar/cubit/app_shell_nav_cubit.dart';
import 'package:looped_admin/feature/settings/cubit/app_locale_cubit.dart';
import 'package:looped_admin/feature/settings/cubit/profile_cubit.dart';
import 'package:looped_admin/feature/settings/cubit/profile_save_result.dart';
import 'package:looped_admin/feature/settings/cubit/profile_state.dart';
import 'package:looped_admin/feature/settings/data/profile_repository_impl.dart';
import 'package:looped_admin/feature/settings/domain/user_profile.dart';
import 'package:looped_admin/feature/settings/widget/account_settings_app_bar.dart';
import 'package:looped_admin/feature/settings/widget/account_settings_colors.dart';
import 'package:looped_admin/feature/settings/widget/account_settings_title_block.dart';
import 'package:looped_admin/feature/settings/widget/assistant_learning_card.dart';
import 'package:looped_admin/feature/settings/widget/language_preferences_card.dart';
import 'package:looped_admin/feature/settings/widget/notification_settings_card.dart';
import 'package:looped_admin/feature/settings/widget/profile_settings_card.dart';
import 'package:looped_admin/feature/settings/widget/settings_logout_button.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(
        repository: ProfileRepositoryImpl(dio: getIt<DioConsumer>()),
      ),
      child: const _AccountSettingsBody(),
    );
  }
}

class _AccountSettingsBody extends StatefulWidget {
  const _AccountSettingsBody();

  @override
  State<_AccountSettingsBody> createState() => _AccountSettingsBodyState();
}

class _AccountSettingsBodyState extends State<_AccountSettingsBody> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _jobTitleController;

  String _displayName = '';
  Uint8List? _localImageBytes;
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

  void _loadProfileIfOnSettingsTab() {
    if (!mounted) return;
    if (context.read<AppShellNavCubit>().state ==
        AppShellNavCubit.settingsTab) {
      context.read<ProfileCubit>().loadProfile();
    }
  }

  void _applyProfile(UserProfile profile) {
    _fullNameController.text = profile.name;
    _emailController.text = profile.email;
    _phoneController.text = profile.displayPhone;
    setState(() {
      _displayName = profile.name;
      _localImageBytes = null;
    });
  }

  String? _resolveImageUrl(String? imageUrl) {
    final raw = imageUrl?.trim() ?? '';
    if (raw.isEmpty) return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }
    final baseUrl = getIt<DioConsumer>().client.options.baseUrl.trim();
    if (baseUrl.isEmpty) return raw;
    if (raw.startsWith('/')) {
      return '$baseUrl$raw';
    }
    return '$baseUrl/$raw';
  }

  Future<void> _onEditPhoto(BuildContext context) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (file == null || !context.mounted) return;

    final bytes = await file.readAsBytes();
    if (!context.mounted) return;
    setState(() => _localImageBytes = bytes);

    final cubit = context.read<ProfileCubit>();
    final result = await cubit.updateProfileImage(base64Encode(bytes));

    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    switch (result) {
      case ProfileSaveResult.success:
        final profile = cubit.state.profile;
        if (profile != null) {
          _applyProfile(profile);
        }
        messenger.showSnackBar(
          SnackBar(content: Text('settings_snackbar_saved'.tr())),
        );
      case ProfileSaveResult.failure:
        setState(() => _localImageBytes = null);
        final error =
            cubit.state.errorMessage ?? 'settings_snackbar_save_failed'.tr();
        messenger.showSnackBar(SnackBar(content: Text(error)));
      case ProfileSaveResult.noChanges:
      case ProfileSaveResult.noProfile:
        setState(() => _localImageBytes = null);
        break;
    }
  }

  Future<void> _onSaveProfile(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final result = await context.read<ProfileCubit>().saveProfile(
          name: _fullNameController.text,
          email: _emailController.text,
          phoneFieldValue: _phoneController.text,
        );

    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    switch (result) {
      case ProfileSaveResult.success:
        final profile = context.read<ProfileCubit>().state.profile;
        if (profile != null) {
          _applyProfile(profile);
        }
        messenger.showSnackBar(
          SnackBar(content: Text('settings_snackbar_saved'.tr())),
        );
      case ProfileSaveResult.noChanges:
        messenger.showSnackBar(
          SnackBar(content: Text('settings_snackbar_no_changes'.tr())),
        );
      case ProfileSaveResult.failure:
        final error =
            context.read<ProfileCubit>().state.errorMessage ??
            'settings_snackbar_save_failed'.tr();
        messenger.showSnackBar(SnackBar(content: Text(error)));
      case ProfileSaveResult.noProfile:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _jobTitleController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileIfOnSettingsTab();
    });
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
    return MultiBlocListener(
      listeners: [
        BlocListener<AppShellNavCubit, int>(
          listener: (context, index) {
            if (index == AppShellNavCubit.settingsTab) {
              context.read<ProfileCubit>().loadProfile();
            }
          },
        ),
        BlocListener<ProfileCubit, ProfileState>(
          listenWhen: (previous, current) =>
              previous.profile != current.profile &&
              current.profile != null,
          listener: (context, state) {
            _applyProfile(state.profile!);
          },
        ),
      ],
      child: ColoredBox(
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
                        child: BlocBuilder<ProfileCubit, ProfileState>(
                          buildWhen: (previous, current) =>
                              previous.isSaving != current.isSaving ||
                              previous.isSavingImage != current.isSavingImage ||
                              previous.profile?.imageUrl !=
                                  current.profile?.imageUrl,
                          builder: (context, profileState) {
                            return ProfileSettingsCard(
                              displayName: _displayName,
                              fullNameController: _fullNameController,
                              emailController: _emailController,
                              phoneController: _phoneController,
                              imageUrl: _resolveImageUrl(
                                profileState.profile?.imageUrl,
                              ),
                              localImageBytes: _localImageBytes,
                              isSaving: profileState.isSaving,
                              isSavingImage: profileState.isSavingImage,
                              onSave: () => _onSaveProfile(context),
                              onEditPhoto: () => _onEditPhoto(context),
                            );
                          },
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
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
                        child: SettingsLogoutButton(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
