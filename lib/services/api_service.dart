import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://YOUR_IP:3000/api';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json.decode(res.body);
    }
    throw Exception(json.decode(res.body)['message'] ?? 'Error');
  }

  static Future<List<dynamic>> getList(String endpoint) async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = json.decode(res.body);
      return decoded is List ? decoded : [];
    }
    throw Exception('Error');
  }

  static Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> body) async {
    final token = await _getToken();
    final res = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json.decode(res.body);
    }
    throw Exception(json.decode(res.body)['message'] ?? 'Error');
  }

  static Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> body) async {
    final token = await _getToken();
    final res = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json.decode(res.body);
    }
    throw Exception(json.decode(res.body)['message'] ?? 'Error');
  }

  static Future<Map<String, dynamic>> checkVersion() async {
    final res = await http.get(Uri.parse('$baseUrl/version/check'));
    return json.decode(res.body);
  }
}
