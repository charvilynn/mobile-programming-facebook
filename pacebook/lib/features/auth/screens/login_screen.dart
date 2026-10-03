import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_divider_with_text.dart';
import '../widgets/loading_overlay.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _errorMessage = null);

    final result = await ref.read(authNotifierProvider.notifier).login(
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );

    if (!mounted) return;
    if (result != null) {
      setState(() => _errorMessage = result);
    } else {
      context.go('/feed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return LoadingOverlay(
      isLoading: isLoading,
      message: 'Masuk ke PaceBook...',
      child: Scaffold(
        backgroundColor: AppColors.bgDeep,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xxl),
                  // Header
                  Text('Masuk', style: AppTypography.display1),
                  const SizedBox(height: 6),
                  Text('Selamat kembali ke PaceBook',
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.textSecondary,
                      )),
                  const SizedBox(height: AppSpacing.xxl),

                  // Error banner (antislop R-27 error state)
                  if (_errorMessage != null) ...[
                    AuthErrorBanner(
                      message: _errorMessage!,
                      onDismiss: () => setState(() => _errorMessage = null),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // Email field
                  AuthTextField(
                    label: 'Email',
                    hint: 'nama@email.com',
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailCtrl,
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Email wajib diisi';
                      if (!val.contains('@')) return 'Format email tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Password field
                  AuthTextField(
                    label: 'Password',
                    hint: 'Masukkan password',
                    isPassword: true,
                    controller: _passCtrl,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    textInputAction: TextInputAction.done,
                    onEditingComplete: _submit,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Password wajib diisi';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Forgot password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.go('/forgot-password'),
                      child: Text('Lupa password?',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.cyan,
                          )),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Login button
                  AuthPrimaryButton(
                    label: 'Masuk',
                    onPressed: _submit,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  const AuthDividerWithText(text: 'belum punya akun?'),
                  const SizedBox(height: AppSpacing.md),

                  // Register link
                  AuthPrimaryButton(
                    label: 'Daftar Sekarang',
                    isOutlined: true,
                    onPressed: () => context.go('/register'),
                    icon: Icons.person_add_outlined,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}