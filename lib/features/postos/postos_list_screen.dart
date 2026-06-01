import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'postos_controller.dart';
import 'posto_card.dart';
import '../vistoria/vistoria_screen.dart';

class PostosListScreen extends StatelessWidget {
  const PostosListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PostosController());

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              controller.postos.isEmpty
                  ? 'Postos'
                  : 'Postos (${controller.postos.length})',
            )),
        actions: [
          Obx(() => controller.isLoading.value
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => controller.loadPostos(forceRefresh: true),
                )),
        ],
      ),
      body: Column(
        children: [
          Obx(() => controller.fromCache.value
              ? _OfflineBanner()
              : const SizedBox.shrink()),
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
                return const Center(child: Text('Nenhum posto encontrado.'));
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

class _OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.amber.shade100,
      child: Row(
        children: [
          Icon(Icons.wifi_off, size: 16, color: Colors.amber.shade800),
          const SizedBox(width: 8),
          Text(
            'Exibindo dados em cache (offline)',
            style: TextStyle(color: Colors.amber.shade800, fontSize: 13),
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
            const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
