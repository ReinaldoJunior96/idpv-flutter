import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

Future<String?> savePhoto(String name, Uint8List bytes) async {
  final dir = await getApplicationDocumentsDirectory();
  final photosDir = Directory('${dir.path}/vistoria_photos');
  if (!photosDir.existsSync()) {
    photosDir.createSync(recursive: true);
  }
  final file = File('${photosDir.path}/$name.jpg');
  await file.writeAsBytes(bytes);
  return file.path;
}

Future<Uint8List?> readPhoto(String path) async {
  final file = File(path);
  if (!file.existsSync()) return null;
  return file.readAsBytes();
}
