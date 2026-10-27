import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/sound_engine.dart';
import '../../../core/services/user_profile_service.dart';
import '../../../shared/widgets/bouncy_card.dart';
import '../../../shared/widgets/top_kiosk_bar.dart';
import '../../animals/screens/animals_screen.dart';
import '../../fruits/screens/fruits_screen.dart';
import '../../interactive_cartoon/screens/interactive_cartoon_screen.dart';
import '../../numbers/screens/numbers_screen.dart';
import '../../reading/screens/reading_screen.dart';
import '../../vehicles/screens/vehicles_screen.dart';
import '../../voice_mimic/screens/voice_mimic_screen.dart';
import '../../story/screens/story_list_screen.dart';
import '../widgets/user_profile_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String currentView = 'home'; // 'home', 'learn_hub', 'animals', 'vehicles', 'fruits', 'reading', 'numbers', 'video', 'mimic'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTimeProfilePopup();
    });
  }

  void _checkFirstTimeProfilePopup() {
    final profile = UserProfileService();
    // Jika belum ke-set dua-duanya (nama & foto), munculkan popup
    if (!profile.isProfileComplete && mounted) {
      UserProfileDialog.show(context);
    }
  }

  void _switchView(String view) {
    SoundEngine().playClick();
    setState(() => currentView = view);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.mainGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Top Safe Area / Kiosk Bar
              const TopKioskBar(),

              // Main Scene Content
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _buildCurrentView(),
                ),
              ),

              // Bottom Ergonomic Navigation Bar
              _buildBottomNav(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (currentView) {
      case 'animals':
        return AnimalsScreen(key: const ValueKey('animals'), onBack: () => _switchView('learn_hub'));
      case 'vehicles':
        return VehiclesScreen(key: const ValueKey('vehicles'), onBack: () => _switchView('learn_hub'));
      case 'fruits':
        return FruitsScreen(key: const ValueKey('fruits'), onBack: () => _switchView('learn_hub'));
      case 'reading':
        return ReadingScreen(key: const ValueKey('reading'), onBack: () => _switchView('learn_hub'));
      case 'numbers':
        return NumbersScreen(key: const ValueKey('numbers'), onBack: () => _switchView('home'));
      case 'video':
        return InteractiveCartoonScreen(key: const ValueKey('video'), onBack: () => _switchView('home'));
      case 'mimic':
        return VoiceMimicScreen(key: const ValueKey('mimic'), onBack: () => _switchView('home'));
      case 'stories':
        return StoryListScreen(key: const ValueKey('stories'), onBack: () => _switchView('home'));
      case 'learn_hub':
        return _buildLearnHub();
      case 'home':
      default:
        return _buildHomeDashboard();
    }
  }

  Widget _buildHomeDashboard() {
    return SingleChildScrollView(
      key: const ValueKey('home_dashboard'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Banner Hero
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFBBF24), Color(0xFFFB923C)],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '100% BEBAS KUOTA',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Dunia Belajar Ceria! 🎈',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'Pilih menu seru di bawah ini ya!',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text('🎈', style: TextStyle(fontSize: 40)),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 4 Main Module Cards Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 600 ? 4 : 2;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  _buildDashboardCard(
                    title: 'Pusat Belajar',
                    subtitle: 'Hewan, Mobil, Buah, Huruf',
                    emoji: '🎒',
                    svgAsset: 'assets/icons/app_icon.svg',
                    borderColor: AppColors.emeraldGreen,
                    gradient: AppColors.cardGreenGradient,
                    onTap: () => _switchView('learn_hub'),
                  ),
                  _buildDashboardCard(
                    title: 'Kartun Interaktif',
                    subtitle: 'Sentuh & Bereaksi',
                    emoji: '🎬',
                    borderColor: AppColors.softPink,
                    gradient: AppColors.cardRoseGradient,
                    onTap: () => _switchView('video'),
                  ),
                  _buildDashboardCard(
                    title: 'Belajar Membaca',
                    subtitle: 'Eja Kata Perlahan',
                    emoji: '🔤',
                    svgAsset: 'assets/icons/reading.svg',
                    borderColor: AppColors.playfulPurple,
                    gradient: AppColors.cardPurpleGradient,
                    onTap: () => _switchView('reading'),
                  ),
                  _buildDashboardCard(
                    title: 'Tirukan Suara',
                    subtitle: 'Rekam & Ubah Nada Lucu',
                    emoji: '🎙️',
                    borderColor: AppColors.warmAmber,
                    gradient: AppColors.cardAmberGradient,
                    onTap: () => _switchView('mimic'),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 12),

          // Quick Banner Angka & Balon
          BouncyCard(
            onTap: () => _switchView('numbers'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.sunnyYellow, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text('🔢', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Ayo Menghitung 1 sampai 10',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          'Letuskan balon warna-warni!',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.sunnyYellow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Mulai 🚀',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF78350F),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Banner Buku Cerita Interaktif
          BouncyCard(
            onTap: () => _switchView('stories'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFF59E0B), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text('📚', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Buku Cerita Interaktif',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          'Pisang Manis untuk Dudung 🍌 (Karaoke & Sentuh)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Baca 📖',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required String subtitle,
    required String emoji,
    String? svgAsset,
    required Color borderColor,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return BouncyCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: borderColor, width: 3),
          boxShadow: [
            BoxShadow(
              color: borderColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: svgAsset != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SvgPicture.asset(
                          svgAsset,
                          width: 38,
                          height: 38,
                          fit: BoxFit.contain,
                        ),
                      )
                    : Text(emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearnHub() {
    return SingleChildScrollView(
      key: const ValueKey('learn_hub'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih Kategori Belajar 🎒',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
          ),
          const Text(
            'Sentuh untuk membuka topik favoritmu:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54),
          ),
          const SizedBox(height: 14),

          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 600 ? 4 : 2;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
                children: [
                  _buildHubCategoryCard(
                    title: 'Sahabat Satwa',
                    subtitle: '16 Hewan & Suaranya',
                    badge: 'Buka 🐾',
                    emoji: '🦁',
                    svgAsset: 'assets/icons/animals.svg',
                    borderColor: AppColors.emeraldGreen,
                    badgeColor: AppColors.emeraldGreen,
                    onTap: () => _switchView('animals'),
                  ),
                  _buildHubCategoryCard(
                    title: 'Kendaraan',
                    subtitle: '13 Alat Transportasi',
                    badge: 'Buka 🚦',
                    emoji: '🚗',
                    svgAsset: 'assets/icons/vehicles.svg',
                    borderColor: AppColors.primarySky,
                    badgeColor: AppColors.primarySky,
                    onTap: () => _switchView('vehicles'),
                  ),
                  _buildHubCategoryCard(
                    title: 'Buah & Warna',
                    subtitle: '12 Buah Segar',
                    badge: 'Buka 🍉',
                    emoji: '🍎',
                    svgAsset: 'assets/icons/fruits.svg',
                    borderColor: AppColors.softPink,
                    badgeColor: AppColors.softPink,
                    onTap: () => _switchView('fruits'),
                  ),
                  _buildHubCategoryCard(
                    title: 'Membaca & Eja',
                    subtitle: 'Alfabet & Suku Kata',
                    badge: 'Buka 📖',
                    emoji: '🔤',
                    svgAsset: 'assets/icons/reading.svg',
                    borderColor: AppColors.playfulPurple,
                    badgeColor: AppColors.playfulPurple,
                    onTap: () => _switchView('reading'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHubCategoryCard({
    required String title,
    required String subtitle,
    required String badge,
    required String emoji,
    String? svgAsset,
    required Color borderColor,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return BouncyCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: borderColor, width: 3),
          boxShadow: [
            BoxShadow(
              color: borderColor.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            svgAsset != null
                ? SvgPicture.asset(
                    svgAsset,
                    width: 58,
                    height: 58,
                    fit: BoxFit.contain,
                  )
                : Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textDark),
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                badge,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: const Border(
          top: BorderSide(color: Color(0xFFFDE68A), width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(id: 'home', icon: '🏠', label: 'Beranda'),
            _buildNavItem(id: 'learn_hub', icon: '🎒', label: 'Belajar'),
            _buildNavItem(id: 'video', icon: '🎬', label: 'Kartun'),
            _buildNavItem(id: 'mimic', icon: '🎙️', label: 'Suaraku'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({required String id, required String icon, required String label}) {
    final isSelected = currentView == id ||
        (id == 'learn_hub' && ['animals', 'vehicles', 'fruits', 'reading'].contains(currentView));

    return GestureDetector(
      onTap: () => _switchView(id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFEF3C7) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: isSelected ? AppColors.warmAmber : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
