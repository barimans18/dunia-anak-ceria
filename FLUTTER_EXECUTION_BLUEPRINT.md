# 🚀 PANDUAN EKSEKUSI FLUTTER: DUNIA ANAK CERIA (KIDS LAUNCHER)

Dokumen ini berisi arsitektur teknis dan **Master Prompt** siap pakai untuk mengubah prototipe web "Dunia Anak Ceria" menjadi aplikasi **Flutter Native Kiosk Launcher** untuk Android (HP & Tablet) dan iPadOS.

---

## 📋 BAGIAN 1: MASTER PROMPT (Copy-Paste Langsung ke AI Coder)

> **Instruksi Penggunaan:** Salin seluruh teks di dalam kotak prompt di bawah ini ke tool AI seperti Claude, Cursor, ChatGPT, atau Windsurf.

```text
Bertindaklah sebagai Senior Flutter Engineer spesialis Kids Educational Apps & Custom Android Kiosk Launcher.

Saya ingin membuat aplikasi Flutter lengkap bernama "Dunia Anak Ceria", sebuah aplikasi Kids Launcher edukasi interaktif untuk anak usia 1-5 tahun (Offline-First). Aplikasi ini berjalan responsif di Mobile (Portrait) dan Tablet/iPad (Portrait & Landscape).

### 1. KEBUTUHAN UTAMA APLIKASI:
1. Berfungsi sebagai Android Default Home Launcher (Kiosk Mode). Tombol Home perangkat mengarah kembali ke aplikasi ini.
2. Terdapat Parental Gate (Pin / Soal Matematika teks sederhana) untuk mengakses Pengaturan Kiosk atau keluar ke launcher sistem.
3. Offline-First 100%: Semua audio efek suara hewan, kendaraan, dan pelafalan suku kata lambat tersimpan di local assets atau disintesis lokal (tts).
4. Tata Letak Edukasi (Stage Card Pattern):
   - Atas: Kartu Besar Interaktif yang menampilkan objek terpilih (Animasi bounce, ejaan suku kata berjeda pelan, tombol suara asli, tombol eja).
   - Bawah: Grid 2 kolom (Mobile) atau 4 kolom (Tablet) untuk daftar objek lainnya.
5. Modul yang Harus Ada:
   - Sahabat Satwa (16 Hewan)
   - Kendaraan Hebat (12 Transportasi)
   - Buah & Warna (12 Buah)
   - Belajar Membaca & Eja (Vokal, Kata Dasar, Alfabet A-Z)
   - Ayo Berhitung Balon (1-10)
   - Studio Tirukan Suara (Perekam audio lokal + pitch shifting lucu)
   - Kartun Interaktif (Custom canvas interaktif sentuh siang/malam, hujan, mobil, balon udara)

### 2. TEKNOLOGI & DEPENDENCIES:
- State Management: Riverpod atau Flutter BLoC
- Audio Playback: just_audio atau audioplayers
- Audio Record: record (dengan izin audio lokal)
- Text-to-Speech: flutter_tts (rate 0.35 - 0.40 agar sangat lambat dan ramah balita)
- Icon Launcher: flutter_launcher_icons
- Responsiveness: ResponsiveLayout / LayoutBuilder (Breakpoint Mobile < 600dp, Tablet >= 600dp)
- Fonts: Google Fonts Fredoka & Nunito

Tolong buatkan:
1. Konfigurasi `android/app/src/main/AndroidManifest.xml` lengkap dengan filter HOME launcher dan lock screen flags.
2. Konfigurasi `pubspec.yaml` lengkap dengan konfigurasi assets dan `flutter_launcher_icons`.
3. Arsitektur folder modular (Clean Architecture: core, features, shared).
4. Widget ResponsiveStageLayout yang mengimplementasikan layout: Kartu Besar di atas + Grid di bawah.
5. SoundEngine service yang menangani pemutaran suara SFX dan TTS suku kata berjeda lambat.
```

---

## 🛠️ BAGIAN 2: KONFIGURASI `pubspec.yaml`

Gunakan konfigurasi berikut untuk dependensi, aset, dan ikon aplikasi:

```yaml
name: dunia_anak_ceria
description: "Interactive Kids Launcher & Learning App for 1-5 Years Old"
publish_to: "none"
version: 1.0.0+1

environment:
  sdk: ">=3.2.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # Audio & Multimedia
  audioplayers: ^6.0.0
  flutter_tts: ^4.2.0
  record: ^5.1.2
  path_provider: ^2.1.3

  # UI, Fonts & Responsiveness
  google_fonts: ^6.2.1
  flutter_svg: ^2.0.10+1
  lottie: ^3.1.2

  # State Management & Storage
  flutter_riverpod: ^2.5.1
  shared_preferences: ^2.2.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  flutter_launcher_icons: ^0.13.1

# Konfigurasi Auto-Generate App Icon
flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/icons/app_icon.png"
  min_sdk_android: 21
  adaptive_icon_background: "#FBBF24" # Kuning Ceria
  adaptive_icon_foreground: "assets/icons/app_icon_foreground.png"

flutter:
  uses-material-design: true

  assets:
    - assets/icons/
    - assets/audio/sfx/
    - assets/audio/animals/
    - assets/audio/vehicles/
    - assets/images/animals/
    - assets/images/vehicles/
    - assets/images/fruits/
```

---

## 📱 BAGIAN 3: KONFIGURASI ANDROID MANIFEST (HOME LAUNCHER KIOSK)

Agar aplikasi dapat dijadikan **Default Home Screen (Launcher)** saat anak menekan tombol Home perangkat, tambahkan filter kategori `HOME` dan `DEFAULT` pada `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />

    <application
        android:label="Dunia Ceria"
        android:name="${applicationName}"
        android:icon="@mipmap/launcher_icon">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTask"
            android:clearTaskOnLaunch="true"
            android:stateNotNeeded="true"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                
                <!-- Menjadikan Launcher Utama HP / Tablet -->
                <category android:name="android.intent.category.HOME" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
```

---

## 🎨 BAGIAN 4: PANDUAN ASET & SPESIFIKASI ICON LAUNCHER

### 1. Struktur Folder Aset
```text
assets/
├── icons/
│   ├── app_icon.png                  # 1024x1024 px (Full Icon)
│   └── app_icon_foreground.png       # 512x512 px (Bintang / Singa Lucu transparan)
├── audio/
│   ├── sfx/                          # pop.mp3, win_star.mp3, click.mp3
│   ├── animals/                      # cat.mp3, dog.mp3, cow.mp3, lion.mp3, dll.
│   └── vehicles/                     # car_horn.mp3, fire_truck.mp3, train.mp3, dll.
└── images/
    ├── animals/                      # cat.png/svg, cow.png/svg, dll.
    ├── vehicles/                     # car.png/svg, bus.png/svg, dll.
    └── fruits/                       # apple.png/svg, banana.png/svg, dll.
```

### 2. Perintah Eksekusi Generate Icon
Setelah menaruh file `assets/icons/app_icon.png`:
```bash
flutter pub get
dart run flutter_launcher_icons
```

---

## 📐 BAGIAN 5: ADAPTASI LAYOUT (MOBILE VS TABLET)

Konsep tata letak **Stage Card Pattern** (Kartu Besar di atas + Grid di bawah) disesuaikan untuk layar HP dan Tablet:

| Parameter | Mobile (< 600dp) | Tablet Portrait (600–900dp) | Tablet Landscape (> 900dp) |
|---|---|---|---|
| **Panggung Utama (Atas)** | Tinggi ~35-40% layar | Tinggi ~40% layar | Panel Kiri (50% lebar layar) |
| **Grid List (Bawah)** | 2 Kolom, scroll vertikal | 3 atau 4 Kolom | Panel Kanan (50% lebar layar, 2-3 kolom) |
| **Ukuran Font Nama** | `text-xl` (20-22sp) | `text-3xl` (28-32sp) | `text-3xl` (32sp) |
| **Target Sentuh Tombol** | Minimal 48x48 dp | Minimal 64x64 dp | Minimal 64x64 dp |

### Contoh Snippet Responsive Layout di Flutter:
```dart
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final isTabletLandscape = constraints.maxWidth >= 900;
      final isTabletPortrait = constraints.maxWidth >= 600;

      if (isTabletLandscape) {
        // Tampilan Belah Dua: Kiri Panggung Interaktif, Kanan Grid Pilihan
        return Row(
          children: [
            Expanded(flex: 5, child: InteractiveStageCard(item: selectedItem)),
            Expanded(flex: 5, child: ItemsGrid(crossAxisCount: 3)),
          ],
        );
      }

      // Tampilan Mobile & Tablet Portrait: Atas Panggung, Bawah Grid
      return Column(
        children: [
          Expanded(flex: isTabletPortrait ? 4 : 5, child: InteractiveStageCard(item: selectedItem)),
          Expanded(flex: isTabletPortrait ? 6 : 5, child: ItemsGrid(crossAxisCount: isTabletPortrait ? 4 : 2)),
        ],
      );
    },
  );
}
```

---

## 🔊 BAGIAN 6: LOGIKA FONIK LAMBAT (AUDIO & TTS ENGINE)

Pada Flutter, buat service suara agar suku kata dieja perlahan sesuai kebutuhan anak 1-5 tahun:

```dart
class PhonicsAudioService {
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _player = AudioPlayer();

  Future<void> init() async {
    await _tts.setLanguage("id-ID");
    await _tts.setSpeechRate(0.36); // Sangat pelan & ramah balita
    await _tts.setPitch(1.2);       // Nada ceria
  }

  // Eja suku kata dengan jeda natural
  Future<void> spellSyllables(List<String> syllables, String fullWord) async {
    for (String syl in syllables) {
      await _tts.speak(syl);
      await Future.delayed(const Duration(milliseconds: 650));
    }
    await Future.delayed(const Duration(milliseconds: 300));
    await _tts.speak(fullWord);
  }

  // Putar SFX Hewan/Kendaraan
  Future<void> playSfx(String assetPath) async {
    await _player.play(AssetSource(assetPath));
  }
}
```