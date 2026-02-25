import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/sholat_controller.dart';

class SholatView extends StatelessWidget {
  const SholatView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SholatController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Shalat'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Tombol Deteksi Lokasi Otomatis ---
            Obx(
              () => controller.isDetectingLocation.value
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: controller.autoDetectLocation,
                      icon: const Icon(Icons.my_location),
                      label: const Text('Gunakan Lokasi Saat Ini'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: 24),

            // --- Dropdown Kabupaten ---
            Obx(() {
              if (controller.isLoadingKabupaten.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessageKota.value.isNotEmpty) {
                return Center(
                  child: Column(
                    children: [
                      Text(
                        controller.errorMessageKota.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: controller.fetchAllKota,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Autocomplete<Map<String, dynamic>>(
                displayStringForOption: (option) => option['lokasi'].toString(),
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<Map<String, dynamic>>.empty();
                  }
                  return controller.listKabupaten
                      .cast<Map<String, dynamic>>()
                      .where((kab) {
                        return kab['lokasi'].toString().toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        );
                      });
                },
                onSelected: (Map<String, dynamic> selection) {
                  final selectedId = selection['id'].toString();
                  controller.selectedKabupaten.value = selectedId;
                  controller.fetchJadwalSholat(selectedId);
                  // Sembunyikan keyboard setelah memilih
                  FocusScope.of(context).unfocus();
                },
                fieldViewBuilder:
                    (
                      BuildContext context,
                      TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted,
                    ) {
                      // Sinkronkan text field dengan lokasi saat ini jika dari GPS
                      if (controller.selectedKabupaten.value != null &&
                          textEditingController.text.isEmpty) {
                        final currentCity = controller.listKabupaten.firstWhere(
                          (kab) =>
                              kab['id'].toString() ==
                              controller.selectedKabupaten.value,
                          orElse: () => null,
                        );
                        if (currentCity != null) {
                          textEditingController.text = currentCity['lokasi']
                              .toString();
                        }
                      }

                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: 'Cari Kabupaten/Kota (contoh: Bireuen)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: const Icon(Icons.search),
                        ),
                        onFieldSubmitted: (String value) {
                          onFieldSubmitted();
                        },
                      );
                    },
              );
            }),

            const SizedBox(height: 32),

            // --- Hasil Jadwal Shalat ---
            Obx(() {
              if (controller.isLoadingJadwal.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.jadwalHariIni.isEmpty) {
                return const Center(
                  child: Text(
                    'Pilih wilayah untuk melihat jadwal hari ini.',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              final jadwal = controller.jadwalHariIni;

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        jadwal['tanggal'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const Divider(height: 32),
                      _buildJadwalRow('Imsak', jadwal['imsak']),
                      _buildJadwalRow('Subuh', jadwal['subuh']),
                      _buildJadwalRow('Terbit', jadwal['terbit']),
                      _buildJadwalRow('Dhuha', jadwal['dhuha']),
                      _buildJadwalRow('Dzuhur', jadwal['dzuhur']),
                      _buildJadwalRow('Ashar', jadwal['ashar']),
                      _buildJadwalRow('Maghrib', jadwal['maghrib']),
                      _buildJadwalRow('Isya', jadwal['isya']),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk menyusun baris jadwal
  Widget _buildJadwalRow(String nama, String? waktu) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            nama,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            waktu ?? '-',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
