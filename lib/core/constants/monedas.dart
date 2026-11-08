/// Catalogo local de monedas que publica la API Frankfurter (Banco Central
/// Europeo). La API solo devuelve codigos ISO 4217; los nombres en espanol y
/// el orden de relevancia para la tienda se resuelven aqui.
abstract final class Monedas {
  /// Monedas base que el usuario puede elegir en la pantalla.
  static const List<String> bases = ['USD', 'EUR', 'GBP', 'MXN'];

  /// Monedas que se muestran primero (clientes mas frecuentes de la tienda).
  static const List<String> destacadas = [
    'USD', 'EUR', 'MXN', 'BRL', 'GBP', 'CAD', 'JPY', 'CNY',
  ];

  static const Map<String, String> _nombres = {
    'AUD': 'Dolar australiano',
    'BGN': 'Lev bulgaro',
    'BRL': 'Real brasileno',
    'CAD': 'Dolar canadiense',
    'CHF': 'Franco suizo',
    'CNY': 'Yuan chino',
    'CZK': 'Corona checa',
    'DKK': 'Corona danesa',
    'EUR': 'Euro',
    'GBP': 'Libra esterlina',
    'HKD': 'Dolar de Hong Kong',
    'HUF': 'Forinto hungaro',
    'IDR': 'Rupia indonesia',
    'ILS': 'Nuevo shekel israeli',
    'INR': 'Rupia india',
    'ISK': 'Corona islandesa',
    'JPY': 'Yen japones',
    'KRW': 'Won surcoreano',
    'MXN': 'Peso mexicano',
    'MYR': 'Ringgit malayo',
    'NOK': 'Corona noruega',
    'NZD': 'Dolar neozelandes',
    'PHP': 'Peso filipino',
    'PLN': 'Zloty polaco',
    'RON': 'Leu rumano',
    'SEK': 'Corona sueca',
    'SGD': 'Dolar de Singapur',
    'THB': 'Baht tailandes',
    'TRY': 'Lira turca',
    'USD': 'Dolar estadounidense',
    'ZAR': 'Rand sudafricano',
  };

  /// Nombre legible; si la API agrega una moneda nueva se muestra el codigo.
  static String nombre(String codigo) => _nombres[codigo] ?? codigo;

  /// Bandera emoji a partir de las dos primeras letras del codigo ISO 4217
  /// (que coinciden con el pais ISO 3166). "EUR" -> "EU" (bandera europea).
  static String bandera(String codigo) {
    if (codigo.length < 2) return '';
    const base = 0x1F1E6 - 0x41; // Indicador regional 'A' menos 'A' ASCII
    final letras = codigo.substring(0, 2).toUpperCase().codeUnits;
    return String.fromCharCodes(letras.map((c) => base + c));
  }

  /// Destacadas primero (en su orden) y el resto alfabeticamente.
  static int compararCodigos(String ca, String cb) {
    final ia = destacadas.indexOf(ca);
    final ib = destacadas.indexOf(cb);
    if (ia != -1 || ib != -1) {
      if (ia == -1) return 1;
      if (ib == -1) return -1;
      return ia.compareTo(ib);
    }
    return ca.compareTo(cb);
  }
}
