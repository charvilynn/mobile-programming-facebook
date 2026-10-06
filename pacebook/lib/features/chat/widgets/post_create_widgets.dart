class ShareBottomSheet extends StatelessWidget {
  final VoidCallback? onShareToFeed;
  final VoidCallback? onShareToCommunity;
  final VoidCallback? onCopyLink;

  const ShareBottomSheet({
    super.key,
    this.onShareToFeed,
    this.onShareToCommunity,
    this.onCopyLink,
  });

  static void show(BuildContext context,
      {VoidCallback? onShareToFeed,
      VoidCallback? onShareToCommunity,
      VoidCallback? onCopyLink}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ShareBottomSheet(
        onShareToFeed: onShareToFeed,
        onShareToCommunity: onShareToCommunity,
        onCopyLink: onCopyLink,
      ),
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
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('Bagikan ke...',
              style: AppTypography.h3.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.md),
          _ShareOption(
            icon: Icons.dynamic_feed_outlined,
            label: 'Bagikan ke Feed',
            subtitle: 'Tampilkan di beranda kamu',
            color: AppColors.cyan,
            onTap: () {
              Navigator.pop(context);
              onShareToFeed?.call();
            },
          ),
          _ShareOption(
            icon: Icons.groups_outlined,
            label: 'Bagikan ke Komunitas',
            subtitle: 'Pilih komunitas yang ingin kamu tuju',
            color: AppColors.magenta,
            onTap: () {
              Navigator.pop(context);
              onShareToCommunity?.call();
            },
          ),
          _ShareOption(
            icon: Icons.link_outlined,
            label: 'Salin Tautan',
            subtitle: 'Salin link postingan ini',
            color: const Color(0xFF8B5CF6),
            onTap: () {
              Navigator.pop(context);
              onCopyLink?.call();
            },
          ),
        ],
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(label,
            style: AppTypography.labelMd
                .copyWith(color: AppColors.textPrimary)),
        subtitle: Text(subtitle,
            style: AppTypography.labelSm.copyWith(color: AppColors.textMuted)),
        onTap: onTap,
      );
}