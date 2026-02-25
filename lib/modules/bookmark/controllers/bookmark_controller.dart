import 'package:get/get.dart';

import '../../../core/storage/storage_service.dart';

class BookmarkController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  // State untuk menyimpan data surat dan ayat
  var lastRead = {}.obs;

  @override
  void onInit() {
    super.onInit();
    loadBookmark();
  }

  // Mengambil data dari local storage
  void loadBookmark() {
    final data = _storageService.getLastRead();
    if (data != null) {
      lastRead.value = {'surat': data['surat'], 'ayat': data['ayat']};
    }
  }
}
