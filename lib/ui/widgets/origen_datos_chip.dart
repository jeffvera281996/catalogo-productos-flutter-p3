import 'package:flutter/material.dart';

import '../../data/repositories/producto_repository.dart';

/// Indica de donde vienen los productos mostrados (red, cache o semilla).
class OrigenDatosChip extends StatelessWidget {
  const OrigenDatosChip({super.key, required this.origen, this.fecha});

  final OrigenDatos? origen;
  final DateTime? fecha;

  @override
  Widget build(BuildContext context) {
    if (origen == null) return const SizedBox.shrink();
    final (IconData icono, String texto) = switch (origen!) {
      OrigenDatos.remoto => (Icons.cloud_done_outlined, 'Catalogo actualizado'),
      OrigenDatos.cache => (
        Icons.offline_pin_outlined,
        'Mostrando copia guardada${_hora(fecha)}',
      ),
      OrigenDatos.semilla => (Icons.inventory_2_outlined, 'Catalogo basico'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(texto, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  static String _hora(DateTime? f) {
    if (f == null) return '';
    String dos(int n) => n.toString().padLeft(2, '0');
    return ' (${dos(f.day)}/${dos(f.month)} ${dos(f.hour)}:${dos(f.minute)})';
  }
}
