import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Primary CTA button with loading state
/// Always renders full-width — wrap with SizedBox if you need a bounded width.
class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final content = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(AppColors.bgDeep),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label, style: AppTypography.button),
            ],
          );

    // Full-width style for auth screens — always inside Column, never in Row
    final fullWidthStyle = ButtonStyle(
      minimumSize: WidgetStateProperty.all(const Size(double.infinity, 48)),
    );

    if (isOutlined) {
      return OutlinedButton(
        style: fullWidthStyle,
        onPressed: isLoading ? null : onPressed,
        child: content,
      );
    }

    return ElevatedButton(
      style: fullWidthStyle,
      onPressed: isLoading ? null : onPressed,
      child: content,
    );
  }
}