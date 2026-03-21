import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/hive_provider.dart';
import 'hive_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token;
      context.read<HiveProvider>().loadHives(token);
    });
  }

  void _showAddHiveDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Hive'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Hive name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              final token = context.read<AuthProvider>().token;
              await context.read<HiveProvider>().addHive(token, ctrl.text.trim());
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final hiveProvider = context.watch<HiveProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${auth.user?.username ?? ''}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      body: hiveProvider.loading
          ? const Center(child: CircularProgressIndicator())
          : hiveProvider.error != null
              ? Center(child: Text('Error: ${hiveProvider.error}'))
              : hiveProvider.hives.isEmpty
                  ? const Center(child: Text('No hives yet. Create one!'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: hiveProvider.hives.length,
                      itemBuilder: (ctx, i) {
                        final hive = hiveProvider.hives[i];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.hive),
                            title: Text(hive.name),
                            subtitle: Text('${hive.gifts.length} gift(s)'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                final token = auth.token;
                                await hiveProvider.deleteHive(token, hive.id);
                              },
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => HiveDetailScreen(hive: hive)),
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHiveDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
