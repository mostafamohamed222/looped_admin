import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:looped_admin/core/res/app_routes.dart';
import 'package:looped_admin/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:looped_admin/feature/auth/presentation/cubit/auth_state.dart';
import 'package:looped_admin/feature/auth/widget/login_assistant_fab.dart';
import 'package:looped_admin/feature/auth/widget/login_domain_field.dart';
import 'package:looped_admin/feature/auth/widget/login_email_field.dart';
import 'package:looped_admin/feature/auth/widget/login_footer_note.dart';
import 'package:looped_admin/feature/auth/widget/login_header.dart';
import 'package:looped_admin/feature/auth/widget/login_password_field.dart';
import 'package:looped_admin/feature/auth/widget/login_remember_device_row.dart';
import 'package:looped_admin/feature/auth/widget/login_session_loading.dart';
import 'package:looped_admin/feature/auth/widget/login_submit_button.dart';
import 'package:looped_admin/feature/auth/widget/login_welcome_block.dart';
import 'package:looped_admin/feature/settings/cubit/app_locale_cubit.dart';

/// Looped AI Operations Assistant — مطابق لتصميم Stitch (بطاقة بيضاء، شبكة نقاط، SSO).
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _domainController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberDevice = false;
  bool _checkingSavedSession = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _tryAutoLoginFromStorage(),
    );
  }

  Future<void> _tryAutoLoginFromStorage() async {
    await context.read<AuthCubit>().checkIfUserLogin();
    if (!mounted) return;
    setState(() => _checkingSavedSession = false);
  }

  @override
  void dispose() {
    _domainController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!mounted) return;
    context.read<AuthCubit>().setRememberMe(_rememberDevice);
    await context.read<AuthCubit>().login(
          _domainController.text,
          _passwordController.text,
          _emailController.text.trim(),
        );
  }

  Future<void> _toggleLocale() async {
    final cubit = context.read<AppLocaleCubit>();
    if (context.locale.languageCode == 'ar') {
      await cubit.setEnglish();
    } else {
      await cubit.setArabic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          current is AuthSuccess || current is AuthError,
      listener: (context, state) {
        if (state is AuthSuccess) {
          navigatorManager.navigateAndFinish(Routes.navBarScreen);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (_checkingSavedSession) {
          return const LoginSessionLoading();
        }

        final loading = state is AuthLoading;
        final isArabic = context.locale.languageCode == 'ar';
        final localeSwitchLabel =
            isArabic ? 'lang_en_title'.tr() : 'lang_ar_title'.tr();

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Material(
                shadowColor: Colors.black45,
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 28, 28, 40),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            LoginHeader(
                              localeSwitchLabel: localeSwitchLabel,
                              onLocalePressed: _toggleLocale,
                            ),
                            const SizedBox(height: 28),
                            const LoginWelcomeBlock(),
                            const SizedBox(height: 28),
                            LoginDomainField(controller: _domainController),
                            const SizedBox(height: 20),
                            LoginEmailField(controller: _emailController),
                            const SizedBox(height: 20),
                            LoginPasswordField(
                              controller: _passwordController,
                              obscurePassword: _obscurePassword,
                              onToggleObscure: () {
                                setState(
                                  () => _obscurePassword = !_obscurePassword,
                                );
                              },
                              onSubmit: _onSubmit,
                            ),
                            const SizedBox(height: 16),
                            LoginRememberDeviceRow(
                              value: _rememberDevice,
                              onChanged: (v) {
                                setState(() => _rememberDevice = v);
                              },
                            ),
                            const SizedBox(height: 24),
                            LoginSubmitButton(
                              loading: loading,
                              onPressed: _onSubmit,
                            ),
                            const SizedBox(height: 28),
                            const LoginFooterNote(),
                          ],
                        ),
                      ),
                    ),
                    const LoginAssistantFab(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
