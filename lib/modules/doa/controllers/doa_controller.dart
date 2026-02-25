import 'package:get/get.dart';

import '../../../core/network/api_service.dart';

class DoaController extends GetxController {
  final ApiService _apiService = ApiService();

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

      final response = await _apiService.getDoaList();

      if (response.statusCode == 200) {
        // Asumsi data doa langsung berupa array atau berada di dalam key tertentu
        // Sesuaikan jika format JSON dari API berbeda
        doaList.value = response.data is List
            ? response.data
            : response.data['data'] ?? [];
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
        final namaDoa = (doa['doa'] ?? '').toString().toLowerCase();
        return namaDoa.contains(query.toLowerCase());
      }).toList();
    }
  }
}
