import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/sound_engine.dart';
import '../../../shared/widgets/bouncy_card.dart';
import 'interactive_cartoon_screen.dart';
import 'interactive_aquarium_screen.dart';

/// Layar Daftar Pilihan Kartun Interaktif
class InteractiveCartoonListScreen extends StatefulWidget {
  final VoidCallback onBack;

  const InteractiveCartoonListScreen({super.key, required this.onBack});

  @override
  State<InteractiveCartoonListScreen> createState() =>
      _InteractiveCartoonListScreenState();
}

class _InteractiveCartoonListScreenState
    extends State<InteractiveCartoonListScreen> {
  // null = tampilan list, 'car' = kartun mobil, 'aquarium' = kartun akuarium
  String? _selectedCartoon;

  void _openCartoon(String cartoonKey) {
    SoundEngine().playClick();
    setState(() => _selectedCartoon = cartoonKey);
  }

  void _closeCartoon() {
    SoundEngine().playClick();
    setState(() => _selectedCartoon = null);
  }

  @override
  Widget build(BuildContext context) {
    // 1. Tampilkan Layar Kartun Mobil jika dipilih
    if (_selectedCartoon == 'car') {
      return InteractiveCartoonScreen(onBack: _closeCartoon);
    }

    // 2. Tampilkan Layar Kartun Akuarium jika dipilih
    if (_selectedCartoon == 'aquarium') {
      return InteractiveAquariumScreen(onBack: _closeCartoon);
    }

    // 3. Tampilkan Layar Daftar Pilihan Kartun
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: widget.onBack,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.pink.shade200, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Text('⬅️', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Panggung Kartun Interaktif 🎬',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Pilih dunia kartun seru untuk dimainkan!',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.sunnyYellow,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  '🌟 2 Dunia',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: Color(0xFF78350F),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Daftar Kartu Kartun Interaktif
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            children: [
              // Kartu 1: Mobil & Pelangi
              _buildCartoonCard(
                title: 'Petualangan Mobil & Pelangi',
                subtitle:
                    'Kendalikan mobil laju cepat, letuskan balon udara, kembang api ceria, dan hadirkan pelangi indah!',
                emojiBanner: '🏎️ 🌈 🎈',
                badgeText: 'FAVORIT BALITA',
                badgeColor: const Color(0xFFFB923C),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFFBEB),
                    Color(0xFFFEF3C7),
                    Color(0xFFFDE68A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderColor: const Color(0xFFF59E0B),
                tagList: ['🏎️ Mobil Laju', '🌧️ Hujan', '🎆 Kembang Api', '🌙 Siang/Malam'],
                onTap: () => _openCartoon('car'),
              ),

              const SizedBox(height: 14),

              // Kartu 2: Akuarium Bawah Laut Ajaib
              _buildCartoonCard(
                title: 'Akuarium Bawah Laut Ajaib',
                subtitle:
                    'Beri makan ikan badut Mimi, buka peti mutiara berkilau, sapa kura-kura, dan semburan tinta gurita!',
                emojiBanner: '🐠 🫧 💎',
                badgeText: '✨ DUNIA BARU',
                badgeColor: const Color(0xFF0284C7),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFF0FDF4),
                    Color(0xFFE0F2FE),
                    Color(0xFFBAE6FD),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderColor: const Color(0xFF0284C7),
                tagList: ['🐠 Ikan Mimi', '🥩 Beri Makan', '📦 Peti Emas', '🐢 Kura-kura', '🐙 Gurita'],
                onTap: () => _openCartoon('aquarium'),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCartoonCard({
    required String title,
    required String subtitle,
    required String emojiBanner,
    required String badgeText,
    required Color badgeColor,
    required LinearGradient gradient,
    required Color borderColor,
    required List<String> tagList,
    required VoidCallback onTap,
  }) {
    return BouncyCard(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.22),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris Atas: Badge & Emoji
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: badgeColor.withValues(alpha: 0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Text(
                  emojiBanner,
                  style: const TextStyle(fontSize: 22),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Judul
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),

            const SizedBox(height: 4),

            // Deskripsi
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: Colors.black.withValues(alpha: 0.7),
              ),
            ),

            const SizedBox(height: 10),

            // Chip Tags
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tagList.map((tag) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: borderColor.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: borderColor,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // Tombol Mainkan
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: borderColor.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sentuh & Mainkan ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text('🎮', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
