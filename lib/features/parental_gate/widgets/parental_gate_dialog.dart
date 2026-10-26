import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/sound_engine.dart';

class ParentalGateDialog extends StatefulWidget {
  const ParentalGateDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const ParentalGateDialog(),
    );
  }

  @override
  State<ParentalGateDialog> createState() => _ParentalGateDialogState();
}

class _ParentalGateDialogState extends State<ParentalGateDialog> {
  late int num1;
  late int num2;
  late int expectedAnswer;
  final TextEditingController _controller = TextEditingController();
  bool hasError = false;
  bool isUnlocked = false;

  // Settings mock state
  int screenTimeMinutes = 30;
  bool isKioskLocked = true;

  @override
  void initState() {
    super.initState();
    _generateMath();
  }

  void _generateMath() {
    final rand = Random();
    num1 = rand.nextInt(5) + 3;
    num2 = rand.nextInt(5) + 2;
    expectedAnswer = num1 + num2;
    _controller.clear();
    hasError = false;
  }

  void _verifyAnswer() {
    final ans = int.tryParse(_controller.text.trim());
    if (ans == expectedAnswer) {
      SoundEngine().playWinStar();
      setState(() {
        isUnlocked = true;
        hasError = false;
      });
    } else {
      SoundEngine().playPop();
      setState(() {
        hasError = true;
      });
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
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 360),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: isUnlocked ? _buildSettingsContent() : _buildChallengeContent(),
      ),
    );
  }

  Widget _buildChallengeContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.sunnyYellow, width: 2),
          ),
          child: const Center(
            child: Text('🔒', style: TextStyle(fontSize: 26)),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Zona Orang Tua',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        const SizedBox(height: 6),
        const Text(
          'Selesaikan perhitungan berikut untuk membuka pengaturan:',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: AppColors.textMedium),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Text(
            '$num1 + $num2 = ?',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.warmAmber,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: 'Jawaban...',
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.warmAmber, width: 2),
            ),
          ),
          onSubmitted: (_) => _verifyAnswer(),
        ),
        if (hasError) ...[
          const SizedBox(height: 8),
          const Text(
            'Jawaban belum tepat, yuk coba lagi!',
            style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: AppColors.textDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warmAmber,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 2,
                ),
                onPressed: _verifyAnswer,
                child: const Text('Buka', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SvgPicture.asset(
                'assets/icons/app_icon.svg',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Pengaturan Kiosk',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.timer_outlined, color: AppColors.warmAmber),
          title: const Text('Batas Waktu Layar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          subtitle: Text('$screenTimeMinutes Menit aktif', style: const TextStyle(fontSize: 11)),
          trailing: DropdownButton<int>(
            value: screenTimeMinutes,
            underline: const SizedBox(),
            items: [15, 30, 45, 60].map((int val) {
              return DropdownMenuItem<int>(
                value: val,
                child: Text('$val m', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              );
            }).toList(),
            onChanged: (newVal) {
              if (newVal != null) setState(() => screenTimeMinutes = newVal);
            },
          ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.shield_outlined, color: AppColors.emeraldGreen),
          title: const Text('Kunci Kiosk Home', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          subtitle: const Text('Cegah anak keluar aplikasi', style: TextStyle(fontSize: 11)),
          value: isKioskLocked,
          activeThumbColor: AppColors.emeraldGreen,
          onChanged: (val) => setState(() => isKioskLocked = val),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade50,
            foregroundColor: Colors.red.shade700,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            elevation: 0,
          ),
          icon: const Icon(Icons.exit_to_app, size: 18),
          label: const Text('Keluar ke Launcher Sistem', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          onPressed: () {
            Navigator.pop(context);
            SystemNavigator.pop();
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warmAmber,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Simpan & Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
