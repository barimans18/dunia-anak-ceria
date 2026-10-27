import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/sound_engine.dart';

class InteractiveCartoonScreen extends StatefulWidget {
  final VoidCallback onBack;
  const InteractiveCartoonScreen({super.key, required this.onBack});

  @override
  State<InteractiveCartoonScreen> createState() =>
      _InteractiveCartoonScreenState();
}

class Particle {
  double x, y, vx, vy, size;
  Color color;
  Particle(
      {required this.x,
      required this.y,
      required this.vx,
      required this.vy,
      required this.size,
      required this.color});
}

class Raindrop {
  double x, y, speed;
  Raindrop({required this.x, required this.y, required this.speed});
}

class _InteractiveCartoonScreenState extends State<InteractiveCartoonScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  bool isNight = false;
  bool isRaining = false;
  bool hasRainbow = false;
  double carX = -70;
  double carSpeed = 2.0;
  double balloonY = -120;
  double balloonX = 140;
  int starScore = 0;

  final List<Particle> particles = [];
  final List<Raindrop> raindrops = [];
  final Random _rand = Random();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _animController.addListener(_updatePhysics);

    // Initial raindrops
    for (int i = 0; i < 35; i++) {
      raindrops.add(Raindrop(
        x: _rand.nextDouble() * 400,
        y: _rand.nextDouble() * 300,
        speed: 4 + _rand.nextDouble() * 4,
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
      // Car moving
      carX += carSpeed;
      if (carX > 450) carX = -80;

      // Balloon
      if (balloonY > -80 && balloonY < 400) {
        balloonY += 0.8;
      }

      // Rain
      if (isRaining) {
        for (var drop in raindrops) {
          drop.y += drop.speed;
          if (drop.y > 320) drop.y = -10;
        }
      }

      // Particles
      for (int i = particles.length - 1; i >= 0; i--) {
        final p = particles[i];
        p.x += p.vx;
        p.y += p.vy;
        p.size *= 0.94;
        if (p.size < 0.6) particles.removeAt(i);
      }
    });
  }

  void _onCanvasTap(TapUpDetails details) {
    final pos = details.localPosition;
    setState(() {
      starScore++;
      // Spawn star particles
      for (int i = 0; i < 8; i++) {
        final angle = _rand.nextDouble() * 2 * pi;
        final speed = 2 + _rand.nextDouble() * 3;
        particles.add(Particle(
          x: pos.dx,
          y: pos.dy,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed,
          size: 6 + _rand.nextDouble() * 4,
          color: [
            Colors.amber,
            Colors.pinkAccent,
            Colors.lightBlueAccent,
            Colors.lightGreenAccent
          ][_rand.nextInt(4)],
        ));
      }
    });

    SoundEngine().playWinStar();
  }

  void _toggleDayNight() {
    setState(() => isNight = !isNight);
    SoundEngine().playClick();
    SoundEngine().speakWord(
        isNight ? 'Malam hari yang tenang...' : 'Siang hari yang ceria!');
  }

  void _triggerRainbow() {
    setState(() => hasRainbow = !hasRainbow);
    SoundEngine().playWinStar();
    if (hasRainbow) SoundEngine().speakWord('Pelangi indah muncul!');
  }

  void _triggerRain() {
    setState(() => isRaining = !isRaining);
    SoundEngine().playPop();
    if (isRaining) SoundEngine().speakWord('Hujan turun, tik tik tik!');
  }

  void _boostCar() {
    setState(() => carSpeed = 6.0);
    SoundEngine().playAsset('audio/vehicles/car.wav');
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => carSpeed = 2.0);
    });
  }

  void _spawnFireworks() {
    SoundEngine().playWinStar();
    SoundEngine().speakWord('Wah, kembang api meriah!');
    setState(() {
      final colors = [
        Colors.red,
        Colors.amber,
        Colors.green,
        Colors.blue,
        Colors.pink,
        Colors.purple
      ];
      for (int i = 0; i < 30; i++) {
        final angle = _rand.nextDouble() * 2 * pi;
        final speed = 2 + _rand.nextDouble() * 5;
        particles.add(Particle(
          x: 180,
          y: 90,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed,
          size: 7 + _rand.nextDouble() * 5,
          color: colors[_rand.nextInt(colors.length)],
        ));
      }
    });
  }

  void _spawnBalloon() {
    SoundEngine().playClick();
    SoundEngine().speakWord('Balon udara terbang!');
    setState(() => balloonY = -20);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
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
                    border: Border.all(color: Colors.pink.shade200),
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
                      'Kartun Interaktif 🎬',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Sentuh layar untuk kejutan seru!',
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
                ),
                child: Text(
                  '⭐ $starScore',
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 13),
                ),
              ),
            ],
          ),
        ),

        // Animated Canvas Box
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.pink.shade300, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: GestureDetector(
                  onTapUp: _onCanvasTap,
                  child: CustomPaint(
                    painter: CartoonPainter(
                      isNight: isNight,
                      isRaining: isRaining,
                      hasRainbow: hasRainbow,
                      carX: carX,
                      balloonY: balloonY,
                      balloonX: balloonX,
                      particles: particles,
                      raindrops: raindrops,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Control Buttons Grid
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
                _buildActionBtn('🌙 Malam/Siang', _toggleDayNight,
                    const Color(0xFFE0E7FF), const Color(0xFF3730A3)),
                _buildActionBtn('🌈 Pelangi', _triggerRainbow,
                    const Color(0xFFFCE7F3), const Color(0xFF9D174D)),
                _buildActionBtn('🌧️ Hujan', _triggerRain,
                    const Color(0xFFE0F2FE), const Color(0xFF0369A1)),
                _buildActionBtn('🏎️ Laju Cepat', _boostCar,
                    const Color(0xFFFEF3C7), const Color(0xFF92400E)),
                _buildActionBtn('🎆 Kembang Api', _spawnFireworks,
                    const Color(0xFFFFE4E6), const Color(0xFFBE123C)),
                _buildActionBtn('🎈 Balon Udara', _spawnBalloon,
                    const Color(0xFFF3E8FF), const Color(0xFF6B21A8)),
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
        elevation: 1,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: textCol.withOpacity(0.3)),
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

class CartoonPainter extends CustomPainter {
  final bool isNight;
  final bool isRaining;
  final bool hasRainbow;
  final double carX;
  final double balloonY;
  final double balloonX;
  final List<Particle> particles;
  final List<Raindrop> raindrops;

  CartoonPainter({
    required this.isNight,
    required this.isRaining,
    required this.hasRainbow,
    required this.carX,
    required this.balloonY,
    required this.balloonX,
    required this.particles,
    required this.raindrops,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Sky
    final skyPaint = Paint();
    if (isNight) {
      skyPaint.color = const Color(0xFF0F172A);
    } else if (isRaining) {
      skyPaint.color = const Color(0xFF94A3B8);
    } else {
      skyPaint.color = const Color(0xFF7DD3FC);
    }
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // 2. Stars if night
    if (isNight) {
      final starPaint = Paint()..color = const Color(0xFFFDE047);
      for (int i = 0; i < 20; i++) {
        final sx = (i * 37) % size.width;
        final sy = (i * 23) % (size.height / 2);
        canvas.drawCircle(Offset(sx, sy), 1.5, starPaint);
      }
    }

    // 3. Rainbow
    if (hasRainbow) {
      final colors = [
        Colors.red,
        Colors.orange,
        Colors.yellow,
        Colors.green,
        Colors.blue,
        Colors.purple
      ];
      for (int i = 0; i < colors.length; i++) {
        final arcPaint = Paint()
          ..color = colors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;
        canvas.drawArc(
          Rect.fromCircle(
              center: Offset(size.width / 2, size.height - 20),
              radius: 100.0 - i * 5),
          pi,
          pi,
          false,
          arcPaint,
        );
      }
    }

    // 4. Sun or Moon
    if (isNight) {
      final moonPaint = Paint()..color = const Color(0xFFFDE047);
      canvas.drawCircle(const Offset(45, 45), 20, moonPaint);
      final cutPaint = Paint()..color = const Color(0xFF0F172A);
      canvas.drawCircle(const Offset(52, 42), 16, cutPaint);
    } else {
      final sunPaint = Paint()..color = const Color(0xFFFBBF24);
      canvas.drawCircle(const Offset(45, 45), 24, sunPaint);
      final strokePaint = Paint()
        ..color = const Color(0xFFF59E0B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(const Offset(45, 45), 24, strokePaint);
    }

    // 5. Hot Air Balloon
    if (balloonY > -60 && balloonY < size.height + 40) {
      final bPaint = Paint()..color = const Color(0xFFEC4899);
      canvas.drawCircle(Offset(balloonX, balloonY), 18, bPaint);
      final basketPaint = Paint()..color = const Color(0xFF831843);
      canvas.drawRect(
          Rect.fromLTWH(balloonX - 5, balloonY + 20, 10, 8), basketPaint);
    }

    // 6. Grass Hills
    final hill1 = Paint()
      ..color = isNight ? const Color(0xFF1E3A1E) : const Color(0xFF4ADE80);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(size.width * 0.3, size.height - 15),
            width: size.width * 0.8,
            height: 90),
        hill1);

    final hill2 = Paint()
      ..color = isNight ? const Color(0xFF142E14) : const Color(0xFF22C55E);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(size.width * 0.8, size.height - 10),
            width: size.width * 0.7,
            height: 80),
        hill2);

    // 7. Road
    final roadPaint = Paint()..color = const Color(0xFF475569);
    canvas.drawRect(
        Rect.fromLTWH(0, size.height - 45, size.width, 45), roadPaint);

    final linePaint = Paint()..color = Colors.white;
    for (double x = 10; x < size.width; x += 40) {
      canvas.drawRect(Rect.fromLTWH(x, size.height - 24, 20, 4), linePaint);
    }

    // 8. Rain
    if (isRaining) {
      final rainPaint = Paint()
        ..color = const Color(0xFFE0F2FE)
        ..strokeWidth = 2;
      for (var drop in raindrops) {
        canvas.drawLine(
            Offset(drop.x, drop.y), Offset(drop.x - 2, drop.y + 10), rainPaint);
      }
    }

    // 9. Moving Car
    final cy = size.height - 48;
    final carBody = Paint()..color = const Color(0xFFEF4444);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(carX, cy, 55, 20), const Radius.circular(8)),
        carBody);

    final carRoof = Paint()..color = const Color(0xFFF87171);
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(carX + 10, cy - 12, 30, 14),
            const Radius.circular(5)),
        carRoof);

    // Wheels
    final wheelPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawCircle(Offset(carX + 12, cy + 20), 7, wheelPaint);
    canvas.drawCircle(Offset(carX + 42, cy + 20), 7, wheelPaint);

    // 10. Particles
    for (var p in particles) {
      final pPaint = Paint()..color = p.color;
      canvas.drawCircle(Offset(p.x, p.y), p.size, pPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CartoonPainter oldDelegate) => true;
}
