import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'posto_model.dart';

class PostosStorage {
  static const String _boxName = 'cache';
  static const String _key = 'postos';

  Future<void> save(List<Posto> postos) async {
    final box = await Hive.openBox<String>(_boxName);
    await box.put(_key, jsonEncode(postos.map((p) => p.toJson()).toList()));
  }

  Future<List<Posto>?> load() async {
    final box = await Hive.openBox<String>(_boxName);
    final json = box.get(_key);
    if (json == null) return null;
    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map((e) => Posto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
