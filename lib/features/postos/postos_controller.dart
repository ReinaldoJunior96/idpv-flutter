import 'package:get/get.dart';
import 'data/posto_model.dart';
import 'data/postos_api.dart';
import 'data/postos_storage.dart';

class PostosController extends GetxController {
  final _api = PostosApi();
  final _storage = PostosStorage();

  final postos = <Posto>[].obs;
  final isLoading = true.obs;
  final fromCache = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadPostos();
  }

  Future<void> loadPostos({bool forceRefresh = false}) async {
    isLoading.value = true;
    error.value = null;

    if (!forceRefresh) {
      final cached = await _storage.load();
      if (cached != null) {
        postos.value = cached;
        fromCache.value = true;
        isLoading.value = false;
        _refreshInBackground();
        return;
      }
    }

    await _fetchFromApi();
  }

  Future<void> _fetchFromApi() async {
    try {
      final result = await _api.fetchPostos();
      await _storage.save(result);
      postos.value = result;
      fromCache.value = false;
    } catch (_) {
      final cached = await _storage.load();
      if (cached != null) {
        postos.value = cached;
        fromCache.value = true;
      } else {
        error.value = 'Sem conexão e sem dados em cache.';
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _refreshInBackground() async {
    try {
      final result = await _api.fetchPostos();
      await _storage.save(result);
      postos.value = result;
      fromCache.value = false;
    } catch (_) {
      // mantém dados em cache silenciosamente
    }
  }
}
