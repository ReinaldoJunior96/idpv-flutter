import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../data/vistoria_model.dart';
import '../data/vistoria_storage.dart';
import 'vistoria_api.dart';

class SyncService extends GetxService {
  final _storage = VistoriaStorage();
  final _api = VistoriaApi();

  final isSyncing = false.obs;
  final isOnline = true.obs;
  final pendingCount = 0.obs;
  final failedCount = 0.obs;

  StreamSubscription? _connectivitySub;

  @override
  void onInit() {
    super.onInit();
    _resetStuckSyncing();
    _listenConnectivity();
    _updateCounts();
    syncPending();
  }

  Future<void> _resetStuckSyncing() async {
    final all = await _storage.loadAll();
    for (final v in all.where((v) => v.syncStatus == SyncStatus.syncing)) {
      await _storage.updateStatus(v.id, SyncStatus.pending);
    }
  }

  void _listenConnectivity() {
    // Estado inicial
    Connectivity().checkConnectivity().then((results) {
      isOnline.value = !results.contains(ConnectivityResult.none);
    });

    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final online = !results.contains(ConnectivityResult.none);
      isOnline.value = online;
      if (online) syncPending();
    });
  }

  Future<void> _updateCounts() async {
    final all = await _storage.loadAll();
    pendingCount.value = all
        .where((v) => v.syncStatus == SyncStatus.pending)
        .length;
    failedCount.value = all
        .where((v) => v.syncStatus == SyncStatus.failed)
        .length;
  }

  Future<void> syncPending() async {
    if (isSyncing.value) return;

    final pending = await _storage.loadPending();
    if (pending.isEmpty) return;

    isSyncing.value = true;
    try {
      for (final vistoria in pending) {
        await _syncOne(vistoria);
        await _updateCounts(); // atualiza badge após cada vistoria, não só no final
      }
    } finally {
      isSyncing.value = false;
      await _updateCounts();
    }
  }

  /// Recoloca todas as vistorias com falha na fila e tenta sincronizar.
  Future<void> retryFailed() async {
    final all = await _storage.loadAll();
    for (final v in all.where((v) => v.syncStatus == SyncStatus.failed)) {
      await _storage.updateStatus(v.id, SyncStatus.pending);
    }
    await _updateCounts();
    await syncPending();
  }

  Future<void> _syncOne(Vistoria vistoria) async {
    try {
      await _storage.updateStatus(vistoria.id, SyncStatus.syncing);
      // Apenas para testar a sync no caso o app fechando no meio, coloquei 8 segundo para testar a sync
      if (const bool.fromEnvironment('SLOW_SYNC')) {
        await Future.delayed(const Duration(seconds: 8));
      }

      final resultadosAtualizados = await _uploadFotos(vistoria);
      await _storage.updateResultados(vistoria.id, resultadosAtualizados);

      final vistoriaComUrls = vistoria.copyWith(
        resultados: resultadosAtualizados,
      );
      await _api.postVistoria(vistoriaComUrls);

      await _storage.updateStatus(vistoria.id, SyncStatus.synced);
    } catch (_) {
      // Marca como falhou — requer ação do usuário ou nova tentativa manual
      await _storage.updateStatus(vistoria.id, SyncStatus.failed);
    }
  }

  Future<List<ItemResult>> _uploadFotos(Vistoria vistoria) async {
    final resultado = <ItemResult>[];
    for (final item in vistoria.resultados) {
      if (item.photoBase64 != null && item.fotoUrl == null) {
        try {
          final bytes = base64Decode(item.photoBase64!);
          final url = await _api.uploadFoto(vistoria.id, item.itemId, bytes);
          resultado.add(item.copyWith(fotoUrl: url));
        } catch (_) {
          resultado.add(item);
        }
      } else {
        resultado.add(item);
      }
    }
    return resultado;
  }

  @override
  void onClose() {
    _connectivitySub?.cancel();
    super.onClose();
  }
}
