import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/info_tile.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _savingUsername = false;
  bool _savingPassword = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateUsername() async {
    final newUsername = _usernameCtrl.text.trim();
    if (newUsername.isEmpty) return;
    if (newUsername.length < 5 || newUsername.length > 20) {
      _showError('Username must be between 5 and 20 characters.');
      return;
    }
    setState(() => _savingUsername = true);
    try {
      await context.read<AuthProvider>().updateUsername(newUsername);
      _usernameCtrl.clear();
      if (mounted) _showSuccess('Username updated!');
    } catch (e) {
      if (mounted) _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _savingUsername = false);
    }
  }

  Future<void> _updatePassword() async {
    final newPassword = _passwordCtrl.text;
    if (newPassword.isEmpty) return;
    if (newPassword != _confirmPasswordCtrl.text) {
      _showError('Passwords do not match.');
      return;
    }
    if (newPassword.length < 7 || !RegExp(r'(?=.*\d)(?=.*[a-z])(?=.*[A-Z])').hasMatch(newPassword)) {
      _showError('Password must be at least 7 characters and include uppercase, lowercase and a number.');
      return;
    }
    setState(() => _savingPassword = true);
    try {
      await context.read<AuthProvider>().updatePassword(newPassword);
      _passwordCtrl.clear();
      _confirmPasswordCtrl.clear();
      if (mounted) _showSuccess('Password updated!');
    } catch (e) {
      if (mounted) _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _savingPassword = false);
    }
  }

  Widget _card(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Theme.of(context).colorScheme.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20, 40, 20, 20 + kBottomNavigationBarHeight + MediaQuery.viewPaddingOf(context).bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Personal information card
            _card(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Personal information', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  InfoTile(label: 'Username', value: user?.username ?? ''),
                  InfoTile(
                    label: 'Email',
                    value: user?.email ?? '',
                    trailing: const Tooltip(
                      message: 'Email can not be changed.',
                      child: Icon(Icons.lock_outline, size: 18),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Change username card
            _card(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Change username', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _usernameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'New username',
                      hintText: '5–20 characters',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: GradientButton(
                      borderRadius: BorderRadius.circular(20),
                      padding: const EdgeInsets.all(14),
                      onPressed: _savingUsername ? null : _updateUsername,
                      child: _savingUsername
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70))
                          : const Text('Update username'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Change password card
            _card(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Change password', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New password',
                      hintText: 'Min 7 chars, upper + lower + number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _confirmPasswordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm new password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: GradientButton(
                      borderRadius: BorderRadius.circular(20),
                      padding: const EdgeInsets.all(14),
                      onPressed: _savingPassword ? null : _updatePassword,
                      child: _savingPassword
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70))
                          : const Text('Update password'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: GradientButton(
                borderRadius: BorderRadius.circular(20),
                padding: const EdgeInsets.all(14),
                danger: true,
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Log out?'),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Log out')),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    context.read<AuthProvider>().logout();
                  }
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout, size: 18),
                    SizedBox(width: 8),
                    Text('Log out'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.all(14),
                  foregroundColor: const Color(0xFF331616),
                  side: const BorderSide(color: Color(0xFF331616)),
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete account?'),
                      content: const Text(
                        'This will permanently delete your account and all your hives and gifts. This cannot be undone.',
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: const Color(0xFFC44B3A), foregroundColor: Colors.white),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    try {
                      await context.read<AuthProvider>().deleteAccount();
                    } catch (e) {
                      if (context.mounted) _showError(e.toString().replaceFirst('Exception: ', ''));
                    }
                  }
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_forever_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Delete account'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

