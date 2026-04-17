import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:azager/core/network/api_config.dart';
import 'package:azager/core/network/api_exception.dart';

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    try {
      final response = await _client.post(
        url,
        headers: headers ?? ApiConfig.defaultHeaders,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection. Please try again.');
    } on http.ClientException {
      throw ApiException(message: 'Connection error. Please try again.');
    }
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    try {
      final response = await _client.get(
        url,
        headers: headers ?? ApiConfig.defaultHeaders,
      );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection. Please try again.');
    } on http.ClientException {
      throw ApiException(message: 'Connection error. Please try again.');
    }
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    try {
      final response = await _client.delete(
        url,
        headers: headers ?? ApiConfig.defaultHeaders,
      );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection. Please try again.');
    } on http.ClientException {
      throw ApiException(message: 'Connection error. Please try again.');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    // Validation errors (422)
    if (response.statusCode == 422) {
      final errors = body['errors'] as Map<String, dynamic>?;
      throw ApiValidationException(
        message: body['message'] as String? ?? 'Validation failed.',
        errors: errors?.map(
          (key, value) => MapEntry(key, List<String>.from(value as List)),
        ),
      );
    }

    throw ApiException(
      message: body['message'] as String? ?? 'Something went wrong.',
      statusCode: response.statusCode,
    );
  }

  void dispose() {
    _client.close();
  }
}
