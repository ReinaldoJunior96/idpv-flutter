import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/checklist_items.dart';
import '../data/vistoria_model.dart';
import '../vistoria_controller.dart';

class ChecklistItemCard extends StatelessWidget {
  final ChecklistItem item;
  final VistoriaController controller;

  const ChecklistItemCard({
    super.key,
    required this.item,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(item.icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  item.nome,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Text(
                item.descricao,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 12),

            // Botões de status
            Obx(() {
              final current = controller.statuses[item.id];
              return Row(
                children: ItemStatus.values.map((s) {
                  final selected = current == s;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              selected ? _statusColor(s) : Colors.grey.shade100,
                          foregroundColor:
                              selected ? Colors.white : Colors.grey.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => controller.setStatus(item.id, s),
                        child: Text(
                          s.label,
                          style: const TextStyle(fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            }),

            const SizedBox(height: 10),

            // Campo de observação
            TextField(
              controller: controller.textControllers[item.id],
              decoration: InputDecoration(
                hintText: 'Observação (opcional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
              maxLines: 2,
              textInputAction: TextInputAction.done,
            ),

            const SizedBox(height: 10),

            // Foto
            Obx(() {
              final bytes = controller.photoBytes[item.id];
              if (bytes != null) {
                return Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        bytes,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => controller.pickPhoto(item.id),
                      icon: const Icon(Icons.camera_alt, size: 16),
                      label: const Text('Trocar'),
                    ),
                  ],
                );
              }
              return TextButton.icon(
                onPressed: () => controller.pickPhoto(item.id),
                icon: const Icon(Icons.camera_alt, size: 16),
                label: const Text('Adicionar foto'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _statusColor(ItemStatus status) {
    switch (status) {
      case ItemStatus.conforme:
        return Colors.green.shade600;
      case ItemStatus.naoConforme:
        return Colors.red.shade600;
      case ItemStatus.naoSeAplica:
        return Colors.grey.shade500;
    }
  }
}
