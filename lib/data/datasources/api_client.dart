import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/errors/app_exceptions.dart';

/// Cliente HTTP minimo. Centraliza URL base, timeout y la traduccion de
/// errores de red a excepciones de dominio.
class ApiClient {
  ApiClient({http.Client? cliente, this.baseUrl = 'https://dummyjson.com'})
    : _cliente = cliente ?? http.Client();

  final http.Client _cliente;
  final String baseUrl;
  static const Duration timeout = Duration(seconds: 8);

  Future<Map<String, dynamic>> get(String ruta) {
    return _ejecutar(() => _cliente.get(Uri.parse('$baseUrl$ruta')));
  }

  Future<Map<String, dynamic>> post(String ruta, Map<String, dynamic> body) {
    return _ejecutar(
      () => _cliente.post(
        Uri.parse('$baseUrl$ruta'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ),
    );
  }

  Future<Map<String, dynamic>> _ejecutar(
    Future<http.Response> Function() peticion,
  ) async {
    final http.Response respuesta;
    try {
      respuesta = await peticion().timeout(timeout);
    } on SocketException {
      throw const SinConexionException();
    } on TimeoutException {
      throw const SinConexionException('El servidor tardo demasiado.');
    } on http.ClientException {
      throw const SinConexionException();
    }

    if (respuesta.statusCode < 200 || respuesta.statusCode >= 300) {
      throw ServidorException(respuesta.statusCode);
    }
    try {
      return jsonDecode(respuesta.body) as Map<String, dynamic>;
    } on FormatException {
      throw const DatosInvalidosException();
    }
  }

  void cerrar() => _cliente.close();
}
