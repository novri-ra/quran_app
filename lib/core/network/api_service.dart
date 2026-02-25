import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      // Ubah baseUrl ke root domain
      baseUrl: 'https://equran.id',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // Mengambil daftar semua surat
  Future<Response> getSuratList() async {
    try {
      final response = await _dio.get('/api/v2/surat');
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Mengambil detail surat beserta ayatnya
  Future<Response> getSuratDetail(int nomorSurat) async {
    try {
      final response = await _dio.get('/api/v2/surat/$nomorSurat');
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // --- API DOA & DZIKIR (Fitur Baru) ---
  Future<Response> getDoaList() async {
    try {
      return await _dio.get('/api/doa');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // --- API JADWAL SHALAT & IMSAKIYAH ---

  // 1. Ambil daftar semua kabupaten/kota (MyQuran API)
  Future<Response> getSemuaKota() async {
    try {
      return await _dio.get('https://api.myquran.com/v2/sholat/kota/semua');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 2. Ambil jadwal shalat bulanan
  Future<Response> getJadwalSholat(
    String idKabupaten,
    int tahun,
    int bulan,
  ) async {
    try {
      return await _dio.get(
        'https://api.myquran.com/v2/sholat/jadwal/$idKabupaten/$tahun/$bulan',
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Mengunduh file audio murottal
  Future<String?> downloadAudio(
    String url,
    String fileName,
    Function(int, int) onReceiveProgress,
  ) async {
    try {
      // Mendapatkan direktori penyimpanan aplikasi
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String savePath = '${appDocDir.path}/$fileName';

      // Cek apakah file sudah ada
      if (File(savePath).existsSync()) {
        return savePath;
      }

      await _dio.download(url, savePath, onReceiveProgress: onReceiveProgress);

      return savePath;
    } catch (e) {
      debugPrint("Error downloading audio: $e");
      return null;
    }
  }

  // Handler error sederhana
  String _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return "Koneksi terputus. Silakan periksa jaringan Anda.";
    }
    return "Terjadi kesalahan pada server.";
  }
}
