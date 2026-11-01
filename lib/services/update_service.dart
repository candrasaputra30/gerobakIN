import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UpdateService {
  static const String _baseUrl = 'http://192.168.1.5:3000';

  static Future<Map<String, dynamic>?> checkUpdate() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final currentVersion = info.version;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final res = await http.get(
        Uri.parse('$_baseUrl/api/version/check'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final latestVersion = data['version'] ?? '1.0.0';

        if (_isNewer(latestVersion, currentVersion)) {
          return {
            'current': currentVersion,
            'latest': latestVersion,
            'apk_url': data['apk_url'] ?? '',
            'changelog': data['changelog'] ?? 'Pembaruan tersedia',
          };
        }
      }
    } catch (_) {}
    return null;
  }

  static bool _isNewer(String latest, String current) {
    final l = latest.split('.').map(int.parse).toList();
    final c = current.split('.').map(int.parse).toList();
    for (int i = 0; i < l.length && i < c.length; i++) {
      if (l[i] > c[i]) return true;
      if (l[i] < c[i]) return false;
    }
    return false;
  }
}