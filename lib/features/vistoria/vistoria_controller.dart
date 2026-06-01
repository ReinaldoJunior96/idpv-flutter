import 'dart:convert';
import 'package:flutter/material.dart' show TextEditingController;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../postos/data/posto_model.dart';
import 'data/checklist_items.dart';
import 'data/vistoria_model.dart';
import 'data/vistoria_storage.dart';
import 'sync/sync_service.dart';

class VistoriaController extends GetxController {
  final Posto posto;
  final _storage = VistoriaStorage();
  final _picker = ImagePicker();

  VistoriaController({required this.posto});

  final statuses = <String, ItemStatus>{}.obs;
  final photoBytes = <String, Uint8List>{}.obs;
  final isSaving = false.obs;

  late final String _startedAt;
  late final Map<String, TextEditingController> textControllers;

  @override
  void onInit() {
    super.onInit();
    _startedAt = DateTime.now().toUtc().toIso8601String();
    textControllers = {
      for (final item in kChecklist) item.id: TextEditingController(),
    };
  }

  @override
  void onClose() {
    for (final c in textControllers.values) {
      c.dispose();
    }
    super.onClose();
  }

  void setStatus(String itemId, ItemStatus status) {
    statuses[itemId] = status;
  }

  Future<void> pickPhoto(String itemId) async {
    final xfile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (xfile == null) return;
    final bytes = await xfile.readAsBytes();
    photoBytes[itemId] = bytes;
  }

  int get answeredCount => statuses.length;
  bool get allAnswered => statuses.length == kChecklist.length;

  Future<void> submit() async {
    if (!allAnswered) {
      Get.snackbar(
        'Atenção',
        'Responda todos os ${kChecklist.length} itens antes de finalizar.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSaving.value = true;
    try {
      final finishedAt = DateTime.now().toUtc().toIso8601String();

      final vistoria = Vistoria(
        id: const Uuid().v4(),
        postoId: posto.id,
        postoNome: posto.nome,
        dataHora: DateTime.now(),
        startedAt: _startedAt,
        finishedAt: finishedAt,
        syncStatus: SyncStatus.pending,
        resultados: kChecklist.map((item) {
          final obs = textControllers[item.id]!.text.trim();
          final bytes = photoBytes[item.id];
          return ItemResult(
            itemId: item.id,
            status: statuses[item.id]!,
            observacao: obs.isEmpty ? null : obs,
            photoBase64: bytes != null ? base64Encode(bytes) : null,
          );
        }).toList(),
      );

      // Salva localmente — não pode ser perdido
      await _storage.save(vistoria);

      // Dispara sync imediatamente (sem await — não bloqueia o promotor)
      Get.find<SyncService>().syncPending();

      Get.back();
      Get.snackbar(
        'Vistoria salva',
        posto.nome,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Erro',
        'Não foi possível salvar a vistoria.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }
}
