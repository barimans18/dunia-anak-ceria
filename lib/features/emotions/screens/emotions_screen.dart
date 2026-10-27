import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_data.dart';
import '../../../core/services/sound_engine.dart';
import '../../../shared/widgets/bouncy_card.dart';
import '../../../shared/widgets/responsive_stage_layout.dart';

class EmotionsScreen extends StatefulWidget {
  final VoidCallback onBack;
  const EmotionsScreen({super.key, required this.onBack});

  @override
  State<EmotionsScreen> createState() => _EmotionsScreenState();
}

class _EmotionsScreenState extends State<EmotionsScreen>
    with SingleTickerProviderStateMixin {
  late EduItem selectedEmotion;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    selectedEmotion = AppData.emotions.first;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _playEmotionSound(EduItem emotion) {
    SoundEngine().playAsset(emotion.soundAsset);
  }

  void _spellEmotion(EduItem emotion) {
    SoundEngine().spellSyllables(emotion.syllables, emotion.name);
  }

  void _selectEmotion(EduItem emotion) {
    setState(() => selectedEmotion = emotion);
    _animController.forward(from: 0.0);
    _playEmotionSound(emotion);
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted && selectedEmotion.id == emotion.id) {
        _spellEmotion(emotion);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveStageLayout(
      title: 'Ekspresi & Emosi 😊',
      subtitle: 'Kenali perasaan & asah empati bersama!',
      onBack: widget.onBack,
      stageCard: _buildStageCard(),
      gridView: _buildEmotionsGrid(),
    );
  }

  Widget _buildStageCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: selectedEmotion.borderColor, width: 3.5),
        boxShadow: [
          BoxShadow(
            color: selectedEmotion.primaryColor.withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: selectedEmotion.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'CERMIN EMOSI CERIA',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.sunnyYellow),
                ),
                child: Text(
                  selectedEmotion.soundText,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Big Interactive Animated Illustration
          BouncyCard(
            onTap: () => _selectEmotion(selectedEmotion),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: selectedEmotion.primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: selectedEmotion.primaryColor.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    selectedEmotion.emoji,
                    style: const TextStyle(fontSize: 58),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            selectedEmotion.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),

          // Syllables chips
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: selectedEmotion.syllables.map((syl) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
                ),
                child: Text(
                  syl,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF78350F),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 6),
          Text(
            selectedEmotion.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),

          // Action Buttons: Dengar Suara & Eja Pelan
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.coralRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 2,
                  ),
                  icon: const Text('📢', style: TextStyle(fontSize: 14)),
                  label: const Text(
                    'Dengar Suara',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _playEmotionSound(selectedEmotion),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warmAmber,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 2,
                  ),
                  icon: const Text('🔤', style: TextStyle(fontSize: 14)),
                  label: const Text(
                    'Eja Pelan',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _spellEmotion(selectedEmotion),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 600 ? 4 : 2;

        return GridView.builder(
          padding: const EdgeInsets.only(bottom: 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.05,
          ),
          itemCount: AppData.emotions.length,
          itemBuilder: (context, index) {
            final emotion = AppData.emotions[index];
            final isSelected = emotion.id == selectedEmotion.id;

            return BouncyCard(
              onTap: () => _selectEmotion(emotion),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFFF1F2) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? emotion.primaryColor
                        : Colors.grey.shade200,
                    width: isSelected ? 3 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? emotion.primaryColor.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(emotion.emoji, style: const TextStyle(fontSize: 34)),
                    const SizedBox(height: 4),
                    Text(
                      emotion.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        emotion.soundText,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? emotion.borderColor
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
