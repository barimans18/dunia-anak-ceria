import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_data.dart';
import '../../../core/services/sound_engine.dart';
import '../../../shared/widgets/bouncy_card.dart';
import '../../../shared/widgets/responsive_stage_layout.dart';

class VehiclesScreen extends StatefulWidget {
  final VoidCallback onBack;
  const VehiclesScreen({super.key, required this.onBack});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  late EduItem selectedVehicle;

  @override
  void initState() {
    super.initState();
    selectedVehicle = AppData.vehicles.first;
  }

  void _playVehicleSound(EduItem vehicle) {
    SoundEngine().playAsset(vehicle.soundAsset);
  }

  void _spellVehicle(EduItem vehicle) {
    SoundEngine().spellSyllables(vehicle.syllables, vehicle.name);
  }

  void _selectVehicle(EduItem vehicle) {
    setState(() => selectedVehicle = vehicle);
    _playVehicleSound(vehicle);
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted && selectedVehicle.id == vehicle.id) {
        _spellVehicle(vehicle);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveStageLayout(
      title: 'Kendaraan Hebat 🚗',
      subtitle: 'Sentuh kartu atas untuk klakson & ejaannya!',
      onBack: widget.onBack,
      stageCard: _buildStageCard(),
      gridView: _buildVehiclesGrid(),
    );
  }

  Widget _buildStageCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: selectedVehicle.borderColor, width: 3.5),
        boxShadow: [
          BoxShadow(
            color: selectedVehicle.primaryColor.withOpacity(0.18),
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
                  color: selectedVehicle.primaryColor,
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
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFBAE6FD)),
                ),
                child: Text(
                  selectedVehicle.soundText,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0369A1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Big Interactive Emoji
          BouncyCard(
            onTap: () => _selectVehicle(selectedVehicle),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: selectedVehicle.primaryColor.withOpacity(0.12),
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
                  selectedVehicle.emoji,
                  style: const TextStyle(fontSize: 60),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Name
          Text(
            selectedVehicle.name,
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
            children: selectedVehicle.syllables.map((syl) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBAE6FD)),
                ),
                child: Text(
                  syl,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0284C7),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 6),
          Text(
            selectedVehicle.description,
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
                    backgroundColor: AppColors.primarySky,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 2,
                  ),
                  icon: const Text('🚨', style: TextStyle(fontSize: 14)),
                  label: const Text('Klakson / Mesin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: () => _playVehicleSound(selectedVehicle),
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
                  onPressed: () => _spellVehicle(selectedVehicle),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclesGrid() {
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
          itemCount: AppData.vehicles.length,
          itemBuilder: (context, index) {
            final vehicle = AppData.vehicles[index];
            final isSelected = vehicle.id == selectedVehicle.id;

            return BouncyCard(
              onTap: () => _selectVehicle(vehicle),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF0F9FF) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primarySky : Colors.grey.shade200,
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
                    Text(vehicle.emoji, style: const TextStyle(fontSize: 34)),
                    const SizedBox(height: 4),
                    Text(
                      vehicle.name,
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
                        vehicle.soundText,
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
