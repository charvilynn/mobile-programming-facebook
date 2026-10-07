import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../profile/widgets/profile_widgets.dart';
import '../../profile/screens/profile_screen.dart';

// Story Models
class StoryItem {
  final int id;
  final String? mediaUrl;
  final String? textContent;
  final String bgColor;
 final String type; // 'image' | 'text'
  final DateTime createdAt;
  final DateTime expiresAt;

  const StoryItem({
    required this.id,
    this.mediaUrl,
    this.textContent,
    required this.bgColor,
    required this.type,
    required this.createdAt,
    required this.expiresAt,
  });

  factory StoryItem.fromJson(Map<String, dynamic> json) {
    return StoryItem(
      id: json['id'] as int? ?? 0,
      mediaUrl: json['mediaUrl'] as String? ?? json['media_url'] as String?,
      textContent: json['textContent'] as String? ?? json['text_content'] as String?,
      bgColor: json['bgColor'] as String? ?? json['bg_color'] as String? ?? '#0F172A',
      type: json['type'] as String? ?? 'text',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString()) ??
              DateTime.now().add(const Duration(hours: 24))
          : DateTime.now().add(const Duration(hours: 24)),
    );
  }
}

class StoryGroup {
  final int userId;
  final String username;
  final String authorName;
  final String? avatarUrl;
  final bool isOwn;
  final bool hasUnseen;
  final List<StoryItem> items;

  const StoryGroup({
    required this.userId,
    required this.username,
    required this.authorName,
    this.avatarUrl,
    this.isOwn = false,
    this.hasUnseen = true,
    required this.items,
  });

  factory StoryGroup.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return StoryGroup(
      userId: json['userId'] as int? ?? 0,
      username: (json['username'] ?? 'user').toString(),
      authorName: (json['authorName'] ?? 'Pengguna').toString(),
      avatarUrl: json['avatarUrl'] as String?,
      isOwn: json['isOwn'] as bool? ?? false,
      hasUnseen: json['hasUnseen'] as bool? ?? true,
      items: rawItems
          .map((i) => StoryItem.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}

// Stories Provider
final storiesProvider =
    FutureProvider.autoDispose<List<StoryGroup>>((ref) async {
  final api = ref.watch(apiClientProvider);
  try {
    final res = await api.get('/stories');
    final rawList = res.data['data'] as List<dynamic>? ?? [];
    return rawList
        .map((g) => StoryGroup.fromJson(g as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
});

Color _parseColor(String? hexString, {Color defaultColor = const Color(0xFF0F172A)}) {
  if (hexString == null || hexString.isEmpty) return defaultColor;
  try {
    String hex = hexString.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse('0x$hex'));
  } catch (_) {
    return defaultColor;
  }
}

// StoryBar
/// Horizontal scrollable story row — Facebook mobile style:
/// Vertical story cards (~9:16 aspect ratio, height 185, width 115)
/// [Add Story Tile] -> [Own Story (if any)] -> [Friends' Stories] -> [Empty hint if 0]
class StoryBar extends ConsumerWidget {
  const StoryBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsync = ref.watch(storiesProvider);

    return SizedBox(
      height: 195,
      child: storiesAsync.when(
        loading: () => ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: 4),
          children: const [
            _AddStoryTile(),
            SizedBox(width: AppSpacing.sm),
            _StoryShimmer(),
          ],
        ),
        error: (_, __) => ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: 4),
          children: const [
            _AddStoryTile(),
            SizedBox(width: AppSpacing.sm),
            _EmptyStoriesHint(),
          ],
        ),
        data: (groups) {
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: 4),
            itemCount: 1 + groups.length + (groups.isEmpty ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (ctx, index) {
              if (index == 0) {
                return const _AddStoryTile();
              }
              if (groups.isEmpty && index == 1) {
                return const _EmptyStoriesHint();
              }
              final group = groups[index - 1];
              return _StoryGroupTile(
                group: group,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => StoryViewerScreen(storyGroup: group),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// Add Story Tile
class _AddStoryTile extends ConsumerWidget {
  const _AddStoryTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider(null)).valueOrNull;

    return GestureDetector(
      onTap: () => showCreateStorySheet(context, ref),
      child: Container(
        width: 115,
        height: 185,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
 // Top Section: User Avatar Image or Gradient
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 56,
              child: profile?.avatarUrl != null &&
                      profile!.avatarUrl!.isNotEmpty
                  ? buildSmartImage(
                      profile.avatarUrl,
                      fit: BoxFit.cover,
                      errorWidget: _buildDefaultAddBg(profile.name),
                    )
                  : _buildDefaultAddBg(profile?.name),
            ),

 // Bottom Section: Title
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 56,
              child: Container(
                color: AppColors.bgSurface,
                padding: const EdgeInsets.only(top: 18, left: 6, right: 6),
                alignment: Alignment.center,
                child: Text(
                  'Buat Cerita',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

 // Floating Plus Button
            Positioned(
              bottom: 38,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.cyan,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.bgSurface, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cyan.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child:
                      Icon(Icons.add, color: AppColors.bgDeep, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAddBg(String? name) {
    return Container(
      color: AppColors.cyan.withValues(alpha: 0.15),
      child: Center(
        child: Icon(Icons.person,
            size: 48, color: AppColors.cyan.withValues(alpha: 0.6)),
      ),
    );
  }
}

// Story Group Tile (Vertical Facebook Card)
class _StoryGroupTile extends StatelessWidget {
  final StoryGroup group;
  final VoidCallback onTap;

  const _StoryGroupTile({
    required this.group,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatarProvider = getSmartImageProvider(group.avatarUrl);
    final firstItem = group.items.isNotEmpty ? group.items.first : null;
    final hasImage =
        firstItem?.mediaUrl != null && firstItem!.mediaUrl!.isNotEmpty;
    final hasText =
        firstItem?.textContent != null && firstItem!.textContent!.isNotEmpty;
    final bgColor = _parseColor(firstItem?.bgColor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 115,
        height: 185,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: group.isOwn
                ? AppColors.cyan
                : (group.hasUnseen ? AppColors.cyan : AppColors.borderSubtle),
            width: group.hasUnseen ? 2 : 1,
          ),
          boxShadow: [
            if (group.hasUnseen)
              BoxShadow(
                color: AppColors.cyan.withValues(alpha: 0.25),
                blurRadius: 8,
              ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
 // 1. Background Content (Image or Text Gradient)
            if (hasImage)
              buildSmartImage(
                firstItem.mediaUrl,
                fit: BoxFit.cover,
                errorWidget: Container(color: AppColors.bgCard),
              )
            else if (hasText)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      bgColor,
                      bgColor.withValues(alpha: 0.7),
                      const Color(0xFF0F172A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 36),
                alignment: Alignment.center,
                child: Text(
                  firstItem.textContent ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              )
            else
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

 // 2. Dark Gradient Overlay for text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

 // 3. Author Avatar with Ring (Top-Left)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      AppColors.cyan,
                      AppColors.magenta,
                      AppColors.cyan,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: AppColors.bgSurface,
                  backgroundImage: avatarProvider,
                  child: avatarProvider == null
                      ? Text(
                          group.authorName.isNotEmpty
                              ? group.authorName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: AppColors.cyan,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        )
                      : null,
                ),
              ),
            ),

 // 4. Author Name (Bottom-Left)
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                group.isOwn ? 'Cerita Anda' : group.authorName,
                style: TextStyle(
                  color: group.isOwn ? AppColors.cyan : Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  shadows: const [
                    Shadow(
                      color: Colors.black87,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Shimmer & Empty State
class _StoryShimmer extends StatelessWidget {
  const _StoryShimmer();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 115,
      height: 185,
      decoration: BoxDecoration(
        color: AppColors.bgCard.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.cyan),
        ),
      ),
    );
  }
}

class _EmptyStoriesHint extends StatelessWidget {
  const _EmptyStoriesHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 125,
      height: 185,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.cyan.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_stories_outlined,
                color: AppColors.cyan, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            'Belum ada story',
            style: AppTypography.labelSm.copyWith(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            'dari teman Anda',
            style: AppTypography.labelSm.copyWith(
              color: AppColors.textMuted,
              fontSize: 10.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// showCreateStorySheet
void showCreateStorySheet(BuildContext context, [WidgetRef? ref]) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.bgCard,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (modalCtx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Buat Story',
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Bagikan momen Anda yang hilang dalam 24 jam',
              style: AppTypography.labelSm.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.lg),

 // 1. Pilih dari Galeri (Photo Story)
            _CreateOption(
              icon: Icons.photo_library_outlined,
              label: 'Pilih dari Galeri',
              subtitle: 'Bagikan foto story 24 jam',
              onTap: () async {
                Navigator.pop(modalCtx);
                await _handlePhotoStory(context, ref);
              },
            ),
            const SizedBox(height: AppSpacing.sm),

 // 2. Story Teks (Text Story with Gradients)
            _CreateOption(
              icon: Icons.text_fields_rounded,
              label: 'Story Teks',
              subtitle: 'Buat story dengan teks & warna gradasi',
              onTap: () {
                Navigator.pop(modalCtx);
                _showTextStoryDialog(context, ref);
              },
            ),
            const SizedBox(height: AppSpacing.sm),

 // 3. Buat Catatan (Notes)
            _CreateOption(
              icon: Icons.edit_note_rounded,
              label: 'Buat Catatan',
              subtitle: 'Tulis status heyo / pemikiran di profil Anda',
              onTap: () {
                Navigator.pop(modalCtx);
                context.push('/notes/create');
              },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    ),
  );
}

class _CreateOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _CreateOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.cyan.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.cyan, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySm
                        .copyWith(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

// Photo Story Handler
Future<void> _handlePhotoStory(BuildContext context, [WidgetRef? ref]) async {
  try {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
      maxHeight: 1200,
    );
    if (file == null) return;

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.cyan),
            ),
            SizedBox(width: 12),
            Text('Mengunggah story foto...'),
          ],
        ),
        backgroundColor: AppColors.bgCard,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
      ),
    );

    final bytes = await file.readAsBytes();
    final b64 = base64Encode(bytes);
    final mime = file.mimeType ?? 'image/jpeg';
    final dataUri = 'data:$mime;base64,$b64';

    final container = ProviderScope.containerOf(context, listen: false);
    final api = container.read(apiClientProvider);

    await api.post('/stories', data: {
      'media_url': dataUri,
      'type': 'image',
    });

    container.invalidate(storiesProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Story foto berhasil dibagikan!'),
          backgroundColor: AppColors.bgCard,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengunggah story: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// Text Story Dialog
void _showTextStoryDialog(BuildContext context, [WidgetRef? ref]) {
  showDialog(
    context: context,
    builder: (dlgCtx) => _TextStoryDialog(ref: ref),
  );
}

class _TextStoryDialog extends StatefulWidget {
  final WidgetRef? ref;
  const _TextStoryDialog({this.ref});

  @override
  State<_TextStoryDialog> createState() => _TextStoryDialogState();
}

class _TextStoryDialogState extends State<_TextStoryDialog> {
  final _ctrl = TextEditingController();
  bool _isPosting = false;

  final List<Map<String, dynamic>> _gradients = [
    {
      'name': 'Deep Space',
      'hex': '#0F172A',
      'colors': [const Color(0xFF0F172A), const Color(0xFF1E293B)],
    },
    {
      'name': 'Neon Cyan',
      'hex': '#083344',
      'colors': [const Color(0xFF083344), const Color(0xFF0E7490)],
    },
    {
      'name': 'Sunset Violet',
      'hex': '#3B0764',
      'colors': [const Color(0xFF3B0764), const Color(0xFF701A75)],
    },
    {
      'name': 'Ruby Ember',
      'hex': '#4C0519',
      'colors': [const Color(0xFF4C0519), const Color(0xFF9F1239)],
    },
    {
      'name': 'Emerald Glow',
      'hex': '#064E3B',
      'colors': [const Color(0xFF064E3B), const Color(0xFF047857)],
    },
  ];

  int _selectedGradient = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _postTextStory() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    setState(() => _isPosting = true);
    try {
      final container = ProviderScope.containerOf(context, listen: false);
      final api = container.read(apiClientProvider);

      await api.post('/stories', data: {
        'text_content': text,
        'bg_color': _gradients[_selectedGradient]['hex'],
        'type': 'text',
      });

      container.invalidate(storiesProvider);

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Story teks berhasil dibagikan!'),
          backgroundColor: AppColors.bgCard,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat story teks: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentGradient = _gradients[_selectedGradient]['colors'] as List<Color>;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
 // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 12, 10),
              child: Row(
                children: [
                  Icon(Icons.text_fields_rounded,
                      color: AppColors.cyan, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Story Teks',
                    style: AppTypography.h3.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.borderSubtle),

 // Live Preview Canvas
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: currentGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: TextField(
                    controller: _ctrl,
                    maxLines: 4,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                      shadows: [
                        Shadow(color: Colors.black54, blurRadius: 4),
                      ],
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Ketik sesuatu untuk dibagikan ke story...',
                      hintStyle: TextStyle(
                        color: Colors.white60,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
            ),

 // Color Palette Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pilih Warna Latar',
                      style: AppTypography.labelSm
                          .copyWith(color: AppColors.textMuted)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _gradients.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (ctx, idx) {
                        final g = _gradients[idx];
                        final colors = g['colors'] as List<Color>;
                        final isSelected = _selectedGradient == idx;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedGradient = idx),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: colors),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: colors.first.withValues(alpha: 0.8),
                                    blurRadius: 6,
                                  ),
                              ],
                            ),
                            child: isSelected
                                ? const Icon(Icons.check,
                                    size: 16, color: Colors.white)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

 // Action Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ElevatedButton(
                onPressed: _ctrl.text.trim().isNotEmpty && !_isPosting
                    ? _postTextStory
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyan,
                  foregroundColor: AppColors.bgDeep,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isPosting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.bgDeep),
                      )
                    : const Text(
                        'Bagikan ke Story',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// StoryViewerScreen (Full Screen Story Viewer)
class StoryViewerScreen extends StatefulWidget {
  final StoryGroup storyGroup;
  const StoryViewerScreen({super.key, required this.storyGroup});

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 6), () {
      if (_currentIndex < widget.storyGroup.items.length - 1) {
        setState(() => _currentIndex++);
        _startTimer();
      } else {
        if (mounted) Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _previous() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _startTimer();
    }
  }

  void _next() {
    if (_currentIndex < widget.storyGroup.items.length - 1) {
      setState(() => _currentIndex++);
      _startTimer();
    } else {
      Navigator.of(context).pop();
    }
  }

  Color _parseColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return const Color(0xFF0F172A);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.storyGroup.items.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text('Tidak ada item story',
              style: AppTypography.bodyMd.copyWith(color: Colors.white)),
        ),
      );
    }

    final currentItem = widget.storyGroup.items[_currentIndex];
    final authorAvatar = getSmartImageProvider(widget.storyGroup.avatarUrl);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
 // Story Content Canvas
            Positioned.fill(
              child: GestureDetector(
                onTapUp: (details) {
                  final width = MediaQuery.of(context).size.width;
                  if (details.localPosition.dx < width / 3) {
                    _previous();
                  } else {
                    _next();
                  }
                },
                child: currentItem.type == 'image' &&
                        currentItem.mediaUrl != null
                    ? Container(
                        color: Colors.black,
                        child: Center(
                          child: Builder(
                            builder: (context) {
                              final imgProvider =
                                  getSmartImageProvider(currentItem.mediaUrl);
                              if (imgProvider != null) {
                                return Image(
                                  image: imgProvider,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(Icons.broken_image,
                                        size: 48, color: Colors.white54),
                                  ),
                                );
                              }
                              return const Center(
                                child: Icon(Icons.broken_image,
                                    size: 48, color: Colors.white54),
                              );
                            },
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _parseColor(currentItem.bgColor),
                              _parseColor(currentItem.bgColor)
                                  .withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Center(
                          child: Text(
                            currentItem.textContent ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                              shadows: [
                                Shadow(
                                  color: Colors.black87,
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            ),

 // Top Gradient Overlay for Readability
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 110,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black87, Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

 // Progress Indicators
            Positioned(
              top: 8,
              left: 12,
              right: 12,
              child: Row(
                children: List.generate(widget.storyGroup.items.length, (i) {
                  return Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: i <= _currentIndex
                            ? AppColors.cyan
                            : Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

 // Author Header & Close Button
            Positioned(
              top: 20,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.cyan.withValues(alpha: 0.2),
                    backgroundImage: authorAvatar,
                    child: authorAvatar == null
                        ? Text(
                            widget.storyGroup.authorName.isNotEmpty
                                ? widget.storyGroup.authorName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                                color: AppColors.cyan,
                                fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.storyGroup.authorName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '@${widget.storyGroup.username}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: Colors.white, size: 24),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
