# Mi Catálogo de Productos

Aplicación sencilla en Flutter para la **Actividad Integradora 1** de Desarrollo de Aplicaciones Móviles.

## ¿Qué hace?

- **Pantalla 1 (HomeScreen):** muestra una lista de productos con su imagen, nombre y precio.
- **Pantalla 2 (DetailScreen):** muestra el detalle del producto elegido y un formulario para hacer un pedido.
- Al tocar **Ver** se pasa el producto a la Pantalla 2 con `Navigator.push`, y se regresa con `Navigator.pop`.

## Carpetas

```
lib/
  main.dart
  models/producto.dart
  screens/home_screen.dart
  screens/detail_screen.dart
  widgets/producto_card.dart
```

## Cómo ejecutar

```
flutter pub get
flutter run
```

Autor: Jefferson Ricardo Vera Macas
