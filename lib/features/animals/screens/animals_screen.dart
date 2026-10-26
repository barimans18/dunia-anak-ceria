import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_data.dart';
import '../../../core/services/sound_engine.dart';
import '../../../shared/widgets/bouncy_card.dart';
import '../../../shared/widgets/responsive_stage_layout.dart';

class AnimalsScreen extends StatefulWidget {
  final VoidCallback onBack;
  const AnimalsScreen({super.key, required this.onBack});

  @override
  State<AnimalsScreen> createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends State<AnimalsScreen> {
  late EduItem selectedAnimal;

  @override
  void initState() {
    super.initState();
    selectedAnimal = AppData.animals.first;
  }

  void _playAnimalSound(EduItem animal) {
    SoundEngine().playAsset(animal.soundAsset);
  }

  void _spellAnimal(EduItem animal) {
    SoundEngine().spellSyllables(animal.syllables, animal.name);
  }

  void _selectAnimal(EduItem animal) {
    setState(() => selectedAnimal = animal);
    _playAnimalSound(animal);
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted && selectedAnimal.id == animal.id) {
        _spellAnimal(animal);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveStageLayout(
      title: 'Sahabat Satwa 🦁',
      subtitle: 'Sentuh kartu atas untuk suara & ejaannya!',
      onBack: widget.onBack,
      stageCard: _buildStageCard(),
      gridView: _buildAnimalsGrid(),
    );
  }

  Widget _buildStageCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: selectedAnimal.borderColor, width: 3.5),
        boxShadow: [
          BoxShadow(
            color: selectedAnimal.primaryColor.withOpacity(0.18),
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
                  color: selectedAnimal.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'INTERAKTIF TERPILIH',
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
                  selectedAnimal.soundText,
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

          // Big Interactive Emoji
          BouncyCard(
            onTap: () => _selectAnimal(selectedAnimal),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: selectedAnimal.primaryColor.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  selectedAnimal.emoji,
                  style: const TextStyle(fontSize: 60),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Name
          Text(
            selectedAnimal.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),

          // Syllables chips
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: selectedAnimal.syllables.map((syl) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Text(
                  syl,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF78350F),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 6),
          Text(
            selectedAnimal.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),

          // Action Buttons
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emeraldGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 2,
                  ),
                  icon: const Text('📢', style: TextStyle(fontSize: 14)),
                  label: const Text('Suara Satwa', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: () => _playAnimalSound(selectedAnimal),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warmAmber,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 2,
                  ),
                  icon: const Text('🔤', style: TextStyle(fontSize: 14)),
                  label: const Text('Eja Pelan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: () => _spellAnimal(selectedAnimal),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalsGrid() {
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
          itemCount: AppData.animals.length,
          itemBuilder: (context, index) {
            final animal = AppData.animals[index];
            final isSelected = animal.id == selectedAnimal.id;

            return BouncyCard(
              onTap: () => _selectAnimal(animal),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFECFDF5) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.emeraldGreen : Colors.grey.shade200,
                    width: isSelected ? 3 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(animal.emoji, style: const TextStyle(fontSize: 34)),
                    const SizedBox(height: 4),
                    Text(
                      animal.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        animal.soundText,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
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
