import 'package:get/get.dart';
import 'package:quran_app/routes/app_routes.dart';

import '../modules/bookmark/controllers/bookmark_controller.dart';
import '../modules/doa/controllers/doa_controller.dart';
import '../modules/main_navigation/controllers/main_navigation_controller.dart';
import '../modules/main_navigation/views/main_navigation_view.dart';
import '../modules/settings/controllers/theme_controller.dart';
import '../modules/sholat/controllers/sholat_controller.dart';
import '../modules/surah_detail/controllers/audio_controller.dart';
import '../modules/surah_detail/controllers/surah_detail_controller.dart';
import '../modules/surah_detail/views/surah_detail_view.dart';
import '../modules/surah_list/controllers/quran_controller.dart';

class AppPages {
  static const initial = Routes.home;

  static final routes = [
    GetPage(
      name: Routes.home,
      page: () => const MainNavigationView(),
      // Menggunakan binding langsung di dalam route untuk injeksi dependency
      binding: BindingsBuilder(() {
        Get.lazyPut<MainNavigationController>(() => MainNavigationController());
        Get.lazyPut<QuranController>(() => QuranController());
        Get.lazyPut<BookmarkController>(() => BookmarkController());
        Get.lazyPut<ThemeController>(() => ThemeController());
        Get.lazyPut<DoaController>(() => DoaController());
        Get.lazyPut<SholatController>(() => SholatController());
      }),
    ),
    GetPage(
      name: Routes.surahDetail,
      page: () => const SurahDetailView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SurahDetailController>(() => SurahDetailController());
        Get.lazyPut<AudioController>(() => AudioController());
      }),
    ),
  ];
}
