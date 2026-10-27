import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/sound_engine.dart';
import '../../../models/story_model.dart';

/// Layar Pembaca Cerita Interaktif Ramah Anak (Landscape-First & Offline-First)
class StoryReaderScreen extends StatefulWidget {
  final StoryModel? story;
  final String storyAssetPath;

  const StoryReaderScreen({
    super.key,
    this.story,
    this.storyAssetPath = 'assets/stories/somat_pisang.json',
  });

  @override
  State<StoryReaderScreen> createState() => _StoryReaderScreenState();
}

class _StoryReaderScreenState extends State<StoryReaderScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPageIndex = 0;

  StoryModel? _storyData;
  bool _isLoading = true;

  // Audio & TTS Engine
  final AudioPlayer _narrationPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  StreamSubscription? _positionSubscription;
  StreamSubscription? _completeSubscription;
  int _currentAudioPositionMs = 0;
  bool _isPlayingNarration = false;

  // Fallback timer jika file audio mp3 fisik belum ada di storage
  Timer? _fallbackKaraokeTimer;

  // Feedback animasi tap suku kata
  int? _tappedSyllableIndex;

  // Feedback animasi interaktif Hotspot
  InteractiveHotspot? _activeHotspot;
  late AnimationController _hotspotAnimController;
  late Animation<double> _hotspotScaleAnimation;
  late Animation<double> _hotspotOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // 1. Kunci orientasi ke Landscape saat layar cerita dibuka
    _lockToLandscape();

    // Inisialisasi controller animasi burst hotspot
    _hotspotAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _hotspotScaleAnimation = Tween<double>(begin: 0.6, end: 1.4).animate(
      CurvedAnimation(parent: _hotspotAnimController, curve: Curves.elasticOut),
    );
    _hotspotOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _hotspotAnimController,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
      ),
    );

    _initAudioListeners();
    _loadStoryData();
  }

  /// Memaksa orientasi perangkat ke mode Landscape penuh
  void _lockToLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  /// Mengembalikan orientasi ke mode bebas/normal saat keluar
  void _restoreOrientations() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _initAudioListeners() {
    // Dengarkan audioPositionStream secara real-time
    _positionSubscription = _narrationPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _currentAudioPositionMs = position.inMilliseconds;
        });
      }
    });

    _completeSubscription = _narrationPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlayingNarration = false;
        });
      }
    });
  }

  Future<void> _loadStoryData() async {
    try {
      if (widget.story != null) {
        _storyData = widget.story;
      } else {
        _storyData = await StoryModel.fromAsset(widget.storyAssetPath);
      }
    } catch (e) {
      debugPrint("Error loading story: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Putar audio narasi halaman pertama
        _playPageNarration(_currentPageIndex);
      }
    }
  }

  /// Putar narasi audio halaman aktif dengan sinkronisasi karaoke
  Future<void> _playPageNarration(int pageIndex) async {
    _fallbackKaraokeTimer?.cancel();
    await _narrationPlayer.stop();

    if (_storyData == null || pageIndex >= _storyData!.pages.length) return;

    final page = _storyData!.pages[pageIndex];
    setState(() {
      _currentAudioPositionMs = 0;
      _isPlayingNarration = true;
    });

    final rawPath = page.audioPath;
    final cleanPath = rawPath.startsWith('assets/') ? rawPath.substring(7) : rawPath;

    // Periksa apakah file audio fisik sudah terdaftar di rootBundle
    bool assetExists = false;
    try {
      await rootBundle.load('assets/$cleanPath');
      assetExists = true;
    } catch (_) {
      assetExists = false;
    }

    if (assetExists) {
      try {
        await _narrationPlayer.setVolume(1.0);
        await _narrationPlayer.play(AssetSource(cleanPath));
        return;
      } catch (e) {
        debugPrint("Error playing audio ($cleanPath): $e. Mengalihkan ke suara TTS.");
      }
    }

    // Fallback: Jika file mp3 tidak ada atau gagal diputar di device,
    // langsung bacakan teks cerita dengan suara jernih via SoundEngine TTS!
    _playNarrationWithTtsFallback(page);
  }

  /// Membacakan teks narasi dengan TTS Bahasa Indonesia + sinkronisasi visual karaoke
  void _playNarrationWithTtsFallback(StoryPage page) {
    SoundEngine().speakWord(page.fullText, rate: 0.38);
    _startFallbackKaraokeSimulation(page.syllables);
  }

  /// Simulasi progress karaoke jika audio file offline fisik belum dimasukkan ke bundle
  void _startFallbackKaraokeSimulation(List<SyllableToken> syllables) {
    if (syllables.isEmpty) {
      setState(() => _isPlayingNarration = false);
      return;
    }

    final maxEndMs = syllables.map((s) => s.endMs).fold(0, (prev, elem) => elem > prev ? elem : prev);
    int simulatedMs = 0;
    const intervalMs = 60;

    _fallbackKaraokeTimer = Timer.periodic(const Duration(milliseconds: intervalMs), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      simulatedMs += intervalMs;
      setState(() {
        _currentAudioPositionMs = simulatedMs;
      });

      if (simulatedMs >= maxEndMs + 400) {
        timer.cancel();
        setState(() {
          _isPlayingNarration = false;
        });
      }
    });
  }

  /// Pelafalan suku kata via TTS saat ditepuk anak
  Future<void> _onSyllableTap(SyllableToken syllable, int index) async {
    SoundEngine().playPop();
    setState(() => _tappedSyllableIndex = index);

    final cleanText = syllable.text.replaceAll(RegExp(r'[^a-zA-Z0-9áéíóúÁÉÍÓÚ]'), '');
    try {
      await SoundEngine().speakWord(cleanText, rate: 0.48);
    } catch (e) {
      debugPrint("TTS tap error: $e");
    }

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted && _tappedSyllableIndex == index) {
        setState(() => _tappedSyllableIndex = null);
      }
    });
  }

  /// Hotspot interaktif diketuk: mainkan SFX dan tampilkan efek riak bintang
  Future<void> _onHotspotTap(InteractiveHotspot hotspot) async {
    // 1. Animasi riak bintang
    setState(() {
      _activeHotspot = hotspot;
    });
    _hotspotAnimController.forward(from: 0.0);

    // 2. Mainkan SFX lokal
    final rawSfx = hotspot.sfxPath;
    final cleanSfx = rawSfx.startsWith('assets/') ? rawSfx.substring(7) : rawSfx;

    bool sfxExists = false;
    try {
      await rootBundle.load('assets/$cleanSfx');
      sfxExists = true;
    } catch (_) {
      sfxExists = false;
    }

    if (sfxExists) {
      try {
        await _sfxPlayer.stop();
        await _sfxPlayer.setVolume(1.0);
        await _sfxPlayer.play(AssetSource(cleanSfx));
        return;
      } catch (_) {}
    }

    // Fallback jika SFX spesifik belum ada
    SoundEngine().playWinStar();
  }

  /// Dialog konfirmasi ramah anak saat ingin keluar dari buku cerita
  Future<bool> _showExitConfirmationDialog() async {
    SoundEngine().playClick();
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFBEB), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppColors.sunnyYellow, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('📚✨', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                Text(
                  'Mau Selesai Membaca?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Cerita seru ini masih menunggu petualanganmu lho!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.comicNeue(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMedium,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Tombol Lanjut Baca (Hijau)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emeraldGreen,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        SoundEngine().playClick();
                        Navigator.of(context).pop(false);
                      },
                      child: Row(
                        children: [
                          const Text('🌟 ', style: TextStyle(fontSize: 18)),
                          Text(
                            'Lanjut Baca',
                            style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Tombol Keluar (Merah/Oranye)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.rubyRed,
                        side: const BorderSide(color: AppColors.rubyRed, width: 2.5),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        SoundEngine().playClick();
                        Navigator.of(context).pop(true);
                      },
                      child: Row(
                        children: [
                          const Text('🏠 ', style: TextStyle(fontSize: 18)),
                          Text(
                            'Keluar',
                            style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    return shouldExit ?? false;
  }

  void _onBackPressed() async {
    final navigator = Navigator.of(context);
    final canExit = await _showExitConfirmationDialog();
    if (canExit && mounted) {
      _restoreOrientations();
      navigator.pop();
    }
  }

  @override
  void dispose() {
    _fallbackKaraokeTimer?.cancel();
    _positionSubscription?.cancel();
    _completeSubscription?.cancel();
    _narrationPlayer.dispose();
    _sfxPlayer.dispose();
    _hotspotAnimController.dispose();
    _pageController.dispose();
    // Pastikan orientasi dinormalkan kembali jika pengguna pop layar
    _restoreOrientations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final shouldExit = await _showExitConfirmationDialog();
        if (shouldExit && mounted) {
          _restoreOrientations();
          navigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1E1E2E),
        body: _isLoading
            ? _buildLoadingState()
            : _storyData == null || _storyData!.pages.isEmpty
                ? _buildErrorState()
                : _buildStoryContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.sunnyYellow, strokeWidth: 4),
          const SizedBox(height: 16),
          Text(
            'Membuka Buku Cerita... 📖✨',
            style: GoogleFonts.fredoka(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('😢', style: TextStyle(fontSize: 50)),
          const SizedBox(height: 12),
          Text(
            'Buku cerita belum dapat dimuat.',
            style: GoogleFonts.fredoka(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _restoreOrientations();
              Navigator.of(context).pop();
            },
            child: const Text('Kembali'),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryContent() {
    final totalPages = _storyData!.pages.length;
    final currentPage = _storyData!.pages[_currentPageIndex];

    return Stack(
      children: [
        // 1. PageView Horizontal untuk Navigasi Halaman Cerita
        PageView.builder(
          controller: _pageController,
          itemCount: totalPages,
          onPageChanged: (newIndex) {
            setState(() {
              _currentPageIndex = newIndex;
            });
            _playPageNarration(newIndex);
          },
          itemBuilder: (context, index) {
            final page = _storyData!.pages[index];
            return _buildPageLayout(page);
          },
        ),

        // 2. Tombol Navigasi Kiri (Halaman Sebelumnya)
        if (_currentPageIndex > 0)
          Positioned(
            left: 14,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildNavArrowButton(
                icon: Icons.arrow_back_rounded,
                onTap: () {
                  SoundEngine().playClick();
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOutCubic,
                  );
                },
              ),
            ),
          ),

        // 3. Tombol Navigasi Kanan (Halaman Berikutnya)
        if (_currentPageIndex < totalPages - 1)
          Positioned(
            right: 14,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildNavArrowButton(
                icon: Icons.arrow_forward_rounded,
                onTap: () {
                  SoundEngine().playClick();
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOutCubic,
                  );
                },
              ),
            ),
          )
        else
          // Tombol Selesai di Halaman Terakhir
          Positioned(
            right: 14,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  SoundEngine().playWinStar();
                  _showCompletionDialog();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 26)),
                      const SizedBox(height: 4),
                      Text(
                        'SELESAI',
                        style: GoogleFonts.fredoka(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // 4. Bar Kontrol Atas (Kembali, Indikator Halaman, Putar Ulang Narasi)
        Positioned(
          top: 12,
          left: 14,
          right: 14,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tombol Kembali Besar Ramah Balita
              GestureDetector(
                onTap: _onBackPressed,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.sunnyYellow, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.arrow_back_rounded, color: AppColors.textDark, size: 28),
                  ),
                ),
              ),

              // Indikator Halaman & Judul
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('📖 ', style: TextStyle(fontSize: 14)),
                    Text(
                      'Halaman ${currentPage.pageNumber} / $totalPages',
                      style: GoogleFonts.fredoka(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Tombol Megafon (Putar Ulang Narasi Suara Halaman Aktif)
              GestureDetector(
                onTap: () {
                  SoundEngine().playClick();
                  _playPageNarration(_currentPageIndex);
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isPlayingNarration
                          ? [const Color(0xFFFBBF24), const Color(0xFFF59E0B)]
                          : [Colors.white, const Color(0xFFF1F5F9)],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isPlayingNarration ? Colors.white : AppColors.sunnyYellow,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _isPlayingNarration ? '🔊' : '📢',
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Membangun layout satu halaman cerita (Background Ilustrasi, Hotspots, Kotak Teks Karaoke)
  Widget _buildPageLayout(StoryPage page) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        return Stack(
          fit: StackFit.expand,
          children: [
            // 1. Ilustrasi Gambar Halaman Penuh Responsif
            Image.asset(
              page.imagePath,
              fit: BoxFit.cover,
              width: screenWidth,
              height: screenHeight,
              errorBuilder: (context, error, stackTrace) {
                // Ilustrasi Fallback Cantik & Menarik jika asset gambar belum disalin
                return _buildIllustrationFallback(page, screenWidth, screenHeight);
              },
            ),

            // Lapisan gradient halus bawah agar teks karaoke selalu terbaca kontras
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: screenHeight * 0.45,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.75),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // 2. Hotspot Interaktif pada Gambar (Render transparan sesuai x_percent & y_percent)
            ...page.hotspots.map((hotspot) {
              final xPos = (hotspot.xPercent / 100.0) * screenWidth;
              final yPos = (hotspot.yPercent / 100.0) * screenHeight;
              final size = hotspot.radius * 2;

              return Positioned(
                left: xPos - hotspot.radius,
                top: yPos - hotspot.radius,
                width: size,
                height: size,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _onHotspotTap(hotspot),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 2,
                      ),
                      color: Colors.white.withOpacity(0.12),
                    ),
                    child: Center(
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.yellow.withOpacity(0.85),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.yellow.withOpacity(0.6),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),

            // 3. Animasi Efek Riak Bintang Hotspot saat Diketuk
            if (_activeHotspot != null)
              AnimatedBuilder(
                animation: _hotspotAnimController,
                builder: (context, child) {
                  final activeX = (_activeHotspot!.xPercent / 100.0) * screenWidth;
                  final activeY = (_activeHotspot!.yPercent / 100.0) * screenHeight;
                  final scale = _hotspotScaleAnimation.value;
                  final opacity = _hotspotOpacityAnimation.value.clamp(0.0, 1.0);

                  return Positioned(
                    left: activeX - 60,
                    top: activeY - 60,
                    child: Opacity(
                      opacity: opacity,
                      child: Transform.scale(
                        scale: scale,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade400,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Text(
                                '✨ ${_activeHotspot!.name} ✨',
                                style: GoogleFonts.fredoka(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text('⭐🌟⭐', style: TextStyle(fontSize: 20)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

            // 4. Panel Teks Karaoke & Syllable Highlighting
            Positioned(
              left: 60,
              right: 60,
              bottom: 16,
              child: _buildKaraokeBox(page),
            ),
          ],
        );
      },
    );
  }

  /// Ilustrasi Cadangan responsif beranimasi jika file WebP belum ada di disk
  Widget _buildIllustrationFallback(StoryPage page, double width, double height) {
    final colors = [
      [const Color(0xFF60A5FA), const Color(0xFF3B82F6)],
      [const Color(0xFFFBBF24), const Color(0xFFF59E0B)],
      [const Color(0xFF34D399), const Color(0xFF059669)],
      [const Color(0xFFF472B6), const Color(0xFFEC4899)],
      [const Color(0xFFA78BFA), const Color(0xFF7C3AED)],
    ];
    final selectedGradient = colors[(page.pageNumber - 1) % colors.length];

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: selectedGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: const Text('🍌🐒🌴', style: TextStyle(fontSize: 64)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Halaman ${page.pageNumber}: ${_storyData?.title ?? ""}',
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Kotak Karaoke dengan Penyorotan Suku Kata Berwarna Mencolok
  Widget _buildKaraokeBox(StoryPage page) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.sunnyYellow, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Syllables Chips (Karaoke Highlighting)
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: List.generate(page.syllables.length, (index) {
              final syllable = page.syllables[index];
              final isCurrent = _currentAudioPositionMs >= syllable.startMs &&
                  _currentAudioPositionMs <= syllable.endMs;
              final isPast = _currentAudioPositionMs > syllable.endMs;
              final isTapped = _tappedSyllableIndex == index;

              return GestureDetector(
                onTap: () => _onSyllableTap(syllable, index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  transform: (isCurrent || isTapped)
                      ? Matrix4.diagonal3Values(1.15, 1.15, 1.0)
                      : Matrix4.identity(),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: (isCurrent || isTapped)
                        ? const LinearGradient(
                            colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                          )
                        : isPast
                            ? const LinearGradient(
                                colors: [Color(0xFFDCFCE7), Color(0xFFBBF7D0)],
                              )
                            : LinearGradient(
                                colors: [Colors.white, Colors.grey.shade50],
                              ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: (isCurrent || isTapped)
                          ? const Color(0xFFD97706)
                          : isPast
                              ? const Color(0xFF10B981)
                              : Colors.grey.shade300,
                      width: (isCurrent || isTapped) ? 2.5 : 1.2,
                    ),
                    boxShadow: (isCurrent || isTapped)
                        ? [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.6),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    syllable.text,
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: (isCurrent || isTapped) ? FontWeight.w900 : FontWeight.w700,
                      color: (isCurrent || isTapped)
                          ? const Color(0xFF78350F)
                          : isPast
                              ? const Color(0xFF065F46)
                              : AppColors.textDark,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          // Petunjuk ketuk suku kata ramah anak
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('👆 ', style: TextStyle(fontSize: 11)),
              Text(
                'Ketuk suku kata untuk mendengar pelafalan pelan',
                style: GoogleFonts.comicNeue(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Tombol Navigasi Panah Kiri/Kanan yang Besar
  Widget _buildNavArrowButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.sunnyYellow, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, color: AppColors.textDark, size: 30),
        ),
      ),
    );
  }

  /// Dialog Penghargaan saat Selesai Membaca Semua Halaman
  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFEF3C7), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppColors.sunnyYellow, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉🌟🏆', style: TextStyle(fontSize: 52)),
                const SizedBox(height: 8),
                Text(
                  'Hebat Sekali! Kamu Juara!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFB45309),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Kamu sudah menyelesaikan buku cerita ini dengan sangat pintar!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.comicNeue(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Baca Ulang dari awal
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primarySky,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _pageController.jumpToPage(0);
                      },
                      child: Row(
                        children: [
                          const Text('🔄 ', style: TextStyle(fontSize: 16)),
                          Text(
                            'Baca Lagi',
                            style: GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Kembali ke Menu
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emeraldGreen,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _restoreOrientations();
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        children: [
                          const Text('🏠 ', style: TextStyle(fontSize: 16)),
                          Text(
                            'Selesai',
                            style: GoogleFonts.fredoka(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
