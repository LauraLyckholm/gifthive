import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hive.dart';
import '../providers/auth_provider.dart';
import '../providers/hive_provider.dart';
import 'hives_screen.dart';
import 'shared_hives_screen.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int index)? onSwitchTab;
  const HomeScreen({super.key, this.onSwitchTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<HiveProvider>().loadHives(auth.token, userId: auth.user?.id);
    });
  }

  void _showAddHiveDialog(BuildContext context) {
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
            decoration: InputDecoration(
              hintText: 'Hive name',
              errorText: nameError,
            ),
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

  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.hive_outlined),
              title: const Text('New hive'),
              onTap: () {
                Navigator.pop(ctx);
                _showAddHiveDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.card_giftcard_outlined),
              title: const Text('New gift'),
              onTap: () {
                Navigator.pop(ctx);
                _showHivePickerSheet(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showHivePickerSheet(BuildContext context) {
    final hives = context.read<HiveProvider>().hives.toList()
      ..sort((a, b) => b.gifts.length.compareTo(a.gifts.length));

    if (hives.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hives yet — create one first!')),
      );
      return;
    }

    final sheetHeight = MediaQuery.of(context).size.height * 0.7;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SizedBox(
        height: sheetHeight,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text('Which hive?', style: Theme.of(context).textTheme.titleMedium),
              ),
              Expanded(
                child: ListView(
                  children: hives.map((hive) => ListTile(
                    leading: const Icon(Icons.hive_outlined),
                    title: Text(hive.name),
                    subtitle: Text('${hive.gifts.length} gift${hive.gifts.length == 1 ? '' : 's'}'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _showAddGiftDialog(context, hive);
                    },
                  )).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddGiftDialog(BuildContext context, Hive hive) {
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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final hiveProvider = context.watch<HiveProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('GiftHive')),
      body: hiveProvider.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => hiveProvider.loadHives(auth.token, userId: auth.user?.id),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + kBottomNavigationBarHeight + MediaQuery.viewPaddingOf(context).bottom),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome back,',
                            style: TextStyle(color: Color(0xFF331616), fontSize: 16),
                          ),
                          Text(
                            auth.user?.username ?? '',
                            style: const TextStyle(
                              color: Color(0xFF331616),
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    Text('Overview', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),

                    // Stat grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (widget.onSwitchTab != null) {
                              widget.onSwitchTab!(1);
                            } else {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const HivesScreen()));
                            }
                          },
                          child: _StatCard(
                            icon: Icons.hive,
                            label: hiveProvider.hives.length == 1 ? 'Hive' : 'Hives',
                            value: '${hiveProvider.hives.length}',
                            clickable: true,
                          ),
                        ),
                        _StatCard(
                          icon: Icons.card_giftcard,
                          label: hiveProvider.totalGifts == 1 ? 'Gift' : 'Gifts',
                          value: '${hiveProvider.totalGifts}',
                        ),
                        _StatCard(
                          icon: Icons.alarm,
                          label: hiveProvider.overdueGifts == 1 ? 'Gift overdue' : 'Gifts overdue',
                          value: '${hiveProvider.overdueGifts}',
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SharedHivesScreen()),
                          ),
                          child: _StatCard(
                            icon: Icons.people_outline,
                            label: 'Shared with me',
                            value: '${hiveProvider.sharedHives.length}',
                            clickable: true,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                            height: 52,
                            width: 52,
                            child: FilledButton.tonal(
                              style: FilledButton.styleFrom(                                           
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                backgroundColor: const Color(0xFFFFC440),
                                foregroundColor: const Color(0xFF331616),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),                                                                       
                              onPressed: () => _showActionSheet(context),
                              child: const Icon(Icons.add),                                            
                            ), 
                          )
                      ]
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool clickable;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.clickable = false,
  });

  static const _textColor = Color(0xFF331616);
  static const _gradient = LinearGradient(
    begin: Alignment(-0.5, 0.87),
    end: Alignment(0.5, -0.87),
    colors: [Color(0xFFFFAF3A), Color(0xFFFFC440)],
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: clickable ? null : Colors.white,
        gradient: clickable ? _gradient : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: _textColor, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: _textColor)),
              Text(label, style: TextStyle(fontSize: 13, color: _textColor.withValues(alpha: 0.7))),
            ],
          ),
        ],
      ),
    );
  }
}
