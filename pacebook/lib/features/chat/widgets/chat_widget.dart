import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/chat_model.dart';
import '../providers/chat_provider.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  bool _isSearching = false;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Memfilter daftar ruangan berdasarkan nama lawan bicara, nama grup, atau teks pesan terakhir
  List<ChatRoom> _filterRooms(List<ChatRoom> rooms) {
    if (_searchQuery.trim().isEmpty) return rooms;
    final q = _searchQuery.toLowerCase();
    return rooms.where((r) {
      final name = r.isGroup
          ? (r.groupName ?? '')
          : r.participants.where((p) => p.id != 1).map((p) => p.name).join('');
      final lastMsg = r.lastMessage?.text ?? '';
      return name.toLowerCase().contains(q) || lastMsg.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(chatRoomsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        title: _isSearching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: AppTypography.bodyMd.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Cari percakapan...',
                  hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textMuted),
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : Text('PaceChat',
                style: AppTypography.h3.copyWith(color: AppColors.textPrimary)),
        actions: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _isSearching
                ? IconButton(
                    key: const ValueKey('close'),
                    icon: Icon(Icons.close, color: AppColors.textSecondary),
                    tooltip: 'Tutup pencarian',
                    onPressed: () => setState(() {
                      _isSearching = false;
                      _searchQuery = '';
                      _searchCtrl.clear();
                    }),
                  )
                : Row(
                    key: const ValueKey('actions'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.search_outlined, color: AppColors.textSecondary),
                        onPressed: () => setState(() => _isSearching = true),
                        tooltip: 'Cari percakapan',
                      ),
                      IconButton(
                        icon: Icon(Icons.group_add_outlined, color: AppColors.textSecondary),
                        onPressed: () => _showCreateGroupSheet(context),
                        tooltip: 'Buat grup baru',
                      ),
                    ],
                  ),
          ),
        ],
      ),
      body: roomsAsync.when(
        loading: () => Center(
            child: CircularProgressIndicator(color: AppColors.cyan, strokeWidth: 2)),
        error: (err, _) => Center(
            child: Text('Gagal memuat obrolan: $err',
                style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary))),
        data: (rooms) {
          final filtered = _filterRooms(rooms);
          if (filtered.isEmpty) {
            return Center(
              child: Text(
                _searchQuery.isNotEmpty
                    ? 'Tidak ada obrolan yang cocok dengan "$_searchQuery"'
                    : 'Belum ada percakapan',
                style: AppTypography.bodyMd.copyWith(color: AppColors.textMuted),
              ),
            );
          }
          return ListView.separated(
            itemCount: filtered.length,
            separatorBuilder: (_, __) => Divider(
                color: AppColors.borderSubtle, height: 1, indent: 72),
            itemBuilder: (ctx, i) {
              final room = filtered[i];
              return ListTile(
                title: Text(room.isGroup ? (room.groupName ?? 'Grup') : room.name),
                subtitle: Text(room.lastMessage?.text ?? 'Belum ada pesan'),
              );
            },
          );
        },
      ),
    );
  }
  void _showCreateGroupSheet(BuildContext ctx) {
    final nameCtrl = TextEditingController();
    final selectedIds = <int>{};
    List<ChatParticipant> friends = [];
    bool isLoadingFriends = true;
    bool hasFetched = false;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) {
          if (!hasFetched) {
            hasFetched = true;
            Future.microtask(() async {
              try {
                final api = ref.read(apiClientProvider);
                final res = await api.get('/users/me/connections');
                final list = res.data['data'] as List<dynamic>? ?? [];
                if (sheetCtx.mounted) {
                  setSheetState(() {
                    friends = list.map((item) {
                      final u = item['User'] ?? item;
                      return ChatParticipant(
                        id: u['id'] as int? ?? 0,
                        name: u['full_name'] as String? ?? u['username'] as String? ?? 'Pengguna',
                        avatarUrl: u['avatar_url'] as String?,
                      );
                    }).toList();
                    isLoadingFriends = false;
                  });
                }
              } catch (_) {
                if (sheetCtx.mounted) {
                  setSheetState(() => isLoadingFriends = false);
                }
              }
            });
          }

          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderSubtle,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Buat Grup Obrolan Baru',
                    style: AppTypography.h3.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  style: AppTypography.bodyMd.copyWith(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Nama Grup',
                    labelStyle: AppTypography.labelMd.copyWith(color: AppColors.textMuted),
                    hintText: 'Misal: Tim Sukses PaceBook',
                    hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textMuted),
                    prefixIcon: Icon(Icons.group, color: AppColors.cyan),
                    filled: true,
                    fillColor: AppColors.bgCard,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.borderSubtle),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Pilih Anggota (${selectedIds.length} dipilih)',
                    style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                if (isLoadingFriends)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(color: AppColors.cyan, strokeWidth: 2),
                  ))
                else if (friends.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text('Belum ada koneksi teman untuk ditambahkan ke grup.',
                        style: AppTypography.bodySm.copyWith(color: AppColors.textMuted)),
                  )
                else
                  SizedBox(
                    height: 160,
                    child: ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (_, idx) {
                        final friend = friends[idx];
                        final isSelected = selectedIds.contains(friend.id);
                        return CheckboxListTile(
                          dense: true,
                          value: isSelected,
                          activeColor: AppColors.cyan,
                          checkColor: AppColors.bgDeep,
                          title: Text(friend.name,
                              style: AppTypography.bodyMd.copyWith(color: AppColors.textPrimary)),
                          onChanged: (val) {
                            setSheetState(() {
                              if (val == true) {
                                selectedIds.add(friend.id);
                              } else {
                                selectedIds.remove(friend.id);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cyan,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) return;
                      try {
                        final api = ref.read(apiClientProvider);
                        await api.post('/chats/groups', data: {
                          'name': name,
                          'member_ids': selectedIds.toList(),
                        });
                        ref.invalidate(chatRoomsProvider);
                        if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                      } catch (_) {}
                    },
                    child: Text('Buat Grup',
                        style: AppTypography.labelMd.copyWith(
                            color: AppColors.bgDeep, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }