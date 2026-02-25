import 'package:get/get.dart';

import '../../../core/network/api_service.dart';

class SholatController extends GetxController {
  final ApiService _apiService = ApiService();

  // Status loading masing-masing tahap
  var isLoadingProvinsi = true.obs;
  var isLoadingKabupaten = false.obs;
  var isLoadingJadwal = false.obs;

  // Tempat menyimpan data dari API
  var listProvinsi = <dynamic>[].obs;
  var listKabupaten = <dynamic>[].obs;
  var jadwalHariIni = {}.obs; // Hanya menyimpan jadwal untuk hari ini

  // Nilai yang dipilih pada Dropdown
  var selectedProvinsi = RxnString();
  var selectedKabupaten = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchProvinsi(); // Otomatis muat provinsi saat halaman dibuka
  }

  Future<void> fetchProvinsi() async {
    try {
      isLoadingProvinsi(true);
      final response = await _apiService.getProvinsi();
      if (response.statusCode == 200) {
        listProvinsi.value = response.data['data'] ?? [];
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat daftar provinsi');
    } finally {
      isLoadingProvinsi(false);
    }
  }

  Future<void> fetchKabupaten(String idProvinsi) async {
    try {
      isLoadingKabupaten(true);
      selectedKabupaten.value = null; // Reset pilihan kota sebelumnya
      jadwalHariIni.clear(); // Bersihkan jadwal lama
      listKabupaten.clear();

      final response = await _apiService.getKabupaten(idProvinsi);
      if (response.statusCode == 200) {
        listKabupaten.value = response.data['data'] ?? [];
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat daftar kabupaten');
    } finally {
      isLoadingKabupaten(false);
    }
  }

  Future<void> fetchJadwalSholat(String idKabupaten) async {
    try {
      isLoadingJadwal(true);
      final now = DateTime.now();

      // Ambil jadwal sebulan penuh
      final response = await _apiService.getJadwalSholat(
        idKabupaten,
        now.year,
        now.month,
      );

      if (response.statusCode == 200) {
        final allJadwal = response.data['data'] ?? [];

        // API EQuran biasanya memberikan array sejumlah hari dalam bulan tersebut
        // Kita ambil index berdasarkan tanggal hari ini dikurang 1
        int todayIndex = now.day - 1;

        if (allJadwal.isNotEmpty && todayIndex < allJadwal.length) {
          jadwalHariIni.value = allJadwal[todayIndex];
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat jadwal shalat');
    } finally {
      isLoadingJadwal(false);
    }
  }
}
