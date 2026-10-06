import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';

//  PostPrivacySelector 
class PostPrivacySelector extends StatelessWidget {
  final String current;
  final void Function(String) onChanged;

  const PostPrivacySelector({
    super.key,
    required this.current,
    required this.onChanged,
  });

  static const _options = [
    ('public', Icons.public, 'Semua Orang',
        'Siapapun bisa melihat postingan ini'),
    ('connections', Icons.people_outline, 'Koneksi',
        'Hanya koneksi kamu yang bisa melihat'),
    ('private', Icons.lock_outline, 'Hanya Saya',
        'Hanya kamu yang bisa melihat'),
  ];

  static void show(BuildContext context,
      {required String current,
      required void Function(String) onChanged}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => PostPrivacySelector(current: current, onChanged: onChanged),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('Siapa yang bisa melihat?',
              style: AppTypography.h3.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.md),
          ..._options.map((opt) {
            final (value, icon, label, desc) = opt;
            final isSelected = current == value;
            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.cyan.withValues(alpha: 0.15)
                      : AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon,
                    color:
                        isSelected ? AppColors.cyan : AppColors.textSecondary,
                    size: 22),
              ),
              title: Text(label,
                  style: AppTypography.labelMd.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
              subtitle: Text(desc,
                  style: AppTypography.labelSm
                      .copyWith(color: AppColors.textMuted)),
              trailing: isSelected
                  ? Icon(Icons.check_circle,
                      color: AppColors.cyan, size: 20)
                  : null,
              onTap: () {
                onChanged(value);
                Navigator.of(context).pop();
              },
            );
          }),
        ],
      ),
    );
  }
}

//  CreatePostToolbar
class CreatePostToolbar extends StatelessWidget {
  final VoidCallback? onAddPhoto;
  final VoidCallback? onAddFeeling;
  final VoidCallback? onAddTag;

  const CreatePostToolbar({
    super.key,
    this.onAddPhoto,
    this.onAddFeeling,
    this.onAddTag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm, horizontal: AppSpacing.md),
      child: Row(
        children: [
          Text('Tambahkan ke postingan:',
              style: AppTypography.labelSm
                  .copyWith(color: AppColors.textMuted)),
          const Spacer(),
          _ToolbarItem(
              icon: Icons.image_outlined,
              color: const Color(0xFF4CAF50),
              tooltip: 'Foto',
              onTap: onAddPhoto ?? () {}),
          _ToolbarItem(
              icon: Icons.emoji_emotions_outlined,
              color: AppColors.magenta,
              tooltip: 'Perasaan',
              onTap: onAddFeeling ?? () {}),
          _ToolbarItem(
              icon: Icons.person_add_outlined,
              color: AppColors.cyan,
              tooltip: 'Tag teman',
              onTap: onAddTag ?? () {}),
        ],
      ),
    );
  }
}

class _ToolbarItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ToolbarItem({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: IconButton(
          icon: Icon(icon, color: color, size: 24),
          onPressed: onTap,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          constraints: const BoxConstraints(),
        ),
      );
}

//  FeelingPickerGrid
class FeelingPickerGrid extends StatelessWidget {
  final void Function(String feeling) onSelect;

  const FeelingPickerGrid({super.key, required this.onSelect});

  static const _feelings = [
    ('😊', 'senang'), ('😢', 'sedih'), ('😍', 'jatuh cinta'),
    ('🤩', 'bersemangat'), ('😤', 'frustrasi'), ('😴', 'mengantuk'),
    ('🎉', 'merayakan'), ('💪', 'termotivasi'), ('🤔', 'berpikir'),
    ('😎', 'keren'), ('🙏', 'bersyukur'), ('😅', 'lega'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.2,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
      ),
      itemCount: _feelings.length,
      itemBuilder: (_, i) {
        final (emoji, label) = _feelings[i];
        return GestureDetector(
          onTap: () => onSelect(label),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 2),
                Text(label,
                    style: AppTypography.labelSm.copyWith(
                        color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        );
      },
    );
  }
}