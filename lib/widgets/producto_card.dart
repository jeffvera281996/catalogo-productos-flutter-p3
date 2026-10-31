import 'package:flutter/material.dart';

import '../models/producto.dart';

// Tarjeta que muestra un producto en la lista
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
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                producto.imagen,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.attach_money,
                        size: 16,
                        color: Colors.green,
                      ),
                      Text('${producto.precio}'),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(onPressed: alPresionar, child: const Text('Ver')),
          ],
        ),
      ),
    );
  }
}
