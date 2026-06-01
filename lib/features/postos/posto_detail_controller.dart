import 'package:get/get.dart';
import '../vistoria/data/vistoria_model.dart';
import '../vistoria/data/vistoria_storage.dart';
import '../vistoria/sync/sync_service.dart';
import 'data/posto_model.dart';

class PostoDetailController extends GetxController {
  final Posto posto;
  final _storage = VistoriaStorage();

  PostoDetailController({required this.posto});

  final vistorias = <Vistoria>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
    ever(Get.find<SyncService>().isSyncing, (_) => load());
  }

  Future<void> load() async {
    final all = await _storage.loadAll();
    final filtered = all
        .where((v) => v.postoId == posto.id)
        .toList()
      ..sort((a, b) => b.dataHora.compareTo(a.dataHora));
    vistorias.value = filtered;
    isLoading.value = false;
  }
}
