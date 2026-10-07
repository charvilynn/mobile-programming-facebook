import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../../profile/screens/profile_screen.dart';
import '../providers/feed_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/post_create_widgets.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _contentCtrl = TextEditingController();
  String _privacy = 'public';
  String? _feeling;
  final List<String> _mediaUrls = [];
  final List<Map<String, dynamic>> _taggedFriends = [];
  bool _isPosting = false;
  bool _hasContent = false;

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  void _onContentChanged(String v) {
    final trimmed = v.trim();
 // Guard: if user pasted raw base64 or data URI into the text field,
 // convert it into a photo attachment automatically!
    if (trimmed.length > 80 &&
        !trimmed.contains(' ') &&
        (trimmed.startsWith('data:image') ||
         trimmed.startsWith('/9j/') ||
         trimmed.startsWith('iVBOR') ||
         trimmed.startsWith('AAt4') ||
         trimmed.startsWith('AAAA'))) {
      final imgUrl = trimmed.startsWith('data:image')
          ? trimmed
          : 'data:image/jpeg;base64,$trimmed';
      setState(() {
        _mediaUrls.add(imgUrl);
        _contentCtrl.clear();
        _hasContent = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gambar dari teks berhasil dilampirkan ke foto postingan.'),
            backgroundColor: AppColors.bgSurface,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    setState(() => _hasContent = v.trim().isNotEmpty);
  }

  void _showTagFriendsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _TagFriendsSheet(
        initiallyTagged: _taggedFriends,
        onDone: (selected) {
          setState(() {
            _taggedFriends.clear();
            _taggedFriends.addAll(selected);
          });
        },
      ),
    );
  }

  void _showAddPhotoModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Lampirkan Foto',
                  style: AppTypography.h3.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.photo_library_outlined,
                      color: AppColors.cyan),
                ),
                title: Text('Pilih dari Komputer / Galeri',
                    style: AppTypography.bodyMd.copyWith(color: AppColors.textPrimary)),
                subtitle: Text('Format PNG, JPG, WEBP',
                    style: AppTypography.labelSm.copyWith(color: AppColors.textMuted)),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.magenta.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.link_rounded,
                      color: AppColors.magenta),
                ),
                title: Text('Tempel Tautan / URL Gambar',
                    style: AppTypography.bodyMd.copyWith(color: AppColors.textPrimary)),
                subtitle: Text('Gunakan tautan gambar langsung dari internet',
                    style: AppTypography.labelSm.copyWith(color: AppColors.textMuted)),
                onTap: () {
                  Navigator.pop(context);
                  _showImageUrlDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (file != null) {
        try {
          final bytes = await file.readAsBytes();
          final base64Str = base64Encode(bytes);
          final mime = file.mimeType ?? 'image/jpeg';
          final dataUri = 'data:$mime;base64,$base64Str';
          setState(() {
            _mediaUrls.add(dataUri);
          });
        } catch (_) {
          setState(() {
            _mediaUrls.add(file.path);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal memilih gambar: $e'),
          backgroundColor: AppColors.bgCard,
        ));
      }
    }
  }

  void _showImageUrlDialog() {
    final urlCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.borderSubtle),
        ),
        title: Text('Tautan Gambar',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary)),
        content: TextField(
          controller: urlCtrl,
          style: AppTypography.bodyMd.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
 hintText: 'https://example.com/gambar.jpg',
            hintStyle: AppTypography.bodySm.copyWith(color: AppColors.textMuted),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.cyan),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal',
                style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final url = urlCtrl.text.trim();
              if (url.isNotEmpty) {
                setState(() => _mediaUrls.add(url));
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cyan,
              foregroundColor: AppColors.bgDeep,
            ),
            child: const Text('Tambahkan'),
          ),
        ],
      ),
    );
  }

  void _showFeelingPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bagaimana perasaanmu?',
                style: AppTypography.h3.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 280,
              child: FeelingPickerGrid(
                onSelect: (feeling) {
                  setState(() => _feeling = feeling);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _post() async {
    final text = _contentCtrl.text.trim();
    if (text.isEmpty && _mediaUrls.isEmpty && _taggedFriends.isEmpty) return;
    setState(() => _isPosting = true);

    try {
      final api = ref.read(apiClientProvider);
      final res = await api.post('/posts', data: {
        'content': text.isNotEmpty ? text : ' ',
        'visibility': _privacy,
        'mediaUrls': _mediaUrls,
        'taggedUsers': _taggedFriends,
        'taggedUserIds': _taggedFriends.map((f) => f['id']).toList(),
      });

      if (res.data != null && res.data['data'] != null) {
        final postJson = Map<String, dynamic>.from(res.data['data'] as Map);
        final createdPost = PostData.fromJson(postJson);
        ref.read(feedProvider.notifier).addPost(createdPost);
      } else {
 // Fallback local add
        final profile = ref.read(profileProvider(null)).valueOrNull;
        final newPost = PostData(
          id: DateTime.now().millisecondsSinceEpoch,
          author: PostAuthor(
            id: profile?.id ?? 1,
            name: profile?.name.isNotEmpty == true ? profile!.name : 'Saya',
            avatarUrl: profile?.avatarUrl,
          ),
          content: text,
          mediaUrls: _mediaUrls,
          taggedUserNames: _taggedFriends
              .map((f) => (f['full_name'] ?? f['name'] ?? f['username'] ?? '').toString())
              .where((s) => s.isNotEmpty)
              .toList(),
          visibility: _privacy,
          reactionCount: 0,
          commentCount: 0,
          shareCount: 0,
          createdAt: DateTime.now(),
          feeling: _feeling,
        );
        ref.read(feedProvider.notifier).addPost(newPost);
      }

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal membuat postingan: $e'),
          backgroundColor: AppColors.bgCard,
        ));
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  Widget _buildPreviewThumbnail(String url) {
    final trimmed = url.trim();
    if (trimmed.startsWith('data:image') || trimmed.startsWith('data:')) {
      try {
        final b64 = trimmed.contains(',') ? trimmed.split(',').last : trimmed;
        return Image.memory(
          base64Decode(b64),
          width: 84, height: 84,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 84, height: 84,
            color: AppColors.bgSurface,
            child: Icon(Icons.broken_image_outlined, color: AppColors.textMuted),
          ),
        );
      } catch (_) {}
    }
    return Image.network(
      trimmed,
      width: 84, height: 84,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: 84, height: 84,
        color: AppColors.bgSurface,
        child: Icon(Icons.broken_image_outlined, color: AppColors.textMuted),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider(null)).valueOrNull;
    final userName = profile != null && profile.name.isNotEmpty ? profile.name : 'Saya';
    final canPost = (_hasContent || _mediaUrls.isNotEmpty || _taggedFriends.isNotEmpty) && !_isPosting;

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.textSecondary),
          onPressed: () => context.pop(),
        ),
        title: Text('Buat Postingan',
            style: AppTypography.labelLg.copyWith(color: AppColors.textPrimary)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: ElevatedButton(
              onPressed: canPost ? _post : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cyan,
                foregroundColor: AppColors.bgDeep,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: _isPosting
                  ? SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.bgDeep))
                  : Text('Posting',
                      style: AppTypography.labelMd
                          .copyWith(color: AppColors.bgDeep,
                              fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
 // Author + Privacy
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.cyan.withValues(alpha: 0.18),
                  backgroundImage: profile?.avatarUrl != null
                      ? NetworkImage(profile!.avatarUrl!)
                      : null,
                  child: profile?.avatarUrl == null
                      ? Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                          style: AppTypography.labelMd.copyWith(
                              color: AppColors.cyan, fontWeight: FontWeight.w700),
                        )
                      : null,
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName,
                        style: AppTypography.labelMd
                            .copyWith(color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    GestureDetector(
                      onTap: () => PostPrivacySelector.show(
                        context,
                        current: _privacy,
                        onChanged: (v) => setState(() => _privacy = v),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.bgSurface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _privacy == 'public'
                                  ? Icons.public
                                  : _privacy == 'connections'
                                      ? Icons.people_outline
                                      : Icons.lock_outline,
                              size: 12,
                              color: AppColors.cyan,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _privacy == 'public'
                                  ? 'Semua Orang'
                                  : _privacy == 'connections'
                                      ? 'Koneksi'
                                      : 'Hanya Saya',
                              style: AppTypography.labelSm
                                  .copyWith(color: AppColors.cyan),
                            ),
                            const SizedBox(width: 2),
                            Icon(Icons.keyboard_arrow_down,
                                size: 12, color: AppColors.cyan),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

 // Content Input
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: TextField(
                controller: _contentCtrl,
                onChanged: _onContentChanged,
                style: AppTypography.bodyMd
                    .copyWith(color: AppColors.textPrimary, height: 1.6),
                maxLines: null,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: _feeling != null
                      ? 'Ceritakan lebih lanjut perasaan kamu...'
                      : 'Apa yang sedang kamu pikirkan?',
                  hintStyle: AppTypography.bodyMd
                      .copyWith(color: AppColors.textMuted),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

 // Tagged Friends Chips
          if (_taggedFriends.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _taggedFriends.map((f) {
                    final name = (f['full_name'] ?? f['name'] ?? f['username'] ?? 'Teman').toString();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.cyan.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_pin_rounded,
                              size: 13, color: AppColors.cyan),
                          const SizedBox(width: 4),
                          Text('bersama $name',
                              style: AppTypography.labelSm
                                  .copyWith(color: AppColors.cyan)),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _taggedFriends.remove(f)),
                            child: Icon(Icons.close,
                                size: 12, color: AppColors.cyan),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

 // Feeling indicator
          if (_feeling != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.magenta.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.magenta.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.emoji_emotions_outlined,
                            size: 14, color: AppColors.magenta),
                        const SizedBox(width: 4),
                        Text('merasa $_feeling',
                            style: AppTypography.labelSm
                                .copyWith(color: AppColors.magenta)),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => setState(() => _feeling = null),
                          child: const Icon(Icons.close,
                              size: 12, color: AppColors.magenta),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

 // Media previews
          if (_mediaUrls.isNotEmpty)
            SizedBox(
              height: 84,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: _mediaUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildPreviewThumbnail(_mediaUrls[i]),
                    ),
                    Positioned(
                      top: 4, right: 4,
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _mediaUrls.removeAt(i)),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                              color: Colors.black87,
                              shape: BoxShape.circle),
                          child: const Icon(Icons.close,
                              size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

 // Toolbar
          CreatePostToolbar(
            onAddPhoto: _showAddPhotoModal,
            onAddFeeling: _showFeelingPicker,
            onAddTag: _showTagFriendsModal,
          ),
        ],
      ),
    );
  }
}

// _TagFriendsSheet
class _TagFriendsSheet extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> initiallyTagged;
  final ValueChanged<List<Map<String, dynamic>>> onDone;

  const _TagFriendsSheet({
    required this.initiallyTagged,
    required this.onDone,
  });

  @override
  ConsumerState<_TagFriendsSheet> createState() => _TagFriendsSheetState();
}

class _TagFriendsSheetState extends ConsumerState<_TagFriendsSheet> {
  final _searchCtrl = TextEditingController();
  final List<Map<String, dynamic>> _selected = [];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selected.addAll(widget.initiallyTagged);
    _searchUsers('');
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.get('/users/search', queryParameters: {'q': query});
      if (res.data != null && res.data['data'] != null) {
        final list = (res.data['data'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        if (mounted) setState(() => _searchResults = list);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.65,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
 // Handle bar
            Center(
              child: Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tag Teman',
                    style: AppTypography.h3.copyWith(color: AppColors.textPrimary)),
                ElevatedButton(
                  onPressed: () {
                    widget.onDone(_selected);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyan,
                    foregroundColor: AppColors.bgDeep,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Selesai (${_selected.length})',
                      style: AppTypography.labelSm.copyWith(
                          color: AppColors.bgDeep, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
 // Search Input
            TextField(
              controller: _searchCtrl,
              onChanged: (v) => _searchUsers(v.trim()),
              style: AppTypography.bodyMd.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 20),
                hintText: 'Cari teman untuk ditandai...',
                hintStyle: AppTypography.bodySm.copyWith(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.bgSurface,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.borderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.cyan),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
 // List of Users
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: AppColors.cyan, strokeWidth: 2))
                  : _searchResults.isEmpty
                      ? Center(
                          child: Text(
                            _searchCtrl.text.isEmpty
                                ? 'Ketik nama pengguna untuk mencari teman'
                                : 'Tidak ada pengguna ditemukan',
                            style: AppTypography.bodySm.copyWith(color: AppColors.textMuted),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _searchResults.length,
                          separatorBuilder: (_, __) =>
                              Divider(color: AppColors.borderSubtle, height: 1),
                          itemBuilder: (ctx, i) {
                            final user = _searchResults[i];
                            final id = user['id'];
                            final isTagged = _selected.any((u) => u['id'] == id);
                            final name = (user['full_name'] ?? user['name'] ?? user['username'] ?? 'User').toString();
                            final username = (user['username'] ?? '').toString();
                            final avatarUrl = user['avatar_url'] as String?;

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.cyan.withValues(alpha: 0.18),
                                backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                                    ? NetworkImage(avatarUrl)
                                    : null,
                                child: avatarUrl == null
                                    ? Text(
                                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                                        style: AppTypography.labelMd.copyWith(
                                            color: AppColors.cyan, fontWeight: FontWeight.w700),
                                      )
                                    : null,
                              ),
                              title: Text(name,
                                  style: AppTypography.labelMd.copyWith(
                                      color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                              subtitle: Text('@$username',
                                  style: AppTypography.labelSm.copyWith(color: AppColors.textMuted)),
                              trailing: Icon(
                                isTagged ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                                color: isTagged ? AppColors.cyan : AppColors.textMuted,
                              ),
                              onTap: () {
                                setState(() {
                                  if (isTagged) {
                                    _selected.removeWhere((u) => u['id'] == id);
                                  } else {
                                    _selected.add(user);
                                  }
                                });
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
