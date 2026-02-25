import 'package:get/get.dart';

import '../../bookmark/controllers/bookmark_controller.dart';

class MainNavigationController extends GetxController {
  var selectedIndex = 0.obs;
  // Menyimpan status apakah tab sudah pernah dikunjungi (Lazy Load)
  var visitedPages = [true, false, false, false, false].obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
    visitedPages[index] = true; // Tandai sudah dikunjungi

    // Jika tab Bookmark (index 3) ditekan, paksa pembaruan data
    if (index == 3 && Get.isRegistered<BookmarkController>()) {
      Get.find<BookmarkController>().loadBookmark();
    }
  }
}
