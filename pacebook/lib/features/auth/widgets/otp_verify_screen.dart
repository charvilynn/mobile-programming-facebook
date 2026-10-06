import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/otp_input_box.dart';
import '../widgets/loading_overlay.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String email;
  const OtpVerifyScreen({super.key, required this.email});
  @override State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  String _otp = '';

  Future<void> _verify() async {
    if (_otp.length < 6) {
      setState(() => _errorMessage = 'Masukkan 6 digit kode OTP');
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });
    await Future.delayed(const Duration(seconds: 1)); 
    setState(() => _isLoading = false);
    if (!mounted) return;
    context.go('/feed');
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: AppColors.bgDeep,
        appBar: AppBar(title: const Text('Verifikasi OTP')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                Text('Kode OTP dikirim ke\n${widget.email}',
                    style: AppTypography.bodyLg.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.xl),
                if (_errorMessage != null) ...[
                  AuthErrorBanner(message: _errorMessage!),
                  const SizedBox(height: AppSpacing.md),
                ],
                OtpInputBox(onCompleted: (otp) => setState(() => _otp = otp)),
                const SizedBox(height: AppSpacing.xl),
                AuthPrimaryButton(label: 'Verifikasi', onPressed: _verify),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: Text('Kirim ulang kode', style: AppTypography.bodyMd.copyWith(
                      color: AppColors.cyan,
                    )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}