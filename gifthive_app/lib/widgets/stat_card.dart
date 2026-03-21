import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool clickable;

  const StatCard({
    super.key,
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
