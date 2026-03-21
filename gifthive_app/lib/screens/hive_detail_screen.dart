import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/gift.dart';
import '../models/hive.dart';
import '../providers/auth_provider.dart';
import '../providers/hive_provider.dart';
import '../widgets/gradient_button.dart';

class HiveDetailScreen extends StatelessWidget {
  final Hive hive;

  const HiveDetailScreen({super.key, required this.hive});

  void _showAddGiftDialog(BuildContext context) {
    final giftCtrl = TextEditingController();
    final tagsCtrl = TextEditingController();
    final List<String> tags = [];
    DateTime? selectedDate;
    String? nameError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Add gift to ${hive.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: giftCtrl,
                onChanged: (_) { if (nameError != null) setDialogState(() => nameError = null); },
                decoration: InputDecoration(
                  labelText: 'Gift name',
                  hintText: 'e.g. Wireless headphones',
                  errorText: nameError,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tagsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Add tag',
                  hintText: 'e.g. tech — press Enter to add',
                  suffixIcon: Icon(Icons.add),
                ),
                onSubmitted: (value) {
                  final tag = value.trim();
                  if (tag.isNotEmpty && !tags.contains(tag)) {
                    setDialogState(() => tags.add(tag));
                    tagsCtrl.clear();
                  }
                },
              ),
              if (tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: tags
                      .map((tag) => Chip(
                            label: Text(tag),
                            onDeleted: () => setDialogState(() => tags.remove(tag)),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedDate == null
                          ? 'No due date set'
                          : 'Due: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                      style: TextStyle(
                        fontSize: 14,
                        color: selectedDate != null && selectedDate!.isBefore(DateTime.now())
                            ? Colors.red
                            : null,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(selectedDate == null ? 'Set date' : 'Change'),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now().add(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (picked != null) setDialogState(() => selectedDate = picked);
                    },
                  ),
                  if (selectedDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () => setDialogState(() => selectedDate = null),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (giftCtrl.text.trim().isEmpty) {
                  setDialogState(() => nameError = 'Gift name is required');
                  return;
                }
                Navigator.pop(ctx);
                final token = context.read<AuthProvider>().token;
                await context.read<HiveProvider>().addGift(
                  token, hive.id, giftCtrl.text.trim(), tags,
                  dueDate: selectedDate,
                );
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditGiftDialog(BuildContext context, Gift gift) {
    final List<String> tags = List.from(gift.tags);
    final tagsCtrl = TextEditingController();
    final existingDue = gift.dueDate != null ? DateTime.tryParse(gift.dueDate!) : null;
    DateTime? selectedDate = existingDue;
    bool clearDueDate = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Edit "${gift.gift}"'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tagsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Add tag',
                  hintText: 'Press Enter to add',
                  suffixIcon: Icon(Icons.add),
                ),
                onSubmitted: (value) {
                  final tag = value.trim();
                  if (tag.isNotEmpty && !tags.contains(tag)) {
                    setDialogState(() => tags.add(tag));
                    tagsCtrl.clear();
                  }
                },
              ),
              if (tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: tags
                      .map((tag) => Chip(
                            label: Text(tag),
                            onDeleted: () => setDialogState(() => tags.remove(tag)),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedDate == null
                          ? 'No due date set'
                          : 'Due: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(selectedDate == null ? 'Set date' : 'Change'),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now().add(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          selectedDate = picked;
                          clearDueDate = false;
                        });
                      }
                    },
                  ),
                  if (selectedDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () => setDialogState(() {
                        selectedDate = null;
                        clearDueDate = true;
                      }),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await context.read<HiveProvider>().editGift(
                  context.read<AuthProvider>().token,
                  hive.id,
                  gift,
                  tags: tags,
                  dueDate: selectedDate,
                  clearDueDate: clearDueDate,
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildGiftSubtitle(Gift gift) {
    final hasTags = gift.tags.isNotEmpty;
    final due = gift.dueDate != null ? DateTime.tryParse(gift.dueDate!) : null;
    if (!hasTags && due == null) return null;

    final isOverdue = due != null && due.isBefore(DateTime.now()) && !gift.bought;
    final dateText = due != null
        ? '${isOverdue ? "Overdue: " : "Due: "}${due.day}/${due.month}/${due.year}'
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasTags) Text(gift.tags.join(', ')),
        if (dateText != null)
          Text(dateText, style: TextStyle(color: isOverdue ? Colors.red : null, fontSize: 12)),
      ],
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 40, 20, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF331616)),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(updatedHive.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                updatedHive.gifts.isEmpty
                ? const Center(child: Text('No gifts yet. Add one!'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    itemCount: updatedHive.gifts.length,
                    itemBuilder: (ctx, i) {
                final gift = updatedHive.gifts[i];
                return Dismissible(
                  key: ValueKey(gift.id),
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
                      context: ctx,
                      builder: (dlg) => AlertDialog(
                        title: const Text('Delete gift?'),
                        content: Text('Remove "${gift.gift}" from this hive?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(dlg, false), child: const Text('Cancel')),
                          FilledButton(
                            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFC44B3A)),
                            onPressed: () => Navigator.pop(dlg, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) => hiveProvider.deleteGift(token, hive.id, gift.id),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: gift.bought ? null : Colors.white,
                      gradient: gift.bought
                          ? const LinearGradient(
                              begin: Alignment(-0.5, 0.87),
                              end: Alignment(0.5, -0.87),
                              colors: [Color(0xFFFFAF3A), Color(0xFFFFC440)],
                            )
                          : null,
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
                        Checkbox(
                          value: gift.bought,
                          onChanged: (_) => hiveProvider.toggleBought(token, hive.id, gift),
                          activeColor: const Color(0xFF331616),
                          checkColor: Colors.white,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gift.gift,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF331616),
                                  decoration: gift.bought ? TextDecoration.lineThrough : null,
                                  decorationColor: const Color(0xFF331616),
                                ),
                              ),
                              if (_buildGiftSubtitle(gift) != null) ...[
                                const SizedBox(height: 2),
                                DefaultTextStyle(
                                  style: TextStyle(fontSize: 13, color: const Color(0xFF331616).withValues(alpha: 0.6)),
                                  child: _buildGiftSubtitle(gift)!,
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Color(0xFF331616)),
                          onPressed: () => _showEditGiftDialog(ctx, gift),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Color(0xFF331616)),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: ctx,
                              builder: (dlg) => AlertDialog(
                                title: const Text('Delete gift?'),
                                content: Text('Remove "${gift.gift}" from this hive?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(dlg, false), child: const Text('Cancel')),
                                  FilledButton(
                                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFFC44B3A)),
                                    onPressed: () => Navigator.pop(dlg, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              hiveProvider.deleteGift(token, hive.id, gift.id);
                            }
                          },
                        ),
                      ],
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
                    onPressed: () => _showAddGiftDialog(context),
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
