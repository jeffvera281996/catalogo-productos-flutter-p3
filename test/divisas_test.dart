import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nexoshop/core/utils/formato.dart';
import 'package:nexoshop/data/datasources/api_client.dart';
import 'package:nexoshop/data/datasources/divisas_remote_datasource.dart';
import 'package:nexoshop/data/models/tasa_cambio.dart';
import 'package:nexoshop/data/repositories/divisas_repository.dart';
import 'package:nexoshop/providers/divisas_provider.dart';

const _jsonApi = {
  'amount': 1.0,
  'base': 'USD',
  'date': '2026-11-06',
  'rates': {'JPY': 152.1, 'EUR': 0.8712, 'AUD': 1.52, 'MXN': 18.43},
};

DivisasProvider _providerCon(MockClient cliente) => DivisasProvider(
  DivisasRepository(
    DivisasRemoteDataSource(
      ApiClient(cliente: cliente, baseUrl: DivisasRemoteDataSource.baseUrl),
    ),
  ),
);

void main() {
  group('TasasCambio (mapeo JSON)', () {
    test('fromJson convierte el mapa "rates" en una lista tipada', () {
      final t = TasasCambio.fromJson(_jsonApi);
      expect(t.base, 'USD');
      expect(t.fecha, DateTime(2026, 11, 6));
      expect(t.tasas, hasLength(4));
      // Destacadas primero (EUR, MXN, JPY) y luego alfabetico (AUD).
      expect(t.tasas.map((e) => e.codigo), ['EUR', 'MXN', 'JPY', 'AUD']);
      expect(t.tasas.first.nombre, 'Euro');
    });

    test('toJson -> fromJson conserva los datos', () {
      final original = TasasCambio.fromJson(_jsonApi);
      final copia = TasasCambio.fromJson(original.toJson());
      expect(copia.toJson(), original.toJson());
    });

    test('TasaCambio convierte montos y se serializa', () {
      const t = TasaCambio(codigo: 'MXN', valor: 18.5);
      expect(t.convertir(10), 185);
      expect(TasaCambio.fromJson(t.toJson()).valor, 18.5);
    });
  });

  group('DivisasProvider (estados)', () {
    test('Cargando -> Exito cuando la API responde 200', () async {
      final p = _providerCon(
        MockClient((req) async {
          expect(req.url.toString(), contains('/latest?base=USD'));
          return http.Response(jsonEncode(_jsonApi), 200);
        }),
      );
      final estados = <DivisasEstado>[];
      p.addListener(() => estados.add(p.estado));

      await p.cargar();

      expect(estados.first, isA<DivisasCargando>());
      expect(p.estado, isA<DivisasExito>());
      expect((p.estado as DivisasExito).datos.tasas, isNotEmpty);
    });

    test('Error con sinConexion = true si no hay red', () async {
      final p = _providerCon(
        MockClient((_) async => throw const SocketException('sin red')),
      );
      await p.cargar();
      final e = p.estado as DivisasError;
      expect(e.sinConexion, isTrue);
    });

    test('Error de servidor ante un codigo HTTP 500', () async {
      final p = _providerCon(MockClient((_) async => http.Response('', 500)));
      await p.cargar();
      final e = p.estado as DivisasError;
      expect(e.sinConexion, isFalse);
      expect(e.mensaje, contains('500'));
    });

    test('Error de datos si el JSON no tiene el formato esperado', () async {
      final p = _providerCon(
        MockClient((_) async => http.Response('{"base":"USD"}', 200)),
      );
      await p.cargar();
      expect(p.estado, isA<DivisasError>());
    });

    test('pull-to-refresh conserva la lista mientras carga', () async {
      final p = _providerCon(
        MockClient((_) async => http.Response(jsonEncode(_jsonApi), 200)),
      );
      await p.cargar();
      final estados = <DivisasEstado>[];
      p.addListener(() => estados.add(p.estado));

      await p.cargar(refrescar: true);

      expect(estados.whereType<DivisasCargando>(), isEmpty);
      expect(p.estado, isA<DivisasExito>());
    });
  });

  test('Formato.numero', () {
    expect(Formato.numero(15230.5), '15,230.50');
    expect(Formato.numero(0.8712), '0.8712');
    expect(Formato.numero(18.43), '18.43');
  });
}
