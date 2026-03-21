import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/hive_provider.dart';
import '../widgets/gradient_button.dart';
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 4),
          ),
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
                                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFFC44B3A), foregroundColor: Colors.white),
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                          onDismissed: (_) => hiveProvider.deleteHive(auth.token, hive.id),
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => HiveDetailScreen(hive: hive)),
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                              child: Row(
                                children: [
                                  const Icon(Icons.hive, color: Color(0xFF331616), size: 28),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(hive.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF331616))),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${hive.gifts.length} ${hive.gifts.length == 1 ? 'gift' : 'gifts'}',
                                          style: TextStyle(fontSize: 13, color: const Color(0xFF331616).withValues(alpha: 0.6)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, color: Color(0xFF331616)),
                                    onPressed: () => _showRenameHiveDialog(hive.id, hive.name),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Color(0xFF331616)),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Delete hive?'),
                                          content: Text('This will permanently delete "${hive.name}" and all its gifts.'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                            FilledButton(
                                              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFC44B3A)),
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
                  child: GradientButton(
                    borderRadius: BorderRadius.circular(12),
                    padding: EdgeInsets.zero,
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
