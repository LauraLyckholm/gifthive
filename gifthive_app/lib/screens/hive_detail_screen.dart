import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hive.dart';
import '../providers/auth_provider.dart';
import '../providers/hive_provider.dart';

class HiveDetailScreen extends StatelessWidget {
  final Hive hive;

  const HiveDetailScreen({super.key, required this.hive});

  void _showAddGiftDialog(BuildContext context) {
    final giftCtrl = TextEditingController();
    final tagsCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add gift to ${hive.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: giftCtrl, decoration: const InputDecoration(hintText: 'Gift name')),
            const SizedBox(height: 12),
            TextField(controller: tagsCtrl, decoration: const InputDecoration(hintText: 'Tags (comma-separated)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (giftCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              final token = context.read<AuthProvider>().token;
              final tags = tagsCtrl.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
              await context.read<HiveProvider>().addGift(token, hive.id, giftCtrl.text.trim(), tags);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch for updates so the list refreshes after mutations
    final updatedHive = context.watch<HiveProvider>().hives.firstWhere(
      (h) => h.id == hive.id,
      orElse: () => hive,
    );
    final token = context.read<AuthProvider>().token;
    final hiveProvider = context.read<HiveProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(updatedHive.name)),
      body: updatedHive.gifts.isEmpty
          ? const Center(child: Text('No gifts yet. Add one!'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: updatedHive.gifts.length,
              itemBuilder: (ctx, i) {
                final gift = updatedHive.gifts[i];
                return Card(
                  child: ListTile(
                    leading: Checkbox(
                      value: gift.bought,
                      onChanged: (_) => hiveProvider.toggleBought(token, hive.id, gift),
                    ),
                    title: Text(
                      gift.gift,
                      style: gift.bought
                          ? const TextStyle(decoration: TextDecoration.lineThrough)
                          : null,
                    ),
                    subtitle: gift.tags.isNotEmpty ? Text(gift.tags.join(', ')) : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => hiveProvider.deleteGift(token, hive.id, gift.id),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGiftDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
