import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../widgets/community_widgets.dart';

// ─── EventDetailScreen ────────────────────────────────────────────────────────
/// Detail Agenda — Olivian
/// Menampilkan info lengkap event: waktu, lokasi, peserta, tombol hadir.
class EventDetailScreen extends ConsumerStatefulWidget {
  final int eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  bool _isLoading = true;
  String _attendStatus = 'none'; // 'none' | 'going' | 'interested'
  EventModel? _event;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _isLoading = false;
        _event = EventModel(
          id: widget.eventId,
          name: 'Flutter Forward Indonesia 2026',
          description: 'Event tahunan komunitas Flutter Indonesia. Hadir 10+ speaker, workshop intensif, dan networking session bersama developer Flutter dari seluruh Indonesia.',
          location: 'Jakarta Convention Center, Jakarta Pusat',
          startTime: DateTime.now().add(const Duration(days: 14, hours: 9)),
          endTime: DateTime.now().add(const Duration(days: 14, hours: 17)),
          attendeeCount: 342,
          isAttending: false,
        );
      });
    }
  }

  void _attend(String status) {
    setState(() => _attendStatus = _attendStatus == status ? 'none' : status);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        _attendStatus == 'none' ? 'Kehadiran dibatalkan.' : status == 'going' ? 'Kamu akan hadir!' : 'Kamu tertarik dengan event ini.',
        style: AppTypography.bodySm.copyWith(color: AppColors.textPrimary),
      ),
      backgroundColor: AppColors.bgCard,
      behavior: SnackBarBehavior.floating,
    ));
  }

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year} · ${dt.hour.toString().padLeft(2, '0')}.${dt.minute.toString().padLeft(2, '0')} WIB';

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.bgDeep,
        body: Center(child: CircularProgressIndicator(color: AppColors.cyan, strokeWidth: 2)),
      );
    }

    final e = _event!;
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textSecondary),
          onPressed: () => context.pop(),
        ),
        title: Text('Detail Agenda', style: AppTypography.labelLg.copyWith(color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Banner ────────────────────────────────────────────────────────
            Container(
              width: double.infinity, height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [AppColors.cyan.withValues(alpha: 0.2), AppColors.magenta.withValues(alpha: 0.12)],
                ),
              ),
              child: Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.event, color: AppColors.cyan, size: 48),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
                    ),
                    child: Text('AGENDA', style: AppTypography.labelSm.copyWith(color: AppColors.cyan, letterSpacing: 1.5)),
                  ),
                ]),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Judul ─────────────────────────────────────────────────
                  Text(e.name, style: AppTypography.h2.copyWith(color: AppColors.textPrimary, height: 1.3)),
                  const SizedBox(height: AppSpacing.md),

                  // ── Info grid ─────────────────────────────────────────────
                  _EventInfoRow(icon: Icons.schedule_outlined, label: 'Mulai', value: _formatDate(e.startTime)),
                  _EventInfoRow(icon: Icons.schedule, label: 'Selesai', value: _formatDate(e.endTime)),
                  _EventInfoRow(icon: Icons.location_on_outlined, label: 'Lokasi', value: e.location ?? 'Online'),
                  _EventInfoRow(icon: Icons.people_outline, label: 'Peserta', value: '${e.attendeeCount} orang hadir'),

                  const SizedBox(height: AppSpacing.lg),
                  Divider(color: AppColors.borderSubtle),
                  const SizedBox(height: AppSpacing.md),

                  // ── Tombol kehadiran ─────────────────────────────────────
                  Text('Kehadiranmu', style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _AttendBtn(
                          label: 'Hadir', icon: Icons.check_circle_outline,
                          active: _attendStatus == 'going',
                          activeColor: AppColors.cyan,
                          onTap: () => _attend('going'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _AttendBtn(
                          label: 'Tertarik', icon: Icons.star_outline,
                          active: _attendStatus == 'interested',
                          activeColor: AppColors.warning,
                          onTap: () => _attend('interested'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  Divider(color: AppColors.borderSubtle),
                  const SizedBox(height: AppSpacing.md),

                  // ── Deskripsi ─────────────────────────────────────────────
                  Text('Tentang Event', style: AppTypography.labelMd.copyWith(color: AppColors.cyan, fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(e.description ?? 'Tidak ada deskripsi.',
                      style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary, height: 1.7)),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventInfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _EventInfoRow({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 18, color: AppColors.cyan),
          const SizedBox(width: AppSpacing.sm),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: AppTypography.labelSm.copyWith(color: AppColors.textMuted)),
            Text(value, style: AppTypography.bodyMd.copyWith(color: AppColors.textPrimary)),
          ]),
        ]),
      );
}

class _AttendBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;
  const _AttendBtn({required this.label, required this.icon, required this.active, required this.activeColor, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? activeColor.withValues(alpha: 0.15) : AppColors.bgSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: active ? activeColor : AppColors.borderSubtle),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 18, color: active ? activeColor : AppColors.textMuted),
            const SizedBox(width: 6),
            Text(label, style: AppTypography.labelMd.copyWith(color: active ? activeColor : AppColors.textMuted, fontWeight: FontWeight.w600)),
          ]),
        ),
      );
}