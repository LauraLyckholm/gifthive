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
                return GestureDetector(
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
                        const Icon(Icons.people_outline, color: Color(0xFF331616), size: 28),
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
                        const Icon(Icons.chevron_right, color: Color(0xFF331616)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
