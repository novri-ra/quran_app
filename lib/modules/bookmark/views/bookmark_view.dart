import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/bookmark_controller.dart';

class BookmarkView extends GetView<BookmarkController> {
  const BookmarkView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terakhir Dibaca')),
      body: Obx(() {
        if (controller.lastRead.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada ayat yang ditandai.',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        final nomorSurat = controller.lastRead['surat'];
        final nomorAyat = controller.lastRead['ayat'];

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const Icon(Icons.bookmark, color: Colors.teal, size: 40),
              title: Text(
                'Surat ke-$nomorSurat',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Ayat ke-$nomorAyat\nKetuk untuk melanjutkan membaca',
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.teal),
              onTap: () {
                // Navigasi langsung ke detail surat tersebut
                Get.toNamed('/surah-detail', arguments: nomorSurat);
              },
            ),
          ),
        );
      }),
    );
  }
}
