import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/monedas.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formato.dart';
import '../../providers/divisas_provider.dart';
import '../widgets/tasa_card.dart';

/// Pantalla 4: tasas de cambio en tiempo real (API publica Frankfurter).
///
/// Permite ver cuanto vale un monto de la tienda en otras monedas.
/// Maneja los tres estados de la peticion y se actualiza con pull-to-refresh.
class DivisasScreen extends StatefulWidget {
  const DivisasScreen({super.key});

  @override
  State<DivisasScreen> createState() => _DivisasScreenState();
}

class _DivisasScreenState extends State<DivisasScreen> {
  late final TextEditingController _montoCtrl;

  @override
  void initState() {
    super.initState();
    final provider = context.read<DivisasProvider>();
    _montoCtrl = TextEditingController(text: _textoMonto(provider.monto));
    // Se consulta la API al abrir la pantalla. Si ya habia datos, se
    // refrescan en segundo plano sin ocultar la lista.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) provider.cargar(refrescar: true);
    });
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    super.dispose();
  }

  static String _textoMonto(double m) =>
      m == m.roundToDouble() ? m.toStringAsFixed(0) : m.toString();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DivisasProvider>();
    final estado = provider.estado;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Divisas'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: provider.cargando ? null : () => provider.cargar(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          _Encabezado(
            provider: provider,
            montoCtrl: _montoCtrl,
          ),
          // Barra fina de progreso cuando se refresca con datos visibles.
          SizedBox(
            height: 3,
            child: provider.cargando && estado is DivisasExito
                ? const LinearProgressIndicator(color: AppColors.accent)
                : null,
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => provider.cargar(refrescar: true),
              // Pattern matching sobre la jerarquia sealed: el compilador
              // exige cubrir Cargando, Exito y Error.
              child: switch (estado) {
                DivisasCargando() => const _VistaCargando(),
                DivisasExito(:final datos) => ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 6, bottom: 32),
                  itemCount: datos.tasas.length,
                  itemBuilder: (_, i) => TasaCard(
                    tasa: datos.tasas[i],
                    base: datos.base,
                    monto: provider.monto,
                  ),
                ),
                DivisasError(:final mensaje, :final sinConexion) => _VistaError(
                  mensaje: mensaje,
                  sinConexion: sinConexion,
                  alReintentar: () => provider.cargar(),
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.provider, required this.montoCtrl});

  final DivisasProvider provider;
  final TextEditingController montoCtrl;

  @override
  Widget build(BuildContext context) {
    final estado = provider.estado;
    final fecha = estado is DivisasExito ? estado.datos.fecha : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Precios en tu moneda',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: montoCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: 'Monto en ${provider.base}',
                    prefixIcon: const Icon(Icons.payments_outlined),
                  ),
                  onChanged: (texto) {
                    final valor =
                        double.tryParse(texto.replaceAll(',', '.')) ?? 0;
                    provider.actualizarMonto(valor);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final codigo in Monedas.bases)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('${Monedas.bandera(codigo)} $codigo'),
                      selected: provider.base == codigo,
                      onSelected: provider.cargando
                          ? null
                          : (_) => provider.cambiarBase(codigo),
                      selectedColor: AppColors.accent,
                      labelStyle: TextStyle(
                        color: provider.base == codigo
                            ? Colors.white
                            : AppColors.ink,
                        fontWeight: FontWeight.w600,
                      ),
                      showCheckmark: false,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.public, size: 14, color: Colors.white70),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  fecha == null
                      ? 'Fuente: Banco Central Europeo (API Frankfurter)'
                      : 'Tasas del BCE al ${Formato.fecha(fecha)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Estado Cargando: lista de tarjetas esqueleto.
class _VistaCargando extends StatelessWidget {
  const _VistaCargando();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const Key('divisas-cargando'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 6),
      itemCount: 8,
      itemBuilder: (_, _) => const TasaCardSkeleton(),
    );
  }
}

/// Estado Error: mensaje claro, accion de reintento y pull-to-refresh.
class _VistaError extends StatelessWidget {
  const _VistaError({
    required this.mensaje,
    required this.sinConexion,
    required this.alReintentar,
  });

  final String mensaje;
  final bool sinConexion;
  final VoidCallback alReintentar;

  @override
  Widget build(BuildContext context) {
    // Se envuelve en un scroll para que el RefreshIndicator siga
    // funcionando aunque el contenido no ocupe toda la pantalla.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      sinConexion
                          ? Icons.wifi_off_rounded
                          : Icons.cloud_off_rounded,
                      size: 42,
                      color: AppColors.danger,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    sinConexion
                        ? 'No pudimos conectarnos'
                        : 'No se pudieron cargar las tasas',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    mensaje,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: alReintentar,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'o desliza hacia abajo para actualizar',
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
