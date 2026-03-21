import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/hive_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HiveProvider()),
      ],
      child: const GiftHiveApp(),
    ),
  );
}

class GiftHiveApp extends StatefulWidget {
  const GiftHiveApp({super.key});

  @override
  State<GiftHiveApp> createState() => _GiftHiveAppState();
}

class _GiftHiveAppState extends State<GiftHiveApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().tryAutoLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GiftHive',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFC440),
        ).copyWith(
          surface: const Color(0xFFF7F6F0),
          onSurface: const Color(0xFF331616),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F6F0),
        textTheme: const TextTheme().apply(
          bodyColor: Color(0xFF331616),
          displayColor: Color(0xFF331616),
        ),
        useMaterial3: true,
      ),
      home: context.watch<AuthProvider>().isLoggedIn
          ? const MainShell()
          : const LoginScreen(),
    );
  }
}
