import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hive_provider.dart';
import 'hive_detail_screen.dart';

class SharedHivesScreen extends StatelessWidget {
  const SharedHivesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hiveProvider = context.watch<HiveProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Shared with me')),
      body: hiveProvider.sharedHives.isEmpty
          ? const Center(child: Text('No hives have been shared with you yet.'))
          : ListView.builder(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + kBottomNavigationBarHeight + MediaQuery.viewPaddingOf(context).bottom),
              itemCount: hiveProvider.sharedHives.length,
              itemBuilder: (ctx, i) {
                final hive = hiveProvider.sharedHives[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.people_outline),
                    title: Text(hive.name),
                    subtitle: Text('${hive.gifts.length} gift(s)'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => HiveDetailScreen(hive: hive)),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
