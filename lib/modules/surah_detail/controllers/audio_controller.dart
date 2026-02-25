import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/network/api_service.dart';
import '../../../core/storage/storage_service.dart';
import 'surah_detail_controller.dart';

class AudioController extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ApiService _apiService = ApiService();
  final StorageService _storageService = Get.find<StorageService>();

  // State untuk pemutar audio
  var isPlaying = false.obs;
  var currentlyPlayingUrl = ''.obs; // Melacak audio mana yang sedang diputar

  // --- Tambahan State untuk Playlist & Index ---
  var playingIndex = (-1).obs;
  List<dynamic> currentAyatList = [];

  // State untuk pengunduhan
  var isDownloading = false.obs;
  var downloadProgress = 0.0.obs;
  var downloadingAyatUrl = ''.obs; // Melacak ayat mana yang sedang diunduh

  @override
  void onInit() {
    super.onInit();
    // Dengarkan perubahan state dari just_audio (misal: selesai memutar)
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        // --- LOGIKA CONTINUOUS PLAYBACK ---
        if (playingIndex.value != -1 &&
            playingIndex.value < currentAyatList.length - 1) {
          int nextIndex = playingIndex.value + 1;
          String nextAudioUrl = currentAyatList[nextIndex]['audio']['01'];
          playAudio(nextAudioUrl, index: nextIndex, playlist: currentAyatList);
        } else {
          // Jika sudah sampai ayat terakhir, hentikan
          stopAudio();
        }
      }
    });
  }

  @override
  void onClose() {
    _audioPlayer.dispose(); // Wajib untuk mencegah memory leak
    super.onClose();
  }

  // Fungsi utama pemutaran audio
  Future<void> playAudio(
    String audioUrl, {
    int? index,
    List<dynamic>? playlist,
  }) async {
    try {
      // Jika tombol play ditekan pada audio yang sama saat sedang berjalan -> Pause
      if (currentlyPlayingUrl.value == audioUrl && isPlaying.value) {
        await pauseAudio();
        return;
      }

      currentlyPlayingUrl.value = audioUrl;
      isPlaying.value = true;

      // Update index & playlist jika ada
      if (index != null) {
        playingIndex.value = index;
        // Panggil fungsi Auto-Scroll di SurahDetailController
        if (Get.isRegistered<SurahDetailController>()) {
          Get.find<SurahDetailController>().scrollToAyat(index);
        }
      }
      if (playlist != null) {
        currentAyatList = playlist;
      }

      // 1. Cek Hive apakah file ini sudah pernah diunduh
      String? localPath = _storageService.getDownloadedAudioPath(audioUrl);

      if (localPath != null) {
        // 2a. Putar dari penyimpanan lokal
        debugPrint("Memutar dari Local Storage: $localPath");
        await _audioPlayer.setFilePath(localPath);
      } else {
        // 2b. Putar secara streaming (URL)
        debugPrint("Streaming dari URL: $audioUrl");
        await _audioPlayer.setUrl(audioUrl);
      }

      await _audioPlayer.play();
    } catch (e) {
      debugPrint("Error pemutaran audio: $e");
      isPlaying.value = false;
      currentlyPlayingUrl.value = '';
      Get.snackbar('Error', 'Gagal memutar audio');
    }
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
    isPlaying.value = false;
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    isPlaying.value = false;
    currentlyPlayingUrl.value = '';
    playingIndex.value = -1; // Reset highlight ayat
  }

  // Fungsi untuk mengunduh audio per ayat
  Future<void> downloadAudio(String url, int nomorSurat, int nomorAyat) async {
    isDownloading.value = true;
    downloadingAyatUrl.value = url;

    // Format penamaan file agar unik: surat_1_ayat_1.mp3
    String fileName = 'surat_${nomorSurat}_ayat_$nomorAyat.mp3';

    String? savePath = await _apiService.downloadAudio(url, fileName, (
      received,
      total,
    ) {
      if (total != -1) {
        downloadProgress.value = received / total;
      }
    });

    if (savePath != null) {
      // Simpan path lokal ke Hive
      await _storageService.markAudioAsDownloaded(url, savePath);
      Get.snackbar('Berhasil', 'Audio ayat $nomorAyat berhasil diunduh');
    } else {
      Get.snackbar('Gagal', 'Terjadi kesalahan saat mengunduh audio');
    }

    // Reset state unduhan
    isDownloading.value = false;
    downloadProgress.value = 0.0;
    downloadingAyatUrl.value = '';
  }
}
