import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/storage/storage_service.dart';

class ThemeController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  // State tema saat ini
  var isDarkMode = false.obs;

  // State tipografi untuk opsi font
  var arabicFontSize = 26.0.obs;
  var latinFontSize = 14.0.obs;
  var arabicFontFamily = 'Nabi'.obs;

  @override
  void onInit() {
    super.onInit();
    // Muat preferensi tema yang tersimpan saat controller diinisialisasi
    isDarkMode.value = _storageService.isDarkMode();

    // Muat pengaturan ukuran font Arab
    arabicFontSize.value = _storageService.getArabicFontSize();

    // Muat pengaturan ukuran font Latin & Terjemahan
    latinFontSize.value = _storageService.getLatinFontSize();

    // Muat preferensi jenis font Arab
    arabicFontFamily.value = _storageService.getArabicFontFamily();
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    // GetX menangani perubahan tema secara langsung ke MaterialApp
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    // Simpan ke Hive
    _storageService.saveThemeMode(isDarkMode.value);
  }

  void changeArabicFontSize(double size) {
    arabicFontSize.value = size;
    _storageService.saveArabicFontSize(size);
  }

  void changeLatinFontSize(double size) {
    latinFontSize.value = size;
    _storageService.saveLatinFontSize(size);
  }

  void changeArabicFontFamily(String family) {
    arabicFontFamily.value = family;
    _storageService.saveArabicFontFamily(family);
  }
}
