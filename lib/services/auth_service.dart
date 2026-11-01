import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _user;

  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get isLoggedIn => _token != null;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final name = prefs.getString('user_name');
    final role = prefs.getString('user_role');
    if (name != null) {
      _user = {'name': name, 'role': role};
    }
    notifyListeners();
  }

  Future<bool> login(String phone, String password) async {
    try {
      final res = await ApiService.post('/auth/login', {
        'phone': phone,
        'password': password,
      });
      _token = res['token'];
      _user = res['user'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('user_name', _user!['name']);
      await prefs.setString('user_role', _user!['role']);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(String name, String phone, String password) async {
    try {
      await ApiService.post('/auth/register', {
        'name': name,
        'phone': phone,
        'password': password,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
