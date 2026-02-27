import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/network/api_service.dart';

class SholatController extends GetxController {
  final ApiService _apiService = ApiService();

  var isLoadingKabupaten = true.obs;
  var isLoadingJadwal = false.obs;
  var isDetectingLocation = false.obs; // Indikator proses GPS

  var errorMessageKota = ''.obs;

  var listKabupaten = <dynamic>[].obs;
  var jadwalHariIni = {}.obs;

  var selectedKabupaten = RxnString();

  @override

  void onInit() {
    super.onInit();
    fetchAllKota();
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

  // Fungsi internal untuk mencocokkan nama GPS dengan database API
  Future<void> _matchLocationWithApi(String provName, String cityName) async {
    // Bersihkan string agar mudah dicocokkan (misal "Kabupaten Bireuen" -> "bireuen")
    String cleanCity = cityName
        .toLowerCase()
        .replaceAll(RegExp(r'kabupaten|kota|kab\.|kota '), '')
        .trim();

    // Cari ID Kabupaten/Kota
    String? matchedCityId;
    for (var kab in listKabupaten) {
      if (kab['lokasi'].toString().toLowerCase().contains(cleanCity)) {
        matchedCityId = kab['id'];
        selectedKabupaten.value = matchedCityId;
        break;
      }
    }

    if (matchedCityId != null) {
      // Jika kota cocok, langsung tampilkan jadwal!
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
  }

  Future<void> fetchAllKota() async {
    try {
      isLoadingKabupaten(true);
      errorMessageKota('');
      final response = await _apiService.getSemuaKota();
      if (response.statusCode == 200) {
        listKabupaten.value = response.data['data'] ?? [];
      } else {
        errorMessageKota('Gagal memuat daftar kota dari server.');
      }
    } catch (e) {
      errorMessageKota('Gagal memuat daftar kota. Periksa koneksi Anda.');
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
        final allJadwal = response.data['data']['jadwal'] ?? [];
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
