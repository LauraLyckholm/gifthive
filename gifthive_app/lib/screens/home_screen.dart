import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/hive_provider.dart';
import 'hives_screen.dart';
import 'shared_hives_screen.dart';

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
      final auth = context.read<AuthProvider>();
      context.read<HiveProvider>().loadHives(auth.token, userId: auth.user?.id);
    });
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
                        color: scheme.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: TextStyle(color: scheme.onPrimary.withValues(alpha: 0.8), fontSize: 16),
                          ),
                          Text(
                            auth.user?.username ?? '',
                            style: TextStyle(
                              color: scheme.onPrimary,
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
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HivesScreen()),
                          ),
                          child: _StatCard(
                          icon: Icons.hive,
                          label: hiveProvider.hives.length == 1 ? 'Hive' : 'Hives',
                          value: '${hiveProvider.hives.length}',
                          color: scheme.primaryContainer,
                          iconColor: scheme.onPrimaryContainer,
                          ),
                        ),
                        _StatCard(
                          icon: Icons.card_giftcard,
                          label: hiveProvider.totalGifts == 1 ? 'Gift' : 'Gifts',
                          value: '${hiveProvider.totalGifts}',
                          color: scheme.secondaryContainer,
                          iconColor: scheme.onSecondaryContainer,
                        ),
                        _StatCard(
                          icon: Icons.alarm,
                          label: hiveProvider.overdueGifts == 1 ? 'Gift overdue' : 'Gifts overdue',
                          value: '${hiveProvider.overdueGifts}',
                          color: hiveProvider.overdueGifts > 0
                              ? scheme.errorContainer
                              : scheme.surfaceContainerHighest,
                          iconColor: hiveProvider.overdueGifts > 0
                              ? scheme.onErrorContainer
                              : scheme.onSurfaceVariant,
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
                            color: scheme.tertiaryContainer,
                            iconColor: scheme.onTertiaryContainer,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            icon: const Icon(Icons.hive),
                            label: const Text('My hives'),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const HivesScreen()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.tonalIcon(
                            icon: const Icon(Icons.add),
                            label: const Text('New hive'),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const HivesScreen(openAddDialog: true)),
                            ),
                          ),
                        ),
                      ],
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
  final Color color;
  final Color iconColor;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: iconColor, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: iconColor)),
              Text(label, style: TextStyle(fontSize: 13, color: iconColor.withValues(alpha: 0.8))),
            ],
          ),
        ],
      ),
    );
  }
}
