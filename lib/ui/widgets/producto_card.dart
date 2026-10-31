import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/producto.dart';
import 'producto_imagen.dart';

// Tarjeta de producto con el estilo NexoShop
class ProductoCard extends StatelessWidget {
  final Producto producto;
  final VoidCallback alPresionar;

  const ProductoCard({
    super.key,
    required this.producto,
    required this.alPresionar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: alPresionar,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ProductoImagen(url: producto.imagen, width: 84, height: 84),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      producto.categoria,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '\$${producto.precio.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.accent),
            ],
          ),
        ),
      ),
    );
  }
}
