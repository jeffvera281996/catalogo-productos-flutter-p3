import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/connectivity_provider.dart';

/// Banner flotante global de conectividad. Se inserta una sola vez en
/// `MaterialApp.builder`, por lo que aparece sobre todas las pantallas sin
/// que ninguna tenga que preocuparse por el estado de la red.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final estado = context.select<ConnectivityProvider, EstadoRed>(
      (p) => p.estado,
    );
    final visible = estado != EstadoRed.enLinea;
    final offline = estado == EstadoRed.sinConexion;
    final inferior = MediaQuery.paddingOf(context).bottom;

    return Stack(
      children: [
        child,
        Positioned(
          left: 16,
          right: 16,
          bottom: 16 + inferior,
          child: IgnorePointer(
            ignoring: !visible,
            child: AnimatedSlide(
              offset: visible ? Offset.zero : const Offset(0, 2),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              child: AnimatedOpacity(
                opacity: visible ? 1 : 0,
                duration: const Duration(milliseconds: 250),
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(14),
                  color: offline ? AppColors.ink : AppColors.success,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          offline ? Icons.wifi_off_rounded : Icons.wifi_rounded,
                          color: offline ? AppColors.accent : Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            offline
                                ? 'Sin conexion. Mostrando datos guardados; '
                                      'tus pedidos se enviaran al volver.'
                                : 'Conexion restablecida',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
