import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/audio_recorder_service.dart';
import '../../../core/services/sound_engine.dart';
import '../../../shared/widgets/bouncy_card.dart';

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
  late AnimationController _pulseController;

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
    _pulseController.dispose();
    _recorderService.dispose();
    super.dispose();
  }

  Future<void> _toggleRecord() async {
    if (!_isRecording) {
      final success = await _recorderService.startRecording();
      if (success) {
        SoundEngine().playClick();
        setState(() {
          _isRecording = true;
          _hasRecordedFile = false;
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin mikrofon diperlukan ya!')),
        );
      }
    } else {
      final path = await _recorderService.stopRecording();
      SoundEngine().playWinStar();
      setState(() {
        _isRecording = false;
        _hasRecordedFile = path != null;
      });
    }
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
                    border: Border.all(color: Colors.amber.shade300),
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
                      'Tekan tombol mikrofon, lalu bicara yuk!',
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Big Mic Button
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = _isRecording ? (1.0 + _pulseController.value * 0.12) : 1.0;
                    return Transform.scale(
                      scale: scale,
                      child: BouncyCard(
                        onTap: _toggleRecord,
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            color: _isRecording ? Colors.red.shade500 : AppColors.warmAmber,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 5),
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
                              style: const TextStyle(fontSize: 50),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),
                Text(
                  _isRecording ? 'Sedang Merekam... Ayo Bicara!' : 'Tekan untuk Bicara',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: _isRecording ? Colors.red.shade600 : AppColors.textDark,
                  ),
                ),

                const SizedBox(height: 24),

                // Playback Buttons
                if (_hasRecordedFile) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emeraldGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 3,
                      ),
                      icon: const Text('▶️', style: TextStyle(fontSize: 18)),
                      label: const Text('Dengar Suaraku', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      onPressed: () => _recorderService.playRecording(playbackRate: 1.0),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.softPink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 3,
                      ),
                      icon: const Text('🐰', style: TextStyle(fontSize: 18)),
                      label: const Text('Suara Kelinci Lucu (Cepat)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      onPressed: () => _recorderService.playRecording(playbackRate: 1.35),
                    ),
                  ),
                ],

                const SizedBox(height: 36),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Suara disimpan lokal di HP kamu, aman tanpa kuota!',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMedium),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
