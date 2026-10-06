import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../widgets/profile_widgets.dart';
import 'profile_screen.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _workCtrl;
  late final TextEditingController _educationCtrl;
  late final TextEditingController _birthdayCtrl;
  String? _gender;

  String? _avatarUrl;
  bool _isSaving = false;
  bool _hasChanges = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _usernameCtrl = TextEditingController();
    _bioCtrl = TextEditingController();
    _locationCtrl = TextEditingController();
    _workCtrl = TextEditingController();
    _educationCtrl = TextEditingController();
    _birthdayCtrl = TextEditingController();

    for (final ctrl in [
      _nameCtrl,
      _usernameCtrl,
      _bioCtrl,
      _locationCtrl,
      _workCtrl,
      _educationCtrl,
      _birthdayCtrl,
    ]) {
      ctrl.addListener(() {
        if (_initialized && mounted) setState(() => _hasChanges = true);
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentProfile();
    });
  }

  Future<void> _loadCurrentProfile() async {
    final profile = ref.read(profileProvider(null)).valueOrNull;
    if (profile != null) {
      _nameCtrl.text = profile.name;
      _usernameCtrl.text = profile.username;
      _bioCtrl.text = profile.bio ?? '';
      _locationCtrl.text = profile.location ?? '';
      _workCtrl.text = profile.work ?? '';
      _educationCtrl.text = profile.education ?? '';
      _birthdayCtrl.text = profile.birthday ?? '';
      _gender = profile.gender;
      _avatarUrl = profile.avatarUrl;
    } else {
      final storage = ref.read(storageServiceProvider);
      final raw = await storage.getUserData();
      if (raw != null && raw.isNotEmpty) {
        try {
          final map = jsonDecode(raw) as Map<String, dynamic>;
          _nameCtrl.text = (map['full_name'] ?? map['fullName'] ?? '').toString();
          _usernameCtrl.text = (map['username'] ?? '').toString();
          _bioCtrl.text = (map['bio'] ?? '').toString();
          _locationCtrl.text = (map['location'] ?? '').toString();
          _workCtrl.text = (map['work'] ?? '').toString();
          _educationCtrl.text = (map['education'] ?? '').toString();
          _birthdayCtrl.text = (map['birthday'] ?? '').toString();
          _gender = map['gender'] as String?;
          _avatarUrl = map['avatar_url'] as String?;
        } catch (_) {}
      }
    }
    setState(() {
      _initialized = true;
      _hasChanges = false;
    });
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2001, 1, 1),
      firstDate: DateTime(1940),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.cyan,
              onPrimary: AppColors.bgDeep,
              surface: AppColors.bgCard,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      const months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      final formatted = '${picked.day} ${months[picked.month - 1]} ${picked.year}';
      setState(() {
        _birthdayCtrl.text = formatted;
        _hasChanges = true;
      });
    }
  }

  Future<void> _pickAvatar() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        final b64 = base64Encode(bytes);
        final mime = file.mimeType ?? 'image/jpeg';
        final dataUri = 'data:$mime;base64,$b64';
        setState(() {
          _avatarUrl = dataUri;
          _hasChanges = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal memilih foto: $e'),
          backgroundColor: AppColors.bgCard,
        ));
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _bioCtrl.dispose();
    _locationCtrl.dispose();
    _workCtrl.dispose();
    _educationCtrl.dispose();
    _birthdayCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final api = ref.read(apiClientProvider);
      final res = await api.patch('/users/me', data: {
        'full_name': _nameCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'work': _workCtrl.text.trim(),
        'education': _educationCtrl.text.trim(),
        'birthday': _birthdayCtrl.text.trim(),
        'gender': _gender,
        if (_avatarUrl != null) 'avatar_url': _avatarUrl,
      });

      if (res.data != null && res.data['data'] != null) {
        final storage = ref.read(storageServiceProvider);
        await storage.saveUserData(jsonEncode(res.data['data']));
      }

      ref.invalidate(profileProvider(null));

      if (mounted) {
        setState(() {
          _isSaving = false;
          _hasChanges = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Profil berhasil diperbarui!',
              style: AppTypography.bodySm.copyWith(color: AppColors.textPrimary)),
          backgroundColor: AppColors.bgCard,
          behavior: SnackBarBehavior.floating,
        ));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal memperbarui profil: $e',
              style: AppTypography.bodySm.copyWith(color: AppColors.error)),
          backgroundColor: AppColors.bgCard,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
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
          onPressed: () => _hasChanges ? _showDiscardDialog() : context.pop(),
        ),
        title: Text('Edit Profil',
            style: AppTypography.labelLg.copyWith(color: AppColors.textPrimary)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: _isSaving
                ? SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                        color: AppColors.cyan, strokeWidth: 2))
                : TextButton(
                    onPressed: _hasChanges ? _save : null,
                    child: Text('Simpan',
                        style: AppTypography.labelMd.copyWith(
                            color: _hasChanges
                                ? AppColors.cyan
                                : AppColors.textMuted,
                            fontWeight: FontWeight.w600)),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickAvatar,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.cyan.withValues(alpha: 0.18),
                      backgroundImage: getSmartImageProvider(_avatarUrl),
                      child: _avatarUrl == null
                          ? Text(
                              _nameCtrl.text.isNotEmpty
                                  ? _nameCtrl.text[0].toUpperCase()
                                  : 'U',
                              style: AppTypography.display1
                                  .copyWith(color: AppColors.cyan),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.cyan,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.bgDeep, width: 2),
                        ),
                        child: Icon(Icons.camera_alt,
                            size: 14, color: AppColors.bgDeep),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            _SectionHeader('Informasi Dasar'),
            EditProfileFormField(
              label: 'Nama Lengkap',
              hint: 'Nama yang ditampilkan di profil',
              controller: _nameCtrl,
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Nama tidak boleh kosong'
                  : null,
            ),
            EditProfileFormField(
              label: 'Username',
              hint: 'contoh: davvin_pratama',
              controller: _usernameCtrl,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Username tidak boleh kosong';
                if (v.contains(' ')) return 'Username tidak boleh mengandung spasi';
                return null;
              },
            ),
            EditProfileFormField(
              label: 'Bio',
              hint: 'Ceritakan sedikit tentang dirimu...',
              controller: _bioCtrl,
              maxLines: 3,
            ),

            _SectionHeader('Detail Pribadi'),
            EditProfileFormField(
              label: 'Tanggal Lahir',
              hint: 'Ketuk untuk memilih tanggal...',
              controller: _birthdayCtrl,
              readOnly: true,
              onTap: _pickBirthday,
              suffixIcon: IconButton(
                icon: Icon(Icons.cake_outlined, color: AppColors.cyan, size: 20),
                onPressed: _pickBirthday,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Jenis Kelamin',
                      style: AppTypography.labelSm.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: ['Pria', 'Wanita', 'Lainnya'].map((g) {
                      final isSelected = _gender == g;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(g),
                          selected: isSelected,
                          selectedColor: AppColors.cyan,
                          backgroundColor: AppColors.bgSurface,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.bgDeep : AppColors.textPrimary,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 13,
                          ),
                          side: BorderSide(
                            color: isSelected ? AppColors.cyan : AppColors.borderSubtle,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _gender = g;
                                _hasChanges = true;
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            _SectionHeader('Informasi Tambahan'),
            EditProfileFormField(
              label: 'Lokasi',
              hint: 'Kota, Negara',
              controller: _locationCtrl,
            ),
            EditProfileFormField(
              label: 'Pekerjaan',
              hint: 'Jabatan / Status pekerjaan',
              controller: _workCtrl,
            ),
            EditProfileFormField(
              label: 'Pendidikan',
              hint: 'Universitas — Jurusan',
              controller: _educationCtrl,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: Text('Buang perubahan?',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary)),
        content: Text('Informasi profil yang belum disimpan akan hilang.',
            style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Lanjut Edit',
                style: AppTypography.labelMd.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () { Navigator.pop(context); context.pop(); },
            child: Text('Buang',
                style: AppTypography.labelMd.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(
            bottom: AppSpacing.sm, top: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: AppTypography.labelMd.copyWith(
                    color: AppColors.cyan, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Divider(color: AppColors.borderSubtle, height: 1),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      );
}