import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import '../services/update_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    await context.read<AuthService>().loadToken();
    if (!mounted) return;
    final update = await UpdateService.checkUpdate();
    if (!mounted) return;
    if (update != null) {
      await _showUpdateDialog(update);
    } else {
      _navigate();
    }
  }

  Future<void> _showUpdateDialog(Map<String, dynamic> update) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.system_update, color: Color(0xFF2D8B57)),
          const SizedBox(width: 8),
          const Text('Update Tersedia'),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Versi baru: ${update['latest']}', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Versi kamu: ${update['current']}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 12),
          Text(update['changelog'] ?? '', style: const TextStyle(fontSize: 13)),
        ]),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); _navigate(); }, child: const Text('Nanti', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              final url = update['apk_url'] ?? '';
              if (url.isNotEmpty) await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              if (mounted) { Navigator.pop(context); _navigate(); }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D8B57), foregroundColor: Colors.white),
            child: const Text('Update Sekarang'),
          ),
        ],
      ),
    );
  }

  void _navigate() {
    final auth = context.read<AuthService>();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => auth.isLoggedIn ? const HomeScreen() : const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D8B57),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 100, height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: const Icon(Icons.local_shipping, size: 60, color: Color(0xFF2D8B57))),
        const SizedBox(height: 24),
        const Text('GERObakIN', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 8),
        const Text('Pindahan Mudah, Angkut Cepat', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 48),
        const CircularProgressIndicator(color: Colors.white),
      ])),
    );
  }
}