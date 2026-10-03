import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class AuthDividerWithText extends StatelessWidget {
  final String text;
  const AuthDividerWithText({super.key, this.text = 'atau'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.border, thickness: 0.5)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(text,
              style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
        ),
        Expanded(child: Divider(color: AppColors.border, thickness: 0.5)),
      ],
    );
  }
}