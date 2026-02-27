# Al-Quran & Super App Ibadah 🕌✨

Aplikasi Al-Quran modern dan berfitur lengkap yang dibangun menggunakan framework **Flutter** dan **GetX** untuk State Management. Dikonsep menggunakan pendekatan arsitektur _Feature-First / Modular_, aplikasi ini tidak hanya menyediakan bacaan Al-Quran, tetapi juga terintegrasi dengan berbagai fitur ibadah harian.

## 🌟 Fitur Utama

- **📖 Bacaan Al-Quran 114 Surat**: Teks Arab kaligrafi khusus, transliterasi Latin, dan terjemahan Bahasa Indonesia.
- **🔍 Pencarian Spesifik**: Filter langsung nama surat dan nama doa dengan cepat.
- **🎧 Continuous Playback Murottal**: Putar Murottal ayat-per-ayat secara berurutan dan otomatis (_Auto-Scroll_ mengikuti ayat yang sedang dibaca).
- **💾 Offline / Cache Storage**: Audio yang sudah diunduh secara cerdas disimpan ke _Local Storage_ (Hive) menghemat bandwidth internet untuk pemutaran berikutnya.
- **🔖 Bookmark Cerdas**: Tandai ayat dan lanjutkan bacaan terakhir langsung dari _Home Screen_.
- **🤲 Kumpulan Doa & Dzikir**: Database ratusan doa harian yang mudah diakses.
- **⏰ Jadwal Shalat & Imsakiyah**: Auto-fokus menentukan wilayah (Provinsi & Kabupaten) secara berjenjang untuk mengeluarkan jadwal waktu shalat akurat _Hari ini_.
- **🌙 Tema Gelap (Dark Mode)**: Preferensi mode membaca malam yang tersimpan selamanya secara permanen.

## 🛠️ Teknologi & Dependensi

Proyek ini bersandar pada ekosistem pustaka mutakhir berikut:

- `get: ^4.6.6` - Manajemen Tampilan (State), Injeksi Dependensi (DI), & Routing (Navigation).
- `dio: ^5.4.0` - Klien HTTP handal penembak _Endpoint_ API eQuran.id.
- `just_audio: ^0.9.36` - Pemutar audio asinkron / _streaming continuous_.
- `scrollable_positioned_list: ^0.3.8` - Render daftar ribuan ayat dengan kontrol gulir (scroll) akurat.
- `hive` & `hive_flutter` - Database penyimpanan kunci-nilai (Key-Value) cepat asinkron untuk Bookmark, Theme State, dan Riwayat Cache Audio.
- `path_provider` - Akses ke path sistem _Sandbox_ milik OS (Android/iOS) guna menyimpan file `.mp3` fisik.

## 🚀 Cara Menjalankan (Clone & Build)

Proyek ini tidak menyimpan kunci rahasia rawan (_secret key_) sehingga 100% aman untuk di-_clone_ dan langsung di-_run_ (_plug-and-play_).

### Prasyarat

- [Flutter SDK](https://flutter.dev/docs/get-started/install) minimal versi `3.24.x`.
- IDE: VS Code atau Android Studio dengan ekstensi/plugin Flutter/Dart terinstal.
- Emulator Android / iOS Simulator yang sudah berjalan (atau _real device_ tercolok via USB Debugging).

### Langkah-Langkah

1. **Clone repositori** ini ke PC Anda:

   ```bash
   git clone https://github.com/novri-ra/quran_app.git
   ```

2. **Masuk ke direktori** repositori:

   ```bash
   cd quran_app
   ```

3. **_(Sangat Disarankan)_ Sinkronisasi Platform & Dependensi**:
   Jalankan perintah ini untuk memastikan konfigurasi _native_ (Android/iOS) dibuat ulang dan seluruh dependensi bawaan diunduh menyesuaikan versi OS di PC lokal Anda:

   ```bash
   flutter create . && flutter pub get
   ```

4. _(Opsional)_ Lakukan **Clean Build** apabila masih ada sisa cache lama yang memengaruhi eksekusi awal:

   ```bash
   flutter clean && flutter pub get
   ```

5. **Jalankan Aplikasi**:
   ```bash
   flutter run
   ```

## 📂 Struktur Proyek Terpenting

Menggunakan pola `Feature-First`, di mana komponen dikumpulkan berdasar spesifikasi fitur ketimbang tipenya (`/lib/` dir):

```text
lib/
├── core/                   # Utilitas tulang punggung (Network, Storage, Theme)
│   ├── network/            # Klasemen logic ApiServer (Dio client)
│   └── storage/            # Konfigurasi Hive local repository
├── modules/                # Fitur-fitur UI tunggal independen
│   ├── bookmark/
│   ├── doa/
│   ├── main_navigation/    # Skeleton aplikasi -> BottomNavigationBar & IndexedStack
│   ├── settings/
│   ├── sholat/
│   ├── surah_detail/       # Kompleksitas tinggi pemutar Audio dan scroll reaktif berada di sini
│   └── surah_list/
├── routes/                 # Konfigurator Centralized GetX Injection Controller (`app_pages.dart`)
└── main.dart               # Titik entri (Entry Point) utama (Flutter run dimulai dari sini)
```

## 🔒 Konfigurasi Keamanan (Gitignore)

File `.gitignore` telah dirancang untuk menghindari kebocoran:

1. Tidak ada arsip _Build_ dan log ter-push.
2. `.env` eksklusif diblokir (Jika di kemudian hari Anda menambahkan API _Key_ berbayar).
3. Melindungi _database cache_ `hive` (jika tidak sengaja masuk ke folder root).

## 📄 Lisensi

Al-Quran App (_Unlicensed / Open-Source_). Data teks mushaf Al-Quran, terjemahan, dan audio murottal bersumber sepenuhnya dari API publik yang disediakan oleh [EQuran.id](https://equran.id/).
