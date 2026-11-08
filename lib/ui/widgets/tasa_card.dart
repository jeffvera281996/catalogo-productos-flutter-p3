import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formato.dart';
import '../../data/models/tasa_cambio.dart';

/// Tarjeta de una moneda: bandera, codigo, nombre, monto convertido y la
/// tasa unitaria respecto a la moneda base.
class TasaCard extends StatelessWidget {
  const TasaCard({
    super.key,
    required this.tasa,
    required this.base,
    required this.monto,
  });

  final TasaCambio tasa;
  final String base;
  final double monto;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(tasa.bandera, style: const TextStyle(fontSize: 26)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tasa.codigo,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tasa.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formato.numero(tasa.convertir(monto)),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '1 $base = ${Formato.numero(tasa.valor)}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta "esqueleto" que se muestra en el estado Cargando. Su opacidad
/// pulsa para indicar actividad sin bloquear la pantalla con un spinner.
class TasaCardSkeleton extends StatefulWidget {
  const TasaCardSkeleton({super.key});

  @override
  State<TasaCardSkeleton> createState() => _TasaCardSkeletonState();
}

class _TasaCardSkeletonState extends State<TasaCardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    lowerBound: 0.35,
    upperBound: 1,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget barra(double ancho, double alto) => Container(
      width: ancho,
      height: alto,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
    );

    return FadeTransition(
      opacity: _ctrl,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              barra(48, 48),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    barra(56, 14),
                    const SizedBox(height: 8),
                    barra(120, 10),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  barra(70, 16),
                  const SizedBox(height: 8),
                  barra(90, 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
