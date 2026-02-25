import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../bookmark/views/bookmark_view.dart';
import '../../doa/views/doa_view.dart';
import '../../settings/views/settings_view.dart';
import '../../sholat/views/sholat_view.dart';
import '../../surah_list/views/surah_list_view.dart';
import '../controllers/main_navigation_controller.dart';

class MainNavigationView extends GetView<MainNavigationController> {
  const MainNavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.selectedIndex.value,
          children: [
            controller.visitedPages[0]
                ? const SurahListView()
                : const SizedBox.shrink(),
            controller.visitedPages[1]
                ? const DoaView()
                : const SizedBox.shrink(),
            controller.visitedPages[2]
                ? const SholatView()
                : const SizedBox.shrink(),
            controller.visitedPages[3]
                ? const BookmarkView()
                : const SizedBox.shrink(),
            controller.visitedPages[4]
                ? const SettingsView()
                : const SizedBox.shrink(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          onTap: controller.changeIndex,
          selectedItemColor: Colors.teal,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: 'Surat',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.pan_tool), label: 'Doa'),
            BottomNavigationBarItem(
              icon: Icon(Icons.access_time_filled),
              label: 'Jadwal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark),
              label: 'Bookmark',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Pengaturan',
            ),
          ],
        ),
      ),
    );
  }
}
