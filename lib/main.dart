import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/postos/postos_list_screen.dart';
import 'features/vistoria/sync/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Get.put(SyncService());
  runApp(const VistoriaApp());
}

class VistoriaApp extends StatelessWidget {
  const VistoriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Vistoria Postos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      home: const PostosListScreen(),
    );
  }
}
