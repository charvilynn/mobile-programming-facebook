import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../widgets/community_widgets.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  final int groupId;
  const GroupDetailScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tc;
  bool _isMember = false;
  bool _isLoading = true;
  GroupModel? _group;

  final List<_MockPost> _posts = [
    _MockPost(author: 'Budi Santoso', content: 'Selamat datang di komunitas Flutter Indonesia! Mari sharing ilmu bersama.', postedAt: DateTime.now().subtract(const Duration(hours: 2))),
    _MockPost(author: 'Sari Wulandari', content: 'Ada yang mau ikut meetup Flutter bulan depan? Info di link bio!', postedAt: DateTime.now().subtract(const Duration(hours: 5))),
    _MockPost(author: 'Reza Firmansyah', content: 'Tips: gunakan const constructor untuk performa widget yang lebih baik.', postedAt: DateTime.now().subtract(const Duration(days: 1))),
  ];

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 3, vsync: this);
    _loadGroup();
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  Future<void> _loadGroup() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _isLoading = false;
        _group = GroupModel(
          id: widget.groupId,
          name: 'Flutter Indonesia',
          memberCount: 4820,
          isMember: false,
          description: 'Komunitas Flutter developer Indonesia. Tempat berdiskusi, sharing, dan belajar bersama tentang pengembangan aplikasi Flutter.',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.bgDeep,
        body: Center(child: CircularProgressIndicator(color: AppColors.cyan, strokeWidth: 2)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.bgDeep,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textSecondary),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.cyan.withValues(alpha: 0.15), AppColors.magenta.withValues(alpha: 0.08)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 64, height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.cyan.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.cyan.withValues(alpha: 0.4)),
                              ),
                              child: Icon(Icons.groups_outlined, color: AppColors.cyan, size: 32),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_group!.name,
                                      style: AppTypography.h2.copyWith(color: AppColors.textPrimary)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(_group!.privacy == 'public' ? Icons.public : Icons.lock_outline,
                                          size: 12, color: AppColors.textMuted),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_group!.privacy == 'public' ? 'Publik' : 'Privat'} · ${_group!.memberCount} anggota',
                                        style: AppTypography.labelSm.copyWith(color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => setState(() => _isMember = !_isMember),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isMember ? AppColors.bgSurface : AppColors.cyan,
                              foregroundColor: _isMember ? AppColors.textSecondary : AppColors.bgDeep,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: Text(_isMember ? 'Sudah Bergabung' : 'Bergabung',
                                style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tc,
              labelColor: AppColors.cyan,
              unselectedLabelColor: AppColors.textMuted,
              indicatorColor: AppColors.cyan,
              labelStyle: AppTypography.labelSm,
              tabs: const [Tab(text: 'Diskusi'), Tab(text: 'Anggota'), Tab(text: 'Info')],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tc,
          children: [
            _posts.isEmpty
                ? _EmptyState(icon: Icons.forum_outlined, label: 'Belum ada diskusi di komunitas ini.')
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                    itemCount: _posts.length,
                    itemBuilder: (_, i) => GroupFeedPostTile(
                      authorName: _posts[i].author,
                      content: _posts[i].content,
                      postedAt: _posts[i].postedAt,
                    ),
                  ),
            ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: 5,
              itemBuilder: (_, i) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.cyan.withValues(alpha: 0.15),
                  child: Text(String.fromCharCode(65 + i),
                      style: AppTypography.labelMd.copyWith(color: AppColors.cyan)),
                ),
                title: Text('Anggota ${i + 1}',
                    style: AppTypography.bodyMd.copyWith(color: AppColors.textPrimary)),
                subtitle: Text(i == 0 ? 'Admin' : 'Member',
                    style: AppTypography.labelSm.copyWith(
                        color: i == 0 ? AppColors.cyan : AppColors.textMuted)),
                onTap: () => context.push('/profile/${i + 10}'),
              ),
            ),
            ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text('Tentang Komunitas',
                    style: AppTypography.labelMd.copyWith(color: AppColors.cyan, fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.sm),
                Text(_group!.description ?? 'Tidak ada deskripsi.',
                    style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary, height: 1.6)),
                const SizedBox(height: AppSpacing.lg),
                _InfoRow(icon: Icons.people_outline, label: '${_group!.memberCount} anggota'),
                _InfoRow(
                    icon: _group!.privacy == 'public' ? Icons.public : Icons.lock_outline,
                    label: _group!.privacy == 'public' ? 'Komunitas publik' : 'Komunitas privat'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MockPost {
  final String author, content;
  final DateTime postedAt;
  const _MockPost({required this.author, required this.content, required this.postedAt});
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String label;
  const _EmptyState({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 52, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.md),
          Text(label, style: AppTypography.bodyMd.copyWith(color: AppColors.textMuted), textAlign: TextAlign.center),
        ]),
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoRow({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
        ]),
      );
}