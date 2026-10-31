import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../widgets/producto_card.dart';
import 'detail_screen.dart';

// Pantalla 1: muestra la lista de productos
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Catalogo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            color: Colors.blue[50],
            child: const Row(
              children: [
                Icon(Icons.store, size: 40, color: Colors.blue),
                SizedBox(width: 10),
                Text('Bienvenido a la tienda', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: listaProductos.length,
              itemBuilder: (context, index) {
                return ProductoCard(
                  producto: listaProductos[index],
                  alPresionar: () {
                    // Ir a la Pantalla 2 enviando el producto seleccionado
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailScreen(producto: listaProductos[index]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
