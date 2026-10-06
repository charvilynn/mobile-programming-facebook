import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';


class GroupModel {
  final int id;
  final String name;
  final String? description;
  final String? avatarUrl;
  final String privacy; 
  final int memberCount;
  final bool isMember;

  const GroupModel({
    required this.id,
    required this.name,
    this.description,
    this.avatarUrl,
    this.privacy = 'public',
    this.memberCount = 0,
    this.isMember = false,
  });
}

class EventModel {
  final int id;
  final String name;
  final String? description;
  final String? location;
  final DateTime startTime;
  final DateTime endTime;
  final int attendeeCount;
  final bool isAttending;

  const EventModel({
    required this.id,
    required this.name,
    this.description,
    this.location,
    required this.startTime,
    required this.endTime,
    this.attendeeCount = 0,
    this.isAttending = false,
  });
}

class MarketItem {
  final int id;
  final String title;
  final String? description;
  final double price;
  final String condition; 
  final String category;
  final String? imageUrl;
  final String sellerName;

  const MarketItem({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    required this.condition,
    required this.category,
    this.imageUrl,
    required this.sellerName,
  });
}

class GroupCard extends StatelessWidget {
  final GroupModel group;
  final VoidCallback? onTap;
  final VoidCallback? onJoin;

  const GroupCard({
    super.key,
    required this.group,
    this.onTap,
    this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        clipBehavior: Clip.hardEdge,
        child: Row(
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: group.avatarUrl != null
                  ? Image.network(group.avatarUrl!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _GroupAvatarPlaceholder(group.name))
                  : _GroupAvatarPlaceholder(group.name),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: AppTypography.labelMd.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${group.memberCount} anggota • ${group.privacy == 'private' ? 'Privat' : 'Publik'}',
                      style: AppTypography.labelSm
                          .copyWith(color: AppColors.textMuted),
                    ),
                    if (group.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        group.description!,
                        style: AppTypography.bodySm
                            .copyWith(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: group.isMember
                  ? OutlinedButton(
                      onPressed: onTap,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(color: AppColors.borderSubtle),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Lihat'),
                    )
                  : ElevatedButton(
                      onPressed: onJoin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cyan.withValues(alpha: 0.15),
                        foregroundColor: AppColors.cyan,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Gabung'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupAvatarPlaceholder extends StatelessWidget {
  final String name;
  const _GroupAvatarPlaceholder(this.name);

  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.bgMuted,
        child: Center(
          child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'G',
              style: AppTypography.h1.copyWith(color: AppColors.cyan.withValues(alpha: 0.6))),
        ),
      );
}

class GroupFeedPostTile extends StatelessWidget {
  final String authorName;
  final String? authorAvatar;
  final String content;
  final int reactionCount;
  final int commentCount;
  final DateTime postedAt;
  final VoidCallback? onTap;

  const GroupFeedPostTile({
    super.key,
    required this.authorName,
    this.authorAvatar,
    required this.content,
    this.reactionCount = 0,
    this.commentCount = 0,
    required this.postedAt,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.cyan.withValues(alpha: 0.18),
                  backgroundImage: authorAvatar != null
                      ? NetworkImage(authorAvatar!)
                      : null,
                  child: authorAvatar == null
                      ? Text(authorName[0].toUpperCase(),
                          style: AppTypography.labelSm.copyWith(color: AppColors.cyan))
                      : null,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(authorName,
                    style: AppTypography.labelMd.copyWith(
                        color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(_timeAgo(postedAt),
                    style: AppTypography.labelSm.copyWith(color: AppColors.textMuted)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(content,
                style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(Icons.favorite_border, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 3),
                Text('$reactionCount',
                    style: AppTypography.labelSm.copyWith(color: AppColors.textMuted)),
                const SizedBox(width: AppSpacing.md),
                Icon(Icons.chat_bubble_outline, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 3),
                Text('$commentCount',
                    style: AppTypography.labelSm.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'baru';
    if (diff.inMinutes < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}j';
    return '${diff.inDays}h';
  }
}

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;
  final VoidCallback? onAttend;

  const EventCard({super.key, required this.event, this.onTap, this.onAttend});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.cyan.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    _monthShort(event.startTime),
                    style: AppTypography.labelSm
                        .copyWith(color: AppColors.cyan, fontSize: 10),
                  ),
                  Text(
                    '${event.startTime.day}',
                    style: AppTypography.h2.copyWith(
                        color: AppColors.cyan, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.name,
                      style: AppTypography.labelMd.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  if (event.location != null)
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(event.location!,
                              style: AppTypography.labelSm
                                  .copyWith(color: AppColors.textMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  Text('${event.attendeeCount} hadir',
                      style: AppTypography.labelSm.copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onAttend,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    event.isAttending ? AppColors.bgSurface : AppColors.cyan,
                foregroundColor: event.isAttending
                    ? AppColors.textSecondary
                    : AppColors.bgDeep,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(event.isAttending ? 'Hadir' : 'Ikut',
                  style: AppTypography.labelSm.copyWith(
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  String _monthShort(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    return months[dt.month - 1];
  }
}

class EventCalendarStrip extends StatefulWidget {
  final DateTime selectedDate;
  final void Function(DateTime) onDateSelected;
  final Set<DateTime> eventDates;

  const EventCalendarStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.eventDates = const {},
  });

  @override
  State<EventCalendarStrip> createState() => _EventCalendarStripState();
}

class _EventCalendarStripState extends State<EventCalendarStrip> {
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedDate;
  }

  static const _days = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: 14,
        itemBuilder: (_, i) {
          final date = today.add(Duration(days: i));
          final isSelected = _selected.day == date.day &&
              _selected.month == date.month;
          final hasEvent = widget.eventDates.any((e) =>
              e.day == date.day && e.month == date.month);

          return GestureDetector(
            onTap: () {
              setState(() => _selected = date);
              widget.onDateSelected(date);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
              width: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.cyan
                    : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isSelected
                        ? AppColors.cyan
                        : AppColors.borderSubtle),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_days[date.weekday % 7],
                      style: AppTypography.labelSm.copyWith(
                          color: isSelected
                              ? AppColors.bgDeep
                              : AppColors.textMuted,
                          fontSize: 10)),
                  Text('${date.day}',
                      style: AppTypography.labelMd.copyWith(
                          color: isSelected
                              ? AppColors.bgDeep
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w700)),
                  if (hasEvent)
                    Container(
                      width: 4, height: 4,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.bgDeep : AppColors.magenta,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class MarketplaceItemCard extends StatelessWidget {
  final MarketItem item;
  final VoidCallback? onTap;

  const MarketplaceItemCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: item.imageUrl != null
                  ? Image.network(item.imageUrl!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _ItemImagePlaceholder())
                  : _ItemImagePlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: AppTypography.labelMd.copyWith(
                          color: AppColors.textPrimary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${_formatPrice(item.price)}',
                    style: AppTypography.labelMd.copyWith(
                        color: AppColors.cyan, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: item.condition == 'new'
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.condition == 'new' ? 'Baru' : 'Bekas',
                      style: AppTypography.labelSm.copyWith(
                          color: item.condition == 'new'
                              ? AppColors.success
                              : AppColors.warning,
                          fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double p) {
    if (p >= 1000000) return '${(p / 1000000).toStringAsFixed(1)}jt';
    if (p >= 1000) return '${(p / 1000).toStringAsFixed(0)}rb';
    return p.toStringAsFixed(0);
  }
}

class _ItemImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.bgSurface,
        child: Center(
          child: Icon(Icons.inventory_2_outlined,
              color: AppColors.textMuted, size: 40),
        ),
      );
}

class MarketplaceCategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const MarketplaceCategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: AppSpacing.sm),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.cyan : AppColors.bgSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isSelected ? AppColors.cyan : AppColors.borderSubtle),
          ),
          child: Text(
            label,
            style: AppTypography.labelSm.copyWith(
                color: isSelected ? AppColors.bgDeep : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400),
          ),
        ),
      );
}

class SettingsMenuTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  const SettingsMenuTile({
    super.key,
    required this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? AppColors.error
        : (iconColor ?? AppColors.textSecondary);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title,
          style: AppTypography.labelMd.copyWith(
              color: isDestructive ? AppColors.error : AppColors.textPrimary)),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style: AppTypography.labelSm.copyWith(color: AppColors.textMuted))
          : null,
      trailing: trailing ??
          Icon(Icons.chevron_right,
              color: AppColors.textMuted, size: 20),
    );
  }
}

class ThemeToggleSwitch extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onChanged;

  const ThemeToggleSwitch({
    super.key,
    required this.isDarkMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppColors.cyan.withValues(alpha: 0.12)
                  : AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: isDarkMode ? AppColors.cyan : AppColors.warning,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mode Tampilan',
                    style: AppTypography.labelMd
                        .copyWith(color: AppColors.textPrimary)),
                Text(isDarkMode ? 'Mode Gelap aktif' : 'Mode Terang aktif',
                    style: AppTypography.labelSm.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
          Switch(
            value: isDarkMode,
            onChanged: onChanged,
            activeThumbColor: AppColors.cyan,
            activeTrackColor: AppColors.cyan.withValues(alpha: 0.35),
            inactiveThumbColor: AppColors.warning,
            inactiveTrackColor: AppColors.warning.withValues(alpha: 0.25),
          ),
        ],
      ),
    );
  }
}

class SearchResultTabView extends StatefulWidget {
  final String query;
  const SearchResultTabView({super.key, required this.query});

  @override
  State<SearchResultTabView> createState() => _SearchResultTabViewState();
}

class _SearchResultTabViewState extends State<SearchResultTabView>
    with SingleTickerProviderStateMixin {
  late TabController _tc;

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tc,
          labelColor: AppColors.cyan,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.cyan,
          labelStyle: AppTypography.labelMd,
          tabs: const [
            Tab(text: 'Orang'),
            Tab(text: 'Postingan'),
            Tab(text: 'Komunitas'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tc,
            children: [
              _SearchPlaceholder(
                  icon: Icons.person_search_outlined,
                  label: 'Cari orang "${widget.query}"'),
              _SearchPlaceholder(
                  icon: Icons.article_outlined,
                  label: 'Cari postingan "${widget.query}"'),
              _SearchPlaceholder(
                  icon: Icons.groups_outlined,
                  label: 'Cari komunitas "${widget.query}"'),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchPlaceholder extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SearchPlaceholder({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.md),
            Text(label,
                style: AppTypography.bodySm.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center),
          ],
        ),
      );
}

class AnimatedSearchBar extends StatefulWidget {
  final void Function(String) onSearch;
  final String hint;

  const AnimatedSearchBar({
    super.key,
    required this.onSearch,
    this.hint = 'Cari orang, post, komunitas...',
  });

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar>
    with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  bool _isExpanded = false;
  late final AnimationController _animCtrl;
  late final Animation<double> _widthFactor;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _widthFactor = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _animCtrl.forward();
    } else {
      _ctrl.clear();
      _animCtrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _widthFactor,
          builder: (_, __) => SizedBox(
            width: _widthFactor.value * (MediaQuery.of(context).size.width - 80),
            child: Opacity(
              opacity: _widthFactor.value,
              child: TextField(
                controller: _ctrl,
                onChanged: widget.onSearch,
                style: AppTypography.bodySm.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle:
                      AppTypography.bodySm.copyWith(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.bgSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: 10),
                  isDense: true,
                ),
              ),
            ),
          ),
        ),
        IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _isExpanded ? Icons.close : Icons.search,
              key: ValueKey(_isExpanded),
              color: _isExpanded ? AppColors.magenta : AppColors.textSecondary,
            ),
          ),
          onPressed: _toggle,
        ),
      ],
    );
  }
}

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;
  final VoidCallback? onAttend;

  const EventCard({super.key, required this.event, this.onTap, this.onAttend});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date badge
            Container(
              width: 52,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.cyan.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    _monthShort(event.startTime),
                    style: AppTypography.labelSm
                        .copyWith(color: AppColors.cyan, fontSize: 10),
                  ),
                  Text(
                    '${event.startTime.day}',
                    style: AppTypography.h2.copyWith(
                        color: AppColors.cyan, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.name,
                      style: AppTypography.labelMd.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  if (event.location != null)
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(event.location!,
                              style: AppTypography.labelSm
                                  .copyWith(color: AppColors.textMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  Text('${event.attendeeCount} hadir',
                      style: AppTypography.labelSm.copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onAttend,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    event.isAttending ? AppColors.bgSurface : AppColors.cyan,
                foregroundColor: event.isAttending
                    ? AppColors.textSecondary
                    : AppColors.bgDeep,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(event.isAttending ? 'Hadir' : 'Ikut',
                  style: AppTypography.labelSm.copyWith(
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  String _monthShort(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    return months[dt.month - 1];
  }
}

class EventCalendarStrip extends StatefulWidget {
  final DateTime selectedDate;
  final void Function(DateTime) onDateSelected;
  final Set<DateTime> eventDates;

  const EventCalendarStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.eventDates = const {},
  });

  @override
  State<EventCalendarStrip> createState() => _EventCalendarStripState();
}

class _EventCalendarStripState extends State<EventCalendarStrip> {
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedDate;
  }

  static const _days = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: 14,
        itemBuilder: (_, i) {
          final date = today.add(Duration(days: i));
          final isSelected = _selected.day == date.day &&
              _selected.month == date.month;
          final hasEvent = widget.eventDates.any((e) =>
              e.day == date.day && e.month == date.month);

          return GestureDetector(
            onTap: () {
              setState(() => _selected = date);
              widget.onDateSelected(date);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
              width: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.cyan
                    : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isSelected
                        ? AppColors.cyan
                        : AppColors.borderSubtle),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_days[date.weekday % 7],
                      style: AppTypography.labelSm.copyWith(
                          color: isSelected
                              ? AppColors.bgDeep
                              : AppColors.textMuted,
                          fontSize: 10)),
                  Text('${date.day}',
                      style: AppTypography.labelMd.copyWith(
                          color: isSelected
                              ? AppColors.bgDeep
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w700)),
                  if (hasEvent)
                    Container(
                      width: 4, height: 4,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.bgDeep : AppColors.magenta,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}