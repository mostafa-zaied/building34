import 'package:flutter/material.dart';

import 'glow_box.dart';

class ExpenseStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool highlighted;

  const ExpenseStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? color : HSLColor.fromColor(color).withLightness(0.32).toColor();

    return GlowBox(
      glowColor: color,
      isHighlighted: highlighted,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: labelColor, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
