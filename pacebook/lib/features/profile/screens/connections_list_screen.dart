import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/providers/core_providers.dart';
import '../widgets/profile_widgets.dart';

// ConnectionsListScreen
/// Menampilkan semua koneksi dari user tertentu.
class ConnectionsListScreen extends ConsumerStatefulWidget {
  final int userId;
  const ConnectionsListScreen({super.key, required this.userId});

  @override
  ConsumerState<ConnectionsListScreen> createState() => _ConnectionsListScreenState();
}

class _ConnectionsListScreenState extends ConsumerState<ConnectionsListScreen> {
  bool _isLoading = true;
  List<UserProfile> _connections = [];
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadConnections();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadConnections() async {
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.get('/users/${widget.userId}/connections');
      final list = (res.data?['data'] as List<dynamic>? ?? []);
      final mapped = list.map((item) {
        final m = Map<String, dynamic>.from(item as Map);
        return UserProfile(
          id: m['id'] as int? ?? 0,
          name: (m['full_name'] ?? m['fullName'] ?? 'Pengguna').toString(),
          username: (m['username'] ?? 'user').toString(),
          avatarUrl: m['avatar_url'] as String?,
          bio: m['bio'] as String?,
          connectionStatus: 'connected',
        );
      }).toList();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _connections = mapped;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _connections = [];
        });
      }
    }
  }

  List<UserProfile> get _filtered => _connections.where((c) =>
      _searchQuery.isEmpty ||
      c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      c.username.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  Future<void> _disconnect(UserProfile user) async {
    setState(() => _connections.removeWhere((c) => c.id == user.id));
    try {
      final api = ref.read(apiClientProvider);
      await api.delete('/connections/${user.id}');
      ref.invalidate(friendSuggestionsProvider);
      ref.invalidate(notificationsProvider);
    } catch (_) {}
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Koneksi dengan ${user.name} diputus.',
          style: AppTypography.bodySm.copyWith(color: AppColors.textPrimary)),
      backgroundColor: AppColors.bgCard,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isMyProfile = widget.userId == 1;

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppColors.textSecondary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isMyProfile ? 'Koneksi Saya' : 'Koneksi',
          style: AppTypography.labelLg.copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: AppTypography.bodyMd.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Cari koneksi...',
                hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textMuted),
                prefixIcon: Icon(Icons.search_outlined,
                    color: AppColors.textMuted, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear,
                            color: AppColors.textMuted, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.bgSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: 10),
              ),
            ),
          ),
          // Count label
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Text('${_filtered.length} koneksi',
                      style: AppTypography.labelSm
                          .copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
          // List
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                        color: AppColors.cyan, strokeWidth: 2))
                : _filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline,
                                color: AppColors.textMuted, size: 56),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Tidak ada koneksi dengan nama "$_searchQuery"'
                                  : 'Belum ada koneksi.',
                              style: AppTypography.bodyMd
                                  .copyWith(color: AppColors.textMuted),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        separatorBuilder: (_, __) => Divider(
                            color: AppColors.borderSubtle, height: 1),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) {
                          final user = _filtered[i];
                          return FriendListTile(
                            user: user,
                            mutualCount: i + 1,
                            onTap: () => context.push('/profile/${user.id}'),
                            onMessage: () => context.push('/chat/${user.id}'),
                            onDisconnect: isMyProfile
                                ? () => _disconnect(user)
                                : null,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ConnectionRequestsScreen
/// Menampilkan permintaan yang masuk + saran koneksi.
class ConnectionRequestsScreen extends ConsumerStatefulWidget {
  const ConnectionRequestsScreen({super.key});

  @override
  ConsumerState<ConnectionRequestsScreen> createState() =>
      _ConnectionRequestsScreenState();
}

class _ConnectionRequestsScreenState
    extends ConsumerState<ConnectionRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tc;
  List<UserProfile> _requests = [];
  List<UserProfile> _suggestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final api = ref.read(apiClientProvider);
      final reqRes = await api.get('/connections/requests');
      final reqList = (reqRes.data?['data'] as List<dynamic>? ?? []);
      final parsedReqs = reqList.map((item) {
        final m = Map<String, dynamic>.from(item as Map);
        final u = (m['requester'] != null)
            ? Map<String, dynamic>.from(m['requester'] as Map)
            : m;
        return UserProfile(
          id: u['id'] as int? ?? 0,
          name: (u['full_name'] ?? u['fullName'] ?? 'Pengguna').toString(),
          username: (u['username'] ?? 'user').toString(),
          avatarUrl: u['avatar_url'] as String?,
          bio: u['bio'] as String?,
          connectionStatus: 'pending_received',
        );
      }).toList();

      final sugRes = await api.get('/users/suggestions');
      final sugList = (sugRes.data?['data'] as List<dynamic>? ?? []);
      final parsedSugs = sugList
          .where((item) {
            final m = Map<String, dynamic>.from(item as Map);
            final status = m['connection_status'];
            return status == 'none';
          })
          .take(10)
          .map((item) {
            final m = Map<String, dynamic>.from(item as Map);
            return UserProfile(
              id: m['id'] as int? ?? 0,
              name: (m['full_name'] ?? m['fullName'] ?? 'Pengguna').toString(),
              username: (m['username'] ?? 'user').toString(),
              avatarUrl: m['avatar_url'] as String?,
              bio: m['bio'] as String?,
              connectionStatus: 'none',
            );
          })
          .toList();

      if (mounted) {
        setState(() {
          _isLoading = false;
          _requests = parsedReqs;
          _suggestions = parsedSugs;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _requests = [];
          _suggestions = [];
        });
      }
    }
  }

  Future<void> _accept(UserProfile user) async {
    setState(() => _requests.removeWhere((r) => r.id == user.id));
    try {
      final api = ref.read(apiClientProvider);
      await api.post('/users/${user.id}/accept-connection');
      ref.invalidate(friendSuggestionsProvider);
      ref.invalidate(notificationsProvider);
    } catch (_) {}
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Permintaan dari ${user.name} diterima!',
          style: AppTypography.bodySm.copyWith(color: AppColors.textPrimary)),
      backgroundColor: AppColors.bgCard,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _reject(UserProfile user) async {
    setState(() => _requests.removeWhere((r) => r.id == user.id));
    try {
      final api = ref.read(apiClientProvider);
      await api.post('/users/${user.id}/reject-connection');
      ref.invalidate(friendSuggestionsProvider);
      ref.invalidate(notificationsProvider);
    } catch (_) {}
  }

  Future<void> _connect(UserProfile user) async {
    setState(() => _suggestions.removeWhere((s) => s.id == user.id));
    try {
      final api = ref.read(apiClientProvider);
      await api.post('/users/${user.id}/connect');
      ref.invalidate(friendSuggestionsProvider);
      ref.invalidate(notificationsProvider);
    } catch (_) {}
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Permintaan koneksi dikirim ke ${user.name}.',
          style: AppTypography.bodySm.copyWith(color: AppColors.textPrimary)),
      backgroundColor: AppColors.bgCard,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppColors.textSecondary),
          onPressed: () => context.pop(),
        ),
        title: Text('Koneksi',
            style: AppTypography.labelLg.copyWith(color: AppColors.textPrimary)),
        bottom: TabBar(
          controller: _tc,
          labelColor: AppColors.cyan,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.cyan,
          labelStyle: AppTypography.labelMd,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Permintaan'),
                  if (_requests.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.magenta,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${_requests.length}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Saran'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: AppColors.cyan, strokeWidth: 2))
          : TabBarView(
              controller: _tc,
              children: [
                // Tab Permintaan
                _requests.isEmpty
                    ? _EmptyTabState(
                        icon: Icons.person_add_disabled_outlined,
                        label: 'Tidak ada permintaan koneksi baru.')
                    : ListView.builder(
                        itemCount: _requests.length,
                        itemBuilder: (_, i) => FriendRequestCard(
                          user: _requests[i],
                          mutualCount: i + 2,
                          onAccept: () => _accept(_requests[i]),
                          onReject: () => _reject(_requests[i]),
                          onTap: () =>
                              context.push('/profile/${_requests[i].id}'),
                        ),
                      ),
                // Tab Saran
                _suggestions.isEmpty
                    ? _EmptyTabState(
                        icon: Icons.people_outline,
                        label: 'Tidak ada saran koneksi baru.')
                    : GridView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppSpacing.sm,
                          mainAxisSpacing: AppSpacing.sm,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: _suggestions.length,
                        itemBuilder: (_, i) => FriendSuggestionCard(
                          user: _suggestions[i],
                          mutualCount: i + 1,
                          onConnect: () => _connect(_suggestions[i]),
                          onDismiss: () => setState(
                              () => _suggestions.removeAt(i)),
                        ),
                      ),
              ],
            ),
    );
  }
}

class _EmptyTabState extends StatelessWidget {
  final IconData icon;
  final String label;
  const _EmptyTabState({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.md),
            Text(label,
                style: AppTypography.bodyMd.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center),
          ],
        ),
      );
}