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
        ],
      ),
    );
  }
}
