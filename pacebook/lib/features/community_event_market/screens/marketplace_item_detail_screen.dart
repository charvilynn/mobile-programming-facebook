import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../widgets/community_widgets.dart';

// MarketplaceItemDetailScreen
/// Detail Barang PaceMarket —
/// Menampilkan foto, harga, deskripsi, profil penjual, dan tombol hubungi.
class MarketplaceItemDetailScreen extends ConsumerStatefulWidget {
  final int itemId;
  const MarketplaceItemDetailScreen({super.key, required this.itemId});

  @override
  ConsumerState<MarketplaceItemDetailScreen> createState() =>
      _MarketplaceItemDetailScreenState();
}

class _MarketplaceItemDetailScreenState
    extends ConsumerState<MarketplaceItemDetailScreen> {
  bool _isLoading = true;
  bool _isSaved = false;
  MarketItem? _item;

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  static const _mockSellerId = 2;

  Future<void> _loadItem() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _isLoading = false;
        _item = const MarketItem(
          id: 1,
          title: 'Laptop Gaming Asus ROG Strix G15',
          description: 'Kondisi 95%, masih bergaransi resmi hingga Desember 2027. Spesifikasi: AMD Ryzen 9 6900HX, RTX 3070 Ti, RAM 16GB DDR5, SSD 1TB NVMe. Jarang dipakai, dijual karena upgrade. Bonus cooling pad + tas laptop original.',
          price: 18500000,
          category: 'Elektronik',
          condition: 'Bekas',
          imageUrl: null,
          sellerName: 'Livi Angelica',
        );
      });
    }
  }

  String _formatPrice(double p) {
    final s = p.toStringAsFixed(0);
    final buf = StringBuffer('Rp ');
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.bgDeep,
        body: Center(child: CircularProgressIndicator(color: AppColors.cyan, strokeWidth: 2)),
      );
    }

    final item = _item!;
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textSecondary),
          onPressed: () => context.pop(),
        ),
        title: Text('Detail Barang', style: AppTypography.labelLg.copyWith(color: AppColors.textPrimary)),
        actions: [
          IconButton(
            icon: Icon(_isSaved ? Icons.bookmark : Icons.bookmark_outline,
                color: _isSaved ? AppColors.cyan : AppColors.textSecondary, size: 22),
            onPressed: () {
              setState(() => _isSaved = !_isSaved);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(_isSaved ? 'Disimpan ke favorit.' : 'Dihapus dari favorit.',
                    style: AppTypography.bodySm.copyWith(color: AppColors.textPrimary)),
                backgroundColor: AppColors.bgCard, behavior: SnackBarBehavior.floating,
              ));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
 // Gambar produk
                  Container(
                    width: double.infinity, height: 260,
                    color: AppColors.bgSurface,
                    child: item.imageUrl != null
                        ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                        : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.image_not_supported_outlined, size: 56, color: AppColors.textMuted),
                            const SizedBox(height: 8),
                            Text('Tidak ada foto', style: AppTypography.labelSm.copyWith(color: AppColors.textMuted)),
                          ]),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
 // Badge kondisi & kategori
                        Row(children: [
                          MarketplaceCategoryChip(label: item.category, isSelected: false, onTap: () {}),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: item.condition == 'Baru' ? AppColors.success.withValues(alpha: 0.15) : AppColors.warning.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(item.condition,
                                style: AppTypography.labelSm.copyWith(
                                    color: item.condition == 'Baru' ? AppColors.success : AppColors.warning)),
                          ),
                        ]),
                        const SizedBox(height: AppSpacing.sm),

 // Judul & harga
                        Text(item.title, style: AppTypography.h2.copyWith(color: AppColors.textPrimary, height: 1.3)),
                        const SizedBox(height: AppSpacing.sm),
                        Text(_formatPrice(item.price),
                            style: AppTypography.h1.copyWith(color: AppColors.cyan, fontWeight: FontWeight.w700)),

                        const SizedBox(height: AppSpacing.lg),
                        Divider(color: AppColors.borderSubtle),
                        const SizedBox(height: AppSpacing.md),

 // Profil penjual
                        Text('Penjual', style: AppTypography.labelMd.copyWith(color: AppColors.textMuted)),
                        const SizedBox(height: AppSpacing.sm),
                        GestureDetector(
                          onTap: () => context.push('/profile/$_mockSellerId'),
                          child: Row(children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.cyan.withValues(alpha: 0.15),
                              child: Text(item.sellerName[0],
                                  style: AppTypography.labelMd.copyWith(color: AppColors.cyan)),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(item.sellerName, style: AppTypography.labelMd.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                              Text('Lihat profil', style: AppTypography.labelSm.copyWith(color: AppColors.cyan)),
                            ]),
                            const Spacer(),
                            Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
                          ]),
                        ),

                        const SizedBox(height: AppSpacing.lg),
                        Divider(color: AppColors.borderSubtle),
                        const SizedBox(height: AppSpacing.md),

 // Deskripsi
                        Text('Deskripsi', style: AppTypography.labelMd.copyWith(color: AppColors.cyan, fontWeight: FontWeight.w600)),
                        const SizedBox(height: AppSpacing.sm),
                        Text(item.description ?? 'Tidak ada deskripsi.',
                            style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary, height: 1.7)),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

 // Bottom action bar
          Container(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              border: Border(top: BorderSide(color: AppColors.borderSubtle)),
            ),
            child: Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/chat/dm-$_mockSellerId'),
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Chat Penjual'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(color: AppColors.borderSubtle),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/chat/dm-$_mockSellerId'),
                  icon: const Icon(Icons.phone_outlined, size: 18),
                  label: const Text('Hubungi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyan,
                    foregroundColor: AppColors.bgDeep,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
