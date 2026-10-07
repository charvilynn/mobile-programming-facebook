import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

enum PasswordStrength { empty, weak, fair, good, strong }

/// 4-bar password strength indicator
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  PasswordStrength _evaluate(String pwd) {
    if (pwd.isEmpty) return PasswordStrength.empty;
    int score = 0;
    if (pwd.length >= 8) score++;
    if (pwd.contains(RegExp(r'[A-Z]'))) score++;
    if (pwd.contains(RegExp(r'[0-9]'))) score++;
    if (pwd.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) score++;
    return PasswordStrength.values[score];
  }

  Color _color(PasswordStrength s) {
    switch (s) {
      case PasswordStrength.weak:  return AppColors.error;
      case PasswordStrength.fair:  return AppColors.warning;
      case PasswordStrength.good:  return AppColors.cyan;
      case PasswordStrength.strong: return AppColors.success;
      default: return AppColors.border;
    }
  }

  String _label(PasswordStrength s) {
    switch (s) {
      case PasswordStrength.weak:  return 'Lemah';
      case PasswordStrength.fair:  return 'Cukup';
      case PasswordStrength.good:  return 'Baik';
      case PasswordStrength.strong: return 'Kuat';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final strength = _evaluate(password);
    final filledBars = strength.index;
    final color = _color(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) => Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 4,
              margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
              decoration: BoxDecoration(
                color: i < filledBars ? color : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          )),
        ),
        if (strength != PasswordStrength.empty) ...[
          const SizedBox(height: 4),
          Text(_label(strength),
              style: AppTypography.caption.copyWith(color: color)),
        ],
      ],
    );
  }
}
