import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/network/api_service.dart';

class SholatController extends GetxController {
  final ApiService _apiService = ApiService();

  var isLoadingProvinsi = true.obs;
  var isLoadingKabupaten = false.obs;
  var isLoadingJadwal = false.obs;
  var isDetectingLocation = false.obs; // Indikator proses GPS

  var listProvinsi = <dynamic>[].obs;
  var listKabupaten = <dynamic>[].obs;
  var jadwalHariIni = {}.obs;

  var selectedProvinsi = RxnString();
  var selectedKabupaten = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchProvinsi();
  }

  // --- Fungsi Baru: Meminta Izin dan Deteksi Otomatis ---
  Future<void> autoDetectLocation() async {
    try {
      isDetectingLocation(true);

      // 1. Minta Izin Notifikasi (Untuk persiapan pengingat Adzan)
      await Permission.notification.request();

      // 2. Minta Izin Lokasi GPS
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Izin Ditolak',
            'Akses lokasi diperlukan untuk fitur ini.',
          );
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Izin Ditolak Permanen',
          'Silakan buka pengaturan HP untuk mengizinkan lokasi.',
          duration: const Duration(seconds: 4),
        );
        return;
      }

      // 3. Ambil Koordinat Saat Ini
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // 4. Ubah Koordinat Menjadi Nama Tempat (Reverse Geocoding)
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Contoh output: adminArea = "Aceh", subAdminArea = "Kabupaten Bireuen"
        String provName = place.administrativeArea ?? '';
        String cityName = place.subAdministrativeArea ?? '';

        await _matchLocationWithApi(provName, cityName);
      }
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Tidak dapat mendeteksi lokasi otomatis. Pastikan GPS aktif.',
      );
    } finally {
      isDetectingLocation(false);
    }
  }

  // Fungsi internal untuk mencocokkan nama GPS dengan database API EQuran
  Future<void> _matchLocationWithApi(String provName, String cityName) async {
    // Bersihkan string agar mudah dicocokkan (misal "Kabupaten Bireuen" -> "bireuen")
    String cleanProv = provName
        .toLowerCase()
        .replaceAll(RegExp(r'provinsi|daerah khusus|di '), '')
        .trim();
    String cleanCity = cityName
        .toLowerCase()
        .replaceAll(RegExp(r'kabupaten|kota|kab\.|kota '), '')
        .trim();

    // A. Cari ID Provinsi
    String? matchedProvId;
    for (var prov in listProvinsi) {
      if (prov['lokasi'].toString().toLowerCase().contains(cleanProv)) {
        matchedProvId = prov['id'];
        selectedProvinsi.value = matchedProvId;
        break;
      }
    }

    if (matchedProvId != null) {
      // B. Ambil daftar kabupaten berdasarkan provinsi tersebut
      await fetchKabupaten(matchedProvId);

      // C. Cari ID Kabupaten/Kota
      String? matchedCityId;
      for (var kab in listKabupaten) {
        if (kab['lokasi'].toString().toLowerCase().contains(cleanCity)) {
          matchedCityId = kab['id'];
          selectedKabupaten.value = matchedCityId;
          break;
        }
      }

      if (matchedCityId != null) {
        // D. Jika kota cocok, langsung tampilkan jadwal!
        await fetchJadwalSholat(matchedCityId);
        Get.snackbar(
          'Lokasi Ditemukan',
          'Jadwal disesuaikan untuk area $cityName',
          backgroundColor: const Color(0xFF009688),
          colorText: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Informasi',
          'Kota $cityName tidak ditemukan di database. Silakan pilih manual.',
        );
      }
    } else {
      Get.snackbar(
        'Informasi',
        'Provinsi $provName tidak ditemukan di database.',
      );
    }
  }

  // ... (Sisa fungsi fetchProvinsi, fetchKabupaten, fetchJadwalSholat biarkan sama seperti sebelumnya) ...
  Future<void> fetchProvinsi() async {
    try {
      isLoadingProvinsi(true);
      final response = await _apiService.getProvinsi();
      if (response.statusCode == 200) {
        listProvinsi.value = response.data['data'] ?? [];
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat provinsi');
    } finally {
      isLoadingProvinsi(false);
    }
  }

  Future<void> fetchKabupaten(String idProvinsi) async {
    try {
      isLoadingKabupaten(true);
      selectedKabupaten.value = null;
      jadwalHariIni.clear();
      listKabupaten.clear();
      final response = await _apiService.getKabupaten(idProvinsi);
      if (response.statusCode == 200) {
        listKabupaten.value = response.data['data'] ?? [];
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat kabupaten');
    } finally {
      isLoadingKabupaten(false);
    }
  }

  Future<void> fetchJadwalSholat(String idKabupaten) async {
    try {
      isLoadingJadwal(true);
      final now = DateTime.now();
      final response = await _apiService.getJadwalSholat(
        idKabupaten,
        now.year,
        now.month,
      );
      if (response.statusCode == 200) {
        final allJadwal = response.data['data'] ?? [];
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
