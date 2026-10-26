import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/user_profile_service.dart';
import '../../features/home/widgets/user_profile_dialog.dart';
import '../../features/parental_gate/widgets/parental_gate_dialog.dart';
import 'bouncy_card.dart';

class TopKioskBar extends StatelessWidget {
  const TopKioskBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFFDE68A), width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: UserProfileService(),
          builder: (context, _) {
            final profile = UserProfileService();
            return Row(
              children: [
                // Avatar with tap to edit profile
                BouncyCard(
                  onTap: () => UserProfileDialog.show(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.sunnyYellow, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _buildAvatar(profile.photoPath),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'DUNIA CERIA',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0369A1),
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Halo, ${profile.displayName}! ✨',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.warmAmber,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                BouncyCard(
                  onTap: () => ParentalGateDialog.show(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.sunnyYellow, width: 1.5),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🛡️', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 4),
                        Text(
                          'Orang Tua',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvatar(String photoPath) {
    if (UserProfileService.isLocalFile(photoPath)) {
      return Image.file(
        File(photoPath),
        width: 44,
        height: 44,
        fit: BoxFit.cover,
      );
    }

    final emoji = UserProfileService.getPresetEmoji(photoPath);
    if (emoji != null) {
      return Center(
        child: Text(emoji, style: const TextStyle(fontSize: 22)),
      );
    }

    return SvgPicture.asset(
      'assets/icons/app_icon.svg',
      width: 44,
      height: 44,
      fit: BoxFit.cover,
    );
  }
}

