import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/audio_recorder_service.dart';
import '../../../core/services/saved_voice_service.dart';
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
  final SavedVoiceService _savedVoiceService = SavedVoiceService();

  int _selectedTab = 0; // 0: Studio, 1: Koleksi Tersimpan
  bool _isRecording = false;
  bool _hasRecordedFile = false;
  bool _isCurrentFileSaved = false;
  int _recordSeconds = 0;
  int _lastRecordedDuration = 0;
  String _currentVoiceTitle = 'Suara Baru';
  Timer? _recordTimer;
  String? _playingVariantId;
  String? _playingSavedVoiceId;
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
    _savedVoiceService.loadRecordings();
    _savedVoiceService.addListener(_onSavedVoiceUpdate);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  void _onSavedVoiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _savedVoiceService.removeListener(_onSavedVoiceUpdate);
    _recordTimer?.cancel();
    _pulseController.dispose();

    // Hapus file sementara jika user keluar tanpa menyimpan
    if (!_isCurrentFileSaved) {
      _recorderService.clearTemporaryFiles();
    }
    _recorderService.dispose();
    super.dispose();
  }

  void _handleBack() {
    _recorderService.stopPlayback();
    if (!_isCurrentFileSaved) {
      _recorderService.clearTemporaryFiles();
    }
    widget.onBack();
  }

  Future<void> _toggleRecord() async {
    if (!_isRecording) {
      await HapticFeedback.mediumImpact();
      await _recorderService.stopPlayback();
      setState(() {
        _playingVariantId = null;
        _playingSavedVoiceId = null;
      });

      // Bersihkan file sementara sebelumnya jika belum disimpan
      if (!_isCurrentFileSaved) {
        await _recorderService.clearTemporaryFiles();
      }

      final success = await _recorderService.startRecording();
      if (success) {
        setState(() {
          _isRecording = true;
          _hasRecordedFile = false;
          _isCurrentFileSaved = false;
          _recordSeconds = 0;
          _currentVoiceTitle = 'Suara Baru';
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
      final recordedDuration = _recordSeconds;
      final path = await _recorderService.stopRecording();

      setState(() {
        _isRecording = false;
        _hasRecordedFile = path != null;
        _playingVariantId = null;
        _lastRecordedDuration = recordedDuration;
      });

      if (path != null) {
        SoundEngine().playWinStar();
        if (mounted) {
          await _showSaveOrSkipDialog(path, recordedDuration);
        }
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
    }
  }

  Future<void> _showSaveOrSkipDialog(String path, int duration) async {
    final defaultTitle = 'Suaraku ${_savedVoiceService.recordings.length + 1}';
    final textController = TextEditingController(text: defaultTitle);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
          contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          title: Row(
            children: const [
              Text('🎉 ', style: TextStyle(fontSize: 22)),
              Expanded(
                child: Text(
                  'Simpan Rekaman Ini?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Durasi: 00:${duration.toString().padLeft(2, '0')} detik',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textMedium),
              ),
              const SizedBox(height: 14),
              const Text(
                'Nama Rekaman:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: textController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Misal: Suara Kucing, Halo Ibu...',
                  prefixIcon: const Icon(Icons.mic, color: AppColors.warmAmber),
                  filled: true,
                  fillColor: Colors.amber.shade50.withOpacity(0.6),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.amber.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.amber.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.warmAmber, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '💡 Pilih "Lewati" jika hanya ingin coba suara lucu tanpa menyimpan ke HP.',
                style: TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _isCurrentFileSaved = false;
                  _currentVoiceTitle = 'Suara Sementara';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kamu bisa langsung coba suara lucu di bawah!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Lewati / Coba Dulu', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emeraldGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              icon: const Icon(Icons.bookmark_add, size: 18),
              label: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.w900)),
              onPressed: () async {
                final title = textController.text.trim();
                final saved = await _savedVoiceService.saveRecording(
                  sourcePath: path,
                  title: title,
                  durationSeconds: duration,
                );
                if (ctx.mounted) Navigator.pop(ctx);

                if (saved != null) {
                  setState(() {
                    _isCurrentFileSaved = true;
                    _currentVoiceTitle = saved.title;
                    // Aktifkan file yang baru disimpan
                    _recorderService.setActiveRecordingPath(saved.filePath);
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✨ Berhasil disimpan sebagai "${saved.title}"!'),
                        backgroundColor: AppColors.emeraldGreen,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _playVariant(VoiceEffect effect) async {
    if (_playingVariantId == effect.id) {
      await _recorderService.stopPlayback();
      setState(() {
        _playingVariantId = null;
      });
      return;
    }

    setState(() {
      _playingVariantId = effect.id;
      _playingSavedVoiceId = null;
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

  Future<void> _playSavedVoice(SavedVoiceModel recording) async {
    if (_playingSavedVoiceId == recording.id) {
      await _recorderService.stopPlayback();
      setState(() {
        _playingSavedVoiceId = null;
      });
      return;
    }

    setState(() {
      _playingSavedVoiceId = recording.id;
      _playingVariantId = null;
    });

    _recorderService.setActiveRecordingPath(recording.filePath);
    await _recorderService.playRecording(
      variantId: 'normal',
      pitchFactor: 1.0,
      onComplete: () {
        if (mounted) {
          setState(() {
            _playingSavedVoiceId = null;
          });
        }
      },
    );
  }

  void _loadSavedVoiceToStudio(SavedVoiceModel recording) {
    _recorderService.stopPlayback();
    _recorderService.setActiveRecordingPath(recording.filePath);
    setState(() {
      _selectedTab = 0;
      _hasRecordedFile = true;
      _isCurrentFileSaved = true;
      _currentVoiceTitle = recording.title;
      _lastRecordedDuration = recording.durationSeconds;
      _playingVariantId = null;
      _playingSavedVoiceId = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Suara "${recording.title}" siap diubah di Studio! 🎙️'),
        backgroundColor: AppColors.warmAmber,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _confirmDeleteSavedVoice(SavedVoiceModel recording) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Rekaman?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('Rekaman "${recording.title}" akan dihapus permanen dari HP kamu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (_playingSavedVoiceId == recording.id) {
        await _recorderService.stopPlayback();
      }
      await _savedVoiceService.deleteRecording(recording.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rekaman berhasil dihapus.')),
        );
      }
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
                onTap: _handleBack,
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
                      'Rekam suara, pilih karakter lucu, dan simpan!',
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

        // Navigation Tabs (Studio vs Koleksi Suara)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.amber.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _recorderService.stopPlayback();
                      setState(() {
                        _selectedTab = 0;
                        _playingSavedVoiceId = null;
                        _playingVariantId = null;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedTab == 0 ? AppColors.warmAmber : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          '🎙️ Studio Suara',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: _selectedTab == 0 ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _recorderService.stopPlayback();
                      setState(() {
                        _selectedTab = 1;
                        _playingSavedVoiceId = null;
                        _playingVariantId = null;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedTab == 1 ? AppColors.warmAmber : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          '📂 Koleksiku (${_savedVoiceService.recordings.length})',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: _selectedTab == 1 ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Body Content
        Expanded(
          child: _selectedTab == 0 ? _buildStudioTab() : _buildSavedVoicesTab(),
        ),
      ],
    );
  }

  Widget _buildStudioTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          const SizedBox(height: 8),

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

          // Live Recording Counter / Status
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

          // Active Voice Banner & Voice Changer Cards
          if (_hasRecordedFile && !_isRecording) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  const Text('✨ ', style: TextStyle(fontSize: 18)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentVoiceTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFB45309),
                          ),
                        ),
                        Text(
                          _isCurrentFileSaved
                              ? 'Tersimpan permanen di HP kamu'
                              : 'File sementara (dihapus saat keluar)',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _isCurrentFileSaved ? AppColors.emeraldGreen : Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!_isCurrentFileSaved && _recorderService.lastRecordedPath != null)
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: AppColors.emeraldGreen,
                      ),
                      icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                      label: const Text('Simpan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        _showSaveOrSkipDialog(
                          _recorderService.lastRecordedPath!,
                          _lastRecordedDuration,
                        );
                      },
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Voice Effects Cards
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
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: isPlaying ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  effect.subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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

          const SizedBox(height: 16),

          // Info Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _isCurrentFileSaved
                  ? '🔒 Suara tersimpan aman di HP kamu, tanpa kuota internet!'
                  : '🔒 File sementara akan otomatis dihapus saat kamu keluar dari layar ini.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMedium),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSavedVoicesTab() {
    final list = _savedVoiceService.recordings;
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('📂', style: TextStyle(fontSize: 42)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Belum Ada Rekaman Tersimpan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Rekam suaramu di Studio, lalu pilih "Simpan" agar bisa diputar lagi kapan saja!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warmAmber,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: const Text('🎙️', style: TextStyle(fontSize: 16)),
                label: const Text('Mulai Rekam Suara', style: TextStyle(fontWeight: FontWeight.w900)),
                onPressed: () {
                  setState(() {
                    _selectedTab = 0;
                  });
                },
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        final isPlaying = _playingSavedVoiceId == item.id;
        final dateStr = '${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year} ${item.createdAt.hour.toString().padLeft(2, '0')}:${item.createdAt.minute.toString().padLeft(2, '0')}';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isPlaying ? AppColors.warmAmber : Colors.amber.shade100,
                width: isPlaying ? 2 : 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isPlaying ? AppColors.warmAmber.withOpacity(0.2) : Colors.black.withOpacity(0.04),
                  blurRadius: isPlaying ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.warmAmber.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('🎵', style: TextStyle(fontSize: 22)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$dateStr • 00:${item.durationSeconds.toString().padLeft(2, '0')}s',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                      tooltip: 'Hapus Rekaman',
                      onPressed: () => _confirmDeleteSavedVoice(item),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, thickness: 0.8),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Tombol Putar Langsung
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isPlaying ? Colors.red : AppColors.emeraldGreen,
                          side: BorderSide(color: isPlaying ? Colors.red : AppColors.emeraldGreen),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        icon: Text(isPlaying ? '⏹️' : '▶️', style: const TextStyle(fontSize: 13)),
                        label: Text(
                          isPlaying ? 'Stop' : 'Putar',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => _playSavedVoice(item),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Tombol Coba Suara Lucu di Studio
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warmAmber,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        icon: const Text('🎭', style: TextStyle(fontSize: 13)),
                        label: const Text(
                          'Coba Suara Lucu',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                        ),
                        onPressed: () => _loadSavedVoiceToStudio(item),
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
