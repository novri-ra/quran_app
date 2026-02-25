import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/doa_controller.dart';

class DoaView extends StatelessWidget {
  const DoaView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DoaController>(); // Mengambil dari Routing

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doa & Dzikir'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari Doa...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: controller.searchDoa,
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
              if (controller.filteredDoaList.isEmpty) {
                return const Center(child: Text('Doa tidak ditemukan'));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.filteredDoaList.length,
                itemBuilder: (context, index) {
                  final doa = controller.filteredDoaList[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            doa['nama'] ?? 'Nama Doa',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const Divider(height: 24),
                          Text(
                            doa['ar'] ?? '',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Nabi',
                              height: 2.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            doa['tr'] ?? '',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Get.isDarkMode
                                  ? Colors.indigoAccent
                                  : Colors.indigo,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            doa['idn'] ?? '',
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
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
