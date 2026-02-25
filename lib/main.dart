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
        useMaterial3: true,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          primary: Colors.teal,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        splashFactory: InkRipple.splashFactory, // Efek Ripple Halus
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
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
          foregroundColor: Colors.white,
        ),
        cardColor: const Color(0xFF1E1E1E),
        colorScheme: const ColorScheme.dark(
          primary: Colors.teal,
          secondary: Colors.tealAccent,
        ),
        splashFactory: InkRipple.splashFactory,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
