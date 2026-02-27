import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/banner_ad_widget.dart';
import '../controllers/quran_controller.dart';

class SurahListView extends GetView<QuranController> {
  const SurahListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Al-Quran'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari Surat...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => controller.searchSurah(value),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(child: Text(controller.errorMessage.value));
              }

              if (controller.filteredSurahList.isEmpty) {
                return const Center(child: Text('Surat tidak ditemukan'));
              }

              return ListView.separated(
                itemCount: controller.filteredSurahList.length,
                separatorBuilder: (context, index) {
                  // Menyisipkan Iklan Banner setiap 5 surat
                  if ((index + 1) % 5 == 0) {
                    return const Column(
                      children: [
                        Divider(),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: BannerAdWidget(),
                        ),
                        Divider(),
                      ],
                    );
                  }
                  return const Divider();
                },
                itemBuilder: (context, index) {
                  final surah = controller.filteredSurahList[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.withValues(alpha: 0.1),
                      child: Text(
                        surah['nomor'].toString(),
                        style: TextStyle(
                          color: Get.isDarkMode
                              ? Colors.tealAccent
                              : Colors.teal,
                        ),
                      ),
                    ),
                    title: Text(
                      surah['namaLatin'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${surah['arti']} • ${surah['jumlahAyat']} Ayat',
                    ),
                    trailing: Text(
                      surah['nama'], // Nama Arab
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Nabi',
                      ),
                    ),
                    onTap: () {
                      // Navigasi ke halaman detail dengan membawa argumen nomor surat
                      Get.toNamed('/surah-detail', arguments: surah['nomor']);
                    },
                  );
                },
              );
            }),
          ),
          // Widget Iklan AdMob
          const BannerAdWidget(),
        ],
      ),
    );
  }
}
