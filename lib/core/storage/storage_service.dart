import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StorageService extends GetxService {
  late Box _bookmarkBox;
  late Box _downloadBox;
  late Box _settingsBox;

  // Nama box untuk Hive
  static const String bookmarkBoxName = 'bookmarkBox';
  static const String downloadBoxName = 'downloadBox';
  static const String settingsBoxName = 'settingsBox';

  Future<StorageService> init() async {
    await Hive.initFlutter();
    _bookmarkBox = await Hive.openBox(bookmarkBoxName);
    _downloadBox = await Hive.openBox(downloadBoxName);
    _settingsBox = await Hive.openBox(settingsBoxName);
    return this;
  }

  // --- Fungsi Bookmark (Terakhir Dibaca) ---

  // Menyimpan map yang berisi nomor surat dan nomor ayat
  Future<void> saveLastRead(int nomorSurat, int nomorAyat) async {
    await _bookmarkBox.put('last_read', {
      'surat': nomorSurat,
      'ayat': nomorAyat,
    });
  }

  // Mengambil data terakhir dibaca
  Map<dynamic, dynamic>? getLastRead() {
    return _bookmarkBox.get('last_read');
  }

  // --- Fungsi Status Unduhan Audio ---

  // Menandai URL audio sebagai sudah diunduh
  Future<void> markAudioAsDownloaded(String audioUrl, String localPath) async {
    await _downloadBox.put(audioUrl, localPath);
  }

  // Memeriksa apakah audio sudah ada di penyimpanan lokal
  // Mengembalikan path lokal jika ada, atau null jika belum diunduh
  String? getDownloadedAudioPath(String audioUrl) {
    return _downloadBox.get(audioUrl);
  }

  // --- Fungsi Pengaturan Tema ---
  Future<void> saveThemeMode(bool isDark) async {
    await _settingsBox.put('is_dark_mode', isDark);
  }

  bool isDarkMode() {
    // Default nilai adalah false (Light Mode) jika belum pernah diset
    return _settingsBox.get('is_dark_mode', defaultValue: false);
  }
}
