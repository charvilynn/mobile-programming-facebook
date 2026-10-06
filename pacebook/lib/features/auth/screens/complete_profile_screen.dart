import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/profile_setup_avatar_picker.dart';
import '../widgets/loading_overlay.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});
  @override State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioCtrl = TextEditingController();
  String? _avatarPath;
  bool _isLoading = false;

  Future<void> _finish() async {
    setState(() => _isLoading = true);
    debugPrint('Profile update: bio=${_bioCtrl.text}, avatar=$_avatarPath');
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
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  Text('Lengkapi Profilmu', style: AppTypography.h1, textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Pilih foto profil dan tulis bio singkat.',
                      style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.xl),
                  ProfileSetupAvatarPicker(
                    onImageSelected: (path) => setState(() => _avatarPath = path),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AuthTextField(
                    label: 'Bio (opsional)',
                    hint: 'Ceritakan sedikit tentang dirimu...',
                    controller: _bioCtrl,
                    prefixIcon: const Icon(Icons.edit_outlined),
                  ),
                  const Spacer(),
                  AuthPrimaryButton(label: 'Selesai', onPressed: _finish),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: () => context.go('/feed'),
                    child: Text('Lewati untuk sekarang',
                        style: AppTypography.bodyMd.copyWith(color: AppColors.textMuted)),
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