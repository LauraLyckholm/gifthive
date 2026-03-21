import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/hive_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF5A623)),
        useMaterial3: true,
      ),
      home: context.watch<AuthProvider>().isLoggedIn
          ? const HomeScreen()
          : const LoginScreen(),
    );
  }
}
