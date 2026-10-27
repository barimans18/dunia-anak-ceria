import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/audio_recorder_service.dart';
import '../../../core/services/sound_engine.dart';
import '../../../shared/widgets/bouncy_card.dart';

class VoiceEffect {
  final String id;
  final String name;
  final String subtitle;
  final String icon;
  final double pitch;
  final Color color;

  const VoiceEffect({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.pitch,
    required this.color,
  });
}

class VoiceMimicScreen extends StatefulWidget {
  final VoidCallback onBack;
  const VoiceMimicScreen({super.key, required this.onBack});

  @override
  State<VoiceMimicScreen> createState() => _VoiceMimicScreenState();
}

class _VoiceMimicScreenState extends State<VoiceMimicScreen> with SingleTickerProviderStateMixin {
  final AudioRecorderService _recorderService = AudioRecorderService();
  bool _isRecording = false;
  bool _hasRecordedFile = false;
  int _recordSeconds = 0;
  Timer? _recordTimer;
  String? _playingVariantId;
  late AnimationController _pulseController;

  static const List<VoiceEffect> _effects = [
    VoiceEffect(
      id: 'normal',
      name: 'Suara Asli',
      subtitle: 'Suara manis kamu',
      icon: '🎤',
      pitch: 1.0,
      color: Color(0xFF10B981),
    ),
    VoiceEffect(
      id: 'rabbit',
      name: 'Kelinci Lincah',
      subtitle: 'Cepat & lucu',
      icon: '🐰',
      pitch: 1.45,
      color: Color(0xFFEC4899),
    ),
    VoiceEffect(
      id: 'chipmunk',
      name: 'Tupai Cempreng',
      subtitle: 'Kartun imut',
      icon: '🐿️',
      pitch: 1.75,
      color: Color(0xFFF59E0B),
    ),
    VoiceEffect(
      id: 'robot',
      name: 'Robot Raksasa',
      subtitle: 'Berat & dalam',
      icon: '🤖',
      pitch: 0.70,
      color: Color(0xFF6366F1),
    ),
    VoiceEffect(
      id: 'cat',
      name: 'Kucing Manja',
      subtitle: 'Lembut menggemaskan',
      icon: '🐱',
      pitch: 1.25,
      color: Color(0xFFFB923C),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _pulseController.dispose();
    _recorderService.dispose();
    super.dispose();
  }

  Future<void> _toggleRecord() async {
    if (!_isRecording) {
      await HapticFeedback.mediumImpact();
      await _recorderService.stopPlayback();
      setState(() {
        _playingVariantId = null;
      });

      final success = await _recorderService.startRecording();
      if (success) {
        setState(() {
          _isRecording = true;
          _hasRecordedFile = false;
          _recordSeconds = 0;
        });

        _recordTimer?.cancel();
        _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) {
            timer.cancel();
            return;
          }
          setState(() {
            _recordSeconds++;
          });
          // Batas rekam maksimal 15 detik agar ramah memori
          if (_recordSeconds >= 15) {
            _toggleRecord();
          }
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin mikrofon diperlukan ya!')),
        );
      }
    } else {
      _recordTimer?.cancel();
      _recordTimer = null;
      await HapticFeedback.mediumImpact();
      final path = await _recorderService.stopRecording();

      if (path != null) {
        SoundEngine().playWinStar();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Suara belum terdengar, coba rekam lebih dekat ya!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      setState(() {
        _isRecording = false;
        _hasRecordedFile = path != null;
        _playingVariantId = null;
      });
    }
  }

  Future<void> _playVariant(VoiceEffect effect) async {
    if (_playingVariantId == effect.id) {
      // Hentikan jika sedang memutar efek yang sama
      await _recorderService.stopPlayback();
      setState(() {
        _playingVariantId = null;
      });
      return;
    }

    setState(() {
      _playingVariantId = effect.id;
    });

    await _recorderService.playRecording(
      variantId: effect.id,
      pitchFactor: effect.pitch,
      onComplete: () {
        if (mounted) {
          setState(() {
            _playingVariantId = null;
          });
        }
      },
    );
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
                onTap: () {
                  _recorderService.stopPlayback();
                  widget.onBack();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.amber.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text('⬅️', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Studio Tirukan Suara 🎙️',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Tekan mikrofon, bicara, lalu pilih suara lucu!',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Body
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              children: [
                const SizedBox(height: 8),

                // Animated Mic Button
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = _isRecording ? (1.0 + _pulseController.value * 0.12) : 1.0;
                    return Transform.scale(
                      scale: scale,
                      child: BouncyCard(
                        onTap: _toggleRecord,
                        child: Container(
                          width: _hasRecordedFile ? 96 : 124,
                          height: _hasRecordedFile ? 96 : 124,
                          decoration: BoxDecoration(
                            color: _isRecording ? Colors.red.shade500 : AppColors.warmAmber,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: (_isRecording ? Colors.red : AppColors.warmAmber).withOpacity(0.4),
                                blurRadius: _isRecording ? 24 : 12,
                                spreadRadius: _isRecording ? 6 : 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _isRecording ? '⏹️' : '🎤',
                              style: TextStyle(fontSize: _hasRecordedFile ? 42 : 52),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Status Text & Live Counter
                if (_isRecording)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Merekam... 00:${_recordSeconds.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    _hasRecordedFile ? 'Tekan mic untuk rekam ulang' : 'Tekan untuk Mulai Bicara',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),

                const SizedBox(height: 16),

                // Voice Changer Options
                if (_hasRecordedFile && !_isRecording) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('✨ ', style: TextStyle(fontSize: 16)),
                        Text(
                          'Pilih Efek Suara Lucu di Bawah:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Cards List
                  Column(
                    children: _effects.map((effect) {
                      final isPlaying = _playingVariantId == effect.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: BouncyCard(
                          onTap: () => _playVariant(effect),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isPlaying ? effect.color : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isPlaying ? Colors.white : effect.color.withOpacity(0.35),
                                width: isPlaying ? 2.5 : 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: effect.color.withOpacity(isPlaying ? 0.35 : 0.08),
                                  blurRadius: isPlaying ? 12 : 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Character Emoji Circle
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isPlaying ? Colors.white.withOpacity(0.25) : effect.color.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      effect.icon,
                                      style: const TextStyle(fontSize: 26),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Title & Subtitle
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        effect.name,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: isPlaying ? Colors.white : const Color(0xFF0F172A),
                                        ),
                                      ),
                                      Text(
                                        effect.subtitle,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isPlaying ? Colors.white.withOpacity(0.85) : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Play / Stop Action Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: isPlaying ? Colors.white : effect.color,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        isPlaying ? '⏹️' : '▶️',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        isPlaying ? 'Stop' : 'Putar',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                          color: isPlaying ? effect.color : Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 20),

                // Safe Local Storage Footer Note
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    '🔒 Suara disimpan lokal di HP kamu, aman tanpa kuota!',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMedium),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
