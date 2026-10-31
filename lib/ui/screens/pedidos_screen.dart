import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/pedido.dart';
import '../../providers/pedido_provider.dart';

/// Historial de pedidos guardados en el dispositivo y su estado de envio.
class PedidosScreen extends StatelessWidget {
  const PedidosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pedidos = context.watch<PedidoProvider>().pedidos;

    return Scaffold(
      appBar: AppBar(title: const Text('Mis pedidos')),
      body: pedidos.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Aun no tienes pedidos.\nElige un producto del catalogo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 10, bottom: 96),
              itemCount: pedidos.length,
              itemBuilder: (_, i) => _PedidoTile(pedido: pedidos[i]),
            ),
    );
  }
}

class _PedidoTile extends StatelessWidget {
  const _PedidoTile({required this.pedido});

  final Pedido pedido;

  @override
  Widget build(BuildContext context) {
    final pendiente = pedido.estaPendiente;
    final color = pendiente ? AppColors.warning : AppColors.success;
    final foto = pedido.fotoPath;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 52,
            height: 52,
            child: foto != null && File(foto).existsSync()
                ? Image.file(File(foto), fit: BoxFit.cover)
                : Container(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: AppColors.primary,
                    ),
                  ),
          ),
        ),
        title: Text(
          '${pedido.cantidad} x ${pedido.productoNombre}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${pedido.cliente} - \$${pedido.total.toStringAsFixed(2)}',
        ),
        trailing: Chip(
          visualDensity: VisualDensity.compact,
          side: BorderSide.none,
          backgroundColor: color.withValues(alpha: 0.14),
          avatar: Icon(
            pendiente ? Icons.schedule : Icons.cloud_done,
            size: 16,
            color: color,
          ),
          label: Text(
            pendiente ? 'Pendiente' : 'Enviado',
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
