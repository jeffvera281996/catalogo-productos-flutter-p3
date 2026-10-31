import 'package:flutter/material.dart';

import '../models/producto.dart';

// Pantalla 2: muestra el detalle del producto y un formulario
class DetailScreen extends StatefulWidget {
  final Producto producto; // dato que llega desde la Pantalla 1

  const DetailScreen({super.key, required this.producto});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final nombreController = TextEditingController();
  final cantidadController = TextEditingController();

  void enviarPedido() {
    if (nombreController.text.isEmpty || cantidadController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Llena todos los campos')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pedido enviado'),
          content: Text(
            '${nombreController.text} pidio ${cantidadController.text} '
            '${widget.producto.nombre}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.producto.nombre),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.producto.imagen,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 10),
            Text(
              widget.producto.nombre,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Precio: \$${widget.producto.precio}',
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
            const SizedBox(height: 10),
            Text(widget.producto.descripcion),
            const Divider(height: 30),
            const Text(
              'Hacer pedido',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Tu nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: cantidadController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: enviarPedido,
              child: const Text('Enviar pedido'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              // Regresar a la Pantalla 1
              onPressed: () => Navigator.pop(context),
              child: const Text('Volver al catalogo'),
            ),
          ],
        ),
      ),
    );
  }
}
