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
  final pendingCount = 0.obs;

  StreamSubscription? _connectivitySub;

  @override
  void onInit() {
    super.onInit();
    _resetStuckSyncing();
    _listenConnectivity();
    syncPending();
  }

  /// Reseta vistorias que ficaram em 'syncing' por crash do app.
  Future<void> _resetStuckSyncing() async {
    final all = await _storage.loadAll();
    for (final v in all.where((v) => v.syncStatus == SyncStatus.syncing)) {
      await _storage.updateStatus(v.id, SyncStatus.pending);
    }
  }

  void _listenConnectivity() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final online = !results.contains(ConnectivityResult.none);
      if (online) syncPending();
    });
  }

  Future<void> syncPending() async {
    if (isSyncing.value) return;

    final pending = await _storage.loadPending();
    pendingCount.value = pending.length;
    if (pending.isEmpty) return;

    isSyncing.value = true;
    try {
      for (final vistoria in pending) {
        await _syncOne(vistoria);
      }
    } finally {
      isSyncing.value = false;
      final remaining = await _storage.loadPending();
      pendingCount.value = remaining.length;
    }
  }

  Future<void> _syncOne(Vistoria vistoria) async {
    try {
      await _storage.updateStatus(vistoria.id, SyncStatus.syncing);

      // 1. Upload fotos e coleta URLs
      final resultadosAtualizados = await _uploadFotos(vistoria);

      // 2. Salva URLs localmente antes de postar (garante que não perdemos as URLs)
      await _storage.updateResultados(vistoria.id, resultadosAtualizados);

      // 3. Envia vistoria com URLs para o servidor
      final vistoriaComUrls = vistoria.copyWith(resultados: resultadosAtualizados);
      await _api.postVistoria(vistoriaComUrls);

      await _storage.updateStatus(vistoria.id, SyncStatus.synced);
    } catch (_) {
      // Volta para pending — será retentado na próxima conexão
      await _storage.updateStatus(vistoria.id, SyncStatus.pending);
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
          resultado.add(item); // continua sem a foto se o upload falhar
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
