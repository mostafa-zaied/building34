import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class ExpenseStatCard extends StatefulWidget {
  final String label;
  final String value;
  final Color color;
  final bool highlighted;
  final bool isEditable;
  final TextEditingController? controller;
  final VoidCallback? onChanged;

  const ExpenseStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.highlighted,
    this.isEditable = false,
    this.controller,
    this.onChanged,
  });

  @override
  State<ExpenseStatCard> createState() => _ExpenseStatCardState();
}

class _ExpenseStatCardState extends State<ExpenseStatCard> {
  bool _hovering = false;
  bool _focused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final active = _hovering || _focused || widget.highlighted;
    final accentText = isDark
        ? widget.color
        : HSLColor.fromColor(widget.color).withLightness(0.35).toColor();

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.isEditable ? () => _focusNode.requestFocus() : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: active ? Matrix4.translationValues(0.0, -2.0, 0.0) : Matrix4.identity(),
          padding: const EdgeInsetsDirectional.symmetric(
            vertical: AppSpacing.sm + 2,
            horizontal: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: active
                ? widget.color.withValues(alpha: isDark ? 0.12 : 0.07)
                : AppColors.card(isDark),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: active
                  ? widget.color.withValues(alpha: 0.75)
                  : (widget.isEditable
                      ? widget.color.withValues(alpha: isDark ? 0.45 : 0.6)
                      : AppColors.border(isDark)),
              width: (active || widget.isEditable) ? 1.4 : 1.0,
            ),
            boxShadow: active
                ? AppShadows.accentGlow(widget.color, active: true, isDark: isDark)
                : AppShadows.card(isDark),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      widget.label,
                      style: AppTypography.caption.copyWith(
                        color: (active || widget.isEditable)
                            ? accentText
                            : AppColors.textSecondary(isDark),
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (widget.isEditable) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.edit_rounded, size: 11, color: accentText),
                  ],
                ],
              ),
              const SizedBox(height: 3),
              if (widget.isEditable && widget.controller != null)
                Focus(
                  onFocusChange: (hasFocus) => setState(() => _focused = hasFocus),
                  child: TextField(
                    focusNode: _focusNode,
                    controller: widget.controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onChanged: (_) => widget.onChanged?.call(),
                    style: AppTypography.statAmount.copyWith(
                      fontSize: 15,
                      color: AppColors.textPrimary(isDark),
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                )
              else
                Text(
                  widget.value,
                  style: AppTypography.statAmount.copyWith(
                    fontSize: 15,
                    color: AppColors.textPrimary(isDark),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
