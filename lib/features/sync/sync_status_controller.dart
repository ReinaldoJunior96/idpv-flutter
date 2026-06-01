import 'package:get/get.dart';
import '../vistoria/data/vistoria_model.dart';
import '../vistoria/data/vistoria_storage.dart';
import '../vistoria/sync/sync_service.dart';

class SyncStatusController extends GetxController {
  final _storage = VistoriaStorage();

  final vistorias = <Vistoria>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();

    // Recarrega sempre que o SyncService muda de estado
    final sync = Get.find<SyncService>();
    ever(sync.isSyncing, (_) => load());
    ever(sync.pendingCount, (_) => load());
    ever(sync.failedCount, (_) => load());
  }

  Future<void> load() async {
    final all = await _storage.loadAll();
    all.sort((a, b) => b.dataHora.compareTo(a.dataHora));
    vistorias.value = all;
    isLoading.value = false;
  }

  Future<void> retryAll() => Get.find<SyncService>().retryFailed();

  Future<void> retrySingle(Vistoria vistoria) async {
    await _storage.updateStatus(vistoria.id, SyncStatus.pending);
    await Get.find<SyncService>().syncPending();
    await load();
  }
}
