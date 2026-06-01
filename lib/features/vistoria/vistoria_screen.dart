import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../postos/data/posto_model.dart';
import 'data/checklist_items.dart';
import 'vistoria_controller.dart';
import 'widgets/checklist_item_card.dart';

class VistoriaScreen extends StatelessWidget {
  final Posto posto;

  const VistoriaScreen({super.key, required this.posto});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VistoriaController(posto: posto), tag: posto.id);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              posto.nome,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${posto.cidade} · ${posto.estado}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Barra de progresso
          Obx(() {
            final answered = controller.answeredCount;
            final total = kChecklist.length;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progresso',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      Text(
                        '$answered / $total',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: answered / total,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            );
          }),

          // Lista de itens
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 100),
              itemCount: kChecklist.length,
              itemBuilder: (_, i) => ChecklistItemCard(
                item: kChecklist[i],
                controller: controller,
              ),
            ),
          ),
        ],
      ),

      // Botão finalizar
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Obx(() => FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: controller.isSaving.value ? null : controller.submit,
                child: controller.isSaving.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Finalizar Vistoria'),
              )),
        ),
      ),
    );
  }
}
