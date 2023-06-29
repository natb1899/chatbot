class Endpoints {
  static const String baseUrl = 'http://192.168.137.1:5001';

  static String apiURL(String endpoint) => '$baseUrl/$endpoint';
}
