import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:looped_admin/core/res/color_manager.dart';
import 'package:looped_admin/feature/settings/widget/account_settings_colors.dart';

class ProfileSettingsCard extends StatelessWidget {
  const ProfileSettingsCard({
    super.key,
    required this.displayName,
    required this.fullNameController,
    required this.emailController,
    required this.phoneController,
    required this.jobTitleController,
    required this.onSave,
    required this.onEditPhoto,
  });

  final String displayName;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController jobTitleController;
  final VoidCallback onSave;
  final VoidCallback onEditPhoto;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorManager.whiteColor,
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          children: [
            _ProfileAvatarWithEdit(onEditPhoto: onEditPhoto),
            const SizedBox(height: 16),
            Text(
              displayName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ColorManager.blackColor,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _ProfileBadge(
                  label: 'profile_badge_verified'.tr(),
                  background: AccountSettingsColors.verificationBg,
                  foreground: AccountSettingsColors.verificationFg,
                ),
                _ProfileBadge(
                  label: 'profile_badge_member_since'.tr(),
                  background: AccountSettingsColors.memberBg,
                  foreground: AccountSettingsColors.memberFg,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _ProfileLabeledField(
              label: 'profile_field_full_name'.tr(),
              controller: fullNameController,
              keyboardType: TextInputType.name,
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 16),
            _ProfileLabeledField(
              label: 'profile_field_email'.tr(),
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 16),
            _ProfileLabeledField(
              label: 'profile_field_phone'.tr(),
              controller: phoneController,
              keyboardType: TextInputType.phone,
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 16),
            _ProfileLabeledField(
              label: 'profile_field_job_title'.tr(),
              controller: jobTitleController,
              keyboardType: TextInputType.text,
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 28),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: AccountSettingsColors.navy,
                  foregroundColor: ColorManager.whiteColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'profile_save_changes'.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  const _ProfileBadge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }
}

class _ProfileAvatarWithEdit extends StatelessWidget {
  const _ProfileAvatarWithEdit({required this.onEditPhoto});

  final VoidCallback onEditPhoto;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 112,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AccountSettingsColors.avatarRing,
                width: 2,
              ),
              color: const Color(0xFFF8FAFC),
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 52,
              color: Color(0xFF94A3B8),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Material(
              color: AccountSettingsColors.navy,
              shape: const CircleBorder(),
              elevation: 2,
              child: InkWell(
                onTap: onEditPhoto,
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(
                    Icons.edit_rounded,
                    color: ColorManager.whiteColor,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileLabeledField extends StatefulWidget {
  const _ProfileLabeledField({
    required this.label,
    required this.controller,
    required this.keyboardType,
    required this.textAlign,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextAlign textAlign;

  @override
  State<_ProfileLabeledField> createState() => _ProfileLabeledFieldState();
}

class _ProfileLabeledFieldState extends State<_ProfileLabeledField> {
  static const Color _surface = Color(0xFFF8FAFC);
  static const Color _surfaceFocused = Color(0xFFFFFFFF);
  static const Color _borderIdle = Color(0xFFE2E8F0);
  static const double _radius = 14;

  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  bool get _focused => _focusNode.hasFocus;

  @override
  Widget build(BuildContext context) {
    final borderColor = _focused
        ? AccountSettingsColors.navy.withValues(alpha: 0.45)
        : _borderIdle;
    final bg = _focused ? _surfaceFocused : _surface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.15,
              height: 1.2,
              color: _focused
                  ? AccountSettingsColors.navy.withValues(alpha: 0.85)
                  : AccountSettingsColors.subtitleGrey,
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(
              color: borderColor,
              width: _focused ? 1.5 : 1,
            ),
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: AccountSettingsColors.navy.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_radius),
            child: TextField(
              focusNode: _focusNode,
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              textAlign: widget.textAlign,
              cursorColor: AccountSettingsColors.navy,
              cursorWidth: 2,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.35,
                color: ColorManager.blackColor,
              ),
              decoration: const InputDecoration(
                isDense: true,
                filled: false,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
