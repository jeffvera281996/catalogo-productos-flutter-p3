import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/producto.dart';
import '../../providers/pedido_provider.dart';
import '../widgets/producto_imagen.dart';

// Pantalla 2: detalle del producto y formulario de pedido
class DetailScreen extends StatefulWidget {
  final Producto producto; // dato que llega desde la Pantalla 1

  const DetailScreen({super.key, required this.producto});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _cantidadController = TextEditingController(text: '1');

  @override
  void dispose() {
    _nombreController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

  Future<void> _enviarPedido() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final resultado = await context.read<PedidoProvider>().crearPedido(
      producto: widget.producto,
      cliente: _nombreController.text.trim(),
      cantidad: int.parse(_cantidadController.text),
    );
    if (!mounted) return;

    final enviado = resultado == ResultadoPedido.enviado;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          enviado ? Icons.check_circle : Icons.schedule_send,
          color: enviado ? AppColors.success : AppColors.warning,
          size: 40,
        ),
        title: Text(enviado ? 'Pedido enviado' : 'Pedido guardado'),
        content: Text(
          enviado
              ? '${_nombreController.text} pidio ${_cantidadController.text} '
                    '${widget.producto.nombre}.'
              : 'No hay conexion. Tu pedido quedo guardado en el telefono y '
                    'se enviara automaticamente cuando vuelva internet.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final producto = widget.producto;
    final enviando = context.select<PedidoProvider, bool>((p) => p.enviando);

    return Scaffold(
      appBar: AppBar(title: Text(producto.nombre)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductoImagen(
                url: producto.imagen,
                width: double.infinity,
                height: 220,
                radio: 16,
              ),
              const SizedBox(height: 14),
              Text(
                producto.nombre,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                '\$${producto.precio.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(producto.descripcion),
              const Divider(height: 32),
              Text(
                'Hacer pedido',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nombreController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Tu nombre'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Escribe tu nombre'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cantidadController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Cantidad'),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Ingresa una cantidad valida';
                  if (n > 99) return 'Maximo 99 unidades';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: enviando ? null : _enviarPedido,
                  icon: enviando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send),
                  label: const Text('Enviar pedido'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Volver al catalogo'),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
