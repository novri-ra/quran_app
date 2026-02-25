import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../core/network/api_service.dart';
import '../../../core/storage/storage_service.dart';
import '../../bookmark/controllers/bookmark_controller.dart';

class SurahDetailController extends GetxController {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = Get.find<StorageService>();

  // --- Tambahan untuk Auto Scroll ---
  final ItemScrollController itemScrollController = ItemScrollController();

  var isLoading = true.obs;
  var surahDetail = {}.obs;
  var errorMessage = ''.obs;

  // Mengambil detail surat berdasarkan nomor surat
  Future<void> fetchSurahDetail(int nomorSurat) async {
    try {
      isLoading(true);
      errorMessage('');

      final response = await _apiService.getSuratDetail(nomorSurat);

      if (response.statusCode == 200) {
        surahDetail.value = response.data['data'];
      } else {
        errorMessage('Gagal memuat detail surat.');
      }
    } catch (e) {
      errorMessage('Terjadi kesalahan: $e');
    } finally {
      isLoading(false);
    }
  }

  // Menyimpan posisi bacaan terakhir ke Local Storage (Hive)
  void saveBookmark(int nomorSurat, int nomorAyat) {
    _storageService.saveLastRead(nomorSurat, nomorAyat);

    // Memberitahu BookmarkController agar me-refresh UI
    if (Get.isRegistered<BookmarkController>()) {
      Get.find<BookmarkController>().loadBookmark();
    }

    Get.snackbar(
      'Berhasil',
      'Telah ditandai sebagai terakhir dibaca',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // --- Fungsi Pemicu Auto-Scroll ---
  void scrollToAyat(int index) {
    if (itemScrollController.isAttached) {
      itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic, // Animasi scroll yang lembut
      );
    }
  }
}
