import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';

// Smart Image Helpers
ImageProvider? getSmartImageProvider(String? url) {
  if (url == null || url.trim().isEmpty) return null;
  final trimmed = url.trim();
  if (trimmed.startsWith('data:')) {
    try {
      final comma = trimmed.indexOf(',');
      final b64 = comma != -1 ? trimmed.substring(comma + 1) : trimmed;
      final bytes = base64Decode(b64);
      return MemoryImage(bytes);
    } catch (_) {
      return null;
    }
  }
  return NetworkImage(trimmed);
}

Widget buildSmartImage(
  String? url, {
  BoxFit fit = BoxFit.cover,
  Widget? errorWidget,
}) {
  if (url == null || url.trim().isEmpty) {
    return errorWidget ?? const SizedBox.shrink();
  }
  final trimmed = url.trim();
  if (trimmed.startsWith('data:')) {
    try {
      final comma = trimmed.indexOf(',');
      final b64 = comma != -1 ? trimmed.substring(comma + 1) : trimmed;
      final bytes = base64Decode(b64);
      return Image.memory(
        bytes,
        fit: fit,
        errorBuilder: (_, __, ___) => errorWidget ?? const SizedBox.shrink(),
      );
    } catch (_) {
      return errorWidget ?? const SizedBox.shrink();
    }
  }
  return Image.network(
    trimmed,
    fit: fit,
    errorBuilder: (_, __, ___) => errorWidget ?? const SizedBox.shrink(),
  );
}

// ProfileModels
class UserProfile {
  final int id;
  final String name;
  final String username;
  final String? avatarUrl;
  final String? coverUrl;
  final String? bio;
  final String? birthday;
  final String? gender;
  final String? location;
  final String? work;
  final String? education;
  final String? thoughtNote;
  final int postCount;
  final int connectionCount;
  final String connectionStatus; // 'none' | 'pending_sent' | 'pending_received' | 'connected'
  final bool isPrivate;

  const UserProfile({
    required this.id,
    required this.name,
    required this.username,
    this.avatarUrl,
    this.coverUrl,
    this.bio,
    this.birthday,
    this.gender,
    this.location,
    this.work,
    this.education,
    this.thoughtNote,
    this.postCount = 0,
    this.connectionCount = 0,
    this.connectionStatus = 'none',
    this.isPrivate = false,
  });
}

// Facebook-Style ProfileHeader
class ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  final bool isMyProfile;
  final VoidCallback? onEditProfile;
  final VoidCallback? onConnect;
  final VoidCallback? onMessage;
  final VoidCallback? onChangeCover;
  final VoidCallback? onChangeAvatar;
  final VoidCallback? onAddStory;

  const ProfileHeader({
    super.key,
    required this.profile,
    required this.isMyProfile,
    this.onEditProfile,
    this.onConnect,
    this.onMessage,
    this.onChangeCover,
    this.onChangeAvatar,
    this.onAddStory,
  });

  @override
  Widget build(BuildContext context) {
    final isRestricted = profile.isPrivate && !isMyProfile;
    final avatarProvider = isRestricted
        ? null
        : getSmartImageProvider(profile.avatarUrl);

    return Column(
      children: [
        // Cover Photo + Centered Avatar with Thought Bubble
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // 1. Cover Photo
            GestureDetector(
              onTap: isMyProfile ? onChangeCover : null,
              child: Container(
                height: 190,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0F172A),
                      AppColors.cyan.withValues(alpha: 0.12),
                      const Color(0xFF1E293B),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child:
                    (!isRestricted &&
                        profile.coverUrl != null &&
                        profile.coverUrl!.isNotEmpty)
                    ? buildSmartImage(
                        profile.coverUrl,
                        fit: BoxFit.cover,
                        errorWidget: _CoverPlaceholder(),
                      )
                    : _CoverPlaceholder(),
              ),
            ),

            // 2. Camera Button on Cover (Bottom-Right)
            if (isMyProfile)
              Positioned(
                top: 146,
                right: 14,
                child: GestureDetector(
                  onTap: onChangeCover,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderSubtle),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),

            // 3. Avatar + Thought Bubble (Centered, Overlapping Cover)
            Positioned(
              top:
                  (!isRestricted &&
                      profile.thoughtNote != null &&
                      profile.thoughtNote!.trim().isNotEmpty)
                  ? 100
                  : 130,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isRestricted &&
                      profile.thoughtNote != null &&
                      profile.thoughtNote!.trim().isNotEmpty) ...[
                    _ThoughtBubble(text: profile.thoughtNote!),
                    const SizedBox(height: 2),
                  ],
                  GestureDetector(
                    onTap: isMyProfile ? onChangeAvatar : null,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.bgDeep,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 16,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 52,
                            backgroundColor: AppColors.cyan.withValues(
                              alpha: 0.2,
                            ),
                            backgroundImage: avatarProvider,
                            child: avatarProvider == null
                                ? (isRestricted
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.lock_rounded,
                                              size: 30,
                                              color: AppColors.textMuted,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              profile.name.isNotEmpty
                                                  ? profile.name[0]
                                                        .toUpperCase()
                                                  : '?',
                                              style: AppTypography.labelMd
                                                  .copyWith(
                                                    color: AppColors.textMuted,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          profile.name.isNotEmpty
                                              ? profile.name[0].toUpperCase()
                                              : '?',
                                          style: AppTypography.h1.copyWith(
                                            color: AppColors.cyan,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 34,
                                          ),
                                        ))
                                : null,
                          ),
                        ),
                        if (isMyProfile)
                          Positioned(
                            bottom: 2,
                            right: 4,
                            child: GestureDetector(
                              onTap: onChangeAvatar,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.bgSurface,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.bgDeep,
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 15,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 80),

        // Centered Name, Username, Stats, Common Friends
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      profile.name,
                      style: AppTypography.h1.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '@${profile.username}',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                '${profile.connectionCount} teman  ·  ${profile.postCount} postingan',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),

              if (profile.connectionCount > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 52,
                      height: 22,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: AppColors.cyan.withValues(
                                alpha: 0.3,
                              ),
                              child: Text(
                                'T',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.cyan,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 14,
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: AppColors.magenta.withValues(
                                alpha: 0.3,
                              ),
                              child: const Text(
                                'C',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.magenta,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 28,
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.amber.withValues(
                                alpha: 0.3,
                              ),
                              child: const Text(
                                'M',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Teman yang terhubung bersama',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],

              if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    profile.bio!,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              if (isMyProfile)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onAddStory,
                        icon: const Icon(Icons.add_circle, size: 18),
                        label: const Text('Tambah Cerita'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cyan,
                          foregroundColor: AppColors.bgDeep,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: AppTypography.labelMd.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onEditProfile,
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit Profil'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.bgSurface,
                          foregroundColor: AppColors.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: AppColors.borderSubtle),
                          ),
                          textStyle: AppTypography.labelMd.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onConnect,
                        icon: Icon(
                          profile.connectionStatus == 'connected'
                              ? Icons.check
                              : (profile.connectionStatus == 'pending_received'
                                    ? Icons.check_rounded
                                    : (profile.connectionStatus ==
                                                  'pending_sent' ||
                                              profile.connectionStatus ==
                                                  'pending'
                                          ? Icons.schedule_rounded
                                          : Icons.person_add_rounded)),
                          size: 18,
                        ),
                        label: Text(
                          profile.connectionStatus == 'connected'
                              ? 'Terhubung'
                              : (profile.connectionStatus == 'pending_received'
                                    ? 'Konfirmasi'
                                    : (profile.connectionStatus ==
                                                  'pending_sent' ||
                                              profile.connectionStatus ==
                                                  'pending'
                                          ? 'Menunggu'
                                          : 'Hubungkan')),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              profile.connectionStatus == 'connected' ||
                                  profile.connectionStatus == 'pending_sent' ||
                                  profile.connectionStatus == 'pending'
                              ? AppColors.bgSurface
                              : AppColors.cyan,
                          foregroundColor:
                              profile.connectionStatus == 'connected' ||
                                  profile.connectionStatus == 'pending_sent' ||
                                  profile.connectionStatus == 'pending'
                              ? AppColors.textSecondary
                              : AppColors.bgDeep,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: AppTypography.labelMd.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onMessage,
                        icon: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 16,
                        ),
                        label: const Text('Pesan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.bgSurface,
                          foregroundColor: AppColors.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: AppColors.borderSubtle),
                          ),
                          textStyle: AppTypography.labelMd.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ThoughtBubble Widget ("heyo")
class _ThoughtBubble extends StatelessWidget {
  final String text;
  const _ThoughtBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    String message = text;
    String? song;
    if (text.contains('🎵')) {
      final parts = text.split('🎵');
      message = parts[0].trim();
      song = parts.length > 1 ? parts[1].trim() : null;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 240),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (song != null && song.isNotEmpty) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.music_note_rounded,
                      size: 12,
                      color: Color(0xFFE11D48),
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        song,
                        style: const TextStyle(
                          color: Color(0xFFE11D48),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (message.isNotEmpty) const SizedBox(height: 2),
              ],
              if (message.isNotEmpty)
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 3,
              height: 3,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// PersonalDetailsCard
class PersonalDetailsCard extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback? onEdit;

  const PersonalDetailsCard({super.key, required this.profile, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    if (profile.work != null && profile.work!.trim().isNotEmpty) {
      rows.add(
        _DetailRow(
          icon: Icons.work_outline_rounded,
          text: 'Bekerja di ${profile.work}',
        ),
      );
    }

    if (profile.education != null && profile.education!.trim().isNotEmpty) {
      rows.add(
        _DetailRow(
          icon: Icons.school_outlined,
          text: 'Belajar di ${profile.education}',
        ),
      );
    }

    if (profile.location != null && profile.location!.trim().isNotEmpty) {
      rows.add(
        _DetailRow(
          icon: Icons.location_on_outlined,
          text: 'Tinggal di ${profile.location}',
        ),
      );
    }

    if (profile.birthday != null && profile.birthday!.trim().isNotEmpty) {
      rows.add(
        _DetailRow(
          icon: Icons.cake_outlined,
          text: 'Lahir pada ${profile.birthday}',
        ),
      );
    }

    if (profile.gender != null && profile.gender!.trim().isNotEmpty) {
      rows.add(
        _DetailRow(
          icon: Icons.person_outline,
          text: 'Jenis kelamin: ${profile.gender}',
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Detail pribadi',
                style: AppTypography.h3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              if (onEdit != null)
                GestureDetector(
                  onTap: onEdit,
                  child: Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: AppColors.cyan,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          if (rows.isNotEmpty) ...[
            for (int i = 0; i < rows.length; i++) ...[
              rows[i],
              if (i < rows.length - 1) const SizedBox(height: 10),
            ],
          ] else ...[
            Text(
              'Belum ada detail pribadi yang ditambahkan.',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          if (onEdit != null) ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onEdit,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.cyan,
                  side: BorderSide(
                    color: AppColors.cyan.withValues(alpha: 0.4),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text('Edit detail publik'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textMuted),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyMd.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

// FriendsGridCard
class FriendsGridCard extends StatelessWidget {
  final int totalFriends;
  final List<UserProfile> friends;
  final VoidCallback? onSeeAll;
  final VoidCallback? onFindFriends;
  final void Function(int userId)? onFriendTap;

  const FriendsGridCard({
    super.key,
    required this.totalFriends,
    this.friends = const [],
    this.onSeeAll,
    this.onFindFriends,
    this.onFriendTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Teman',
                    style: AppTypography.h3.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    '$totalFriends teman',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              if (totalFriends > 0)
                TextButton(
                  onPressed: onSeeAll,
                  child: Text(
                    'Lihat semua',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.cyan,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          if (friends.isEmpty || totalFriends == 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.lg,
                horizontal: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.bgSurface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.borderSubtle.withValues(alpha: 0.6),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.people_outline_rounded,
                      size: 28,
                      color: AppColors.cyan,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Belum ada teman',
                    style: AppTypography.h3.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mulai bangun koneksimu dengan mencari teman di Jelajah.',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton.icon(
                    onPressed: onFindFriends,
                    icon: Icon(
                      Icons.explore_outlined,
                      size: 16,
                      color: AppColors.cyan,
                    ),
                    label: Text(
                      'Cari Teman di Jelajah',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.cyan,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.cyan),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: friends.length.clamp(0, 6),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 12,
                childAspectRatio: 0.74,
              ),
              itemBuilder: (ctx, i) {
                final f = friends[i];
                final avatar = getSmartImageProvider(f.avatarUrl);
                return GestureDetector(
                  onTap: () => onFriendTap?.call(f.id),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.cyan.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            image: avatar != null
                                ? DecorationImage(
                                    image: avatar,
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: avatar == null
                              ? Center(
                                  child: Text(
                                    f.name.isNotEmpty
                                        ? f.name[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      color: AppColors.cyan,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        f.name,
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '@${f.username}',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

// ProfileFilterPills
class ProfileFilterPills extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const ProfileFilterPills({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  static const _labels = ['Semua', 'Foto', 'Catatan', 'Koneksi'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        scrollDirection: Axis.horizontal,
        itemCount: _labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final isSelected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.cyan : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.cyan : AppColors.borderSubtle,
                ),
              ),
              child: Center(
                child: Text(
                  _labels[i],
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.bgDeep
                        : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.bgMuted, AppColors.cyan.withValues(alpha: 0.08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.landscape_outlined,
          color: AppColors.textMuted.withValues(alpha: 0.4),
          size: 48,
        ),
      ),
    );
  }
}

// ProfileStatsBar
class ProfileStatsBar extends StatelessWidget {
  final int postCount;
  final int connectionCount;
  final VoidCallback? onConnectionsTap;

  const ProfileStatsBar({
    super.key,
    required this.postCount,
    required this.connectionCount,
    this.onConnectionsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: 'Postingan', value: postCount),
          _Divider(),
          GestureDetector(
            onTap: onConnectionsTap,
            child: _StatItem(
              label: 'Koneksi',
              value: connectionCount,
              accent: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int value;
  final bool accent;
  const _StatItem({
    required this.label,
    required this.value,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        _formatCount(value),
        style: AppTypography.h2.copyWith(
          color: accent ? AppColors.cyan : AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        style: AppTypography.labelSm.copyWith(color: AppColors.textMuted),
      ),
    ],
  );

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 32, color: AppColors.borderSubtle);
}

// ProfileTabBar
class ProfileTabBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTabChanged;
  final bool isMyProfile;

  const ProfileTabBar({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
    this.isMyProfile = false,
  });

  static const _tabs = ['Post', 'Info', 'Foto', 'Koneksi'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
        color: AppColors.bgCard,
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final isSelected = i == currentIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm + 2,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? AppColors.cyan : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  _tabs[i],
                  textAlign: TextAlign.center,
                  style: AppTypography.labelMd.copyWith(
                    color: isSelected
                        ? AppColors.cyan
                        : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// FriendListTile
class FriendListTile extends StatelessWidget {
  final UserProfile user;
  final int? mutualCount;
  final VoidCallback? onTap;
  final VoidCallback? onMessage;
  final VoidCallback? onDisconnect;

  const FriendListTile({
    super.key,
    required this.user,
    this.mutualCount,
    this.onTap,
    this.onMessage,
    this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: AppColors.cyan.withValues(alpha: 0.18),
        backgroundImage: user.avatarUrl != null
            ? NetworkImage(user.avatarUrl!)
            : null,
        child: user.avatarUrl == null
            ? Text(
                user.name[0].toUpperCase(),
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.cyan,
                  fontWeight: FontWeight.w700,
                ),
              )
            : null,
      ),
      title: Text(
        user.name,
        style: AppTypography.labelMd.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: mutualCount != null && mutualCount! > 0
          ? Text(
              '$mutualCount koneksi bersama',
              style: AppTypography.labelSm.copyWith(color: AppColors.textMuted),
            )
          : Text(
              '@${user.username}',
              style: AppTypography.labelSm.copyWith(color: AppColors.textMuted),
            ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.chat_outlined, size: 20),
            color: AppColors.cyan,
            onPressed: onMessage,
            tooltip: 'Kirim pesan',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, size: 20),
            color: AppColors.textMuted,
            onPressed: () => _showOptions(context),
            tooltip: 'Opsi lain',
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.sm),
          ListTile(
            leading: const Icon(
              Icons.person_remove_outlined,
              color: AppColors.error,
            ),
            title: Text(
              'Putuskan Koneksi',
              style: AppTypography.labelMd.copyWith(color: AppColors.error),
            ),
            onTap: () {
              Navigator.pop(context);
              onDisconnect?.call();
            },
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

// FriendRequestCard
class FriendRequestCard extends StatelessWidget {
  final UserProfile user;
  final int? mutualCount;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onTap;

  const FriendRequestCard({
    super.key,
    required this.user,
    this.mutualCount,
    this.onAccept,
    this.onReject,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTap,
            child: CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.magenta.withValues(alpha: 0.18),
              backgroundImage: user.avatarUrl != null
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null
                  ? Text(
                      user.name[0].toUpperCase(),
                      style: AppTypography.h3.copyWith(
                        color: AppColors.magenta,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (mutualCount != null && mutualCount! > 0)
                  Text(
                    '$mutualCount koneksi bersama',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cyan,
                          foregroundColor: AppColors.bgDeep,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Terima',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.bgDeep,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onReject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: BorderSide(color: AppColors.borderSubtle),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Tolak',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// FriendSuggestionCard
class FriendSuggestionCard extends StatelessWidget {
  final UserProfile user;
  final int mutualCount;
  final VoidCallback? onConnect;
  final VoidCallback? onDismiss;

  const FriendSuggestionCard({
    super.key,
    required this.user,
    required this.mutualCount,
    this.onConnect,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close, size: 16, color: AppColors.textMuted),
            ),
          ),
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.cyan.withValues(alpha: 0.18),
            backgroundImage: user.avatarUrl != null
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: user.avatarUrl == null
                ? Text(
                    user.name[0].toUpperCase(),
                    style: AppTypography.h2.copyWith(color: AppColors.cyan),
                  )
                : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            user.name,
            style: AppTypography.labelMd.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (mutualCount > 0) ...[
            const SizedBox(height: 2),
            Text(
              '$mutualCount bersama',
              style: AppTypography.labelSm.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onConnect,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cyan.withValues(alpha: 0.15),
                foregroundColor: AppColors.cyan,
                padding: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                elevation: 0,
              ),
              child: Text(
                'Hubungkan',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.cyan,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// AboutInfoTile
class AboutInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const AboutInfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// PhotoAlbumGridItem
class PhotoAlbumGridItem extends StatelessWidget {
  final String imageUrl;
  final VoidCallback? onTap;

  const PhotoAlbumGridItem({super.key, required this.imageUrl, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: AppColors.bgSurface,
            child: Icon(
              Icons.broken_image_outlined,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

// EditProfileFormField
class EditProfileFormField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;

  const EditProfileFormField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            readOnly: readOnly,
            onTap: onTap,
            style: AppTypography.bodyMd.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.bodyMd.copyWith(
                color: AppColors.textMuted,
              ),
              filled: true,
              fillColor: AppColors.bgSurface,
              suffixIcon: suffixIcon,
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
                borderSide: BorderSide(color: AppColors.cyan, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.error),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// MutualFriendsRow
class MutualFriendsRow extends StatelessWidget {
  final List<String?> avatarUrls;
  final List<String> names;
  final int totalMutual;

  const MutualFriendsRow({
    super.key,
    required this.avatarUrls,
    required this.names,
    required this.totalMutual,
  });

  @override
  Widget build(BuildContext context) {
    if (totalMutual == 0) return const SizedBox.shrink();
    const maxShow = 3;
    final showing = avatarUrls.take(maxShow).toList();
    return Row(
      children: [
        SizedBox(
          width: showing.length * 20.0 + 12,
          height: 28,
          child: Stack(
            children: List.generate(showing.length, (i) {
              return Positioned(
                left: i * 20.0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.bgCard, width: 1.5),
                  ),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.cyan.withValues(alpha: 0.18),
                    backgroundImage: showing[i] != null
                        ? NetworkImage(showing[i]!)
                        : null,
                    child: showing[i] == null
                        ? Text(
                            names.length > i ? names[i][0].toUpperCase() : '?',
                            style: TextStyle(
                              fontSize: 8,
                              color: AppColors.cyan,
                            ),
                          )
                        : null,
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            '$totalMutual koneksi bersama',
            style: AppTypography.labelSm.copyWith(
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
