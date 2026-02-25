import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

class QuranController extends GetxController {
  // Reactive variables (State)
  var isLoading = true.obs;
  var surahList = <dynamic>[].obs; // Menyimpan data asli
  var filteredSurahList = <dynamic>[].obs; // Menyimpan data hasil pencarian
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSurahList(); // Ambil data saat controller diinisialisasi
  }

  Future<void> fetchSurahList() async {
    try {
      isLoading(true);
      errorMessage('');

      final String jsonString = await rootBundle.loadString(
        'assets/data/surat.json',
      );
      final Map<String, dynamic> response = jsonDecode(jsonString);

      if (response['code'] == 200) {
        surahList.value = response['data'] ?? [];
        filteredSurahList.value = surahList;
      } else {
        errorMessage('Gagal membaca data surat lokal.');
      }
    } catch (e) {
      errorMessage('Terjadi kesalahan: $e');
    } finally {
      isLoading(false);
    }
  }

  // Fungsi pencarian surat berdasarkan nama Latin
  void searchSurah(String query) {
    if (query.isEmpty) {
      filteredSurahList.value = surahList;
    } else {
      filteredSurahList.value = surahList.where((surah) {
        final namaLatin = surah['namaLatin'].toString().toLowerCase();
        return namaLatin.contains(query.toLowerCase());
      }).toList();
    }
  }
}
