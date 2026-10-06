import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/loading_overlay.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    await Future.delayed(const Duration(seconds: 1)); // replace with API call
    setState(() { _isLoading = false; _emailSent = true; });
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: AppColors.bgDeep,
        appBar: AppBar(title: const Text('Lupa Password')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _emailSent
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mark_email_read_outlined, color: AppColors.cyan, size: 56),
                      const SizedBox(height: AppSpacing.md),
                      Text('Email Terkirim', style: AppTypography.h1),
                      const SizedBox(height: AppSpacing.sm),
                      Text('Cek email ${_emailCtrl.text} untuk link reset password.',
                          style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center),
                      const SizedBox(height: AppSpacing.xl),
                      AuthPrimaryButton(label: 'Kembali ke Login', onPressed: () => context.go('/login')),
                    ],
                  )
                : Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.lg),
                        Text('Masukkan email kamu, kami akan mengirim link reset password.',
                            style: AppTypography.bodyLg.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: AppSpacing.xl),
                        if (_errorMessage != null) ...[
                          AuthErrorBanner(message: _errorMessage!),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        AuthTextField(
                          label: 'Email',
                          hint: 'nama@email.com',
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailCtrl,
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Email wajib diisi';
                            if (!v.contains('@')) return 'Format tidak valid';
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AuthPrimaryButton(label: 'Kirim Link Reset', onPressed: _submit),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}