import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/hive.dart';
import 'hive_detail_screen.dart';
import 'home_screen.dart';
import 'hives_screen.dart';
import 'faq_screen.dart';
import 'account_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  final _tabs = const [
    _Tab(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    _Tab(icon: Icons.hive_outlined, activeIcon: Icons.hive, label: 'Hives'),
    _Tab(icon: Icons.help_outline, activeIcon: Icons.help, label: 'FAQ'),
    _Tab(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Account'),
  ];

  Future<bool> _onWillPop() async {
    final nav = _navigatorKeys[_currentIndex].currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
      return false;
    }
    return true;
  }

  Widget _buildTab(int index) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => switch (index) {
          0 => HomeScreen(
              onSwitchTab: (i) {
                _navigatorKeys[i].currentState?.popUntil((route) => route.isFirst);
                setState(() => _currentIndex = i);
              },
              onOpenHiveDetail: (hive) {
                setState(() => _currentIndex = 1);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _navigatorKeys[1].currentState?.popUntil((route) => route.isFirst);
                  _navigatorKeys[1].currentState?.push(
                    MaterialPageRoute(builder: (_) => HiveDetailScreen(hive: hive)),
                  );
                });
              },
            ),
          1 => const HivesScreen(),
          2 => const FaqScreen(),
          _ => const AccountScreen(),
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _onWillPop();
      },
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: _currentIndex,
          children: List.generate(4, _buildTab),
        ),
        bottomNavigationBar: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: scheme.surface.withValues(alpha: 0.75),
                border: Border(
                  top: BorderSide(
                    color: scheme.outlineVariant.withValues(alpha: 0.4),
                    width: 0.5,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(_tabs.length, (i) {
                      final tab = _tabs[i];
                      final active = i == _currentIndex;
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          _navigatorKeys[i].currentState?.popUntil((route) => route.isFirst);
                          setState(() => _currentIndex = i);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: active
                                ? const LinearGradient(
                              begin: Alignment(-0.5, 0.87),
                              end: Alignment(0.5, -0.87),
                              colors: [Color(0xFFFFAF3A), Color(0xFFFFC440)],
                            )
                                : null,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                active ? tab.activeIcon : tab.icon,
                                color: active ? const Color(0xFF331616) : scheme.onSurfaceVariant,
                                size: 24,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                tab.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                                  color: active ? const Color(0xFF331616) : scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _Tab({required this.icon, required this.activeIcon, required this.label});
}
