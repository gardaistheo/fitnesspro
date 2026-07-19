import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  String? _token;

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 401) {
      // Token invalid/expired
      _token = null;
      throw Exception('Unauthorized: Token expired or invalid');
    } else {
      final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(
        errorBody['message'] ??
            'Request failed with status ${response.statusCode}',
      );
    }
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = _getHeaders();

    try {
      final response = await http.get(uri, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = _getHeaders();

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = _getHeaders();

    try {
      final response = await http.put(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = _getHeaders();

    try {
      final response = await http.delete(uri, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  String? getToken() {
    return _token;
  }
}
