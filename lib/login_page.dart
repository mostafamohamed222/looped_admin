import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:looped_admin/core/res/app_routes.dart';
import 'package:looped_admin/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:looped_admin/feature/auth/presentation/cubit/auth_state.dart';

/// Looped AI Operations Assistant — مطابق لتصميم Stitch (بطاقة بيضاء، شبكة نقاط، SSO).
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color _navy = Color(0xFF0A1128);
  static const Color _navyButton = Color(0xFF0D1528);
  static const Color _linkBlue = Color(0xFF2563EB);
  static const Color _fabBlue = Color(0xFF7DD3FC);
  static const Color _muted = Color(0xFF64748B);
  static const Color _labelGrey = Color(0xFF475569);

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryAutoLoginFromStorage());
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

  String? _validateDomainField(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return 'login_validation_domain_empty'.tr();
    }
    if (AuthCubit.normalizeTenantDomain(raw).isEmpty) {
      return 'login_validation_domain_invalid'.tr();
    }
    return null;
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

  InputBorder _underlineBorder(Color color, {double width = 1}) {
    return UnderlineInputBorder(
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: _navy,
                strokeWidth: 2.5,
              ),
            ),
          );
        }
        final loading = state is AuthLoading;
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Flexible(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: _LoopedWordmark(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('login_locale_snackbar'.tr()),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.language_rounded,
                                  size: 18,
                                  color: _labelGrey.withValues(alpha: 0.9),
                                ),
                                label: Text(
                                  'login_language_switch_label'.tr(),
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: _labelGrey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _labelGrey,
                                  side: BorderSide(color: Colors.grey.shade300),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  shape: const StadiumBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'login_welcome'.tr(),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: _navy,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'login_subtitle'.tr(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _muted,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'login_domain_label'.tr(),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: _labelGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _domainController,
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(
                            color: _navy,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'login_domain_hint'.tr(),
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w400,
                            ),
                            prefixIcon: Icon(
                              Icons.public_rounded,
                              color: Colors.grey.shade500,
                              size: 22,
                            ),
                            isDense: true,
                            border: _underlineBorder(Colors.grey.shade300),
                            enabledBorder: _underlineBorder(Colors.grey.shade300),
                            focusedBorder: _underlineBorder(_navy, width: 2),
                            errorBorder: _underlineBorder(theme.colorScheme.error),
                            focusedErrorBorder: _underlineBorder(
                              theme.colorScheme.error,
                              width: 2,
                            ),
                            contentPadding: const EdgeInsets.only(bottom: 6, top: 4),
                          ),
                          validator: _validateDomainField,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'login_username_label'.tr(),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: _labelGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(
                            color: _navy,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'login_email_hint'.tr(),
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w400,
                            ),
                            prefixIcon: Icon(
                              Icons.person_outline_rounded,
                              color: Colors.grey.shade500,
                              size: 22,
                            ),
                            isDense: true,
                            border: _underlineBorder(Colors.grey.shade300),
                            enabledBorder: _underlineBorder(Colors.grey.shade300),
                            focusedBorder: _underlineBorder(_navy, width: 2),
                            errorBorder: _underlineBorder(theme.colorScheme.error),
                            focusedErrorBorder: _underlineBorder(
                              theme.colorScheme.error,
                              width: 2,
                            ),
                            contentPadding: const EdgeInsets.only(bottom: 6, top: 4),
                          ),
                          validator: (v) {
                            final t = v?.trim() ?? '';
                            return switch (t) {
                              '' => 'login_validation_email_empty'.tr(),
                              _ when !t.contains('@') =>
                                  'login_validation_email_invalid'.tr(),
                              _ => null,
                            };
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'login_password_label'.tr(),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: _labelGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('login_reset_snackbar'.tr()),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                foregroundColor: _linkBlue,
                              ),
                              child: Text(
                                'login_forgot_password'.tr(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          autofillHints: const [AutofillHints.password],
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _onSubmit(),
                          style: const TextStyle(
                            color: _navy,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.lock_outline_rounded,
                              color: Colors.grey.shade500,
                              size: 22,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.grey.shade500,
                                size: 22,
                              ),
                              onPressed: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            ),
                            isDense: true,
                            border: _underlineBorder(Colors.grey.shade300),
                            enabledBorder: _underlineBorder(Colors.grey.shade300),
                            focusedBorder: _underlineBorder(_navy, width: 2),
                            errorBorder: _underlineBorder(theme.colorScheme.error),
                            focusedErrorBorder: _underlineBorder(
                              theme.colorScheme.error,
                              width: 2,
                            ),
                            contentPadding: const EdgeInsets.only(bottom: 6, top: 4),
                          ),
                          validator: (v) {
                            final p = v ?? '';
                            return switch (p) {
                              _ when p.isEmpty =>
                                  'login_validation_password_empty'.tr(),
                              _ when p.length < 6 =>
                                  'login_validation_password_short'.tr(),
                              _ => null,
                            };
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _rememberDevice,
                                onChanged: (v) {
                                  setState(() => _rememberDevice = v ?? false);
                                },
                                activeColor: _navy,
                                side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'login_remember_device'.tr(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: _labelGrey,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 52,
                          child: FilledButton(
                            onPressed: loading ? null : _onSubmit,
                            style: FilledButton.styleFrom(
                              backgroundColor: _navyButton,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: _navyButton.withValues(alpha: 0.6),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'login_button'.tr(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Icon(Icons.login_rounded, size: 22),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey.shade200)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'login_sso_divider'.tr(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: _muted,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey.shade200)),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('login_google_snackbar'.tr())),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _navy,
                                  side: BorderSide(color: Colors.grey.shade300),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const _GoogleGlyph(),
                                    const SizedBox(width: 10),
                                    Text(
                                      'login_google'.tr(),
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('login_azure_snackbar'.tr())),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _navy,
                                  side: BorderSide(color: Colors.grey.shade300),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.apartment_rounded, size: 22),
                                    const SizedBox(width: 8),
                                    Text(
                                      'login_azure'.tr(),
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'login_footer_note'.tr(),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _muted.withValues(alpha: 0.9),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Material(
                    elevation: 6,
                    shadowColor: _fabBlue.withValues(alpha: 0.5),
                    shape: const CircleBorder(),
                    color: _fabBlue,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {},
                      child: const SizedBox(
                        width: 48,
                        height: 48,
                        child: Center(
                          child: _LoopedORing(size: 26),
                        ),
                      ),
                    ),
                  ),
                ),
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

class _LoopedWordmark extends StatelessWidget {
  const _LoopedWordmark();

  static const _navy = Color(0xFF0A1128);

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w800,
      color: _navy,
      letterSpacing: 0.2,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('L', style: style.copyWith(height: 1)),
        const SizedBox(width: 2),
        const _LoopedORing(size: 28),
        Text('OPED', style: style.copyWith(height: 1)),
      ],
    );
  }
}

class _LoopedORing extends StatelessWidget {
  const _LoopedORing({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _LoopedOPainter()),
    );
  }
}

class _LoopedOPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outer = size.width * 0.46;
    const count = 26;
    for (var i = 0; i < count; i++) {
      final angle = (i * 2 * math.pi / count) - math.pi / 2;
      final isRed = i % 2 == 0;
      final paint = Paint()
        ..color = isRed ? const Color(0xFFE11D48) : const Color(0xFF38BDF8)
        ..strokeWidth = size.width * 0.055
        ..strokeCap = StrokeCap.round;
      final dir = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + dir * (outer * 0.38),
        center + dir * outer,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DotGridPainter extends CustomPainter {
  const _DotGridPainter();

  static const _dot = Color(0xFF3D4F6F);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = _dot.withValues(alpha: 0.35);
    const step = 14.0;
    for (var x = 0.0; x < size.width + step; x += step) {
      for (var y = 0.0; y < size.height + step; y += step) {
        canvas.drawCircle(Offset(x, y), 1.1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final center = Offset(size.width / 2, size.height / 2);
    final stroke = s * 0.14;

    final blue = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final green = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final yellow = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final red = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final r = s * 0.38;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      -math.pi / 2,
      math.pi * 0.55,
      false,
      blue,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      math.pi * 0.05,
      math.pi * 0.45,
      false,
      green,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      math.pi * 0.5,
      math.pi * 0.35,
      false,
      yellow,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      math.pi * 0.85,
      math.pi * 0.55,
      false,
      red,
    );

    canvas.drawLine(
      Offset(center.dx + r * 0.15, center.dy),
      Offset(center.dx + r * 1.05, center.dy),
      blue,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
