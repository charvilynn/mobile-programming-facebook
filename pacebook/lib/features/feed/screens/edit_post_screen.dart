import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../widgets/post_card.dart';
import '../widgets/post_create_widgets.dart';

// EditPostScreen
/// Layar Edit Post —
/// Memuat post yang ada, lalu izinkan edit teks, privasi, dan foto.
class EditPostScreen extends ConsumerStatefulWidget {
  final int postId;
  const EditPostScreen({super.key, required this.postId});

  @override
  ConsumerState<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends ConsumerState<EditPostScreen> {
  final _textCtrl = TextEditingController();
  String _privacy = 'public';
  bool _isLoading = true;
  bool _isSaving = false;
  PostData? _originalPost;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPost() async {
 // Mock: load post berdasarkan postId
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      final mock = PostData(
        id: widget.postId,
        author: const PostAuthor(id: 1, name: 'Davvin Pratama'),
        content: 'Ini adalah postingan #${widget.postId} yang sedang diedit.',
        mediaUrls: [],
        visibility: 'public',
        reactionCount: 12,
        commentCount: 3,
        shareCount: 1,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      );
      setState(() {
        _originalPost = mock;
        _textCtrl.text = mock.content;
        _privacy = mock.visibility;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveEdit() async {
    if (_textCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Konten post tidak boleh kosong.',
            style: AppTypography.bodySm.copyWith(color: AppColors.textPrimary)),
        backgroundColor: AppColors.bgCard,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _isSaving = true);
 // TODO: panggil API PATCH /posts/:id
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Postingan berhasil diperbarui!',
            style: AppTypography.bodySm.copyWith(color: AppColors.textPrimary)),
        backgroundColor: AppColors.bgCard,
        behavior: SnackBarBehavior.floating,
      ));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.textSecondary, size: 22),
          onPressed: () => _showDiscardDialog(),
        ),
        title: Text('Edit Postingan',
            style: AppTypography.labelLg.copyWith(color: AppColors.textPrimary)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: _isSaving
                ? SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                        color: AppColors.cyan, strokeWidth: 2))
                : ElevatedButton(
                    onPressed: _textCtrl.text.trim().isNotEmpty ? _saveEdit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cyan,
                      foregroundColor: AppColors.bgDeep,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: 6),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text('Simpan',
                        style: AppTypography.labelMd.copyWith(
                            color: AppColors.bgDeep,
                            fontWeight: FontWeight.w600)),
                  ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.cyan, strokeWidth: 2))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
 // Author info row
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.cyan.withValues(alpha: 0.18),
                          child: Text(
                            _originalPost?.author.name.isNotEmpty == true
                                ? _originalPost!.author.name[0].toUpperCase()
                                : 'D',
                            style: AppTypography.labelMd
                                .copyWith(color: AppColors.cyan),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _originalPost?.author.name ?? 'Davvin',
                              style: AppTypography.labelMd.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600),
                            ),
 // Privacy selector pill
                            GestureDetector(
                              onTap: () => _showPrivacyPicker(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.bgSurface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: AppColors.borderSubtle),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _privacy == 'public'
                                          ? Icons.public
                                          : _privacy == 'friends'
                                              ? Icons.people_outline
                                              : Icons.lock_outline,
                                      size: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      _privacy == 'public'
                                          ? 'Semua Orang'
                                          : _privacy == 'friends'
                                              ? 'Teman'
                                              : 'Hanya Saya',
                                      style: AppTypography.labelSm.copyWith(
                                          color: AppColors.textSecondary),
                                    ),
                                    const SizedBox(width: 3),
                                    Icon(Icons.arrow_drop_down,
                                        size: 14, color: AppColors.textMuted),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

 // Text editor
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md),
                    child: TextField(
                      controller: _textCtrl,
                      maxLines: null,
                      minLines: 5,
                      onChanged: (_) => setState(() {}),
                      style: AppTypography.bodyMd
                          .copyWith(color: AppColors.textPrimary, height: 1.6),
                      decoration: InputDecoration(
                        hintText: 'Apa yang ada di pikiranmu?',
                        hintStyle: AppTypography.bodyMd
                            .copyWith(color: AppColors.textMuted),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

 // Toolbar (foto, perasaan, dll)
                  Divider(color: AppColors.borderSubtle),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tambahkan ke postingan',
                            style: AppTypography.labelSm
                                .copyWith(color: AppColors.textMuted)),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            _ToolbarBtn(
                              icon: Icons.photo_outlined,
                              color: AppColors.success,
                              label: 'Foto',
                              onTap: () {},
                            ),
                            _ToolbarBtn(
                              icon: Icons.tag_faces_outlined,
                              color: AppColors.warning,
                              label: 'Perasaan',
                              onTap: () {},
                            ),
                            _ToolbarBtn(
                              icon: Icons.location_on_outlined,
                              color: AppColors.error,
                              label: 'Lokasi',
                              onTap: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
    );
  }

  void _showPrivacyPicker() {
    PostPrivacySelector.show(
      context,
      current: _privacy,
      onChanged: (p) => setState(() => _privacy = p),
    );
  }

  void _showDiscardDialog() {
    final changed = _textCtrl.text != (_originalPost?.content ?? '') ||
        _privacy != (_originalPost?.visibility ?? 'public');
    if (!changed) {
      context.pop();
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: Text('Buang perubahan?',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary)),
        content: Text('Perubahan yang belum disimpan akan hilang.',
            style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal',
                style: AppTypography.labelMd
                    .copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: Text('Buang',
                style: AppTypography.labelMd.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// Toolbar button
class _ToolbarBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ToolbarBtn({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 4),
              Text(label,
                  style: AppTypography.labelSm
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
}
