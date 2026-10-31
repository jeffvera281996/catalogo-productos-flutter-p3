import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/catalogo_provider.dart';
import '../../providers/pedido_provider.dart';
import '../widgets/origen_datos_chip.dart';
import '../widgets/producto_card.dart';
import 'detail_screen.dart';

// Pantalla 1: catalogo de productos
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalogo = context.watch<CatalogoProvider>();
    final pendientes = context.select<PedidoProvider, int>((p) => p.pendientes);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            tooltip: 'Mis pedidos',
            onPressed: () => Navigator.pushNamed(context, Rutas.pedidos),
            icon: Badge(
              isLabelVisible: pendientes > 0,
              backgroundColor: AppColors.accent,
              label: Text('$pendientes'),
              child: const Icon(Icons.receipt_long_outlined),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            decoration: const BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hola, bienvenido',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  AppStrings.slogan,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                OrigenDatosChip(
                  origen: catalogo.origen,
                  fecha: catalogo.actualizado,
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<CatalogoProvider>().cargar(),
              child: _Lista(catalogo: catalogo),
            ),
          ),
        ],
      ),
    );
  }
}

class _Lista extends StatelessWidget {
  const _Lista({required this.catalogo});

  final CatalogoProvider catalogo;

  @override
  Widget build(BuildContext context) {
    if (catalogo.productos.isEmpty && catalogo.cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    final productos = catalogo.productos;
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 10, bottom: 96),
      itemCount: productos.length,
      itemBuilder: (context, index) {
        final producto = productos[index];
        return ProductoCard(
          producto: producto,
          alPresionar: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailScreen(producto: producto),
            ),
          ),
        );
      },
    );
  }
}
