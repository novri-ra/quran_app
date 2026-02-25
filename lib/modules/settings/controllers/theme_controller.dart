import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/storage/storage_service.dart';

class ThemeController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  // State tema saat ini
  var isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Muat preferensi tema yang tersimpan saat controller diinisialisasi
    isDarkMode.value = _storageService.isDarkMode();
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    // GetX menangani perubahan tema secara langsung ke MaterialApp
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    // Simpan ke Hive
    _storageService.saveThemeMode(isDarkMode.value);
  }
}
