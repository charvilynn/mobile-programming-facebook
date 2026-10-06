class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  String _query = '';
  // Track in-flight optimistic updates (userId -> new status)
  final Map<int, String> _optimisticStatus = {};

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _connect(int friendId, String name) async {
    setState(() => _optimisticStatus[friendId] = 'pending_sent');
    try {
      final api = ref.read(apiClientProvider);
      await api.post('/users/$friendId/connect');
      if (!mounted) return;
      ref.invalidate(friendSuggestionsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Permintaan pertemanan terkirim ke $name'),
          backgroundColor: AppColors.bgCard,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _optimisticStatus.remove(friendId));
      ref.invalidate(friendSuggestionsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim permintaan: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _accept(int friendId, String name) async {
    setState(() => _optimisticStatus[friendId] = 'accepted');
    try {
      final api = ref.read(apiClientProvider);
      await api.post('/users/$friendId/accept-connection');
      if (!mounted) return;
      ref.invalidate(friendSuggestionsProvider);
      ref.invalidate(notificationsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sekarang berteman dengan $name!'),
          backgroundColor: AppColors.bgCard,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _optimisticStatus.remove(friendId));
      ref.invalidate(friendSuggestionsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menerima permintaan: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildStatusWidget(int uid, String name, String backendStatus) {
    final status = _optimisticStatus[uid] ?? backendStatus;

    if (status == 'accepted' || status == 'connected') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.cyan.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cyan),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_rounded, size: 14, color: AppColors.cyan),
            const SizedBox(width: 4),
            Text('Terhubung',
                style: AppTypography.labelSm.copyWith(
                    color: AppColors.cyan, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    if (status == 'pending_sent') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule_rounded, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Text('Menunggu',
                style: AppTypography.labelSm.copyWith(
                    color: AppColors.textMuted, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    if (status == 'pending_received') {
      return ElevatedButton(
        onPressed: () => _accept(uid, name),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cyan,
          foregroundColor: AppColors.bgDeep,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: Text('Konfirmasi',
            style: AppTypography.labelSm.copyWith(
                color: AppColors.bgDeep, fontWeight: FontWeight.w700)),
      );
    }

    return ElevatedButton.icon(
      onPressed: () => _connect(uid, name),
      icon: const Icon(Icons.person_add_rounded, size: 14),
      label: const Text('Hubungkan'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.cyan,
        foregroundColor: AppColors.bgDeep,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        textStyle: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        title: TextField(
          controller: _ctrl,
          onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
          style: AppTypography.bodyMd.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Cari teman, nama, atau username...',
            hintStyle: AppTypography.bodySm.copyWith(color: AppColors.textMuted),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: AppColors.cyan, size: 20),
          ),
        ),
      ),
      body: Consumer(builder: (context, ref, _) {
        final suggestionsAsync = ref.watch(friendSuggestionsProvider);
        return suggestionsAsync.when(
          loading: () => Center(child: CircularProgressIndicator(color: AppColors.cyan)),
          error: (e, _) => Center(child: Text('Gagal memuat saran teman: $e')),
          data: (users) {
            final filtered = _query.isEmpty
                ? users
                : users.where((u) {
                    final n = (u['full_name'] ?? u['username'] ?? '').toString().toLowerCase();
                    return n.contains(_query);
                  }).toList();

            if (filtered.isEmpty) {
              return Center(
                child: Text('Tidak ada pengguna yang cocok.',
                    style: AppTypography.bodyMd.copyWith(color: AppColors.textMuted)),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => Divider(color: AppColors.borderSubtle),
              itemBuilder: (ctx, i) {
                final u = filtered[i];
                final id = u['id'] as int;
                final name = (u['full_name'] ?? u['username'] ?? 'User').toString();
                final username = (u['username'] ?? '').toString();
                final status = (u['connection_status'] ?? 'none').toString();

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.cyan.withValues(alpha: 0.2),
                    child: Text(name[0].toUpperCase(), style: TextStyle(color: AppColors.cyan)),
                  ),
                  title: Text(name, style: AppTypography.labelMd.copyWith(color: AppColors.textPrimary)),
                  subtitle: Text('@$username', style: AppTypography.labelSm.copyWith(color: AppColors.textMuted)),
                  trailing: _buildStatusWidget(id, name, status),
                );
              },
            );
          },
        );
      }),
    );
  }
}