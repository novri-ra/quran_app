import 'dart:io';

import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

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

  // Menandai URL audio sebagai sudah diunduh dengan menyimpan hanya NAMA FILE (relative path)
  Future<void> markAudioAsDownloaded(String audioUrl, String fileName) async {
    await _downloadBox.put(audioUrl, fileName);
  }

  // Memeriksa apakah audio sudah ada di penyimpanan lokal
  // Mengembalikan path absolut, atau null jika belum diunduh (atau file fisik tidak ada)
  Future<String?> getDownloadedAudioPath(String audioUrl) async {
    String? fileName = _downloadBox.get(audioUrl);
    if (fileName != null) {
      // Rekonstruksi path absolut setiap kali dipanggil (mencegah error storage berubah)
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String fullPath = '${appDocDir.path}/$fileName';

      // Jika file mentah ada, kembalikan, kalau tidak null (berarti file terhapus di luar aplikasi)
      if (File(fullPath).existsSync()) {
        return fullPath;
      } else {
        // Hapus dari caching jika file fisik hilang
        await _downloadBox.delete(audioUrl);
        return null;
      }
    }
    return null;
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
