import 'package:flutter/material.dart';
import 'data/posto_model.dart';

class PostoCard extends StatelessWidget {
  final Posto posto;
  final VoidCallback? onTap;

  const PostoCard({super.key, required this.posto, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _bandeiraCor(posto.bandeira),
          child: Text(
            posto.bandeira[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          posto.nomeFantasia,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text('${posto.municipio} · ${posto.uf}',
                style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 6),
            Row(
              children: [
                _Chip(
                  label: posto.bandeira,
                  color: _bandeiraCor(posto.bandeira),
                ),
                const SizedBox(width: 6),
                _Chip(
                  label: _statusLabel(posto.status),
                  color: _statusCor(posto.status),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        isThreeLine: true,
        onTap: onTap,
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
      case 'raízen':
      case 'raizen':
        return const Color(0xFF0066CC);
      default:
        return const Color(0xFF607D8B);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'EM_IMPLANTACAO':
        return 'Em Implantação';
      case 'ATIVO':
        return 'Ativo';
      case 'INATIVO':
        return 'Inativo';
      default:
        return status;
    }
  }

  Color _statusCor(String status) {
    switch (status) {
      case 'EM_IMPLANTACAO':
        return Colors.orange;
      case 'ATIVO':
        return Colors.green;
      case 'INATIVO':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
