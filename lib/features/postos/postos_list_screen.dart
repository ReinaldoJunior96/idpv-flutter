import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/widgets/connectivity_banner.dart';
import 'postos_controller.dart';
import 'posto_card.dart';
import '../vistoria/vistoria_screen.dart';
import '../vistoria/sync/sync_service.dart';
import '../sync/sync_status_screen.dart';

class PostosListScreen extends StatelessWidget {
  const PostosListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PostosController());
    final sync = Get.find<SyncService>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              controller.postos.isEmpty
                  ? 'Postos'
                  : 'Postos (${controller.postos.length})',
            )),
        actions: [
          // Indicador de conectividade
          Obx(() => Icon(
                sync.isOnline.value ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                size: 20,
                color: sync.isOnline.value ? Colors.green : Colors.red,
              )),
          const SizedBox(width: 4),

          // Botão de status de sync com badge
          Obx(() {
            final count =
                sync.pendingCount.value + sync.failedCount.value;
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.sync_rounded),
                  tooltip: 'Status de sincronização',
                  onPressed: () => Get.to(() => const SyncStatusScreen()),
                ),
                if (count > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: sync.failedCount.value > 0
                            ? Colors.red
                            : Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          }),

          // Refresh da lista
          Obx(() => controller.isLoading.value
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () => controller.loadPostos(forceRefresh: true),
                )),
        ],
      ),
      body: Column(
        children: [
          // Banner de conectividade / sync
          const ConnectivityBanner(),

          // Banner de cache (dados offline)
          Obx(() => controller.fromCache.value
              ? _CacheBanner()
              : const SizedBox.shrink()),

          // Lista de postos
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.postos.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.error.value != null) {
                return _ErrorState(
                  message: controller.error.value!,
                  onRetry: () => controller.loadPostos(forceRefresh: true),
                );
              }

              if (controller.postos.isEmpty) {
                return const _EmptyState();
              }

              return RefreshIndicator(
                onRefresh: () => controller.loadPostos(forceRefresh: true),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: controller.postos.length,
                  itemBuilder: (_, i) => PostoCard(
                    posto: controller.postos[i],
                    onTap: () => Get.to(
                      () => VistoriaScreen(posto: controller.postos[i]),
                    ),
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

class _CacheBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.amber.shade100,
      child: Row(
        children: [
          Icon(Icons.history_rounded, size: 14, color: Colors.amber.shade800),
          const SizedBox(width: 8),
          Text(
            'Exibindo postos salvos localmente',
            style: TextStyle(color: Colors.amber.shade800, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Não foi possível carregar os postos',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
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
          Icon(Icons.store_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Nenhum posto encontrado',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
