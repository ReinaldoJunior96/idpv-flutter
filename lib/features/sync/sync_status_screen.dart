import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../vistoria/data/vistoria_model.dart';
import '../vistoria/sync/sync_service.dart';
import 'sync_status_controller.dart';

class SyncStatusScreen extends StatelessWidget {
  const SyncStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SyncStatusController());
    final sync = Get.find<SyncService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sincronização'),
        actions: [
          Obx(() => sync.failedCount.value > 0
              ? TextButton.icon(
                  onPressed: controller.retryAll,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar todas'),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Column(
        children: [
          // Status geral de conectividade
          Obx(() => _ConnectivityHeader(
                isOnline: sync.isOnline.value,
                isSyncing: sync.isSyncing.value,
                pending: sync.pendingCount.value,
                failed: sync.failedCount.value,
              )),

          // Lista de vistorias
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.vistorias.isEmpty) {
                return const _EmptyState();
              }

              return RefreshIndicator(
                onRefresh: controller.load,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: controller.vistorias.length,
                  itemBuilder: (_, i) => _VistoriaCard(
                    vistoria: controller.vistorias[i],
                    onRetry: () =>
                        controller.retrySingle(controller.vistorias[i]),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ConnectivityHeader extends StatelessWidget {
  final bool isOnline;
  final bool isSyncing;
  final int pending;
  final int failed;

  const _ConnectivityHeader({
    required this.isOnline,
    required this.isSyncing,
    required this.pending,
    required this.failed,
  });

  @override
  Widget build(BuildContext context) {
    final (color, icon, text) = switch ((isOnline, isSyncing, failed > 0)) {
      (false, _, _) => (
          Colors.grey.shade700,
          Icons.wifi_off_rounded,
          'Sem conexão · vistorias serão enviadas ao voltar online',
        ),
      (true, true, _) => (
          Colors.blue.shade700,
          Icons.sync_rounded,
          'Sincronizando vistorias...',
        ),
      (true, false, true) => (
          Colors.red.shade700,
          Icons.error_outline_rounded,
          '$failed vistoria(s) com falha de sincronização',
        ),
      (true, false, false) when pending > 0 => (
          Colors.orange.shade800,
          Icons.schedule_rounded,
          '$pending vistoria(s) na fila de sincronização',
        ),
      _ => (
          Colors.green.shade700,
          Icons.cloud_done_rounded,
          'Tudo sincronizado',
        ),
    };

    return Container(
      width: double.infinity,
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (isSyncing && isOnline)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          else
            Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VistoriaCard extends StatelessWidget {
  final Vistoria vistoria;
  final VoidCallback onRetry;

  const _VistoriaCard({required this.vistoria, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = _statusInfo(vistoria.syncStatus);
    final dt = vistoria.dataHora;
    final dateStr =
        '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    vistoria.postoNome,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                _StatusChip(label: label, color: color, icon: icon),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              dateStr,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            Text(
              '${vistoria.resultados.length} itens vistoriados',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            if (vistoria.syncStatus == SyncStatus.failed) ...[
              const SizedBox(height: 12),
              const Text(
                'Não foi possível enviar esta vistoria. Verifique sua conexão e tente novamente.',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Tentar novamente'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  (Color, IconData, String) _statusInfo(SyncStatus status) {
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

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusChip(
      {required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.task_alt, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Nenhuma vistoria registrada',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
