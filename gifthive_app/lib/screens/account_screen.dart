import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

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
      appBar: AppBar(title: const Text('My account')),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + kBottomNavigationBarHeight + MediaQuery.viewPaddingOf(context).bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info section
            Text('Personal information', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _InfoTile(label: 'Username', value: user?.username ?? ''),
            _InfoTile(
              label: 'Email',
              value: user?.email ?? '',
              trailing: const Tooltip(
                message: 'Email can not be changed.',
                child: Icon(Icons.lock_outline, size: 18),
              ),
            ),

            const Divider(height: 40),

            // Change username
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
              child: FilledButton(
                onPressed: _savingUsername ? null : _updateUsername,
                child: _savingUsername
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Update username'),
              ),
            ),

            const Divider(height: 40),

            // Change password
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
              child: FilledButton(
                onPressed: _savingPassword ? null : _updatePassword,
                child: _savingPassword
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Update password'),
              ),
            ),

            const Divider(height: 40),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;

  const _InfoTile({required this.label, required this.value, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
          ?trailing,
        ],
      ),
    );
  }
}
