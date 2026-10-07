import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/widgets/profile_widgets.dart';
import '../widgets/community_widgets.dart';

// GroupsListScreen
class GroupsListScreen extends ConsumerStatefulWidget {
  const GroupsListScreen({super.key});
  @override
  ConsumerState<GroupsListScreen> createState() => _GroupsListScreenState();
}

class _GroupsListScreenState extends ConsumerState<GroupsListScreen> {
  bool _isLoading = true;
  final List<GroupModel> _groups = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _groups.addAll([
            const GroupModel(id: 1, name: 'Flutter Indonesia', memberCount: 4820, isMember: true,
                description: 'Komunitas Flutter developer Indonesia'),
            const GroupModel(id: 2, name: 'UI/UX Designers', memberCount: 2310, isMember: false,
                description: 'Share karya dan diskusi desain'),
            const GroupModel(id: 3, name: 'Campus Gamer', memberCount: 980, isMember: false,
                privacy: 'private', description: 'Gaming bareng mahasiswa'),
          ]);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        title: Text('Komunitas',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppColors.textSecondary),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppColors.cyan),
            onPressed: () {},
            tooltip: 'Buat Komunitas',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.cyan, strokeWidth: 2))
          : _groups.isEmpty
              ? _EmptyState(
                  icon: Icons.groups_outlined,
                  title: 'Belum ada komunitas',
                  subtitle: 'Buat atau temukan komunitas yang sesuai minatmu.')
              : ListView.builder(
                  itemCount: _groups.length,
                  itemBuilder: (_, i) => GroupCard(
                    group: _groups[i],
                    onTap: () => context.push('/groups/${_groups[i].id}'),
                    onJoin: () => setState(() {
                      _groups[i] = GroupModel(
                        id: _groups[i].id,
                        name: _groups[i].name,
                        memberCount: _groups[i].memberCount + 1,
                        description: _groups[i].description,
                        privacy: _groups[i].privacy,
                        isMember: true,
                      );
                    }),
                  ),
                ),
    );
  }
}

// EventsListScreen
class EventsListScreen extends ConsumerStatefulWidget {
  const EventsListScreen({super.key});
  @override
  ConsumerState<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends ConsumerState<EventsListScreen> {
  late DateTime _selectedDate;
  final List<EventModel> _events = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    final now = DateTime.now();
    _events.addAll([
      EventModel(
        id: 1,
        name: 'Flutter Meetup Jakarta',
        location: 'Gedung Startup Hub, Jakarta',
        startTime: now.add(const Duration(days: 2)),
        endTime: now.add(const Duration(days: 2, hours: 3)),
        attendeeCount: 87,
      ),
      EventModel(
        id: 2,
        name: 'UX Design Workshop',
        location: 'Online via Zoom',
        startTime: now.add(const Duration(days: 5)),
        endTime: now.add(const Duration(days: 5, hours: 2)),
        attendeeCount: 142,
        isAttending: true,
      ),
      EventModel(
        id: 3,
        name: 'Hackathon PaceBook',
        location: 'Universitas XYZ, Aula Utama',
        startTime: now.add(const Duration(days: 10)),
        endTime: now.add(const Duration(days: 11)),
        attendeeCount: 56,
      ),
    ]);
  }

  Set<DateTime> get _eventDates => _events
      .map((e) => DateTime(e.startTime.year, e.startTime.month, e.startTime.day))
      .toSet();

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
        title: Text('Agenda',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary)),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppColors.cyan),
            onPressed: () {},
            tooltip: 'Buat Agenda',
          ),
        ],
      ),
      body: Column(
        children: [
          EventCalendarStrip(
            selectedDate: _selectedDate,
            onDateSelected: (d) => setState(() => _selectedDate = d),
            eventDates: _eventDates,
          ),
          Expanded(
            child: _events.isEmpty
                ? _EmptyState(
                    icon: Icons.event_outlined,
                    title: 'Tidak ada agenda',
                    subtitle: 'Buat agenda atau ikuti acara yang menarik.')
                : ListView.builder(
                    itemCount: _events.length,
                    itemBuilder: (_, i) => EventCard(
                      event: _events[i],
                      onTap: () {},
                      onAttend: () => setState(() {
                        final e = _events[i];
                        _events[i] = EventModel(
                          id: e.id,
                          name: e.name,
                          location: e.location,
                          startTime: e.startTime,
                          endTime: e.endTime,
                          attendeeCount: e.isAttending
                              ? e.attendeeCount - 1
                              : e.attendeeCount + 1,
                          isAttending: !e.isAttending,
                        );
                      }),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// MarketplaceHomeScreen
class MarketplaceHomeScreen extends ConsumerStatefulWidget {
  const MarketplaceHomeScreen({super.key});
  @override
  ConsumerState<MarketplaceHomeScreen> createState() =>
      _MarketplaceHomeScreenState();
}

class _MarketplaceHomeScreenState extends ConsumerState<MarketplaceHomeScreen> {
  String _selectedCategory = 'Semua';
  final _categories = ['Semua', 'Elektronik', 'Pakaian', 'Buku', 'Furniture', 'Lainnya'];
  String _query = '';

  final _items = const [
    MarketItem(id: 1, title: 'MacBook Pro 2021 M1', price: 18500000,
        condition: 'used', category: 'Elektronik', sellerName: 'Davvin',
 imageUrl: 'https://picsum.photos/seed/mac/400/400'),
    MarketItem(id: 2, title: 'Baju Batik Modern', price: 150000,
        condition: 'new', category: 'Pakaian', sellerName: 'Livi',
 imageUrl: 'https://picsum.photos/seed/baju/400/400'),
    MarketItem(id: 3, title: 'Flutter in Action Book', price: 220000,
        condition: 'used', category: 'Buku', sellerName: 'Chandra',
 imageUrl: 'https://picsum.photos/seed/buku/400/400'),
    MarketItem(id: 4, title: 'Gaming Chair', price: 2750000,
        condition: 'new', category: 'Furniture', sellerName: 'Olivian',
 imageUrl: 'https://picsum.photos/seed/chair/400/400'),
  ];

  List<MarketItem> get _filtered => _items.where((item) {
        final matchCat = _selectedCategory == 'Semua' ||
            item.category == _selectedCategory;
        final matchQuery = _query.isEmpty ||
            item.title.toLowerCase().contains(_query.toLowerCase());
        return matchCat && matchQuery;
      }).toList();

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
        title: Text('PaceMarket',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary)),
        actions: [
          AnimatedSearchBar(onSearch: (q) => setState(() => _query = q)),
          IconButton(
            icon: Icon(Icons.add_shopping_cart_outlined,
                color: AppColors.cyan),
            onPressed: () {},
            tooltip: 'Jual barang',
          ),
        ],
      ),
      body: Column(
        children: [
 // Category chips
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              itemCount: _categories.length,
              itemBuilder: (_, i) => MarketplaceCategoryChip(
                label: _categories[i],
                isSelected: _selectedCategory == _categories[i],
                onTap: () => setState(() => _selectedCategory = _categories[i]),
              ),
            ),
          ),
 // Items grid
          Expanded(
            child: _filtered.isEmpty
                ? _EmptyState(
                    icon: Icons.storefront_outlined,
                    title: 'Tidak ada barang',
                    subtitle: 'Coba kategori atau kata kunci lain.')
                : GridView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.sm,
                      mainAxisSpacing: AppSpacing.sm,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => MarketplaceItemCard(
                      item: _filtered[i],
                      onTap: () {},
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// SettingsScreen
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _privacyKey = 'public';
  String _privacyLabel = 'Semua Orang';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final storage = ref.read(storageServiceProvider);
      final saved = await storage.getProfileVisibility();
      if (saved != null && mounted) {
        setState(() {
          _privacyKey = saved;
          _privacyLabel = _mapPrivacyLabel(saved);
        });
      }
    });
  }

  String _mapPrivacyLabel(String key) {
    switch (key) {
      case 'friends':
        return 'Hanya Teman';
      case 'private':
        return 'Hanya Saya';
      case 'public':
      default:
        return 'Semua Orang';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppColors.textSecondary),
          onPressed: () => context.pop(),
        ),
        title: Text('Pengaturan',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary)),
      ),
      body: ListView(
        children: [
          _SettingsSection(title: 'Akun', children: [
            SettingsMenuTile(
              icon: Icons.person_outline,
              iconColor: AppColors.cyan,
              title: 'Edit Profil',
              subtitle: 'Ubah nama, bio, tanggal lahir, dan info diri',
              onTap: () => context.push('/edit-profile'),
            ),
            SettingsMenuTile(
              icon: Icons.lock_outline,
              iconColor: AppColors.electricBlue,
              title: 'Ganti Password',
              subtitle: 'Perbarui kata sandi akun PaceBook kamu',
              onTap: () => _showChangePasswordModal(context),
            ),
          ]),
          _SettingsSection(title: 'Privasi', children: [
            SettingsMenuTile(
              icon: Icons.visibility_outlined,
              iconColor: AppColors.textSecondary,
              title: 'Siapa yang bisa melihat profil',
              subtitle: _privacyLabel,
              onTap: () => _showPrivacyModal(context),
            ),
          ]),
          _SettingsSection(title: 'Tampilan', children: [
            ThemeToggleSwitch(
              isDarkMode: isDark,
              onChanged: (val) {
                ref.read(themeModeProvider.notifier).toggleTheme(val);
              },
            ),
          ]),
          _SettingsSection(title: 'Tentang', children: [
            SettingsMenuTile(
              icon: Icons.info_outline,
              title: 'Versi Aplikasi',
              subtitle: '1.0.0 (Build 2026.1)',
              trailing: Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
              onTap: () => _showAboutDialog(context),
            ),
          ]),
          _SettingsSection(title: '', children: [
            SettingsMenuTile(
              icon: Icons.logout,
              title: 'Keluar',
              subtitle: 'Akhiri sesi saat ini pada perangkat ini',
              isDestructive: true,
              trailing: const SizedBox.shrink(),
              onTap: () => _confirmLogout(context),
            ),
          ]),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  void _showChangePasswordModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ChangePasswordSheet(),
    );
  }

  void _showPrivacyModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PrivacySelectorSheet(
        currentKey: _privacyKey,
        onSelected: (key, label) async {
          Navigator.pop(ctx);
          setState(() {
            _privacyKey = key;
            _privacyLabel = label;
          });
          final messenger = ScaffoldMessenger.of(context);
          try {
            await ref.read(storageServiceProvider).saveProfileVisibility(key);
            await ref.read(apiClientProvider).patch('/users/me', data: {
              'profile_visibility': key,
            });
            messenger.showSnackBar(
              SnackBar(
                content: Text('Privasi profil diatur ke: $label'),
                backgroundColor: AppColors.bgCard,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } catch (_) {}
        },
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0284C7), Color(0xFF22D3EE)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text('P',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('PaceBook',
                style: AppTypography.h2.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text('Versi 1.0.0 • Production Build 2026.1',
                style: AppTypography.labelSm.copyWith(color: AppColors.cyan)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Aplikasi media sosial modern dengan fokus pada konektivitas komunitas tanpa batas. Mendukung interaksi realtime, story ephemeral, catatan status, dan kontrol privasi terpercaya.',
              style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Divider(color: AppColors.borderSubtle, height: 1),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Platform',
                    style: AppTypography.labelSm.copyWith(color: AppColors.textMuted)),
                Text('Flutter Web & Mobile',
                    style: AppTypography.labelSm.copyWith(color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Backend API',
                    style: AppTypography.labelSm.copyWith(color: AppColors.textMuted)),
                Text('Node.js & SQLite Express',
                    style: AppTypography.labelSm.copyWith(color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Status Server',
                    style: AppTypography.labelSm.copyWith(color: AppColors.textMuted)),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('Terhubung (v1)',
                        style: AppTypography.labelSm.copyWith(color: AppColors.success)),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cyan,
                foregroundColor: AppColors.bgDeep,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Keluar dari Akun?',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary)),
        content: Text('Kamu akan keluar dari akun PaceBook kamu. Sesi aktif akan diakhiri dengan aman.',
            style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal',
                style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// Change Password BottomSheet
class _ChangePasswordSheet extends ConsumerStatefulWidget {
  const _ChangePasswordSheet();

  @override
  ConsumerState<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<_ChangePasswordSheet> {
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final oldPass = _oldPassCtrl.text.trim();
    final newPass = _newPassCtrl.text.trim();
    final confirmPass = _confirmPassCtrl.text.trim();

    if (oldPass.isEmpty) {
      setState(() => _errorMessage = 'Password saat ini wajib diisi.');
      return;
    }
    if (newPass.length < 6) {
      setState(() => _errorMessage = 'Password baru minimal 6 karakter.');
      return;
    }
    if (newPass != confirmPass) {
      setState(() => _errorMessage = 'Konfirmasi password tidak cocok.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final api = ref.read(apiClientProvider);
      await api.post('/auth/change-password', data: {
        'current_password': oldPass,
        'new_password': newPass,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: AppColors.success, size: 20),
                SizedBox(width: 8),
                Text('Password berhasil diperbarui!'),
              ],
            ),
            backgroundColor: AppColors.bgCard,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      String err = 'Gagal mengubah password. Pastikan password lama benar.';
      if (e is DioException && e.response?.data is Map) {
        final msg = e.response?.data['message'];
        if (msg != null) err = msg.toString();
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = err;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Ganti Password',
                style: AppTypography.h3.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text('Pastikan password baru kamu kuat dan mudah kamu ingat.',
                style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.lg),

            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.sm + 2),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_errorMessage!,
                          style: AppTypography.labelSm.copyWith(color: AppColors.error)),
                    ),
                  ],
                ),
              ),

            _buildPasswordField(
              label: 'Password Saat Ini',
              controller: _oldPassCtrl,
              obscure: _obscureOld,
              onToggle: () => setState(() => _obscureOld = !_obscureOld),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildPasswordField(
              label: 'Password Baru',
              controller: _newPassCtrl,
              obscure: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildPasswordField(
              label: 'Konfirmasi Password Baru',
              controller: _confirmPassCtrl,
              obscure: _obscureConfirm,
              onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            const SizedBox(height: AppSpacing.xl),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cyan,
                      foregroundColor: AppColors.bgDeep,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.bgDeep),
                          )
                        : const Text('Simpan Password'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.labelSm.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: AppTypography.bodyMd.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.bgDeep,
            hintText: '••••••••',
            hintStyle: TextStyle(color: AppColors.textMuted),
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
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AppColors.textMuted,
                size: 20,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }
}

// Privacy Selector BottomSheet
class _PrivacySelectorSheet extends StatelessWidget {
  final String currentKey;
  final Function(String key, String label) onSelected;

  const _PrivacySelectorSheet({
    required this.currentKey,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('Siapa yang Bisa Melihat Profil',
              style: AppTypography.h3.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text('Tentukan siapa yang dapat melihat detail profil lengkap kamu.',
              style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.md),
          _PrivacyOptionTile(
            icon: Icons.public_rounded,
            iconColor: AppColors.cyan,
            title: 'Semua Orang',
            subtitle: 'Siapa saja di dalam maupun luar PaceBook dapat melihat profil Anda.',
            isSelected: currentKey == 'public',
            onTap: () => onSelected('public', 'Semua Orang'),
          ),
          _PrivacyOptionTile(
            icon: Icons.group_outlined,
            iconColor: AppColors.electricBlue,
            title: 'Hanya Teman',
            subtitle: 'Hanya pengguna yang terhubung sebagai teman yang dapat melihat profil Anda.',
            isSelected: currentKey == 'friends',
            onTap: () => onSelected('friends', 'Hanya Teman'),
          ),
          _PrivacyOptionTile(
            icon: Icons.lock_outline_rounded,
            iconColor: AppColors.warning,
            title: 'Hanya Saya',
            subtitle: 'Profil Anda disembunyikan dari orang lain dan bersifat privat.',
            isSelected: currentKey == 'private',
            onTap: () => onSelected('private', 'Hanya Saya'),
          ),
        ],
      ),
    );
  }
}

class _PrivacyOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PrivacyOptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
        decoration: BoxDecoration(
          color: isSelected ? iconColor.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: iconColor.withValues(alpha: 0.35))
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTypography.labelMd.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
                  Text(subtitle,
                      style: AppTypography.labelSm.copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: iconColor, size: 20),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xs),
            child: Text(title,
                style: AppTypography.labelSm.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5)),
          ),
        Container(
          color: AppColors.bgCard,
          child: Column(
            children: [
              ...children,
              Divider(color: AppColors.borderSubtle, height: 1),
            ],
          ),
        ),
      ],
    );
  }
}

// SearchScreen (Jelajah & Saran Teman)
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
 // Optimistic override takes priority
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
                style: AppTypography.labelSm
                    .copyWith(color: AppColors.cyan, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    if (status == 'pending_received') {
      return ElevatedButton.icon(
        onPressed: () => _accept(uid, name),
        icon: const Icon(Icons.check_rounded, size: 15),
        label: const Text('Konfirmasi'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cyan,
          foregroundColor: AppColors.bgDeep,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          minimumSize: const Size(0, 34),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w700),
        ),
      );
    }

    if (status == 'pending_sent' || status == 'pending') {
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
                style: AppTypography.labelSm
                    .copyWith(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

 // status == 'none' or other
    return ElevatedButton.icon(
      onPressed: () => _connect(uid, name),
      icon: const Icon(Icons.person_add_rounded, size: 15),
      label: const Text('Hubungkan'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.cyan,
        foregroundColor: AppColors.bgDeep,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: const Size(0, 34),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final suggestionsAsync = ref.watch(friendSuggestionsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppColors.textSecondary),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/feed');
            }
          },
        ),
        title: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              Icon(Icons.search, size: 20, color: AppColors.cyan),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  onChanged: (v) => setState(() => _query = v),
                  style:
                      AppTypography.bodyMd.copyWith(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Cari teman, post, komunitas...',
                    hintStyle: AppTypography.bodyMd
                        .copyWith(color: AppColors.textMuted, fontSize: 13),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              if (_query.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _ctrl.clear();
                    setState(() => _query = '');
                  },
                  child: Icon(Icons.close,
                      size: 18, color: AppColors.textMuted),
                ),
            ],
          ),
        ),
      ),
      body: _query.isNotEmpty
          ? SearchResultTabView(query: _query)
          : RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(friendSuggestionsProvider);
              },
              color: AppColors.cyan,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
 // Section Header: Saran Teman
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.cyan.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person_add_alt_1_rounded,
                            color: AppColors.cyan, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Saran Teman',
                              style: AppTypography.h3.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                              ),
                            ),
                            Text(
                              'Orang yang terdaftar di database PaceBook',
                              style: AppTypography.labelSm
                                  .copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.refresh,
                            color: AppColors.cyan, size: 20),
                        tooltip: 'Muat ulang saran',
                        onPressed: () =>
                            ref.invalidate(friendSuggestionsProvider),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

 // Suggestions List from Real Database
                  suggestionsAsync.when(
                    loading: () => Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.cyan, strokeWidth: 2),
                      ),
                    ),
                    error: (err, _) => Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline,
                              size: 40, color: AppColors.error),
                          const SizedBox(height: 8),
                          Text('Gagal memuat saran teman',
                              style: AppTypography.bodyMd
                                  .copyWith(color: AppColors.textPrimary)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () =>
                                ref.invalidate(friendSuggestionsProvider),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.cyan,
                                foregroundColor: AppColors.bgDeep),
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                    data: (users) {
                      if (users.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 36, horizontal: 20),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.cyan.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.people_outline_rounded,
                                    size: 36, color: AppColors.cyan),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Belum Ada Pengguna Lain',
                                style: AppTypography.h3.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Semua pengguna yang Anda daftarkan di database akan muncul di sini sebagai saran teman.',
                                style: AppTypography.bodySm.copyWith(
                                    color: AppColors.textMuted, height: 1.4),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: users.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (ctx, idx) {
                          final u = users[idx];
                          final int uid = u['id'] as int? ?? 0;
                          final String name = (u['full_name'] ??
                                  u['fullName'] ??
                                  'Pengguna')
                              .toString();
                          final String username =
                              (u['username'] ?? 'user').toString();
                          final String? avatarUrl = u['avatar_url'] as String?;
                          final String? bio = u['bio'] as String?;
                          final String backendStatus =
                              (u['connection_status'] ?? 'none').toString();

                          final avatarProvider =
                              getSmartImageProvider(avatarUrl);

                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.bgCard,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: AppColors.borderSubtle, width: 1),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              onTap: () => context.push('/profile/$uid'),
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor:
                                    AppColors.cyan.withValues(alpha: 0.2),
                                backgroundImage: avatarProvider,
                                child: avatarProvider == null
                                    ? Text(
                                        name.isNotEmpty
                                            ? name[0].toUpperCase()
                                            : '?',
                                        style: TextStyle(
                                          color: AppColors.cyan,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      )
                                    : null,
                              ),
                              title: Text(
                                name,
                                style: AppTypography.labelLg.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '@$username',
                                    style: AppTypography.bodySm.copyWith(
                                        color: AppColors.textMuted, fontSize: 12),
                                  ),
                                  if (bio != null && bio.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      bio,
                                      style: AppTypography.bodySm.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 11,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                              trailing: _buildStatusWidget(uid, name, backendStatus),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

// Shared Empty State
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyState({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 56, color: AppColors.textMuted),
              const SizedBox(height: AppSpacing.md),
              Text(title,
                  style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
                  textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text(subtitle,
                  style: AppTypography.bodyMd
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}
