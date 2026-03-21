import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/hive_provider.dart';
import 'hive_detail_screen.dart';

class HivesScreen extends StatefulWidget {
  final bool openAddDialog;

  const HivesScreen({super.key, this.openAddDialog = false});

  @override
  State<HivesScreen> createState() => _HivesScreenState();
}

class _HivesScreenState extends State<HivesScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.openAddDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showAddHiveDialog());
    }
  }

  void _showRenameHiveDialog(String hiveId, String currentName) {
    final ctrl = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Hive'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Hive name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              final token = context.read<AuthProvider>().token;
              await context.read<HiveProvider>().renameHive(token, hiveId, ctrl.text.trim());
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddHiveDialog() {
    final ctrl = TextEditingController();
    String? nameError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
        title: const Text('New Hive'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          onChanged: (_) { if (nameError != null) setDialogState(() => nameError = null); },
          decoration: InputDecoration(hintText: 'Hive name', errorText: nameError),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) {
                setDialogState(() => nameError = 'Hive name is required');
                return;
              }
              Navigator.pop(ctx);
              final token = context.read<AuthProvider>().token;
              await context.read<HiveProvider>().addHive(token, ctrl.text.trim());
            },
            child: const Text('Create'),
          ),
        ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final hiveProvider = context.watch<HiveProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Hives'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                hiveProvider.loading
                ? const Center(child: CircularProgressIndicator())
                : hiveProvider.error != null
                    ? Center(child: Text('Error: ${hiveProvider.error}'))
                    : hiveProvider.hives.isEmpty
                        ? const Center(child: Text('No hives yet. Create one!'))
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                            itemCount: hiveProvider.hives.length,
                            itemBuilder: (ctx, i) {
                              final hive = hiveProvider.hives[i];
                              return Dismissible(
                          key: ValueKey(hive.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.delete_outline, color: Colors.white),
                          ),
                          confirmDismiss: (_) async {
                            return await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete hive?'),
                                content: Text('This will permanently delete "${hive.name}" and all its gifts.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                  FilledButton(
                                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                          onDismissed: (_) => hiveProvider.deleteHive(auth.token, hive.id),
                          child: Card(
                            child: ListTile(
                              leading: const Icon(Icons.hive),
                              title: Text(hive.name),
                              subtitle: Text('${hive.gifts.length} gift(s)'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: () => _showRenameHiveDialog(hive.id, hive.name),
                                  ),
                                  IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete hive?'),
                                      content: Text('This will permanently delete "${hive.name}" and all its gifts.'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                        FilledButton(
                                          style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                          onPressed: () => Navigator.pop(ctx, true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await hiveProvider.deleteHive(auth.token, hive.id);
                                  }
                                },
                              ),
                                ],
                              ),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => HiveDetailScreen(hive: hive)),
                              ),
                            ),
                          ),
                        );
                            },
                          ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                height: 48,
                                child: IgnorePointer(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0),
                                          Theme.of(context).scaffoldBackgroundColor,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 80 + kBottomNavigationBarHeight + MediaQuery.viewPaddingOf(context).bottom),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 52,
                  height: 52,
                  child: FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      backgroundColor: const Color(0xFFFFC440),
                      foregroundColor: const Color(0xFF331616),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _showAddHiveDialog,
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
