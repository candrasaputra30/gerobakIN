import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const String currentVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(seconds: 2));
    await context.read<AuthService>().loadToken();
    await _checkUpdate();
  }

  Future<void> _checkUpdate() async {
    try {
      final data = await ApiService.checkVersion();
      final latestVersion = data['version'];
      final apkUrl = data['apk_url'];

      if (latestVersion != currentVersion && apkUrl != null && apkUrl != '') {
        if (mounted) {
          _showUpdateDialog(latestVersion, apkUrl, data['changelog'] ?? '');
          return;
        }
      }
    } catch (e) {
      // skip kalau backend ga bisa dicapai
    }
    _navigate();
  }

  void _showUpdateDialog(String version, String apkUrl, String changelog) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Update Tersedia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Versi baru: $version'),
            const SizedBox(height: 8),
            Text(changelog),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _navigate,
            child: const Text('Nanti'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D8B57),
            ),
            onPressed: () => _downloadUpdate(apkUrl),
            child: const Text('Update Sekarang',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadUpdate(String apkUrl) async {
    // buka url download APK
    Navigator.pop(context);
    _navigate();
  }

  void _navigate() {
    if (!mounted) return;
    final auth = context.read<AuthService>();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => auth.isLoggedIn
            ? const HomeScreen()
            : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D8B57),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.local_shipping,
                size: 72,
                color: Color(0xFF2D8B57),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'GERObakIN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pindahan Mudah, Angkut Cepat',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
