import 'package:flutter/material.dart';

class EduItem {
  final String id;
  final String name;
  final String soundText;
  final String emoji;
  final List<String> syllables;
  final String description;
  final Color primaryColor;
  final Color borderColor;
  final String soundAsset;

  const EduItem({
    required this.id,
    required this.name,
    required this.soundText,
    required this.emoji,
    required this.syllables,
    required this.description,
    required this.primaryColor,
    required this.borderColor,
    required this.soundAsset,
  });
}

class FruitItem {
  final String name;
  final String colorName;
  final String emoji;
  final String taste;
  final List<String> syllables;
  final Color color;

  const FruitItem({
    required this.name,
    required this.colorName,
    required this.emoji,
    required this.taste,
    required this.syllables,
    required this.color,
  });
}

class BasicWordItem {
  final String word;
  final List<String> syllables;
  final String emoji;
  final Color color;

  const BasicWordItem({
    required this.word,
    required this.syllables,
    required this.emoji,
    required this.color,
  });
}

class AppData {
  // 16 Sahabat Satwa
  static const List<EduItem> animals = [
    EduItem(
      id: 'cat',
      name: 'Kucing',
      soundText: 'Mee-oong!',
      emoji: '🐱',
      syllables: ['Ku', 'cing'],
      description: 'Kucing suka dielus lembut dan suka makan ikan.',
      primaryColor: Color(0xFFF59E0B),
      borderColor: Color(0xFFFBBF24),
      soundAsset: 'audio/animals/cat.wav',
    ),
    EduItem(
      id: 'dog',
      name: 'Anjing',
      soundText: 'Guk-guk!',
      emoji: '🐶',
      syllables: ['An', 'jing'],
      description: 'Anjing setia dan suka bermain lempar bola.',
      primaryColor: Color(0xFFFB923C),
      borderColor: Color(0xFFF97316),
      soundAsset: 'audio/animals/dog.wav',
    ),
    EduItem(
      id: 'cow',
      name: 'Sapi',
      soundText: 'Mooo-ww!',
      emoji: '🐮',
      syllables: ['Sa', 'pi'],
      description: 'Sapi menghasilkan susu segar yang sehat dan lezat.',
      primaryColor: Color(0xFF10B981),
      borderColor: Color(0xFF34D399),
      soundAsset: 'audio/animals/cow.wav',
    ),
    EduItem(
      id: 'sheep',
      name: 'Domba',
      soundText: 'Mbeeek!',
      emoji: '🐑',
      syllables: ['Dom', 'ba'],
      description: 'Domba memiliki bulu wol putih yang tebal dan hangat.',
      primaryColor: Color(0xFF38BDF8),
      borderColor: Color(0xFF0284C7),
      soundAsset: 'audio/animals/sheep.wav',
    ),
    EduItem(
      id: 'horse',
      name: 'Kuda',
      soundText: 'Hii-haaa!',
      emoji: '🐴',
      syllables: ['Ku', 'da'],
      description: 'Kuda berlari sangat kencang di padang rumput hijau.',
      primaryColor: Color(0xFFD97706),
      borderColor: Color(0xFFF59E0B),
      soundAsset: 'audio/animals/horse.wav',
    ),
    EduItem(
      id: 'duck',
      name: 'Bebek',
      soundText: 'Kwek-kwek!',
      emoji: '🦆',
      syllables: ['Be', 'bek'],
      description: 'Bebek berenang lincah di danau bersama teman-temannya.',
      primaryColor: Color(0xFFEAB308),
      borderColor: Color(0xFFCA8A04),
      soundAsset: 'audio/animals/duck.wav',
    ),
    EduItem(
      id: 'lion',
      name: 'Singa',
      soundText: 'Rrr-oaar!',
      emoji: '🦁',
      syllables: ['Si', 'nga'],
      description: 'Singa adalah raja hutan berbulu lebat yang gagah.',
      primaryColor: Color(0xFFEF4444),
      borderColor: Color(0xFFDC2626),
      soundAsset: 'audio/animals/lion.wav',
    ),
    EduItem(
      id: 'tiger',
      name: 'Harimau',
      soundText: 'Graaa-wrr!',
      emoji: '🐯',
      syllables: ['Ha', 'ri', 'mau'],
      description: 'Harimau bertubuh loreng jingga yang lincah dan kuat.',
      primaryColor: Color(0xFFEA580C),
      borderColor: Color(0xFFC2410C),
      soundAsset: 'audio/animals/tiger.wav',
    ),
    EduItem(
      id: 'rooster',
      name: 'Ayam',
      soundText: 'Kukuruyuk!',
      emoji: '🐓',
      syllables: ['A', 'yam'],
      description: 'Ayam berkokok menyambut sinar matahari pagi yang cerah.',
      primaryColor: Color(0xFFF43F5E),
      borderColor: Color(0xFFE11D48),
      soundAsset: 'audio/animals/rooster.wav',
    ),
    EduItem(
      id: 'elephant',
      name: 'Gajah',
      soundText: 'Trompet Belalai!',
      emoji: '🐘',
      syllables: ['Ga', 'jah'],
      description:
          'Gajah bertubuh sangat besar dengan telinga lebar dan belalai.',
      primaryColor: Color(0xFF6366F1),
      borderColor: Color(0xFF4F46E5),
      soundAsset: 'audio/animals/elephant.wav',
    ),
    EduItem(
      id: 'frog',
      name: 'Katak',
      soundText: 'Kwekk-kwekk!',
      emoji: '🐸',
      syllables: ['Ka', 'tak'],
      description: 'Katak hijau melompat riang di atas daun teratai.',
      primaryColor: Color(0xFF14B8A6),
      borderColor: Color(0xFF0D9488),
      soundAsset: 'audio/animals/frog.wav',
    ),
    EduItem(
      id: 'monkey',
      name: 'Monyet',
      soundText: 'Uu-aa-aa!',
      emoji: '🐵',
      syllables: ['Mon', 'yet'],
      description:
          'Monyet suka bergelantungan di dahan pohon dan makan pisang.',
      primaryColor: Color(0xFFB45309),
      borderColor: Color(0xFF92400E),
      soundAsset: 'audio/animals/monkey.wav',
    ),
    EduItem(
      id: 'rabbit',
      name: 'Kelinci',
      soundText: 'Hop-hop!',
      emoji: '🐰',
      syllables: ['Ke', 'lin', 'ci'],
      description: 'Kelinci imut bertelinga panjang yang gemar makan wortel.',
      primaryColor: Color(0xFFEC4899),
      borderColor: Color(0xFFDB2777),
      soundAsset: 'audio/animals/rabbit.wav',
    ),
    EduItem(
      id: 'bee',
      name: 'Lebah',
      soundText: 'Bzzz-bzzz!',
      emoji: '🐝',
      syllables: ['Le', 'bah'],
      description:
          'Lebah mungil rajin mengumpulkan nektar bunga untuk membuat madu.',
      primaryColor: Color(0xFFFACC15),
      borderColor: Color(0xFFEAB308),
      soundAsset: 'audio/animals/bee.wav',
    ),
    EduItem(
      id: 'owl',
      name: 'Burung Hantu',
      soundText: 'Hu-huuu!',
      emoji: '🦉',
      syllables: ['Bu', 'rung', 'Han', 'tu'],
      description:
          'Burung hantu memiliki mata bulat besar dan melihat di malam hari.',
      primaryColor: Color(0xFF8B5CF6),
      borderColor: Color(0xFF7C3AED),
      soundAsset: 'audio/animals/owl.wav',
    ),
    EduItem(
      id: 'dolphin',
      name: 'Lumba-lumba',
      soundText: 'Siulan Air!',
      emoji: '🐬',
      syllables: ['Lum', 'ba'],
      description:
          'Lumba-lumba sahabat laut yang cerdas dan gemar melompat tinggi.',
      primaryColor: Color(0xFF06B6D4),
      borderColor: Color(0xFF0891B2),
      soundAsset: 'audio/animals/dolphin.wav',
    ),
  ];

  // 13 Kendaraan Hebat
  static const List<EduItem> vehicles = [
    EduItem(
      id: 'car',
      name: 'Mobil',
      soundText: 'Tin-tiinn!',
      emoji: '🚗',
      syllables: ['Mo', 'bil'],
      description: 'Mobil beroda empat melaju mengantar keluarga jalan-jalan.',
      primaryColor: Color(0xFF38BDF8),
      borderColor: Color(0xFF0284C7),
      soundAsset: 'audio/vehicles/car.wav',
    ),
    EduItem(
      id: 'motorcycle',
      name: 'Motor',
      soundText: 'Ngeeeng-ngeeeng!',
      emoji: '🏍️',
      syllables: ['Mo', 'tor'],
      description: 'Sepeda motor beroda dua yang lincah melaju di jalan raya.',
      primaryColor: Color(0xFF0EA5E9),
      borderColor: Color(0xFF0284C7),
      soundAsset: 'audio/vehicles/motorcycle.wav',
    ),
    EduItem(
      id: 'fire',
      name: 'Pemadam',
      soundText: 'Wiuu-wiuu!',
      emoji: '🚒',
      syllables: ['Pe', 'ma', 'dam'],
      description: 'Mobil pemadam sigap memadamkan kobaran api berbahaya.',
      primaryColor: Color(0xFFEF4444),
      borderColor: Color(0xFFDC2626),
      soundAsset: 'audio/vehicles/fire.wav',
    ),
    EduItem(
      id: 'ambulance',
      name: 'Ambulans',
      soundText: 'Ninoo-ninoo!',
      emoji: '🚑',
      syllables: ['Am', 'bu', 'lans'],
      description: 'Membawa orang yang sakit bergegas cepat ke rumah sakit.',
      primaryColor: Color(0xFFF43F5E),
      borderColor: Color(0xFFBE123C),
      soundAsset: 'audio/vehicles/ambulance.wav',
    ),
    EduItem(
      id: 'bus',
      name: 'Bus Sekolah',
      soundText: 'Din-dinn!',
      emoji: '🚌',
      syllables: ['Bus', 'Se', 'ko', 'lah'],
      description: 'Mengantar anak-anak riang gembira pergi ke sekolah.',
      primaryColor: Color(0xFFFBBF24),
      borderColor: Color(0xFFF59E0B),
      soundAsset: 'audio/vehicles/bus.wav',
    ),
    EduItem(
      id: 'train',
      name: 'Kereta Api',
      soundText: 'Tuut-tuut!',
      emoji: '🚂',
      syllables: ['Ke', 're', 'ta'],
      description: 'Kereta api melaju kencang di atas rel besi yang panjang.',
      primaryColor: Color(0xFFF97316),
      borderColor: Color(0xFFEA580C),
      soundAsset: 'audio/vehicles/train.wav',
    ),
    EduItem(
      id: 'plane',
      name: 'Pesawat',
      soundText: 'Wuuush!',
      emoji: '✈️',
      syllables: ['Pe', 'sa', 'wat'],
      description: 'Terbang tinggi menembus awan biru mengarungi angkasa.',
      primaryColor: Color(0xFF6366F1),
      borderColor: Color(0xFF4F46E5),
      soundAsset: 'audio/vehicles/plane.wav',
    ),
    EduItem(
      id: 'rocket',
      name: 'Roket',
      soundText: 'Meluncur ke Bintang!',
      emoji: '🚀',
      syllables: ['Ro', 'ket'],
      description:
          'Meluncur ke luar angkasa menuju bulan dan bintang berkelap-kelip.',
      primaryColor: Color(0xFFA855F7),
      borderColor: Color(0xFF9333EA),
      soundAsset: 'audio/vehicles/rocket.wav',
    ),
    EduItem(
      id: 'heli',
      name: 'Helikopter',
      soundText: 'Whop-whop!',
      emoji: '🚁',
      syllables: ['He', 'li', 'kop', 'ter'],
      description:
          'Baling-baling berputar kencang mengangkat helikopter ke langit.',
      primaryColor: Color(0xFF14B8A6),
      borderColor: Color(0xFF0D9488),
      soundAsset: 'audio/vehicles/heli.wav',
    ),
    EduItem(
      id: 'ship',
      name: 'Kapal Laut',
      soundText: 'Fooog-horn!',
      emoji: '🚢',
      syllables: ['Ka', 'pal'],
      description: 'Kapal besar berlayar megah mengarungi samudera luas.',
      primaryColor: Color(0xFF0284C7),
      borderColor: Color(0xFF0369A1),
      soundAsset: 'audio/vehicles/ship.wav',
    ),
    EduItem(
      id: 'bicycle',
      name: 'Sepeda',
      soundText: 'Kring-kriing!',
      emoji: '🚲',
      syllables: ['Se', 'pe', 'da'],
      description: 'Dikayuh santai bersama teman sambil menghirup udara segar.',
      primaryColor: Color(0xFF10B981),
      borderColor: Color(0xFF059669),
      soundAsset: 'audio/vehicles/bicycle.wav',
    ),
    EduItem(
      id: 'truck',
      name: 'Truk Besar',
      soundText: 'Brum-brumm!',
      emoji: '🚚',
      syllables: ['Truk', 'Be', 'sar'],
      description:
          'Mengangkut barang-barang berbobot berat keliling antar kota.',
      primaryColor: Color(0xFFD97706),
      borderColor: Color(0xFFB45309),
      soundAsset: 'audio/vehicles/truck.wav',
    ),
    EduItem(
      id: 'tractor',
      name: 'Traktor',
      soundText: 'Puk-puk-puk!',
      emoji: '🚜',
      syllables: ['Trak', 'tor'],
      description:
          'Membantu pak tani membajak tanah sawah agar tanaman tumbuh subur.',
      primaryColor: Color(0xFF84CC16),
      borderColor: Color(0xFF65A30D),
      soundAsset: 'audio/vehicles/tractor.wav',
    ),
  ];

  // 12 Buah & Warna
  static const List<FruitItem> fruits = [
    FruitItem(
      name: 'Apel',
      colorName: 'Merah',
      emoji: '🍎',
      taste: 'Manis dan Segar!',
      syllables: ['A', 'pel'],
      color: Color(0xFFEF4444),
    ),
    FruitItem(
      name: 'Pisang',
      colorName: 'Kuning',
      emoji: '🍌',
      taste: 'Manis dan Lembut!',
      syllables: ['Pi', 'sang'],
      color: Color(0xFFFBBF24),
    ),
    FruitItem(
      name: 'Jeruk',
      colorName: 'Oranye',
      emoji: '🍊',
      taste: 'Segar Kaya Vitamin C!',
      syllables: ['Je', 'ruk'],
      color: Color(0xFFF97316),
    ),
    FruitItem(
      name: 'Semangka',
      colorName: 'Hijau Merah',
      emoji: '🍉',
      taste: 'Banyak Airnya Segar!',
      syllables: ['Se', 'mang', 'ka'],
      color: Color(0xFF10B981),
    ),
    FruitItem(
      name: 'Anggur',
      colorName: 'Ungu',
      emoji: '🍇',
      taste: 'Kecil Manis Enak!',
      syllables: ['Ang', 'gur'],
      color: Color(0xFFA855F7),
    ),
    FruitItem(
      name: 'Stroberi',
      colorName: 'Merah Cerah',
      emoji: '🍓',
      taste: 'Asam Manis Segar!',
      syllables: ['Stro', 'be', 'ri'],
      color: Color(0xFFEC4899),
    ),
    FruitItem(
      name: 'Mangga',
      colorName: 'Kuning Harum',
      emoji: '🥭',
      taste: 'Manis Harum Sekali!',
      syllables: ['Mang', 'ga'],
      color: Color(0xFFEAB308),
    ),
    FruitItem(
      name: 'Nanas',
      colorName: 'Kuning Bersisik',
      emoji: '🍍',
      taste: 'Manis Asam Segar!',
      syllables: ['Na', 'nas'],
      color: Color(0xFFD97706),
    ),
    FruitItem(
      name: 'Pepaya',
      colorName: 'Jingga',
      emoji: '🍈',
      taste: 'Manis dan Sehat untuk Perut!',
      syllables: ['Pe', 'pa', 'ya'],
      color: Color(0xFFFB923C),
    ),
    FruitItem(
      name: 'Alpukat',
      colorName: 'Hijau Krim',
      emoji: '🥑',
      taste: 'Lembut Bergizi Tinggi!',
      syllables: ['Al', 'pu', 'kat'],
      color: Color(0xFF16A34A),
    ),
    FruitItem(
      name: 'Ceri',
      colorName: 'Merah Merona',
      emoji: '🍒',
      taste: 'Kecil Manis Cantik!',
      syllables: ['Ce', 'ri'],
      color: Color(0xFFE11D48),
    ),
    FruitItem(
      name: 'Melon',
      colorName: 'Hijau Muda',
      emoji: '🍈',
      taste: 'Wangi dan Dingin Manis!',
      syllables: ['Me', 'lon'],
      color: Color(0xFF14B8A6),
    ),
  ];

  // Kata Dasar Membaca
  static const List<BasicWordItem> basicWords = [
    BasicWordItem(
        word: 'BOLA',
        syllables: ['Bo', 'la'],
        emoji: '⚽',
        color: Color(0xFF38BDF8)),
    BasicWordItem(
        word: 'BUKU',
        syllables: ['Bu', 'ku'],
        emoji: '📚',
        color: Color(0xFF10B981)),
    BasicWordItem(
        word: 'IBU',
        syllables: ['I', 'bu'],
        emoji: '👩',
        color: Color(0xFFEC4899)),
    BasicWordItem(
        word: 'BABA',
        syllables: ['Ba', 'ba'],
        emoji: '👨',
        color: Color(0xFF6366F1)),
    BasicWordItem(
        word: 'SUSU',
        syllables: ['Su', 'su'],
        emoji: '🥛',
        color: Color(0xFFF59E0B)),
    BasicWordItem(
        word: 'ROTI',
        syllables: ['Ro', 'ti'],
        emoji: '🍞',
        color: Color(0xFFF97316)),
    BasicWordItem(
        word: 'TOPI',
        syllables: ['To', 'pi'],
        emoji: '🧢',
        color: Color(0xFF14B8A6)),
    BasicWordItem(
        word: 'MEJA',
        syllables: ['Me', 'ja'],
        emoji: '🪑',
        color: Color(0xFFA855F7)),
  ];

  // Huruf Vokal
  static const Map<String, Map<String, dynamic>> vowels = {
    'A': {
      'word': 'Apel',
      'emoji': '🍎',
      'syl': ['A', 'pel'],
      'color': Color(0xFFEF4444)
    },
    'I': {
      'word': 'Ikan',
      'emoji': '🐟',
      'syl': ['I', 'kan'],
      'color': Color(0xFF38BDF8)
    },
    'U': {
      'word': 'Udang',
      'emoji': '🦐',
      'syl': ['U', 'dang'],
      'color': Color(0xFF10B981)
    },
    'E': {
      'word': 'Elang',
      'emoji': '🦅',
      'syl': ['E', 'lang'],
      'color': Color(0xFFF59E0B)
    },
    'O': {
      'word': 'Obat',
      'emoji': '💊',
      'syl': ['O', 'bat'],
      'color': Color(0xFFA855F7)
    },
  };

  // Angka 1-10
  static const List<String> numberWords = [
    '',
    'Satu',
    'Dua',
    'Tiga',
    'Empat',
    'Lima',
    'Enam',
    'Tujuh',
    'Delapan',
    'Sembilan',
    'Sepuluh'
  ];

  static const List<List<String>> numberSyllables = [
    [],
    ['Sa', 'tu'],
    ['Du', 'a'],
    ['Ti', 'ga'],
    ['Em', 'pat'],
    ['Li', 'ma'],
    ['E', 'nam'],
    ['Tu', 'juh'],
    ['De', 'la', 'pan'],
    ['Sem', 'bi', 'lan'],
    ['Se', 'pu', 'luh'],
  ];

  // 8 Aktivitas Harian (Daily Routines & Kemandirian)
  static const List<EduItem> routines = [
    EduItem(
      id: 'makan',
      name: 'Makan',
      soundText: 'Nyam-nyam! 🍲',
      emoji: '🍲',
      syllables: ['Ma', 'kan'],
      description: 'Makan makanan sehat bergizi agar tubuh kuat dan pintar.',
      primaryColor: Color(0xFFF59E0B),
      borderColor: Color(0xFFFBBF24),
      soundAsset: 'audio/routines/eating.wav',
    ),
    EduItem(
      id: 'minum',
      name: 'Minum',
      soundText: 'Gluk-gluk! 🥛',
      emoji: '🥛',
      syllables: ['Mi', 'num'],
      description:
          'Minum air putih segar secara teratur agar badan selalu segar.',
      primaryColor: Color(0xFF38BDF8),
      borderColor: Color(0xFF0284C7),
      soundAsset: 'audio/routines/drinking.wav',
    ),
    EduItem(
      id: 'pipis',
      name: 'Pipis',
      soundText: 'Syuuur-flush! 🚽',
      emoji: '🚽',
      syllables: ['Pi', 'pis'],
      description:
          'Beri tahu Ayah & Bunda saat mau pipis di toilet kamar mandi.',
      primaryColor: Color(0xFF06B6D4),
      borderColor: Color(0xFF0891B2),
      soundAsset: 'audio/routines/pee.wav',
    ),
    EduItem(
      id: 'pup',
      name: 'Pupup',
      soundText: 'Plung-splash! 🧻',
      emoji: '🧻',
      syllables: ['Pu', 'pup'],
      description:
          'Duduk nyaman di kloset lalu bersihkan hingga tuntas dan bersih.',
      primaryColor: Color(0xFFD97706),
      borderColor: Color(0xFFB45309),
      soundAsset: 'audio/routines/poop.wav',
    ),
    EduItem(
      id: 'mandi',
      name: 'Mandi',
      soundText: 'Kwek-byuuur! 🛁',
      emoji: '🛁',
      syllables: ['Man', 'di'],
      description:
          'Mandi air sejuk pakai sabun wangi dan bebek karet yang riang.',
      primaryColor: Color(0xFF10B981),
      borderColor: Color(0xFF059669),
      soundAsset: 'audio/routines/bath.wav',
    ),
    EduItem(
      id: 'sikat_gigi',
      name: 'Sikat Gigi',
      soundText: 'Gosok-gosok! 🪥',
      emoji: '🪥',
      syllables: ['Si', 'kat', 'Gi', 'gi'],
      description:
          'Sikat gigi pagi hari dan malam sebelum tidur agar gigi sehat putih.',
      primaryColor: Color(0xFF8B5CF6),
      borderColor: Color(0xFF7C3AED),
      soundAsset: 'audio/routines/brush_teeth.wav',
    ),
    EduItem(
      id: 'cuci_tangan',
      name: 'Cuci Tangan',
      soundText: 'Gemericik air! 🧼',
      emoji: '🧼',
      syllables: ['Cu', 'ci', 'Ta', 'ngan'],
      description:
          'Bilas tangan pakai sabun setelah main agar kuman hilang bersih.',
      primaryColor: Color(0xFF14B8A6),
      borderColor: Color(0xFF0D9488),
      soundAsset: 'audio/routines/wash_hands.wav',
    ),
    EduItem(
      id: 'bobo',
      name: 'Bobo',
      soundText: 'Lullaby lembut... 🛌',
      emoji: '🛌',
      syllables: ['Bo', 'bo'],
      description:
          'Bobo nyenyak tepat waktu agar mimpi indah dan bangun bugar.',
      primaryColor: Color(0xFF6366F1),
      borderColor: Color(0xFF4F46E5),
      soundAsset: 'audio/routines/sleep.wav',
    ),
  ];

  // 8 Ekspresi & Emosi (Expressions & Feelings)
  static const List<EduItem> emotions = [
    EduItem(
      id: 'senang',
      name: 'Senang',
      soundText: 'Hahaha ceria! 😄',
      emoji: '😄',
      syllables: ['Se', 'nang'],
      description:
          'Senyum mengembang ceria, hati gembira bermain bersama teman!',
      primaryColor: Color(0xFFF59E0B),
      borderColor: Color(0xFFFBBF24),
      soundAsset: 'audio/emotions/happy.wav',
    ),
    EduItem(
      id: 'sedih',
      name: 'Sedih',
      soundText: 'Huhu... peluk ya 🥺',
      emoji: '🥺',
      syllables: ['Se', 'dih'],
      description: 'Tak apa merasa sedih, peluk Ayah & Bunda agar hati tenang.',
      primaryColor: Color(0xFF38BDF8),
      borderColor: Color(0xFF0284C7),
      soundAsset: 'audio/emotions/sad.wav',
    ),
    EduItem(
      id: 'marah',
      name: 'Marah',
      soundText: 'Tarik napas lega... 😤',
      emoji: '😤',
      syllables: ['Ma', 'rah'],
      description:
          'Saat kesal, hembuskan napas pelan seperti meniup lilin lembut.',
      primaryColor: Color(0xFFEF4444),
      borderColor: Color(0xFFDC2626),
      soundAsset: 'audio/emotions/angry.wav',
    ),
    EduItem(
      id: 'kaget',
      name: 'Kaget',
      soundText: 'Wah, o-oh! 😲',
      emoji: '😲',
      syllables: ['Ka', 'get'],
      description:
          'Ada kejutan seru yang membuat mata dan mulut membulat heran!',
      primaryColor: Color(0xFFF97316),
      borderColor: Color(0xFFEA580C),
      soundAsset: 'audio/emotions/surprised.wav',
    ),
    EduItem(
      id: 'takut',
      name: 'Takut',
      soundText: 'Deg-deg... aman kok! 🫣',
      emoji: '🫣',
      syllables: ['Ta', 'kut'],
      description:
          'Ada Ayah & Bunda yang selalu menjagamu, kamu anak pemberani!',
      primaryColor: Color(0xFF8B5CF6),
      borderColor: Color(0xFF7C3AED),
      soundAsset: 'audio/emotions/scared.wav',
    ),
    EduItem(
      id: 'sayang',
      name: 'Sayang',
      soundText: 'Muach! Sayang kamu! 🥰',
      emoji: '🥰',
      syllables: ['Sa', 'yang'],
      description:
          'Peluk hangat penuh kasih untuk mama, papa, dan sahabat tersayang.',
      primaryColor: Color(0xFFEC4899),
      borderColor: Color(0xFFDB2777),
      soundAsset: 'audio/emotions/love.wav',
    ),
    EduItem(
      id: 'mengantuk',
      name: 'Mengantuk',
      soundText: 'Hoaaam... ngantuk 🥱',
      emoji: '🥱',
      syllables: ['Ngan', 'tuk'],
      description:
          'Mata terasa berat dan menguap lucu, saatnya istirahat tidur.',
      primaryColor: Color(0xFF6366F1),
      borderColor: Color(0xFF4F46E5),
      soundAsset: 'audio/emotions/sleepy.wav',
    ),
    EduItem(
      id: 'hebat',
      name: 'Hebat',
      soundText: 'Horeee, berhasil! 🥳',
      emoji: '🥳',
      syllables: ['He', 'bat'],
      description:
          'Horeee! Aku berhasil melakukannya sendiri, aku bangga dan hebat!',
      primaryColor: Color(0xFF10B981),
      borderColor: Color(0xFF059669),
      soundAsset: 'audio/emotions/proud.wav',
    ),
  ];
}
