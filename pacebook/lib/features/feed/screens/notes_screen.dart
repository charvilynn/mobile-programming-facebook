import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../profile/screens/profile_screen.dart';
import '../../profile/widgets/profile_widgets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';

// Music Song Model & 20 Western Hit Songs
class NoteSong {
  final String title;
  final String artist;
  final String duration;
  final Color color;

  const NoteSong({
    required this.title,
    required this.artist,
    required this.duration,
    required this.color,
  });
}

const List<NoteSong> kPopularWesternSongs = [
  NoteSong(title: 'Cruel Summer', artist: 'Taylor Swift', duration: '2:58', color: Color(0xFFE11D48)),
  NoteSong(title: 'Blinding Lights', artist: 'The Weeknd', duration: '3:20', color: Color(0xFFDC2626)),
  NoteSong(title: 'As It Was', artist: 'Harry Styles', duration: '2:47', color: Color(0xFF2563EB)),
  NoteSong(title: 'Birds of a Feather', artist: 'Billie Eilish', duration: '3:18', color: Color(0xFF0D9488)),
  NoteSong(title: 'Espresso', artist: 'Sabrina Carpenter', duration: '2:55', color: Color(0xFFD97706)),
  NoteSong(title: 'Vampire', artist: 'Olivia Rodrigo', duration: '3:39', color: Color(0xFF7C3AED)),
  NoteSong(title: 'Shape of You', artist: 'Ed Sheeran', duration: '3:53', color: Color(0xFF059669)),
  NoteSong(title: 'Levitating', artist: 'Dua Lipa', duration: '3:23', color: Color(0xFFDB2777)),
  NoteSong(title: 'STAY', artist: 'The Kid LAROI & Justin Bieber', duration: '2:21', color: Color(0xFF4F46E5)),
  NoteSong(title: 'Flowers', artist: 'Miley Cyrus', duration: '3:20', color: Color(0xFFCA8A04)),
  NoteSong(title: 'Starboy', artist: 'The Weeknd ft. Daft Punk', duration: '3:50', color: Color(0xFF9333EA)),
  NoteSong(title: 'Golden Hour', artist: 'JVKE', duration: '3:29', color: Color(0xFFEAB308)),
  NoteSong(title: 'Someone You Loved', artist: 'Lewis Capaldi', duration: '3:02', color: Color(0xFF64748B)),
  NoteSong(title: 'Save Your Tears', artist: 'The Weeknd', duration: '3:35', color: Color(0xFFE11D48)),
  NoteSong(title: 'Bad Guy', artist: 'Billie Eilish', duration: '3:14', color: Color(0xFF16A34A)),
  NoteSong(title: 'Watermelon Sugar', artist: 'Harry Styles', duration: '2:54', color: Color(0xFFF43F5E)),
  NoteSong(title: 'Heat Waves', artist: 'Glass Animals', duration: '3:58', color: Color(0xFF0284C7)),
  NoteSong(title: 'Anti-Hero', artist: 'Taylor Swift', duration: '3:20', color: Color(0xFF475569)),
  NoteSong(title: 'Believer', artist: 'Imagine Dragons', duration: '3:24', color: Color(0xFFB91C1C)),
  NoteSong(title: 'Perfect', artist: 'Ed Sheeran', duration: '4:23', color: Color(0xFF0D9488)),
];

// Decorative GIF / Sticker Model
class NoteGif {
  final String label;
  final String emoji;
  final String tag;
  const NoteGif({required this.label, required this.emoji, required this.tag});
}

const List<NoteGif> kDecorativeGifs = [
  NoteGif(label: 'Vibing Cat', emoji: '🐱🎵', tag: 'cat'),
  NoteGif(label: 'Sparkles', emoji: '✨✨', tag: 'sparkles'),
  NoteGif(label: 'Chill Coffee', emoji: '☕🍩', tag: 'coffee'),
  NoteGif(label: 'Fire Mood', emoji: '🔥🔥', tag: 'fire'),
  NoteGif(label: 'Dancing', emoji: '💃🎉', tag: 'dance'),
  NoteGif(label: 'Night Owl', emoji: '🌙⭐', tag: 'night'),
  NoteGif(label: 'Headphones', emoji: '🎧🎶', tag: 'music'),
  NoteGif(label: 'Rocket High', emoji: '🚀✨', tag: 'rocket'),
];

// Notes Screen
class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider(null));

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        surfaceTintColor: Colors.transparent,
        title: Text('Catatan',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppColors.cyan, size: 24),
            tooltip: 'Tulis Catatan',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateNoteScreen()),
            ),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: AppColors.cyan, strokeWidth: 2),
        ),
        error: (_, __) => const _NotesEmpty(),
        data: (profile) {
          final currentNote = profile.thoughtNote;
          final hasNote = currentNote != null && currentNote.trim().isNotEmpty;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
 // Top Header / User Note Preview
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: AppColors.cyan.withValues(alpha: 0.15),
                          backgroundImage: getSmartImageProvider(profile.avatarUrl),
                          child: profile.avatarUrl == null
                              ? Text(
                                  profile.name.isNotEmpty
                                      ? profile.name[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                      color: AppColors.cyan,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                )
                              : null,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name,
                                style: AppTypography.labelLg.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                hasNote
                                    ? 'Catatan aktif saat ini'
                                    : 'Belum ada catatan aktif',
                                style: AppTypography.bodySm.copyWith(
                                    color: hasNote
                                        ? AppColors.cyan
                                        : AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CreateNoteScreen()),
                          ),
                          icon: Icon(hasNote ? Icons.edit : Icons.add, size: 14),
                          label: Text(hasNote ? 'Ubah' : 'Tulis'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cyan,
                            foregroundColor: AppColors.bgDeep,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            minimumSize: const Size(0, 34),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                            textStyle: AppTypography.labelSm.copyWith(
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    if (hasNote) ...[
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.bgSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.cyan.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentNote,
                              style: AppTypography.bodyMd.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

 // Feature explanation
              Row(
                children: [
                  Icon(Icons.music_note_rounded,
                      color: AppColors.cyan, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Fitur Catatan Pacebook',
                    style: AppTypography.h3.copyWith(
                        color: AppColors.textPrimary, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Bagikan pemikiran singkat hingga 60 karakter, sematkan lagu barat favorit dari 20 playlist hits, atau hiasi catatanmu dengan stiker GIF.',
                style: AppTypography.bodySm.copyWith(
                    color: AppColors.textSecondary, height: 1.4),
              ),

              const SizedBox(height: AppSpacing.lg),

 // Songs preview section
              Text(
                'Lagu Barat Populer Tersedia (20 Lagu)',
                style: AppTypography.labelMd.copyWith(
                    color: AppColors.textPrimary, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
 itemCount: 5, // Show first 5 previews
                  separatorBuilder: (_, __) =>
                      Divider(color: AppColors.borderSubtle, height: 1),
                  itemBuilder: (_, i) {
                    final song = kPopularWesternSongs[i];
                    return ListTile(
                      dense: true,
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: song.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.music_note, color: song.color, size: 20),
                      ),
                      title: Text(song.title,
                          style: AppTypography.labelMd.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600)),
                      subtitle: Text(song.artist,
                          style: AppTypography.bodySm
                              .copyWith(color: AppColors.textMuted, fontSize: 12)),
                      trailing: Text(song.duration,
                          style: AppTypography.labelSm
                              .copyWith(color: AppColors.textMuted)),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateNoteScreen()),
                  ),
                  child: Text('Buka Pemilih Catatan & Musik Lengkap →',
                      style: TextStyle(color: AppColors.cyan, fontSize: 13)),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateNoteScreen()),
        ),
        backgroundColor: AppColors.cyan,
        foregroundColor: AppColors.bgDeep,
        icon: const Icon(Icons.edit_note, size: 22),
        label: Text('Tulis Catatan',
            style: AppTypography.labelMd.copyWith(
                color: AppColors.bgDeep, fontWeight: FontWeight.w700)),
        elevation: 4,
      ),
    );
  }
}

class _NotesEmpty extends StatelessWidget {
  const _NotesEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Icon(Icons.note_alt_outlined,
                  size: 40, color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Belum ada catatan',
                style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tulis catatan singkat yang bisa dibagikan ke teman-temanmu.',
              style:
                  AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Create Note Screen (Facebook / Instagram Notes Style)
class CreateNoteScreen extends ConsumerStatefulWidget {
  const CreateNoteScreen({super.key});

  @override
  ConsumerState<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends ConsumerState<CreateNoteScreen> {
  final _ctrl = TextEditingController();
  final int _maxLength = 60;

  NoteSong? _selectedSong;
  NoteGif? _selectedGif;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
 // Pre-fill existing note if available
    final profile = ref.read(profileProvider(null)).valueOrNull;
    if (profile != null && profile.thoughtNote != null) {
      final text = profile.thoughtNote!;
 // Look for music tag in existing note
      if (text.contains('🎵')) {
        final parts = text.split('🎵');
        _ctrl.text = parts[0].trim();
        final songPart = parts[1].trim();
        final match = kPopularWesternSongs.firstWhere(
          (s) => songPart.contains(s.title),
          orElse: () => kPopularWesternSongs[0],
        );
        _selectedSong = match;
      } else {
        _ctrl.text = text;
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  int get _remaining => _maxLength - _ctrl.text.length;

  void _showMusicPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _MusicPickerSheet(
        selectedSong: _selectedSong,
        onSelect: (song) {
          setState(() => _selectedSong = song);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showGifPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _GifPickerSheet(
        selectedGif: _selectedGif,
        onSelect: (gif) {
          setState(() => _selectedGif = gif);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  Future<void> _saveNote() async {
    final noteRaw = _ctrl.text.trim();
    if (noteRaw.isEmpty && _selectedSong == null) return;

    setState(() => _isSaving = true);
    try {
 // Build note string
      String noteText = '';
      if (_selectedGif != null) {
        noteText += '${_selectedGif!.emoji} ';
      }
      noteText += noteRaw;
      if (_selectedSong != null) {
        noteText += ' 🎵 ${_selectedSong!.title} - ${_selectedSong!.artist}';
      }

      final api = ref.read(apiClientProvider);
      final res = await api.patch('/users/me', data: {
        'thought_note': noteText.trim(),
      });

      final storage = ref.read(storageServiceProvider);
      if (res.data != null && res.data['data'] != null) {
        await storage.saveUserData(jsonEncode(res.data['data']));
      }

      ref.invalidate(profileProvider(null));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Catatan berhasil dibagikan ke profil!'),
          backgroundColor: AppColors.bgCard,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membagikan catatan: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider(null)).valueOrNull;
    final canShare = (_ctrl.text.trim().isNotEmpty || _selectedSong != null) &&
        !_isSaving;

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        surfaceTintColor: Colors.transparent,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Batal',
              style: AppTypography.labelMd
                  .copyWith(color: AppColors.textSecondary)),
        ),
        title: Text('Catatan Baru',
            style:
                AppTypography.labelLg.copyWith(color: AppColors.textPrimary)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: ElevatedButton(
              onPressed: canShare ? _saveNote : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cyan,
                foregroundColor: AppColors.bgDeep,
                minimumSize: const Size(76, 36),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: _isSaving
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.bgDeep))
                  : const Text('Bagikan',
                      style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          children: [
            const SizedBox(height: 36),

 // Thought Bubble with Speech Pointer
            Container(
              constraints: const BoxConstraints(maxWidth: 320),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.cyan.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cyan.withValues(alpha: 0.1),
                    blurRadius: 16,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
 // 1. Attached Song Pill (if selected)
                  if (_selectedSong != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _selectedSong!.color.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: _selectedSong!.color.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.music_note_rounded,
                              size: 14, color: _selectedSong!.color),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${_selectedSong!.title} · ${_selectedSong!.artist}',
                              style: TextStyle(
                                color: _selectedSong!.color,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => setState(() => _selectedSong = null),
                            child: Icon(Icons.close,
                                size: 14, color: _selectedSong!.color),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

 // 2. Attached GIF / Sticker Badge (if selected)
                  if (_selectedGif != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_selectedGif!.emoji,
                            style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 6),
                        Text(
                          _selectedGif!.label,
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.cyan,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => setState(() => _selectedGif = null),
                          child: Icon(Icons.close,
                              size: 14, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],

 // 3. Note Input Field
                  TextField(
                    controller: _ctrl,
                    maxLength: _maxLength,
                    maxLines: 3,
                    minLines: 1,
                    textAlign: TextAlign.center,
                    autofocus: true,
                    style: AppTypography.bodyLg.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Bagikan pemikiran...',
                      hintStyle: AppTypography.bodyLg.copyWith(
                        color: AppColors.textMuted,
                      ),
                      border: InputBorder.none,
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),

 // Character Counter
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$_remaining',
                      style: AppTypography.labelSm.copyWith(
                        color: _remaining < 10
                            ? AppColors.error
                            : AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),

 // Speech bubble downward connector dots
            const SizedBox(height: 4),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.cyan.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 3),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.cyan.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 6),

 // Centered User Avatar
            CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.cyan.withValues(alpha: 0.2),
              backgroundImage: getSmartImageProvider(profile?.avatarUrl),
              child: profile?.avatarUrl == null
                  ? Text(
                      (profile?.name ?? 'U').isNotEmpty
                          ? (profile?.name ?? 'U')[0].toUpperCase()
                          : 'U',
                      style: AppTypography.h1.copyWith(color: AppColors.cyan),
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              profile?.name ?? 'Profil Anda',
              style: AppTypography.labelMd.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 32),

 // Attachment Toolbar (Musik & GIF/Pajangan)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
 // 1. Music Button
                  InkWell(
                    onTap: _showMusicPicker,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      child: Row(
                        children: [
                          Icon(Icons.music_note_rounded,
                              size: 20,
                              color: _selectedSong != null
                                  ? AppColors.cyan
                                  : AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            _selectedSong != null
                                ? _selectedSong!.title
                                : 'Musik',
                            style: AppTypography.labelMd.copyWith(
                              color: _selectedSong != null
                                  ? AppColors.cyan
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Container(
                    height: 20,
                    width: 1,
                    color: AppColors.borderSubtle,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),

 // 2. GIF / Sticker Button (Pajangan)
                  InkWell(
                    onTap: _showGifPicker,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      child: Row(
                        children: [
                          Icon(Icons.gif_box_outlined,
                              size: 20,
                              color: _selectedGif != null
                                  ? AppColors.magenta
                                  : AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            _selectedGif != null ? _selectedGif!.emoji : 'GIF',
                            style: AppTypography.labelMd.copyWith(
                              color: _selectedGif != null
                                  ? AppColors.magenta
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

 // Privacy Footnote
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline,
                    color: AppColors.textMuted, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Catatan akan terlihat oleh temanmu selama 24 jam',
                  style: AppTypography.bodySm
                      .copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Music Picker Bottom Sheet (20 Popular Western Songs)
class _MusicPickerSheet extends StatefulWidget {
  final NoteSong? selectedSong;
  final ValueChanged<NoteSong> onSelect;

  const _MusicPickerSheet({
    required this.selectedSong,
    required this.onSelect,
  });

  @override
  State<_MusicPickerSheet> createState() => _MusicPickerSheetState();
}

class _MusicPickerSheetState extends State<_MusicPickerSheet> {
  final _searchCtrl = TextEditingController();
  String _filter = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = kPopularWesternSongs.where((s) {
      if (_filter.isEmpty) return true;
      final query = _filter.toLowerCase();
      return s.title.toLowerCase().contains(query) ||
          s.artist.toLowerCase().contains(query);
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollCtrl) {
        return Column(
          children: [
 // Handle bar
            Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

 // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.music_note_rounded,
                        color: AppColors.cyan, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pilih Musik Barat Populer',
                            style: AppTypography.h3.copyWith(
                                color: AppColors.textPrimary, fontSize: 17)),
                        Text('20 lagu barat hit yang sedang tren',
                            style: AppTypography.labelSm
                                .copyWith(color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

 // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search,
                        color: AppColors.textSecondary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _filter = v),
                        style: AppTypography.bodyMd
                            .copyWith(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Cari lagu atau artis...',
                          hintStyle: AppTypography.bodyMd
                              .copyWith(color: AppColors.textMuted),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (_filter.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          setState(() => _filter = '');
                        },
                        child: Icon(Icons.close,
                            size: 16, color: AppColors.textMuted),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),
            Divider(color: AppColors.borderSubtle, height: 1),

 // List of songs
            Expanded(
              child: ListView.separated(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                    Divider(color: AppColors.borderSubtle, height: 1),
                itemBuilder: (ctx, i) {
                  final song = filtered[i];
                  final isSelected = widget.selectedSong?.title == song.title;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: song.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: song.color.withValues(alpha: 0.4)),
                      ),
                      child: Icon(Icons.music_note_rounded,
                          color: song.color, size: 24),
                    ),
                    title: Text(
                      song.title,
                      style: AppTypography.bodyMd.copyWith(
                        color: isSelected
                            ? AppColors.cyan
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      song.artist,
                      style: AppTypography.bodySm
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(song.duration,
                            style: AppTypography.labelSm
                                .copyWith(color: AppColors.textMuted)),
                        const SizedBox(width: 8),
                        if (isSelected)
                          Icon(Icons.check_circle,
                              color: AppColors.cyan, size: 20)
                        else
                          Icon(Icons.play_circle_outline_rounded,
                              color: AppColors.textMuted, size: 22),
                      ],
                    ),
                    onTap: () => widget.onSelect(song),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// GIF / Pajangan Picker Bottom Sheet
class _GifPickerSheet extends StatelessWidget {
  final NoteGif? selectedGif;
  final ValueChanged<NoteGif> onSelect;

  const _GifPickerSheet({
    required this.selectedGif,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.gif_box_rounded,
                    color: AppColors.magenta, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Stiker & GIF Dekorasi (Pajangan)',
                  style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Pilih ikon animasi atau stiker untuk menghias catatan profilmu',
              style: AppTypography.bodySm.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.lg),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: kDecorativeGifs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (ctx, i) {
                final gif = kDecorativeGifs[i];
                final isSelected = selectedGif?.tag == gif.tag;

                return GestureDetector(
                  onTap: () => onSelect(gif),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.magenta.withValues(alpha: 0.18)
                          : AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.magenta
                            : AppColors.borderSubtle,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(gif.emoji, style: const TextStyle(fontSize: 26)),
                        const SizedBox(height: 4),
                        Text(
                          gif.label,
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected
                                ? AppColors.magenta
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
