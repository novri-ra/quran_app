import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

class DoaController extends GetxController {
  var isLoading = true.obs;
  var doaList = <dynamic>[].obs;
  var filteredDoaList = <dynamic>[].obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDoaList();
  }

  Future<void> fetchDoaList() async {
    try {
      isLoading(true);
      errorMessage('');

      final String jsonString = await rootBundle.loadString(
        'assets/data/doa.json',
      );
      final Map<String, dynamic> response = jsonDecode(jsonString);

      if (response['status'] == 'success') {
        doaList.value = response['data'] ?? [];
        filteredDoaList.value = doaList;
      } else {
        errorMessage('Gagal mengambil data doa.');
      }
    } catch (e) {
      errorMessage('Terjadi kesalahan: $e');
    } finally {
      isLoading(false);
    }
  }

  void searchDoa(String query) {
    if (query.isEmpty) {
      filteredDoaList.value = doaList;
    } else {
      filteredDoaList.value = doaList.where((doa) {
        final namaDoa = (doa['nama'] ?? '').toString().toLowerCase();
        return namaDoa.contains(query.toLowerCase());
      }).toList();
    }
  }
}
