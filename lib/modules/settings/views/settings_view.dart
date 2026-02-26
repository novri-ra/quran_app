import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/theme_controller.dart';

class SettingsView extends GetView<ThemeController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Obx(
            () => SwitchListTile(
              title: const Text(
                'Tema Gelap (Dark Mode)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Tampilan kontras tinggi untuk kenyamanan membaca',
              ),
              value: controller.isDarkMode.value,
              activeThumbColor: Colors.teal,
              onChanged: (value) => controller.toggleTheme(),
              secondary: Icon(
                controller.isDarkMode.value
                    ? Icons.dark_mode
                    : Icons.light_mode,
                color: Colors.teal,
              ),
            ),
          ),
          const Divider(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Personalisasi Tipografi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Pengaturan Ukuran Font Arab
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ukuran Font Arab',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${controller.arabicFontSize.value.toInt()} pt',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيم',
                    style: TextStyle(
                      fontFamily: 'Nabi',
                      fontSize: controller.arabicFontSize.value,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
                Slider(
                  value: controller.arabicFontSize.value,
                  min: 18.0,
                  max: 48.0,
                  divisions: 15,
                  activeColor: Colors.teal,
                  label: '${controller.arabicFontSize.value.toInt()}',
                  onChanged: (value) {
                    controller.changeArabicFontSize(value);
                  },
                ),
                const SizedBox(height: 16),
                // Pengaturan Ukuran Font Latin & Terjemahan
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ukuran Teks Latin & Arti',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${controller.latinFontSize.value.toInt()} pt',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    'Dengan nama Allah Yang Maha Pengasih, Maha Penyayang.',
                    style: TextStyle(
                      fontSize: controller.latinFontSize.value,
                      color: Get.isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
                Slider(
                  value: controller.latinFontSize.value,
                  min: 10.0,
                  max: 24.0,
                  divisions: 14,
                  activeColor: Colors.teal,
                  label: '${controller.latinFontSize.value.toInt()}',
                  onChanged: (value) {
                    controller.changeLatinFontSize(value);
                  },
                ),
                const SizedBox(height: 16),
                // Pengaturan Jenis Font Arab
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jenis Font Arab',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        dropdownColor: Get.isDarkMode
                            ? const Color(0xFF1E1E1E)
                            : Colors.white,
                        style: TextStyle(
                          color: Get.isDarkMode ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Get.isDarkMode
                              ? Colors.teal[900]
                              : Colors.teal[50],
                        ),
                        initialValue: controller.arabicFontFamily.value,
                        items: const [
                          DropdownMenuItem(
                            value: 'Nabi',
                            child: Text('Nabi (Lokal)'),
                          ),
                          DropdownMenuItem(
                            value: 'Amiri',
                            child: Text('Amiri (Google Fonts)'),
                          ),
                          DropdownMenuItem(
                            value: 'Lateef',
                            child: Text('Lateef (Google Fonts)'),
                          ),
                          DropdownMenuItem(
                            value: 'Aref Ruqaa',
                            child: Text('Aref Ruqaa (Google Fonts)'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            controller.changeArabicFontFamily(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
