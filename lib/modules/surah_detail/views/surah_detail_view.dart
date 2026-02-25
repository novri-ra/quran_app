import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../controllers/audio_controller.dart';
import '../controllers/surah_detail_controller.dart';

class SurahDetailView extends GetView<SurahDetailController> {
  const SurahDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil argumen nomor surat dari navigasi sebelumnya
    final nomorSurat = Get.arguments as int;

    // Ambil Controllers (sudah di-inject oleh Router bindigs)
    final detailCtrl = Get.find<SurahDetailController>();
    final audioCtrl = Get.find<AudioController>();

    // Panggil API saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      detailCtrl.fetchSurahDetail(nomorSurat);
    });

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            detailCtrl.isLoading.value
                ? 'Memuat...'
                : detailCtrl.surahDetail['namaLatin'] ?? 'Detail Surat',
          ),
        ),
        backgroundColor: Colors.teal,
        actions: [
          // Tombol Putar Semua Ayat
          Obx(() {
            if (detailCtrl.isLoading.value) return const SizedBox.shrink();
            final isPlayingAny = audioCtrl.isPlaying.value;
            return IconButton(
              icon: Icon(
                isPlayingAny ? Icons.stop_circle : Icons.play_circle_fill,
                size: 28,
              ),
              onPressed: () {
                if (isPlayingAny) {
                  audioCtrl.stopAudio();
                } else {
                  final ayatList =
                      detailCtrl.surahDetail['ayat'] as List<dynamic>;
                  audioCtrl.playAudio(
                    ayatList[0]['audio']['01'],
                    index: 0,
                    playlist: ayatList,
                  );
                }
              },
            );
          }),
        ],
      ),
      body: Obx(() {
        if (detailCtrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (detailCtrl.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  detailCtrl.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    detailCtrl.fetchSurahDetail(nomorSurat);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final surah = detailCtrl.surahDetail;
        final ayatList = surah['ayat'] as List<dynamic>;

        // Mengganti ListView dengan ScrollablePositionedList
        return ScrollablePositionedList.builder(
          itemScrollController: detailCtrl.itemScrollController,
          padding: const EdgeInsets.all(16.0),
          itemCount: ayatList.length,
          itemBuilder: (context, index) {
            final ayat = ayatList[index];
            final String audioUrl =
                ayat['audio']['01']; // Mengambil audio qori 01

            return Obx(() {
              // Mengecek apakah ayat ini sedang diputar
              bool isThisAyatPlaying = audioCtrl.playingIndex.value == index;

              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: isThisAyatPlaying ? 8 : 2,
                color: isThisAyatPlaying
                    ? (Get.isDarkMode ? Colors.teal[900] : Colors.teal[50])
                    : Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isThisAyatPlaying ? Colors.teal : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Baris Aksi: Bookmark, Download, Play
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.teal,
                            child: Text(
                              ayat['nomorAyat'].toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.bookmark_border,
                                  color: Colors.teal,
                                ),
                                onPressed: () => detailCtrl.saveBookmark(
                                  nomorSurat,
                                  ayat['nomorAyat'],
                                ),
                              ),
                              // Indikator Unduhan / Tombol Download
                              Obx(() {
                                bool isThisDownloading =
                                    audioCtrl.isDownloading.value &&
                                    audioCtrl.downloadingAyatUrl.value ==
                                        audioUrl;

                                if (isThisDownloading) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                    ),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        value: audioCtrl.downloadProgress.value,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                }
                                return IconButton(
                                  icon: const Icon(
                                    Icons.download,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () => audioCtrl.downloadAudio(
                                    audioUrl,
                                    nomorSurat,
                                    ayat['nomorAyat'],
                                  ),
                                );
                              }),
                              // Tombol Play/Pause
                              Obx(() {
                                bool isPlayingThis =
                                    audioCtrl.isPlaying.value &&
                                    audioCtrl.currentlyPlayingUrl.value ==
                                        audioUrl;

                                return IconButton(
                                  icon: Icon(
                                    isPlayingThis
                                        ? Icons.pause_circle_filled
                                        : Icons.play_circle_fill,
                                    color: Colors.teal,
                                    size: 32,
                                  ),
                                  onPressed: () {
                                    if (isPlayingThis) {
                                      audioCtrl.pauseAudio();
                                    } else {
                                      // Lempar index dan playlist saat ayat spesifik diklik
                                      audioCtrl.playAudio(
                                        audioUrl,
                                        index: index,
                                        playlist: ayatList,
                                      );
                                    }
                                  },
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                      // Progress Bar Audio (hanya tampil jika ayat ini yang sedang diputar/dipause)
                      Obx(() {
                        bool isPlayingThis =
                            audioCtrl.currentlyPlayingUrl.value == audioUrl;

                        if (!isPlayingThis) return const SizedBox.shrink();

                        final position = audioCtrl.position.value;
                        final duration = audioCtrl.duration.value;

                        // Cegah error pembagian dengan nol atau nilai slider tidak valid
                        double sliderValue = position.inMilliseconds.toDouble();
                        double sliderMax = duration.inMilliseconds.toDouble();

                        if (sliderValue > sliderMax) {
                          sliderValue = sliderMax;
                        }

                        if (sliderMax <= 0) {
                          sliderMax = 1.0;
                          sliderValue = 0.0;
                        }

                        return Column(
                          children: [
                            const SizedBox(height: 8),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 4.0,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6.0,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 14.0,
                                ),
                              ),
                              child: Slider(
                                value: sliderValue,
                                min: 0.0,
                                max: sliderMax,
                                activeColor: Colors.teal,
                                inactiveColor: Colors.teal.withValues(
                                  alpha: 0.3,
                                ),
                                onChanged: (value) {
                                  audioCtrl.seekAudio(
                                    Duration(milliseconds: value.toInt()),
                                  );
                                },
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(position),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  _formatDuration(duration),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 16),
                      // Teks Arab
                      Text(
                        ayat['teksArab'],
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Nabi',
                          height: 2.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Transliterasi
                      Text(
                        ayat['teksLatin'],
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Get.isDarkMode
                              ? Colors.indigoAccent
                              : Colors.indigo,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Terjemahan
                      Text(
                        ayat['teksIndonesia'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Get.isDarkMode
                              ? Colors.white70
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
          },
        );
      }),
    );
  }

  // Helper function untuk memformat Duration menjadi menit:detik
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
