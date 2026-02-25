import 'package:get/get.dart';

import '../../bookmark/controllers/bookmark_controller.dart';

class MainNavigationController extends GetxController {
  var selectedIndex = 0.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
    // Jika tab Bookmark (index 1) ditekan, paksa pembaruan data
    if (index == 1 && Get.isRegistered<BookmarkController>()) {
      Get.find<BookmarkController>().loadBookmark();
    }
  }
}
