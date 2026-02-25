import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/storage/storage_service.dart';
import 'routes/app_pages.dart';

void main() async {
  // Memastikan binding Flutter sudah siap sebelum inisialisasi library native/lokal
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi StorageService (Hive) dan daftarkan ke GetX agar bisa dipanggil dari mana saja
  final storageService = await Get.putAsync<StorageService>(
    () async => await StorageService().init(),
  );

  bool isDark = storageService.isDarkMode();

  runApp(MyApp(isDark: isDark));
}

class MyApp extends StatelessWidget {
  final bool isDark;
  const MyApp({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Al-Quran App',
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light, // Default
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.teal,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.teal,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      // Konfigurasi Tema Gelap Kontras Tinggi
      darkTheme: ThemeData.dark().copyWith(
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Poppins'),
        primaryColor: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
          centerTitle: true,
        ),
        cardColor: const Color(0xFF1E1E1E),
        colorScheme: const ColorScheme.dark(
          primary: Colors.teal,
          secondary: Colors.tealAccent,
        ),
      ),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
