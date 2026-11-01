import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: const GERObakINApp(),
    ),
  );
}

class GERObakINApp extends StatelessWidget {
  const GERObakINApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GERObakIN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D8B57),
          primary: const Color(0xFF2D8B57),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}
