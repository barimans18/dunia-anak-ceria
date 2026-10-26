import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/sound_engine.dart';
import '../../../core/services/user_profile_service.dart';
import '../../../shared/widgets/bouncy_card.dart';

class UserProfileDialog extends StatefulWidget {
  const UserProfileDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const UserProfileDialog(),
    );
  }

  @override
  State<UserProfileDialog> createState() => _UserProfileDialogState();
}

class _UserProfileDialogState extends State<UserProfileDialog> {
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String _selectedPhoto = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final profile = UserProfileService();
    _nameController.text = profile.name;
    _selectedPhoto = profile.photoPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    SoundEngine().playClick();
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );
      if (file != null) {
        setState(() {
          _selectedPhoto = file.path;
          _errorMessage = null;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _showImageSourceSheet() {
    SoundEngine().playClick();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pilih Sumber Foto 📸',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.primarySky),
                title: const Text('Buka Galeri Foto', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.warmAmber),
                title: const Text('Gunakan Kamera', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Yuk, tuliskan namamu dulu ya!');
      SoundEngine().playPop();
      return;
    }
    if (_selectedPhoto.isEmpty) {
      setState(() => _errorMessage = 'Pilih foto atau salah satu karakter di bawah ya!');
      SoundEngine().playPop();
      return;
    }

    SoundEngine().playWinStar();
    await UserProfileService().saveProfile(
      name: name,
      photoPath: _selectedPhoto,
    );

    if (mounted) {
      Navigator.pop(context);
      SoundEngine().speakWord('Halo, $name! Selamat bermain!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
        side: const BorderSide(color: AppColors.sunnyYellow, width: 4),
      ),
      child: Container(
        padding: const EdgeInsets.all(22),
        constraints: const BoxConstraints(maxWidth: 380),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              const Text(
                'Halo Teman Ceria! ✨',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Yuk isi nama dan pilih fotomu agar belajarmu makin seru!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.textMedium),
              ),
              const SizedBox(height: 18),

              // Avatar Circle Preview with Camera Badge
              GestureDetector(
                onTap: _showImageSourceSheet,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.sunnyYellow, width: 3.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _buildAvatarPreview(),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.warmAmber,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              TextButton.icon(
                onPressed: _showImageSourceSheet,
                icon: const Icon(Icons.add_photo_alternate_outlined, size: 16, color: Color(0xFF0284C7)),
                label: const Text(
                  'Upload dari HP / Kamera',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                ),
              ),

              const SizedBox(height: 6),
              const Text(
                'Atau pilih karakter favoritmu:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),

              // Preset Avatars Selector
              SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: UserProfileService.presetAvatars.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final item = UserProfileService.presetAvatars[index];
                    final isSelected = _selectedPhoto == item['id'];
                    return BouncyCard(
                      onTap: () {
                        SoundEngine().playClick();
                        setState(() {
                          _selectedPhoto = item['id']!;
                          _errorMessage = null;
                        });
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFEF3C7) : Colors.grey.shade100,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.warmAmber : Colors.grey.shade300,
                            width: isSelected ? 3 : 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(item['emoji']!, style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),

              // Name Input
              TextField(
                controller: _nameController,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText: 'Tulis nama panggilanmu...',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400, fontWeight: FontWeight.w600),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppColors.warmAmber, width: 2.5),
                  ),
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: const TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Nanti Saja (Skip)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warmAmber,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _save,
                      child: const Text(
                        'Simpan 🚀',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPreview() {
    if (UserProfileService.isLocalFile(_selectedPhoto)) {
      return Image.file(
        File(_selectedPhoto),
        fit: BoxFit.cover,
        width: 90,
        height: 90,
      );
    }

    final emoji = UserProfileService.getPresetEmoji(_selectedPhoto);
    if (emoji != null) {
      return Center(
        child: Text(emoji, style: const TextStyle(fontSize: 48)),
      );
    }

    return Center(
      child: SvgPicture.asset(
        'assets/icons/app_icon.svg',
        width: 90,
        height: 90,
        fit: BoxFit.cover,
      ),
    );
  }
}
