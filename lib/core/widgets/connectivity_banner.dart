import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/vistoria/sync/sync_service.dart';

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final sync = Get.find<SyncService>();

    return Obx(() {
      final online = sync.isOnline.value;
      final syncing = sync.isSyncing.value;
      final pending = sync.pendingCount.value;
      final failed = sync.failedCount.value;

      if (!online) {
        return _Banner(
          color: Colors.grey.shade800,
          icon: Icons.wifi_off_rounded,
          text: pending > 0
              ? 'Offline · $pending vistoria(s) aguardando conexão'
              : 'Sem conexão',
        );
      }

      if (syncing) {
        return _Banner(
          color: Colors.blue.shade700,
          icon: Icons.sync_rounded,
          text: 'Sincronizando...',
          showSpinner: true,
        );
      }

      if (failed > 0) {
        return _Banner(
          color: Colors.red.shade700,
          icon: Icons.error_outline_rounded,
          text: '$failed vistoria(s) com falha · Toque para tentar novamente',
          onTap: sync.retryFailed,
        );
      }

      if (pending > 0) {
        return _Banner(
          color: Colors.orange.shade800,
          icon: Icons.schedule_rounded,
          text: '$pending vistoria(s) aguardando sincronização',
        );
      }

      return const SizedBox.shrink();
    });
  }
}

class _Banner extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  final bool showSpinner;
  final VoidCallback? onTap;

  const _Banner({
    required this.color,
    required this.icon,
    required this.text,
    this.showSpinner = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              if (showSpinner)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                Icon(icon, size: 14, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (onTap != null)
                const Icon(Icons.chevron_right, size: 16, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
