import 'package:flutter/material.dart';

class ApartmentCard extends StatefulWidget {
  final int aptNum;
  final String label;
  final String statusText;
  final bool isPaid;
  final VoidCallback onTap;

  const ApartmentCard({
    super.key,
    required this.aptNum,
    required this.label,
    required this.statusText,
    required this.isPaid,
    required this.onTap,
  });

  @override
  State<ApartmentCard> createState() => _ApartmentCardState();
}

class _ApartmentCardState extends State<ApartmentCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final defaultBorder = isDark ? Colors.white24 : Colors.black12;
    final borderColor = widget.isPaid
        ? const Color(0xFF22C55E)
        : (_hovering ? const Color(0xFF6366F1) : defaultBorder);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: _hovering ? Matrix4.translationValues(0.0, -3.0, 0.0) : Matrix4.identity(),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: widget.isPaid || _hovering ? 1.8 : 1),
            boxShadow: _hovering || widget.isPaid
                ? [
                    BoxShadow(
                      color: borderColor.withValues(alpha: _hovering ? 0.45 : 0.2),
                      blurRadius: _hovering ? 14 : 6,
                    ),
                  ]
                : null,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 3),
                Text(
                  widget.statusText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: widget.isPaid
                        ? (isDark ? const Color(0xFF22C55E) : const Color(0xFF15803D))
                        : (isDark ? Colors.white70 : Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
