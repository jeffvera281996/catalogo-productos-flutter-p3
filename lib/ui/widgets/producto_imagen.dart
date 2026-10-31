import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Imagen remota con cache en disco: una vez vista, se muestra tambien
/// sin conexion. Si falla, muestra un icono neutro en vez de un error rojo.
class ProductoImagen extends StatelessWidget {
  const ProductoImagen({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.radio = 12,
  });

  final String url;
  final double? width;
  final double? height;
  final double radio;

  @override
  Widget build(BuildContext context) {
    final fondo = Container(
      width: width,
      height: height,
      color: AppColors.primary.withValues(alpha: 0.06),
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: AppColors.muted),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(radio),
      child: url.isEmpty
          ? fondo
          : CachedNetworkImage(
              imageUrl: url,
              width: width,
              height: height,
              fit: BoxFit.cover,
              placeholder: (_, _) => fondo,
              errorWidget: (_, _, _) => fondo,
            ),
    );
  }
}
