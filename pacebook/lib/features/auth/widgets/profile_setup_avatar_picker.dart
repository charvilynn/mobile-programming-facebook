import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';


class ProfileSetupAvatarPicker extends StatefulWidget {
  final void Function(String? imagePath) onImageSelected;
  final String? initialImagePath;

  const ProfileSetupAvatarPicker({
    super.key,
    required this.onImageSelected,
    this.initialImagePath,
  });

  @override
  State<ProfileSetupAvatarPicker> createState() => _ProfileSetupAvatarPickerState();
}

class _ProfileSetupAvatarPickerState extends State<ProfileSetupAvatarPicker> {
  String? _imagePath;
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    HapticFeedback.lightImpact();
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _imagePath = picked.path);
      widget.onImageSelected(picked.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.bgCard,
              border: Border.all(color: AppColors.cyan, width: 2),
              boxShadow: [BoxShadow(
                color: AppColors.cyanGlow,
                blurRadius: 12,
                spreadRadius: 1,
              )],
            ),
            child: _imagePath != null
                ? ClipOval(
                    child: Image.network(_imagePath!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.person, color: AppColors.cyan, size: 40,
                      )),
                  )
                : Icon(Icons.person_outline, color: AppColors.cyan, size: 40),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cyan,
            ),
            child: Icon(Icons.camera_alt, size: 16, color: AppColors.bgDeep),
          ),
        ],
      ),
    );
  }
}