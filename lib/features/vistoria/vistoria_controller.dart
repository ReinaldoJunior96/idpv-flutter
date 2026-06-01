import 'package:flutter/material.dart' show TextEditingController;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../postos/data/posto_model.dart';
import 'data/checklist_items.dart';
import 'data/vistoria_model.dart';
import 'data/vistoria_storage.dart';

class VistoriaController extends GetxController {
  final Posto posto;
  final _storage = VistoriaStorage();
  final _picker = ImagePicker();

  VistoriaController({required this.posto});

  final statuses = <String, ItemStatus>{}.obs;
  // bytes para exibir a foto na UI (funciona em web e native)
  final photoBytes = <String, Uint8List>{}.obs;
  // path para salvar no modelo (somente native)
  final _photoPaths = <String, String>{};
  final isSaving = false.obs;

  late final Map<String, TextEditingController> textControllers;

  @override
  void onInit() {
    super.onInit();
    textControllers = {
      for (final item in kChecklist)
        item.id: TextEditingController(),
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
    if (!kIsWeb) _photoPaths[itemId] = xfile.path;
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
      final vistoria = Vistoria(
        id: const Uuid().v4(),
        postoId: posto.id,
        postoNomeFantasia: posto.nomeFantasia,
        dataHora: DateTime.now(),
        resultados: kChecklist.map((item) {
          final obs = textControllers[item.id]!.text.trim();
          return ItemResult(
            itemId: item.id,
            status: statuses[item.id]!,
            observacao: obs.isEmpty ? null : obs,
            photoPath: _photoPaths[item.id],
          );
        }).toList(),
      );

      await _storage.save(vistoria);
      Get.back();
      Get.snackbar(
        'Vistoria salva',
        posto.nomeFantasia,
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
