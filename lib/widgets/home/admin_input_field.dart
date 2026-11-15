import 'package:flutter/material.dart';

class AdminInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color color;
  final String onFocusKey;
  final ValueChanged<String?> onHighlight;
  final VoidCallback onChanged;

  const AdminInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.color,
    required this.onFocusKey,
    required this.onHighlight,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final labelColor = isDark ? color : HSLColor.fromColor(color).withLightness(0.32).toColor();

    return MouseRegion(
      onEnter: (_) => onHighlight(onFocusKey),
      onExit: (_) => onHighlight(null),
      child: Focus(
        onFocusChange: (hasFocus) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onHighlight(hasFocus ? onFocusKey : null);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: isDark ? 0.7 : 0.9)),
          ),
          child: Row(
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: labelColor, fontWeight: FontWeight.bold)),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.left,
                  onChanged: (_) => onChanged(),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
