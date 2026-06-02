import 'dart:typed_data';

import 'photo_storage_stub.dart'
    if (dart.library.io) 'photo_storage_native.dart';

/// Salva bytes no filesystem (native) ou retorna null (web).
Future<String?> savePhotoLocally(String name, Uint8List bytes) =>
    savePhoto(name, bytes);

/// Lê bytes do filesystem (native) ou retorna null (web).
Future<Uint8List?> readPhotoLocally(String path) => readPhoto(path);
