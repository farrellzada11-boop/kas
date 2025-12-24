import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http
          .get(
            Uri.parse('${AppConstants.baseUrl}$endpoint'),
            headers: _headers,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectionTimeout));

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Connection error: $e');
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse('${AppConstants.baseUrl}$endpoint'),
            headers: _headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(milliseconds: AppConstants.connectionTimeout));

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Connection error: $e');
    }
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http
          .put(
            Uri.parse('${AppConstants.baseUrl}$endpoint'),
            headers: _headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(milliseconds: AppConstants.connectionTimeout));

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Connection error: $e');
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http
          .delete(
            Uri.parse('${AppConstants.baseUrl}$endpoint'),
            headers: _headers,
          )
          .timeout(const Duration(milliseconds: AppConstants.connectionTimeout));

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Connection error: $e');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else if (response.statusCode == 401) {
      throw ApiException('Unauthorized: Please login again');
    } else if (response.statusCode == 404) {
      throw ApiException('Resource not found');
    } else if (response.statusCode >= 500) {
      throw ApiException('Server error: Please try again later');
    } else {
      throw ApiException(body['message'] ?? 'Request failed');
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
