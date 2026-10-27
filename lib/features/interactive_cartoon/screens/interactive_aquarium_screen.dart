import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/services/sound_engine.dart';

/// Model partikel riak / bintang saat layar diketuk
class RippleParticle {
  double x, y, vx, vy, size;
  Color color;
  double alpha;

  RippleParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    this.alpha = 1.0,
  });
}

/// Model butir pakan ikan
class FishFood {
  double x, y;
  double vy;
  Color color;

  FishFood({
    required this.x,
    required this.y,
    this.vy = 1.2,
    required this.color,
  });
}

/// Model gelembung udara
class AirBubble {
  double x, y;
  double speed;
  double radius;
  double wobbleOffset;

  AirBubble({
    required this.x,
    required this.y,
    required this.speed,
    required this.radius,
    required this.wobbleOffset,
  });
}

/// Model partikel tinta pelangi gurita
class InkParticle {
  double x, y, vx, vy, radius;
  Color color;
  double alpha;

  InkParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.color,
    this.alpha = 1.0,
  });
}

class InteractiveAquariumScreen extends StatefulWidget {
  final VoidCallback onBack;

  const InteractiveAquariumScreen({super.key, required this.onBack});

  @override
  State<InteractiveAquariumScreen> createState() =>
      _InteractiveAquariumScreenState();
}

class _InteractiveAquariumScreenState extends State<InteractiveAquariumScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final Random _rand = Random();

  // State lingkungan & objek
  bool isNight = false;
  bool isChestOpen = false;
  int pearlScore = 0;
  double animTime = 0.0;

  // Ikan Badut (Mimi)
  double clownX = 80;
  double clownY = 130;
  double clownSpeed = 1.8;
  bool clownFacingRight = true;
  double clownTailAngle = 0.0;

  // Ubur-ubur Neon
  double jellyY = 80;

  // Kura-kura Laut
  bool isTurtleActive = false;
  double turtleX = -80;
  double turtleY = 160;

  // Gurita & Tinta
  bool isOctopusActive = false;
  double octopusScale = 0.0;

  // Lists entitas
  final List<AirBubble> bubbles = [];
  final List<FishFood> foods = [];
  final List<RippleParticle> tapParticles = [];
  final List<InkParticle> inkParticles = [];

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _animController.addListener(_updatePhysics);

    // Inisialisasi gelembung alami awal
    for (int i = 0; i < 28; i++) {
      bubbles.add(AirBubble(
        x: _rand.nextDouble() * 360,
        y: _rand.nextDouble() * 270,
        speed: 0.8 + _rand.nextDouble() * 1.5,
        radius: 3 + _rand.nextDouble() * 4.5,
        wobbleOffset: _rand.nextDouble() * 2 * pi,
      ));
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _updatePhysics() {
    setState(() {
      animTime += 0.05;

      // 1. Update gelembung naik
      for (final b in bubbles) {
        b.y -= b.speed;
        b.x += sin(animTime * 2.5 + b.wobbleOffset) * 0.45;
        if (b.y < -15) {
          b.y = 275;
          b.x = _rand.nextDouble() * 360;
        }
      }

      // 2. Update pakan jatuh & pergerakan Ikan Badut (Mimi)
      if (foods.isNotEmpty) {
        // Cari pakan terdekat
        FishFood? targetFood;
        double minDist = 999999;
        for (final food in foods) {
          final dist =
              hypot(food.x - clownX, food.y - clownY);
          if (dist < minDist) {
            minDist = dist;
            targetFood = food;
          }
        }

        if (targetFood != null) {
          // Gerakkan ikan mengejar pakan
          final dx = targetFood.x - clownX;
          final dy = targetFood.y - clownY;
          final angle = atan2(dy, dx);
          clownFacingRight = dx >= 0;

          clownX += cos(angle) * 3.2;
          clownY += sin(angle) * 3.2;

          // Cek apakah ikan berhasil memakan pakan
          if (minDist < 16) {
            foods.remove(targetFood);
            pearlScore += 2;
            _spawnSparkle(clownX, clownY, Colors.amberAccent);
            SoundEngine().playAsset('audio/sfx/feed_drop.wav');
          }
        }
      } else {
        // Renang santai horizontal bolak-balik
        if (clownFacingRight) {
          clownX += clownSpeed;
          if (clownX > 320) clownFacingRight = false;
        } else {
          clownX -= clownSpeed;
          if (clownX < 40) clownFacingRight = true;
        }
        clownY = 130 + sin(animTime * 2.2) * 18;
      }

      // Kibasan ekor ikan
      clownTailAngle = sin(animTime * 7) * 0.45;

      // 3. Update Pakan Ikan
      for (int i = foods.length - 1; i >= 0; i--) {
        final f = foods[i];
        f.y += f.vy;
        f.x += sin(animTime * 3 + i) * 0.2;
        if (f.y > 245) {
          // Pakan sampai di pasir, perlahan hilang
          foods.removeAt(i);
        }
      }

      // 4. Update Ubur-ubur Neon (melayang naik turun)
      jellyY = 85 + sin(animTime * 1.8) * 24;

      // 5. Update Kura-kura jika aktif
      if (isTurtleActive) {
        turtleX += 1.4;
        turtleY = 155 + sin(animTime * 1.5) * 12;
        if (turtleX > 430) {
          isTurtleActive = false;
        }
      }

      // 6. Update Gurita
      if (isOctopusActive) {
        if (octopusScale < 1.0) {
          octopusScale += 0.08;
        }
      } else {
        if (octopusScale > 0.0) {
          octopusScale -= 0.05;
          if (octopusScale < 0) octopusScale = 0;
        }
      }

      // 7. Update Partikel Tinta Gurita
      for (int i = inkParticles.length - 1; i >= 0; i--) {
        final p = inkParticles[i];
        p.x += p.vx;
        p.y += p.vy;
        p.radius += 0.25;
        p.alpha -= 0.016;
        if (p.alpha <= 0.05) {
          inkParticles.removeAt(i);
        }
      }

      // 8. Update Partikel Sentuhan Tap
      for (int i = tapParticles.length - 1; i >= 0; i--) {
        final p = tapParticles[i];
        p.x += p.vx;
        p.y += p.vy;
        p.size *= 0.93;
        p.alpha -= 0.035;
        if (p.size < 0.6 || p.alpha <= 0.05) {
          tapParticles.removeAt(i);
        }
      }
    });
  }

  void _spawnSparkle(double x, double y, Color baseColor) {
    for (int i = 0; i < 8; i++) {
      final angle = _rand.nextDouble() * 2 * pi;
      final speed = 1.5 + _rand.nextDouble() * 2.5;
      tapParticles.add(RippleParticle(
        x: x,
        y: y,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        size: 5 + _rand.nextDouble() * 4,
        color: baseColor,
      ));
    }
  }

  double hypot(double dx, double dy) => sqrt(dx * dx + dy * dy);

  // ----------------------------------------------------
  // INTERAKSI SENTUHAN KANVAS (TAP)
  // ----------------------------------------------------
  void _onCanvasTap(TapUpDetails details, BoxConstraints constraints) {
    final local = details.localPosition;
    final scaleX = 360.0 / constraints.maxWidth;
    final scaleY = 270.0 / constraints.maxHeight;
    final virtX = (local.dx * scaleX).clamp(0.0, 360.0);
    final virtY = (local.dy * scaleY).clamp(0.0, 270.0);

    setState(() {
      pearlScore++;

      // Munculkan partikel riak berkilau multi-warna
      final colors = [
        Colors.amberAccent,
        Colors.cyanAccent,
        Colors.pinkAccent,
        Colors.lightGreenAccent,
        Colors.white,
      ];

      for (int i = 0; i < 14; i++) {
        final angle = _rand.nextDouble() * 2 * pi;
        final speed = 1.8 + _rand.nextDouble() * 3.5;
        tapParticles.add(RippleParticle(
          x: virtX,
          y: virtY,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed,
          size: 6 + _rand.nextDouble() * 5,
          color: colors[_rand.nextInt(colors.length)],
        ));
      }

      // Tambahkan gelembung spontan dari titik tap
      for (int i = 0; i < 4; i++) {
        bubbles.add(AirBubble(
          x: virtX + (_rand.nextDouble() * 20 - 10),
          y: virtY + (_rand.nextDouble() * 20 - 10),
          speed: 1.2 + _rand.nextDouble() * 1.5,
          radius: 3 + _rand.nextDouble() * 3.5,
          wobbleOffset: _rand.nextDouble() * 2 * pi,
        ));
      }
    });

    SoundEngine().playWinStar();
  }

  // ----------------------------------------------------
  // 6 TOMBOL AKSI INTERAKTIF
  // ----------------------------------------------------

  // Tombol 1: Gelembung ekstra
  void _triggerBubbles() {
    setState(() {
      for (int i = 0; i < 20; i++) {
        bubbles.add(AirBubble(
          x: _rand.nextDouble() * 360,
          y: 260 + _rand.nextDouble() * 40,
          speed: 1.8 + _rand.nextDouble() * 2.2,
          radius: 3.5 + _rand.nextDouble() * 5,
          wobbleOffset: _rand.nextDouble() * 2 * pi,
        ));
      }
    });
    SoundEngine().playAsset('audio/sfx/bubbles.wav');
    SoundEngine().speakWord('Gelembung udara berbusa!');
  }

  // Tombol 2: Beri Makan Ikan
  void _triggerFeeding() {
    setState(() {
      final colors = [
        const Color(0xFFF97316),
        const Color(0xFFEAB308),
        const Color(0xFFEC4899),
        const Color(0xFF84CC16),
        const Color(0xFF06B6D4),
      ];

      for (int i = 0; i < 5; i++) {
        foods.add(FishFood(
          x: 60 + _rand.nextDouble() * 240,
          y: 10 + _rand.nextDouble() * 15,
          vy: 0.9 + _rand.nextDouble() * 0.7,
          color: colors[i % colors.length],
        ));
      }
    });
    SoundEngine().playAsset('audio/sfx/feed_drop.wav');
    SoundEngine().speakWord('Nyam-nyam, waktunya makan ikan!');
  }

  // Tombol 3: Buka/Tutup Peti Harta Karun
  void _toggleTreasureChest() {
    setState(() {
      isChestOpen = !isChestOpen;
      if (isChestOpen) {
        pearlScore += 5;
        // Semburkan partikel koin emas & mutiara
        for (int i = 0; i < 18; i++) {
          final angle = -pi * 0.85 + _rand.nextDouble() * pi * 0.7;
          final speed = 2.0 + _rand.nextDouble() * 3.0;
          tapParticles.add(RippleParticle(
            x: 82,
            y: 220,
            vx: cos(angle) * speed,
            vy: sin(angle) * speed,
            size: 6 + _rand.nextDouble() * 5,
            color: _rand.nextBool() ? Colors.amberAccent : Colors.white,
          ));
        }
      }
    });
    SoundEngine().playAsset('audio/sfx/treasure_open.wav');
    SoundEngine().speakWord(isChestOpen
        ? 'Harta karun mutiara berkilau!'
        : 'Peti harta karun tertutup rapi!');
  }

  // Tombol 4: Kura-kura Laut Melintas
  void _triggerTurtle() {
    setState(() {
      isTurtleActive = true;
      turtleX = -70;
      turtleY = 140 + _rand.nextDouble() * 40;
    });
    SoundEngine().playAsset('audio/sfx/turtle_swim.wav');
    SoundEngine().speakWord('Halo kura-kura laut yang ramah!');
  }

  // Tombol 5: Gurita Tinta Pelangi
  void _triggerOctopusInk() {
    setState(() {
      isOctopusActive = true;

      final rainbowColors = [
        const Color(0xFFEF4444),
        const Color(0xFFF97316),
        const Color(0xFFFBBF24),
        const Color(0xFF10B981),
        const Color(0xFF06B6D4),
        const Color(0xFF8B5CF6),
        const Color(0xFFEC4899),
      ];

      for (int i = 0; i < 32; i++) {
        final angle = _rand.nextDouble() * 2 * pi;
        final speed = 1.0 + _rand.nextDouble() * 3.5;
        inkParticles.add(InkParticle(
          x: 180,
          y: 130,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed * 0.8,
          radius: 8 + _rand.nextDouble() * 8,
          color: rainbowColors[_rand.nextInt(rainbowColors.length)],
        ));
      }
    });

    SoundEngine().playAsset('audio/sfx/octopus_squirts.wav');
    SoundEngine().speakWord('Coot! Gurita menyembur tinta pelangi!');

    // Sembunyikan gurita setelah beberapa saat
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => isOctopusActive = false);
    });
  }

  // Tombol 6: Siang & Malam
  void _toggleDayNight() {
    setState(() => isNight = !isNight);
    SoundEngine().playAsset('audio/sfx/night_glow.wav');
    SoundEngine().speakWord(isNight
        ? 'Malam laut dalam yang berpendar neon...'
        : 'Siang hari di laut cerah berjemur!');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top App Bar Ceria
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: widget.onBack,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF38BDF8), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.15),
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
                      'Akuarium Bawah Laut Ajaib 🐠',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Sentuh air untuk buat riak & panggil ikan!',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              // Badge Skor Mutiara
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF38BDF8), Color(0xFF06B6D4)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF06B6D4).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🐚 ', style: TextStyle(fontSize: 13)),
                    Text(
                      '$pearlScore',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Animated 4:3 Aquarium Canvas Box
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isNight
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF38BDF8),
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isNight
                            ? const Color(0xFF4F46E5)
                            : const Color(0xFF0284C7))
                        .withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onTapUp: (details) =>
                          _onCanvasTap(details, constraints),
                      child: CustomPaint(
                        painter: AquariumPainter(
                          animTime: animTime,
                          isNight: isNight,
                          isChestOpen: isChestOpen,
                          clownX: clownX,
                          clownY: clownY,
                          clownFacingRight: clownFacingRight,
                          clownTailAngle: clownTailAngle,
                          jellyY: jellyY,
                          isTurtleActive: isTurtleActive,
                          turtleX: turtleX,
                          turtleY: turtleY,
                          isOctopusActive: isOctopusActive,
                          octopusScale: octopusScale,
                          bubbles: bubbles,
                          foods: foods,
                          tapParticles: tapParticles,
                          inkParticles: inkParticles,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 6 Tombol Aksi Interaktif (Grid 3x2)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.1,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildActionBtn(
                  '🫧 Gelembung',
                  _triggerBubbles,
                  const Color(0xFFE0F2FE),
                  const Color(0xFF0284C7),
                ),
                _buildActionBtn(
                  '🥩 Beri Makan',
                  _triggerFeeding,
                  const Color(0xFFFEF3C7),
                  const Color(0xFFD97706),
                ),
                _buildActionBtn(
                  isChestOpen ? '💎 Tutup Peti' : '📦 Buka Peti',
                  _toggleTreasureChest,
                  const Color(0xFFFCE7F3),
                  const Color(0xFFBE185D),
                ),
                _buildActionBtn(
                  '🐢 Kura-Kura',
                  _triggerTurtle,
                  const Color(0xFFDCFCE7),
                  const Color(0xFF15803D),
                ),
                _buildActionBtn(
                  '🐙 Gurita Tinta',
                  _triggerOctopusInk,
                  const Color(0xFFF3E8FF),
                  const Color(0xFF7E22CE),
                ),
                _buildActionBtn(
                  isNight ? '☀️ Mode Siang' : '🌙 Mode Malam',
                  _toggleDayNight,
                  isNight ? const Color(0xFFFEF08A) : const Color(0xFF1E1B4B),
                  isNight ? const Color(0xFF854D0E) : const Color(0xFFC7D2FE),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionBtn(
      String label, VoidCallback onTap, Color bg, Color textCol) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: textCol,
        elevation: 1.5,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: textCol.withValues(alpha: 0.35), width: 1.5),
        ),
      ),
      onPressed: onTap,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
      ),
    );
  }
}

// ========================================================
// CUSTOM PAINTER AKUARIUM (Murni tanpa aset gambar eksternal)
// Sistem Koordinat Virtual 360 x 270
// ========================================================
class AquariumPainter extends CustomPainter {
  final double animTime;
  final bool isNight;
  final bool isChestOpen;
  final double clownX;
  final double clownY;
  final bool clownFacingRight;
  final double clownTailAngle;
  final double jellyY;
  final bool isTurtleActive;
  final double turtleX;
  final double turtleY;
  final bool isOctopusActive;
  final double octopusScale;
  final List<AirBubble> bubbles;
  final List<FishFood> foods;
  final List<RippleParticle> tapParticles;
  final List<InkParticle> inkParticles;

  AquariumPainter({
    required this.animTime,
    required this.isNight,
    required this.isChestOpen,
    required this.clownX,
    required this.clownY,
    required this.clownFacingRight,
    required this.clownTailAngle,
    required this.jellyY,
    required this.isTurtleActive,
    required this.turtleX,
    required this.turtleY,
    required this.isOctopusActive,
    required this.octopusScale,
    required this.bubbles,
    required this.foods,
    required this.tapParticles,
    required this.inkParticles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Skala kanvas riil ke virtual kanvas 360x270
    canvas.scale(size.width / 360.0, size.height / 270.0);

    // 1. Latar Air (Gradasi Siang / Malam)
    _drawWaterBackground(canvas);

    // 2. Sinar Matahari Menembus Air (Khusus Siang Hari)
    if (!isNight) {
      _drawSunRays(canvas);
    } else {
      _drawNightStarsAndGlow(canvas);
    }

    // 3. Karang & Rumput Laut di Latar Belakang
    _drawCoralsAndSeaweed(canvas);

    // 4. Dasar Laut Bukit Pasir
    _drawSandBottom(canvas);

    // 5. Peti Harta Karun (Treasure Chest)
    _drawTreasureChest(canvas);

    // 6. Ubur-ubur Neon (Jellyfish)
    _drawNeonJellyfish(canvas);

    // 7. Kura-kura Laut (jika aktif)
    if (isTurtleActive) {
      _drawSeaTurtle(canvas);
    }

    // 8. Gurita & Tinta Pelangi
    if (octopusScale > 0.05) {
      _drawOctopus(canvas);
    }
    _drawInkParticles(canvas);

    // 9. Pakan Ikan Jatuh
    _drawFishFoods(canvas);

    // 10. Ikan Badut (Mimi)
    _drawClownfish(canvas);

    // 11. Gelembung Udara
    _drawBubbles(canvas);

    // 12. Partikel Sentuhan Layar
    _drawTapParticles(canvas);

    canvas.restore();
  }

  // 1. Latar Air
  void _drawWaterBackground(Canvas canvas) {
    const rect = Rect.fromLTWH(0, 0, 360, 270);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isNight
            ? [
                const Color(0xFF0F172A),
                const Color(0xFF1E1B4B),
                const Color(0xFF0C4A6E),
              ]
            : [
                const Color(0xFF38BDF8),
                const Color(0xFF0284C7),
                const Color(0xFF0369A1),
              ],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  // 2. Sinar Matahari
  void _drawSunRays(Canvas canvas) {
    final rayPaint = Paint()..style = PaintingStyle.fill;
    final rayOrigins = [40.0, 110.0, 190.0, 270.0, 330.0];

    for (int i = 0; i < rayOrigins.length; i++) {
      final originX = rayOrigins[i];
      final alpha = (0.10 + 0.05 * sin(animTime * 1.5 + i)).clamp(0.04, 0.20);
      rayPaint.color = Colors.white.withValues(alpha: alpha);

      final path = Path()
        ..moveTo(originX - 10, 0)
        ..lineTo(originX + 15, 0)
        ..lineTo(originX + 55 + sin(animTime + i) * 10, 270)
        ..lineTo(originX - 25 + sin(animTime + i) * 10, 270)
        ..close();
      canvas.drawPath(path, rayPaint);
    }
  }

  // Bintang pendar laut dalam saat malam
  void _drawNightStarsAndGlow(Canvas canvas) {
    final starPaint = Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.4);
    for (int i = 0; i < 22; i++) {
      final sx = (i * 47) % 350 + 5.0;
      final sy = (i * 31) % 180 + 10.0;
      final radius = 1.0 + (sin(animTime * 3 + i) * 0.6).abs();
      canvas.drawCircle(Offset(sx, sy), radius, starPaint);
    }
  }

  // 3. Karang & Rumput Laut
  void _drawCoralsAndSeaweed(Canvas canvas) {
    // Rumput laut bergoyang kiri
    _drawSingleSeaweed(canvas, 25, 255, 6, 85, const Color(0xFF15803D), 0.0);
    _drawSingleSeaweed(canvas, 42, 258, 5, 70, const Color(0xFF22C55E), 0.8);
    _drawSingleSeaweed(canvas, 60, 252, 6, 95, const Color(0xFF16A34A), 1.6);

    // Karang laut kiri (Oranye & Pink)
    _drawCoralBranch(canvas, 105, 245, const Color(0xFFFB923C));
    _drawCoralBranch(canvas, 125, 248, const Color(0xFFF472B6));

    // Karang kipas ungu kanan
    _drawFanCoral(canvas, 235, 246, const Color(0xFFA855F7));

    // Rumput laut bergoyang kanan
    _drawSingleSeaweed(canvas, 305, 252, 6, 90, const Color(0xFF16A34A), 0.5);
    _drawSingleSeaweed(canvas, 325, 256, 5, 80, const Color(0xFF22C55E), 1.2);
    _drawSingleSeaweed(canvas, 342, 250, 6, 100, const Color(0xFF15803D), 2.1);
  }

  void _drawSingleSeaweed(Canvas canvas, double x, double y, double width,
      double height, Color color, double phase) {
    final paint = Paint()
      ..color = isNight ? color.withValues(alpha: 0.7) : color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = width;

    final sway = sin(animTime * 2.2 + phase) * 14;
    final path = Path()..moveTo(x, y);

    path.cubicTo(
      x + sway * 0.4,
      y - height * 0.35,
      x - sway * 0.6,
      y - height * 0.7,
      x + sway,
      y - height,
    );
    canvas.drawPath(path, paint);
  }

  void _drawCoralBranch(Canvas canvas, double cx, double cy, Color color) {
    final paint = Paint()
      ..color = isNight ? color.withValues(alpha: 0.8) : color
      ..style = PaintingStyle.fill;

    // Batang & cabang karang
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - 5, cy - 35, 10, 35), const Radius.circular(5)),
        paint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - 16, cy - 25, 12, 8), const Radius.circular(4)),
        paint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - 18, cy - 38, 8, 16), const Radius.circular(4)),
        paint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(cx + 4, cy - 20, 14, 8), const Radius.circular(4)),
        paint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(cx + 10, cy - 32, 8, 15), const Radius.circular(4)),
        paint);

    // Titik mutiara karang
    canvas.drawCircle(Offset(cx - 14, cy - 38), 4,
        Paint()..color = Colors.white.withValues(alpha: 0.8));
    canvas.drawCircle(Offset(cx + 14, cy - 32), 4,
        Paint()..color = Colors.white.withValues(alpha: 0.8));
    canvas.drawCircle(Offset(cx, cy - 36), 4.5,
        Paint()..color = Colors.white.withValues(alpha: 0.8));
  }

  void _drawFanCoral(Canvas canvas, double cx, double cy, Color color) {
    final paint = Paint()
      ..color = color.withValues(alpha: isNight ? 0.75 : 0.9)
      ..style = PaintingStyle.fill;

    for (int i = -3; i <= 3; i++) {
      final angle = -pi / 2 + i * 0.22;
      final ex = cx + cos(angle) * 32;
      final ey = cy + sin(angle) * 32;
      canvas.drawLine(
        Offset(cx, cy),
        Offset(ex, ey),
        Paint()
          ..color = color
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawCircle(Offset(ex, ey), 3.5, paint);
    }
  }

  // 4. Dasar Laut Bukit Pasir
  void _drawSandBottom(Canvas canvas) {
    final sandPaint1 = Paint()
      ..color = isNight ? const Color(0xFF1E293B) : const Color(0xFFFDE68A);
    final sandPaint2 = Paint()
      ..color = isNight ? const Color(0xFF0F172A) : const Color(0xFFFCD34D);

    // Bukit pasir belakang
    final pathBack = Path()
      ..moveTo(0, 235)
      ..quadraticBezierTo(90, 220, 180, 238)
      ..quadraticBezierTo(270, 250, 360, 230)
      ..lineTo(360, 270)
      ..lineTo(0, 270)
      ..close();
    canvas.drawPath(pathBack, sandPaint2);

    // Bukit pasir depan
    final pathFront = Path()
      ..moveTo(0, 245)
      ..quadraticBezierTo(100, 255, 200, 242)
      ..quadraticBezierTo(300, 232, 360, 246)
      ..lineTo(360, 270)
      ..lineTo(0, 270)
      ..close();
    canvas.drawPath(pathFront, sandPaint1);

    // Kerang hias kecil di pasir
    final shellPaint = Paint()..color = const Color(0xFFFDA4AF);
    canvas.drawArc(
      const Rect.fromLTWH(180, 252, 14, 10),
      pi,
      pi,
      true,
      shellPaint,
    );
    canvas.drawArc(
      const Rect.fromLTWH(260, 248, 12, 9),
      pi,
      pi,
      true,
      Paint()..color = const Color(0xFFBAE6FD),
    );
  }

  // 5. Peti Harta Karun (Treasure Chest)
  void _drawTreasureChest(Canvas canvas) {
    const cx = 75.0;
    const cy = 246.0;

    // Badan peti kayu
    final woodPaint = Paint()..color = const Color(0xFF78350F);
    final goldTrim = Paint()..color = const Color(0xFFFACC15);

    // Kotak bawah peti
    final bodyRect =
        RRect.fromRectAndRadius(const Rect.fromLTWH(cx - 22, cy - 18, 44, 22),
            const Radius.circular(5));
    canvas.drawRRect(bodyRect, woodPaint);

    // Lis emas kotak bawah
    canvas.drawRect(const Rect.fromLTWH(cx - 22, cy - 18, 5, 22), goldTrim);
    canvas.drawRect(const Rect.fromLTWH(cx + 17, cy - 18, 5, 22), goldTrim);
    canvas.drawRect(const Rect.fromLTWH(cx - 4, cy - 12, 8, 8), goldTrim);

    if (isChestOpen) {
      // Sinar emas memancar keluar peti
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.amberAccent.withValues(alpha: 0.6),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: const Offset(cx, cy - 25), radius: 35));
      canvas.drawCircle(const Offset(cx, cy - 25), 35, glowPaint);

      // Koin emas berkilau
      canvas.drawCircle(const Offset(cx - 8, cy - 19), 4, goldTrim);
      canvas.drawCircle(const Offset(cx + 8, cy - 19), 4, goldTrim);
      canvas.drawCircle(const Offset(cx, cy - 21), 4.5, goldTrim);

      // Mutiara besar bersinar di tengah
      canvas.drawCircle(const Offset(cx, cy - 26), 6.5,
          Paint()..color = Colors.white);
      canvas.drawCircle(const Offset(cx - 2, cy - 28), 2.5,
          Paint()..color = Colors.white.withValues(alpha: 0.9));

      // Tutup peti terangkat ke atas miring
      final lidPath = Path()
        ..moveTo(cx - 24, cy - 18)
        ..lineTo(cx + 20, cy - 34)
        ..lineTo(cx + 24, cy - 26)
        ..lineTo(cx - 20, cy - 10)
        ..close();
      canvas.drawPath(lidPath, woodPaint);
      canvas.drawCircle(const Offset(cx, cy - 24), 3, goldTrim);
    } else {
      // Tutup peti tertutup rapi
      final lidRect = RRect.fromRectAndRadius(
          const Rect.fromLTWH(cx - 24, cy - 28, 48, 12),
          const Radius.circular(6));
      canvas.drawRRect(lidRect, woodPaint);
      canvas.drawRect(const Rect.fromLTWH(cx - 24, cy - 28, 5, 12), goldTrim);
      canvas.drawRect(const Rect.fromLTWH(cx + 19, cy - 28, 5, 12), goldTrim);
      canvas.drawCircle(const Offset(cx, cy - 16), 3, goldTrim);
    }
  }

  // 6. Ubur-ubur Neon (Jellyfish)
  void _drawNeonJellyfish(Canvas canvas) {
    const jx = 285.0;
    final jy = jellyY;

    final domeColor = isNight ? const Color(0xFFC084FC) : const Color(0xFFF472B6);

    // Pendar cahaya neon di sekitar tudung
    canvas.drawCircle(
      Offset(jx, jy),
      22,
      Paint()
        ..color = domeColor.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Tudung ubur-ubur
    final domePaint = Paint()
      ..color = domeColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final domePath = Path()
      ..moveTo(jx - 18, jy)
      ..quadraticBezierTo(jx, jy - 24, jx + 18, jy)
      ..quadraticBezierTo(jx + 10, jy + 4, jx, jy + 2)
      ..quadraticBezierTo(jx - 10, jy + 4, jx - 18, jy)
      ..close();
    canvas.drawPath(domePath, domePaint);

    // Bintik mutiara pada tudung
    final spotPaint = Paint()..color = Colors.white.withValues(alpha: 0.7);
    canvas.drawCircle(Offset(jx - 8, jy - 8), 2.5, spotPaint);
    canvas.drawCircle(Offset(jx, jy - 13), 3, spotPaint);
    canvas.drawCircle(Offset(jx + 8, jy - 8), 2.5, spotPaint);

    // Tentakel bergelombang
    final tentaclePaint = Paint()
      ..color = domeColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 4; i++) {
      final tx = jx - 12 + i * 8.0;
      final sway = sin(animTime * 3.5 + i) * 6;
      final tPath = Path()
        ..moveTo(tx, jy + 2)
        ..cubicTo(
          tx + sway,
          jy + 16,
          tx - sway,
          jy + 30,
          tx + sway * 0.5,
          jy + 42,
        );
      canvas.drawPath(tPath, tentaclePaint);
    }
  }

  // 7. Kura-kura Laut
  void _drawSeaTurtle(Canvas canvas) {
    final kx = turtleX;
    final ky = turtleY;

    final shellPaint = Paint()..color = const Color(0xFF15803D);
    final skinPaint = Paint()..color = const Color(0xFF4ADE80);

    // Kepala kura-kura
    canvas.drawCircle(Offset(kx + 22, ky), 9, skinPaint);
    // Mata
    canvas.drawCircle(Offset(kx + 24, ky - 3), 2.5, Paint()..color = Colors.black);
    canvas.drawCircle(Offset(kx + 25, ky - 4), 1, Paint()..color = Colors.white);

    // Sirip depan mendayung
    final flipperAngle = sin(animTime * 4) * 0.4;
    canvas.save();
    canvas.translate(kx + 8, ky - 10);
    canvas.rotate(flipperAngle);
    canvas.drawOval(
        Rect.fromCenter(center: const Offset(0, -6), width: 10, height: 20),
        skinPaint);
    canvas.restore();

    canvas.save();
    canvas.translate(kx + 8, ky + 10);
    canvas.rotate(-flipperAngle);
    canvas.drawOval(
        Rect.fromCenter(center: const Offset(0, 6), width: 10, height: 20),
        skinPaint);
    canvas.restore();

    // Tempurung oval
    canvas.drawOval(
        Rect.fromCenter(center: Offset(kx, ky), width: 34, height: 24),
        shellPaint);

    // Pola heksagonal emas tempurung
    final patternPaint = Paint()
      ..color = const Color(0xFFFDE047)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawCircle(Offset(kx - 4, ky), 5, patternPaint);
    canvas.drawCircle(Offset(kx + 6, ky), 5, patternPaint);

    // Ekor kecil
    canvas.drawOval(
        Rect.fromCenter(center: Offset(kx - 18, ky), width: 7, height: 4),
        skinPaint);
  }

  // 8. Gurita Kecil
  void _drawOctopus(Canvas canvas) {
    const ox = 180.0;
    const oy = 130.0;

    canvas.save();
    canvas.translate(ox, oy);
    canvas.scale(octopusScale);

    final octoPaint = Paint()..color = const Color(0xFFEC4899);

    // Kepala gurita
    canvas.drawCircle(Offset.zero, 18, octoPaint);

    // Mata besar lucu
    canvas.drawCircle(const Offset(-6, -2), 5, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(6, -2), 5, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(-5, -2), 2.5, Paint()..color = Colors.black);
    canvas.drawCircle(const Offset(7, -2), 2.5, Paint()..color = Colors.black);

    // Senyum manis
    final smile = Path()
      ..moveTo(-4, 7)
      ..quadraticBezierTo(0, 11, 4, 7);
    canvas.drawPath(
        smile,
        Paint()
          ..color = const Color(0xFF831843)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round);

    // Tentakel gurita
    for (int i = 0; i < 5; i++) {
      final tx = -14.0 + i * 7.0;
      final sway = sin(animTime * 5 + i) * 5;
      final tPath = Path()
        ..moveTo(tx, 14)
        ..quadraticBezierTo(tx + sway, 24, tx - sway, 32);
      canvas.drawPath(
          tPath,
          Paint()
            ..color = const Color(0xFFDB2777)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.5
            ..strokeCap = StrokeCap.round);
    }

    canvas.restore();
  }

  void _drawInkParticles(Canvas canvas) {
    for (final p in inkParticles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.alpha.clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawCircle(Offset(p.x, p.y), p.radius, paint);
    }
  }

  // 9. Pakan Ikan
  void _drawFishFoods(Canvas canvas) {
    for (final f in foods) {
      canvas.drawCircle(Offset(f.x, f.y), 4.5, Paint()..color = f.color);
      canvas.drawCircle(
          Offset(f.x - 1.2, f.y - 1.2), 1.5, Paint()..color = Colors.white);
    }
  }

  // 10. Ikan Badut (Mimi)
  void _drawClownfish(Canvas canvas) {
    canvas.save();
    canvas.translate(clownX, clownY);
    if (!clownFacingRight) {
      canvas.scale(-1.0, 1.0);
    }

    final orangePaint = Paint()..color = const Color(0xFFEA580C);
    final whitePaint = Paint()..color = Colors.white;
    final blackOutline = Paint()..color = const Color(0xFF1E293B);

    // Ekor Ikan Mengibas
    canvas.save();
    canvas.translate(-24, 0);
    canvas.rotate(clownTailAngle);
    final tailPath = Path()
      ..moveTo(0, 0)
      ..lineTo(-16, -12)
      ..quadraticBezierTo(-10, 0, -16, 12)
      ..close();
    canvas.drawPath(tailPath, orangePaint);
    canvas.drawPath(
        tailPath,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    canvas.restore();

    // Sirip Atas & Bawah
    final finTop = Path()
      ..moveTo(-10, -11)
      ..quadraticBezierTo(2, -22, 12, -10)
      ..close();
    canvas.drawPath(finTop, orangePaint);

    final finBottom = Path()
      ..moveTo(-6, 11)
      ..quadraticBezierTo(2, 20, 10, 10)
      ..close();
    canvas.drawPath(finBottom, orangePaint);

    // Badan Utama Oval
    canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 44, height: 26),
        orangePaint);

    // 2 Garis Putih Khas Ikan Badut dengan Garis Hitam
    _drawClownStripe(canvas, -4, 25);
    _drawClownStripe(canvas, 10, 20);

    // Sirip Dada Bergetar
    final finFlutter = sin(animTime * 8) * 4;
    final pectoralFin = Path()
      ..moveTo(2, 2)
      ..quadraticBezierTo(6 + finFlutter, 14, 14, 8)
      ..close();
    canvas.drawPath(pectoralFin, orangePaint);

    // Mata Besar Ceria & Lucu
    canvas.drawCircle(const Offset(13, -4), 5.5, whitePaint);
    canvas.drawCircle(const Offset(14.5, -4), 3.2, blackOutline);
    canvas.drawCircle(const Offset(15.5, -5), 1.2, whitePaint);

    // Senyum Ceria
    final mouthPath = Path()
      ..moveTo(19, 2)
      ..quadraticBezierTo(17, 7, 21, 5);
    canvas.drawPath(
      mouthPath,
      Paint()
        ..color = const Color(0xFF9A3412)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );

    canvas.restore();
  }

  void _drawClownStripe(Canvas canvas, double x, double height) {
    final stripeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(x, 0), width: 6.5, height: height),
      const Radius.circular(3),
    );
    canvas.drawRRect(stripeRect, Paint()..color = Colors.white);
    canvas.drawRRect(
      stripeRect,
      Paint()
        ..color = const Color(0xFF0F172A).withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  // 11. Gelembung Udara
  void _drawBubbles(Canvas canvas) {
    for (final b in bubbles) {
      final bubblePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4;

      canvas.drawCircle(Offset(b.x, b.y), b.radius, bubblePaint);

      // Kilau cahaya gelembung kecil
      canvas.drawCircle(
        Offset(b.x - b.radius * 0.35, b.y - b.radius * 0.35),
        b.radius * 0.3,
        Paint()..color = Colors.white.withValues(alpha: 0.75),
      );
    }
  }

  // 12. Partikel Sentuhan Layar
  void _drawTapParticles(Canvas canvas) {
    for (final p in tapParticles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.alpha.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant AquariumPainter oldDelegate) => true;
}
