import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_data.dart';
import '../../../core/services/sound_engine.dart';
import '../../../shared/widgets/bouncy_card.dart';

class ReadingScreen extends StatefulWidget {
  final VoidCallback onBack;
  const ReadingScreen({super.key, required this.onBack});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  String selectedTab = 'vowels'; // 'vowels', 'words', 'alphabet'
  String activeVowel = 'A';

  void _tapVowel(String vowel) {
    setState(() => activeVowel = vowel);
    SoundEngine().playClick();
    final data = AppData.vowels[vowel]!;
    SoundEngine().spellSyllables(data['syl'] as List<String>, '$vowel... ${data['word']}');
  }

  void _tapBasicWord(BasicWordItem item) {
    SoundEngine().playPop();
    SoundEngine().spellSyllables(item.syllables, item.word);
  }

  void _tapLetter(String letter) {
    SoundEngine().playClick();
    SoundEngine().speakWord('Huruf... $letter', rate: 0.35);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Header
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
                    border: Border.all(color: Colors.purple.shade200),
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
                      'Belajar Membaca & Eja 🔤',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Pelafalan pelan & eja suku kata',
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

        // Tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              _buildTabButton('vowels', 'Vokal'),
              const SizedBox(width: 8),
              _buildTabButton('words', 'Kata Dasar'),
              const SizedBox(width: 8),
              _buildTabButton('alphabet', 'A - Z'),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Sub-Tab Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: selectedTab == 'vowels'
                ? _buildVowelsContent()
                : selectedTab == 'words'
                    ? _buildWordsContent()
                    : _buildAlphabetContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(String tabKey, String label) {
    final isSelected = selectedTab == tabKey;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          SoundEngine().playClick();
          setState(() => selectedTab = tabKey);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.playfulPurple : const Color(0xFFF3E8FF),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.playfulPurple.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : const Color(0xFF7E22CE),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVowelsContent() {
    final currentData = AppData.vowels[activeVowel]!;

    return Column(
      children: [
        // 5 Big Vowel Buttons (A, I, U, E, O)
        Row(
          children: ['A', 'I', 'U', 'E', 'O'].map((vowel) {
            final isSelected = activeVowel == vowel;
            final vColor = AppData.vowels[vowel]!['color'] as Color;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: BouncyCard(
                  onTap: () => _tapVowel(vowel),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected ? vColor : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: vColor, width: isSelected ? 3 : 2),
                      boxShadow: [
                        BoxShadow(
                          color: vColor.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        vowel,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: isSelected ? Colors.white : vColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // Display Box
        Expanded(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFFD8B4FE), width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.playfulPurple.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  currentData['emoji'] as String,
                  style: const TextStyle(fontSize: 80),
                ),
                const SizedBox(height: 12),
                Text(
                  '$activeVowel - ${currentData['word']}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF7E22CE),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ejaan: "${(currentData['syl'] as List<String>).join('... ')}... ${currentData['word']}!"',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.playfulPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    elevation: 3,
                  ),
                  icon: const Text('🔊', style: TextStyle(fontSize: 16)),
                  label: const Text('Eja Lagi Perlahan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  onPressed: () => _tapVowel(activeVowel),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWordsContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 600 ? 4 : 2;

        return GridView.builder(
          padding: const EdgeInsets.only(bottom: 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.15,
          ),
          itemCount: AppData.basicWords.length,
          itemBuilder: (context, index) {
            final item = AppData.basicWords[index];

            return BouncyCard(
              onTap: () => _tapBasicWord(item),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: item.color, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: item.color.withOpacity(0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item.emoji, style: const TextStyle(fontSize: 34)),
                    const SizedBox(height: 4),
                    Text(
                      item.word,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: item.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.syllables.join(' - '),
                        style: TextStyle(
                          fontSize: 10,
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

  Widget _buildAlphabetContent() {
    final alphabet = List.generate(26, (i) => String.fromCharCode(65 + i));

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 600 ? 8 : 5;

        return GridView.builder(
          padding: const EdgeInsets.only(bottom: 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.0,
          ),
          itemCount: alphabet.length,
          itemBuilder: (context, index) {
            final letter = alphabet[index];

            return BouncyCard(
              onTap: () => _tapLetter(letter),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFC084FC), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.playfulPurple.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    letter,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF7E22CE),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
