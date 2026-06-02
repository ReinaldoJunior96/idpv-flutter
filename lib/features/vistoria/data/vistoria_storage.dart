import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'vistoria_model.dart';

class VistoriaStorage {
  static const String _boxName = 'vistorias';

  Future<Box<String>> get _box => Hive.openBox<String>(_boxName);

  Future<void> save(Vistoria vistoria) async {
    final box = await _box;
    await box.put(vistoria.id, jsonEncode(vistoria.toJson()));
  }

  Future<List<Vistoria>> loadAll() async {
    final box = await _box;
    return box.values
        .map(
          (json) => Vistoria.fromJson(jsonDecode(json) as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<Vistoria>> loadPending() async {
    final all = await loadAll();
    // Inclui 'syncing' para recuperar de crashes durante uma sync anterior
    return all
        .where(
          (v) =>
              v.syncStatus == SyncStatus.pending ||
              v.syncStatus == SyncStatus.syncing,
        )
        .toList()
      // adiciona fila por FIFO(First In, First Out)
      ..sort((a, b) => a.dataHora.compareTo(b.dataHora));
  }

  Future<void> updateStatus(String id, SyncStatus status) async {
    final box = await _box;
    final json = box.get(id);
    if (json == null) return;
    final vistoria = Vistoria.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
    );
    await box.put(
      id,
      jsonEncode(vistoria.copyWith(syncStatus: status).toJson()),
    );
  }

  Future<void> updateResultados(String id, List<ItemResult> resultados) async {
    final box = await _box;
    final json = box.get(id);
    if (json == null) return;
    final vistoria = Vistoria.fromJson(
      jsonDecode(json) as Map<String, dynamic>,
    );
    await box.put(
      id,
      jsonEncode(vistoria.copyWith(resultados: resultados).toJson()),
    );
  }
}
