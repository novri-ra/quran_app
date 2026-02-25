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
          return Center(child: Text(detailCtrl.errorMessage.value));
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
}
