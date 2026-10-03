import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../../auth/providers/auth_provider.dart';
import '../../feed/providers/bookmarks_provider.dart';
import '../widgets/profile_widgets.dart';
import '../../feed/widgets/post_card.dart';
import '../../feed/widgets/story_bar.dart';

// ProfileProvider
final profileProvider =
    FutureProvider.family<UserProfile, int?>((ref, userId) async {
  final api = ref.watch(apiClientProvider);
  final storage = ref.watch(storageServiceProvider);

  try {
    final endpoint =
        (userId == null || userId == 0) ? '/users/me' : '/users/$userId';
    final res = await api.get(endpoint);
    final data = res.data['data'] as Map<String, dynamic>;

    return UserProfile(
      id: data['id'] as int? ?? 0,
      name: (data['full_name'] ?? data['fullName'] ?? 'Pengguna PaceBook')
          .toString(),
      username: (data['username'] ?? 'user').toString(),
      avatarUrl: data['avatar_url'] as String?,
      coverUrl: data['cover_url'] as String?,
      bio: data['bio'] as String?,
      birthday: data['birthday'] as String?,
      gender: data['gender'] as String?,
      location: data['location'] as String?,
      work: data['work'] as String?,
      education: data['education'] as String?,
      thoughtNote: data['thought_note'] as String?,
      postCount: data['postCount'] as int? ?? 0,
      connectionCount: data['connectionCount'] as int? ?? 0,
      connectionStatus: (data['connectionStatus'] ?? 'none').toString(),
      isPrivate: data['isPrivate'] as bool? ?? false,
    );
  } catch (_) {
    final rawUser = await storage.getUserData();
    if (rawUser != null && rawUser.isNotEmpty) {
      try {
        final map = jsonDecode(rawUser) as Map<String, dynamic>;
        return UserProfile(
          id: map['id'] as int? ?? 0,
          name: (map['full_name'] ?? map['fullName'] ?? 'Pengguna PaceBook')
              .toString(),
          username: (map['username'] ?? 'user').toString(),
          avatarUrl: map['avatar_url'] as String?,
          coverUrl: map['cover_url'] as String?,
          bio: map['bio'] as String?,
          birthday: map['birthday'] as String?,
          gender: map['gender'] as String?,
          location: map['location'] as String?,
          work: map['work'] as String?,
          education: map['education'] as String?,
          thoughtNote: map['thought_note'] as String?,
          postCount: 0,
          connectionCount: 0,
          connectionStatus: 'none',
        );
      } catch (_) {}
    }
    return UserProfile(
      id: userId ?? 0,
      name: 'Pengguna PaceBook',
      username: 'user',
      postCount: 0,
      connectionCount: 0,
      connectionStatus: 'none',
    );
  }
});

// User Posts Provider
final userPostsProvider =
    FutureProvider.family<List<PostData>, int>((ref, userId) async {
  final api = ref.watch(apiClientProvider);
  try {
    final endpoint = (userId == 0)
        ? '/posts?limit=30'
        : '/posts?userId=$userId&limit=30';
    final res = await api.get(endpoint);
    final rawList = res.data['data'] as List<dynamic>? ?? [];
    return rawList
        .map((p) => PostData.fromJson(p as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
});

// Profile Friends Provider
final profileFriendsProvider =
    FutureProvider.family<List<UserProfile>, int>((ref, userId) async {
  final api = ref.watch(apiClientProvider);
  try {
    final endpoint = (userId == 0) ? '/users/me/connections' : '/users/$userId/connections';
    final res = await api.get(endpoint);
    final list = res.data['data'] as List<dynamic>? ?? [];
    return list.map((item) {
      final u = item as Map<String, dynamic>;
      return UserProfile(
        id: u['id'] as int? ?? 0,
        name: (u['full_name'] ?? u['fullName'] ?? 'Pengguna').toString(),
        username: (u['username'] ?? 'user').toString(),
        avatarUrl: u['avatar_url'] as String?,
        bio: u['bio'] as String?,
      );
    }).toList();
  } catch (_) {
    return [];
  }
});

// ProfileScreen
class ProfileScreen extends ConsumerStatefulWidget {
  final int? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _selectedFilter = 0;
  bool _isUploading = false;

  bool get _isMyProfile => widget.userId == null || widget.userId == 0;

  Future<void> _pickAndUploadAvatar() async {
    if (_isUploading) return;
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (file == null) return;

      setState(() => _isUploading = true);

      final bytes = await file.readAsBytes();
      final b64 = base64Encode(bytes);
      final mime = file.mimeType ?? 'image/jpeg';
      final dataUri = 'data:$mime;base64,$b64';

      final api = ref.read(apiClientProvider);
      final res = await api.patch('/users/me', data: {
        'avatar_url': dataUri,
      });

      final storage = ref.read(storageServiceProvider);
      if (res.data != null && res.data['data'] != null) {
        await storage.saveUserData(jsonEncode(res.data['data']));
      }

      ref.invalidate(profileProvider(widget.userId));

      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Foto profil berhasil diperbarui!'),
            backgroundColor: AppColors.bgCard,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui foto profil: $e'),
            backgroundColor: AppColors.bgCard,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadCover() async {
    if (_isUploading) return;
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1400,
        maxHeight: 800,
      );
      if (file == null) return;

      setState(() => _isUploading = true);

      final bytes = await file.readAsBytes();
      final b64 = base64Encode(bytes);
      final mime = file.mimeType ?? 'image/jpeg';
      final dataUri = 'data:$mime;base64,$b64';

      final api = ref.read(apiClientProvider);
      final res = await api.patch('/users/me', data: {
        'cover_url': dataUri,
      });

      final storage = ref.read(storageServiceProvider);
      if (res.data != null && res.data['data'] != null) {
        await storage.saveUserData(jsonEncode(res.data['data']));
      }

      ref.invalidate(profileProvider(widget.userId));

      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Foto sampul berhasil diperbarui!'),
            backgroundColor: AppColors.bgCard,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui foto sampul: $e'),
            backgroundColor: AppColors.bgCard,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showAddStoryModal(BuildContext context) {
    showCreateStorySheet(context, ref);
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (_isMyProfile) ...[
              ListTile(
                leading: Icon(Icons.edit_outlined,
                    color: AppColors.textSecondary),
                title: Text('Edit Profil', style: AppTypography.bodyMd),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/edit-profile');
                },
              ),
              ListTile(
                leading:
                    Icon(Icons.bookmark_rounded, color: AppColors.cyan),
                title: Text('Postingan Tersimpan (Simpanan)',
                    style: AppTypography.bodyMd),
                trailing: Consumer(builder: (_, r, __) {
                  final count = r.watch(bookmarksProvider).length;
                  return count > 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.cyan.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('$count',
                              style: AppTypography.labelSm
                                  .copyWith(color: AppColors.cyan)),
                        )
                      : const SizedBox.shrink();
                }),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/bookmarks');
                },
              ),
            ],
            ListTile(
              leading: Icon(Icons.settings_outlined,
                  color: AppColors.textSecondary),
              title: Text('Pengaturan', style: AppTypography.bodyMd),
              onTap: () {
                Navigator.pop(context);
                context.push('/settings');
              },
            ),
            Divider(color: AppColors.borderSubtle, height: 1),
            ListTile(
              leading:
                  const Icon(Icons.logout_rounded, color: AppColors.error),
              title: Text('Keluar dari Akun',
                  style:
                      AppTypography.bodyMd.copyWith(color: AppColors.error)),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authNotifierProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider(widget.userId));

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: profileAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(
              color: AppColors.cyan, strokeWidth: 2),
        ),
        error: (err, _) => _ProfileError(
          error: err.toString(),
          onRetry: () => ref.refresh(profileProvider(widget.userId)),
        ),
        data: (profile) {
          final userPostsAsync = ref.watch(userPostsProvider(profile.id));

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 0,
                    pinned: true,
                    floating: false,
                    backgroundColor: AppColors.bgDeep,
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                    leading: _isMyProfile
                        ? IconButton(
                            icon: Icon(Icons.menu_rounded,
                                color: AppColors.textPrimary, size: 24),
                            onPressed: () => _showProfileMenu(context),
                          )
                        : IconButton(
                            icon: Icon(Icons.arrow_back_ios_new,
                                size: 18, color: AppColors.textPrimary),
                            onPressed: () => context.pop(),
                          ),
                    title: Text(
                      profile.name,
                      style: AppTypography.h3.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    centerTitle: false,
                    actions: [
                      if (_isMyProfile)
                        IconButton(
                          icon: Icon(Icons.edit_outlined,
                              color: AppColors.textPrimary, size: 22),
                          onPressed: () => context.push('/edit-profile'),
                          tooltip: 'Edit Profil',
                        ),
                      IconButton(
                        icon: Icon(Icons.search,
                            color: AppColors.textPrimary, size: 22),
                        onPressed: () => context.push('/discovery/explore'),
                        tooltip: 'Cari',
                      ),
                    ],
                  ),

                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileHeader(
                          profile: profile,
                          isMyProfile: _isMyProfile,
                          onChangeAvatar: _pickAndUploadAvatar,
                          onChangeCover: _pickAndUploadCover,
                          onEditProfile: () => context.push('/edit-profile'),
                          onAddStory: () => _showAddStoryModal(context),
                          onConnect: () async {
                            if (profile.connectionStatus == 'pending_received') {
                              try {
                                final api = ref.read(apiClientProvider);
                                await api.post('/users/${profile.id}/accept-connection');
                                ref.invalidate(profileProvider(profile.id));
                                ref.invalidate(friendSuggestionsProvider);
                                ref.invalidate(notificationsProvider);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Sekarang berteman dengan ${profile.name}!'),
                                    backgroundColor: AppColors.bgCard,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } catch (_) {}
                            } else if (profile.connectionStatus == 'none') {
                              try {
                                final api = ref.read(apiClientProvider);
                                await api.post('/users/${profile.id}/connect');
                                ref.invalidate(profileProvider(profile.id));
                                ref.invalidate(friendSuggestionsProvider);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Permintaan pertemanan dikirim ke ${profile.name}'),
                                    backgroundColor: AppColors.bgCard,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } catch (_) {}
                            }
                          },
                          onMessage: () {
                            final encodedName = Uri.encodeComponent(profile.name);
                            context.push('/chat/dm/${profile.id}?name=$encodedName');
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),

                        if (profile.isPrivate && !_isMyProfile)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.xl),
                            child: Column(
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: AppColors.bgCard,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.borderSubtle),
                                  ),
                                  child: Icon(Icons.lock_outline_rounded,
                                      color: AppColors.textMuted, size: 32),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text('Akun ini private',
                                    style: AppTypography.h3
                                        .copyWith(color: AppColors.textPrimary)),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'Terhubung terlebih dahulu untuk melihat\nprofil, foto, dan postingan dari akun ini.',
                                  style: AppTypography.bodySm.copyWith(
                                      color: AppColors.textSecondary),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        else ...[
                          ProfileFilterPills(
                            selectedIndex: _selectedFilter,
                            onSelect: (i) => setState(() => _selectedFilter = i),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          if (_selectedFilter == 0) ...[
                            PersonalDetailsCard(
                              profile: profile,
                              onEdit: _isMyProfile
                                  ? () => context.push('/edit-profile')
                                  : null,
                            ),
                            const SizedBox(height: AppSpacing.md),

                            Consumer(
                              builder: (context, ref, _) {
                                final friendsAsync =
                                    ref.watch(profileFriendsProvider(profile.id));
                                final friendsList = friendsAsync.value ?? [];
                                return FriendsGridCard(
                                  totalFriends: profile.connectionCount,
                                  friends: friendsList,
                                  onSeeAll: () =>
                                      context.push('/connections/${profile.id}'),
                                  onFindFriends: () => context.go('/search'),
                                  onFriendTap: (fId) =>
                                      context.push('/profile/$fId'),
                                );
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),

                            if (_isMyProfile) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md),
                                child: InkWell(
                                  onTap: () => context.push('/bookmarks'),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.md,
                                        vertical: 12),
                                    decoration: BoxDecoration(
                                      color: AppColors.bgCard,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: AppColors.borderSubtle),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.cyan
                                                .withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(Icons.bookmark_rounded,
                                              color: AppColors.cyan, size: 20),
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Postingan Tersimpan',
                                                  style: AppTypography.labelMd
                                                      .copyWith(
                                                    color: AppColors.textPrimary,
                                                    fontWeight: FontWeight.w600,
                                                  )),
                                              Consumer(builder: (_, r, __) {
                                                final count = r
                                                    .watch(bookmarksProvider)
                                                    .length;
                                                return Text(
                                                  '$count postingan tersimpan',
                                                  style: AppTypography.labelSm
                                                      .copyWith(
                                                          color: AppColors
                                                              .textMuted),
                                                );
                                              }),
                                            ],
                                          ),
                                        ),
                                        Icon(Icons.arrow_forward_ios_rounded,
                                            size: 14,
                                            color: AppColors.textMuted),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                            ],

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Postingan',
                                    style: AppTypography.h3.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                                  ),
                                  if (_isMyProfile)
                                    TextButton.icon(
                                      onPressed: () =>
                                          context.push('/create-post'),
                                      icon: Icon(Icons.add,
                                          size: 16, color: AppColors.cyan),
                                      label: Text(
                                        'Buat Postingan',
                                        style: AppTypography.labelMd.copyWith(
                                          color: AppColors.cyan,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],

                          if (_selectedFilter == 1)
                            _buildPhotosView(userPostsAsync),

                          if (_selectedFilter == 2)
                            _buildNotesView(context),

                          if (_selectedFilter == 3)
                            _buildConnectionsView(context, profile),
                        ],
                      ],
                    ),
                  ),

                  if (_selectedFilter == 0 && !(profile.isPrivate && !_isMyProfile))
                    userPostsAsync.when(
                      loading: () => SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.xl),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.cyan,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      ),
                      error: (err, _) => SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Center(
                            child: Text(
                              'Gagal memuat postingan: $err',
                              style: AppTypography.bodySm
                                  .copyWith(color: AppColors.textMuted),
                            ),
                          ),
                        ),
                      ),
                      data: (posts) {
                        if (posts.isEmpty) {
                          return SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.post_add_outlined,
                                        color: AppColors.textMuted, size: 52),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      'Belum ada postingan',
                                      style: AppTypography.h3.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Postingan yang kamu buat akan muncul di sini.',
                                      style: AppTypography.bodySm.copyWith(
                                          color: AppColors.textMuted),
                                      textAlign: TextAlign.center,
                                    ),
                                    if (_isMyProfile) ...[
                                      const SizedBox(height: AppSpacing.md),
                                      ElevatedButton.icon(
                                        onPressed: () =>
                                            context.push('/create-post'),
                                        icon: const Icon(Icons.edit_note,
                                            size: 18),
                                        label:
                                            const Text('Buat Postingan Pertama'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.cyan,
                                          foregroundColor: AppColors.bgDeep,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) {
                              final post = posts[i];
                              return Padding(
                                padding:
                                    const EdgeInsets.only(bottom: AppSpacing.sm),
                                child: PostCard(post: post),
                              );
                            },
                            childCount: posts.length,
                          ),
                        );
                      },
                    ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 90),
                  ),
                ],
              ),

              if (_isUploading)
                Container(
                  color: Colors.black.withValues(alpha: 0.6),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: AppColors.cyan,
                          strokeWidth: 3,
                        ),
                        SizedBox(height: AppSpacing.md),
                        Text(
                          'Mengunggah foto...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPhotosView(AsyncValue<List<PostData>> postsAsync) {
    return postsAsync.when(
      loading: () => Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(
              color: AppColors.cyan, strokeWidth: 2),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (posts) {
        final allImages = <String>[];
        for (final p in posts) {
          allImages.addAll(p.mediaUrls);
        }

        if (allImages.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.photo_library_outlined,
                      color: AppColors.textMuted, size: 48),
                  SizedBox(height: AppSpacing.sm),
                  Text('Belum ada foto',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text('Foto dari postinganmu akan tampil di sini.',
                      style:
                          TextStyle(color: AppColors.textMuted, fontSize: 13)),
                ],
              ),
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allImages.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemBuilder: (ctx, i) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: buildSmartImage(allImages[i], fit: BoxFit.cover),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildNotesView(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Icon(Icons.note_alt_outlined,
              size: 48, color: AppColors.cyan),
          const SizedBox(height: AppSpacing.sm),
          Text('Catatan Harian',
              style: AppTypography.h3
                  .copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(
            'Tulis pemikiran cepat, ide, dan catatan pribadimu.',
            style: AppTypography.bodySm.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: () => context.push('/notes'),
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('Buka Halaman Catatan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cyan,
              foregroundColor: AppColors.bgDeep,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionsView(BuildContext context, UserProfile profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Icon(Icons.people_outline,
              size: 48, color: AppColors.cyan),
          const SizedBox(height: AppSpacing.sm),
          Text('${profile.connectionCount} Koneksi',
              style: AppTypography.h3
                  .copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(
            'Kelola koneksi, permintaan berteman, dan jelajahi orang baru.',
            style: AppTypography.bodySm.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: () => context.push('/connections/${profile.id}'),
            icon: const Icon(Icons.people, size: 16),
            label: const Text('Lihat Semua Koneksi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cyan,
              foregroundColor: AppColors.bgDeep,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}

// Error State
class _ProfileError extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ProfileError({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off_outlined,
                  size: 56, color: AppColors.textMuted),
              const SizedBox(height: AppSpacing.md),
              Text('Gagal memuat profil',
                  style:
                      AppTypography.h3.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.sm),
              Text(error,
                  style: AppTypography.bodySm
                      .copyWith(color: AppColors.textMuted),
                  textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyan,
                    foregroundColor: AppColors.bgDeep),
              ),
            ],
          ),
        ),
      );
}