import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_divider_with_text.dart';
import '../widgets/password_strength_indicator.dart';
import '../widgets/loading_overlay.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _errorMessage = null);
    final result = await ref.read(authNotifierProvider.notifier).register(
      username: _usernameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      fullName: _nameCtrl.text.trim(),
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
    final password = _passCtrl.text;

    return LoadingOverlay(
      isLoading: isLoading,
      message: 'Membuat akun...',
      child: Scaffold(
        backgroundColor: AppColors.bgDeep,
        appBar: AppBar(
          title: const Text('Buat Akun'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => context.go('/login'),
            tooltip: 'Kembali',
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Form(
              key: _formKey,
              onChanged: () => setState(() {}),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_errorMessage != null) ...[
                    AuthErrorBanner(
                      message: _errorMessage!,
                      onDismiss: () => setState(() => _errorMessage = null),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  AuthTextField(
                    label: 'Nama Lengkap',
                    hint: 'Nama yang akan ditampilkan',
                    controller: _nameCtrl,
                    prefixIcon: const Icon(Icons.badge_outlined),
                    validator: (v) => (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AuthTextField(
                    label: 'Username',
                    hint: 'username unik kamu',
                    controller: _usernameCtrl,
                    prefixIcon: const Icon(Icons.alternate_email),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Username wajib diisi';
                      if (v.length < 3) return 'Min. 3 karakter';
                      if (v.contains(' ')) return 'Tidak boleh ada spasi';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AuthTextField(
                    label: 'Email',
                    hint: 'nama@email.com',
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailCtrl,
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Email wajib diisi';
                      if (!v.contains('@')) return 'Format email tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AuthTextField(
                    label: 'Password',
                    hint: 'Min. 8 karakter',
                    isPassword: true,
                    controller: _passCtrl,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    textInputAction: TextInputAction.done,
                    onEditingComplete: _submit,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password wajib diisi';
                      if (v.length < 8) return 'Min. 8 karakter';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  PasswordStrengthIndicator(password: password),
                  const SizedBox(height: AppSpacing.lg),
                  AuthPrimaryButton(
                    label: 'Daftar',
                    onPressed: _submit,
                    isLoading: isLoading,
                    icon: Icons.rocket_launch_rounded,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const AuthDividerWithText(text: 'sudah punya akun?'),
                  const SizedBox(height: AppSpacing.md),
                  AuthPrimaryButton(
                    label: 'Masuk',
                    isOutlined: true,
                    onPressed: () => context.go('/login'),
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