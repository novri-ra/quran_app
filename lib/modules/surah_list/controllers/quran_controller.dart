import 'package:get/get.dart';

import '../../../core/network/api_service.dart';

class QuranController extends GetxController {
  final ApiService _apiService = ApiService();

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

  // Mengambil daftar surat dari EQuran.id
  Future<void> fetchSurahList() async {
    try {
      isLoading(true);
      errorMessage('');

      final response = await _apiService.getSuratList();

      if (response.statusCode == 200) {
        // API EQuran v2 membungkus datanya di dalam key 'data'
        surahList.value = response.data['data'];
        filteredSurahList.value = surahList;
      } else {
        errorMessage('Gagal mengambil data dari server.');
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
