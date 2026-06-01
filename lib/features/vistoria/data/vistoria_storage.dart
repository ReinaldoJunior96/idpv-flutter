import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'vistoria_model.dart';

class VistoriaStorage {
  static const String _boxName = 'vistorias';

  Future<void> save(Vistoria vistoria) async {
    final box = await Hive.openBox<String>(_boxName);
    await box.put(vistoria.id, jsonEncode(vistoria.toJson()));
  }

  Future<List<Vistoria>> loadAll() async {
    final box = await Hive.openBox<String>(_boxName);
    return box.values
        .map((json) =>
            Vistoria.fromJson(jsonDecode(json) as Map<String, dynamic>))
        .toList();
  }
}
