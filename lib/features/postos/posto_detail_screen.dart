import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../vistoria/data/vistoria_model.dart';
import '../vistoria/vistoria_screen.dart';
import 'data/posto_model.dart';
import 'posto_detail_controller.dart';

class PostoDetailScreen extends StatelessWidget {
  final Posto posto;

  const PostoDetailScreen({super.key, required this.posto});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PostoDetailController(posto: posto), tag: posto.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(posto.nome),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Get.to(() => VistoriaScreen(posto: posto));
          controller.load();
        },
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('Nova Vistoria'),
      ),
      body: CustomScrollView(
        slivers: [
          // Card de info do posto
          SliverToBoxAdapter(
            child: _PostoInfoCard(posto: posto),
          ),

          // Título da seção
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Histórico de Vistorias',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          // Lista de vistorias
          Obx(() {
            if (controller.isLoading.value) {
              return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (controller.vistorias.isEmpty) {
              return const SliverFillRemaining(
                child: _EmptyHistory(),
              );
            }

            return SliverList.builder(
              itemCount: controller.vistorias.length,
              itemBuilder: (_, i) =>
                  _VistoriaHistoryCard(vistoria: controller.vistorias[i]),
            );
          }).value,
        ],
      ),
    );
  }
}

// Extensão para poder usar Obx dentro de SliverList
extension on Obx {
  Widget get value => this;
}

class _PostoInfoCard extends StatelessWidget {
  final Posto posto;

  const _PostoInfoCard({required this.posto});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _bandeiraCor(posto.bandeira),
                  radius: 22,
                  child: Text(
                    posto.bandeira[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        posto.nome,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        posto.bandeira,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _bandeiraCor(posto.bandeira),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (posto.jaAuditado)
                  const _StatusChip(
                    label: 'Auditado',
                    color: Colors.green,
                  ),
              ],
            ),
            const Divider(height: 24),
            _InfoRow(icon: Icons.location_on_rounded, text: posto.endereco),
            const SizedBox(height: 4),
            _InfoRow(
              icon: Icons.place_rounded,
              text: '${posto.cidade} · ${posto.estado}',
            ),
          ],
        ),
      ),
    );
  }

  Color _bandeiraCor(String bandeira) {
    switch (bandeira.toLowerCase()) {
      case 'ipiranga':
        return const Color(0xFFFF6B00);
      case 'shell':
        return const Color(0xFFDD1E2F);
      case 'petrobras':
        return const Color(0xFF009B3A);
      case 'ale':
        return const Color(0xFF003087);
      default:
        return const Color(0xFF607D8B);
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }
}

class _VistoriaHistoryCard extends StatelessWidget {
  final Vistoria vistoria;

  const _VistoriaHistoryCard({required this.vistoria});

  @override
  Widget build(BuildContext context) {
    final dt = vistoria.dataHora;
    final dateStr =
        '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    final conformes = vistoria.resultados
        .where((r) => r.status == ItemStatus.conforme)
        .length;
    final naoConformes = vistoria.resultados
        .where((r) => r.status == ItemStatus.naoConforme)
        .length;
    final naoAplica = vistoria.resultados
        .where((r) => r.status == ItemStatus.naoSeAplica)
        .length;

    final (color, icon, label) = _syncInfo(vistoria.syncStatus);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 13, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                _StatusChip(label: label, color: color, icon: icon),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _ResultadoBadge(
                  count: conformes,
                  label: 'Conforme',
                  color: Colors.green,
                  icon: Icons.check_circle_outline_rounded,
                ),
                const SizedBox(width: 8),
                if (naoConformes > 0) ...[
                  _ResultadoBadge(
                    count: naoConformes,
                    label: 'Não Conforme',
                    color: Colors.red,
                    icon: Icons.cancel_outlined,
                  ),
                  const SizedBox(width: 8),
                ],
                if (naoAplica > 0)
                  _ResultadoBadge(
                    count: naoAplica,
                    label: 'N/A',
                    color: Colors.grey,
                    icon: Icons.remove_circle_outline_rounded,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  (Color, IconData, String) _syncInfo(SyncStatus status) {
    switch (status) {
      case SyncStatus.pending:
        return (Colors.orange, Icons.schedule_rounded, 'Pendente');
      case SyncStatus.syncing:
        return (Colors.blue, Icons.sync_rounded, 'Enviando...');
      case SyncStatus.synced:
        return (Colors.green, Icons.cloud_done_rounded, 'Sincronizado');
      case SyncStatus.failed:
        return (Colors.red, Icons.error_outline_rounded, 'Falhou');
    }
  }
}

class _ResultadoBadge extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final IconData icon;

  const _ResultadoBadge({
    required this.count,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 3),
        Text(
          '$count $label',
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _StatusChip({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.assignment_outlined,
              size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Nenhuma vistoria registrada',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 6),
          Text(
            'Toque em "Nova Vistoria" para começar',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
