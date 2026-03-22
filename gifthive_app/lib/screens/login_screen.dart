import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_services.dart';
import '../widgets/gradient_button.dart';
import 'register_screen.dart';
import 'faq_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  void _showForgotPasswordDialog() {
    final emailCtrl = TextEditingController();
    bool sending = false;
    bool sent = false;
    String? dialogError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Forgot password?'),
          content: sent
              ? const Text('If that email is registered, a reset link has been sent. Check your inbox.')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Enter your email and we\'ll send you a reset link.'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                      autofocus: true,
                    ),
                    if (dialogError != null) ...[
                      const SizedBox(height: 8),
                      Text(dialogError!, style: TextStyle(color: Theme.of(ctx).colorScheme.error, fontSize: 13)),
                    ],
                  ],
                ),
          actions: sent
              ? [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))]
              : [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                  FilledButton(
                    onPressed: sending ? null : () async {
                      if (emailCtrl.text.trim().isEmpty) return;
                      setDialogState(() { sending = true; dialogError = null; });
                      try {
                        await ApiService().forgotPassword(emailCtrl.text.trim());
                        setDialogState(() { sending = false; sent = true; });
                      } catch (e) {
                        setDialogState(() {
                          sending = false;
                          dialogError = e.toString().replaceFirst('Exception: ', '');
                        });
                      }
                    },
                    child: sending
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Send link'),
                  ),
                ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      await context.read<AuthProvider>().login(
        _usernameCtrl.text.trim(),
        _passwordCtrl.text,
      );
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.help_outline, color: Color(0xFF331616)),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqScreen())),
                ),
              ),
              Text('GiftHive', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 32),
              TextField(
                controller: _usernameCtrl,
                decoration: const InputDecoration(labelText: 'Username', hintText: 'Enter your username'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordCtrl,
                decoration: const InputDecoration(labelText: 'Password', hintText: 'Enter your password'),
                obscureText: true,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 24),
              GradientButton(
                borderRadius: BorderRadius.circular(20),
                padding: const EdgeInsets.all(14),
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70))
                    : const Text('Log in'),
              ),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: const Text("Don't have an account? Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
