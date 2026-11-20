import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class ExpenseStatCard extends StatefulWidget {
  final String label;
  final String value;
  final Color color;
  final IconData? icon;
  final bool highlighted;
  final bool isEditable;
  final TextEditingController? controller;
  final String? initialEditText;
  final VoidCallback? onChanged;
  final ValueChanged<String>? onTextChanged;
  final VoidCallback? onDelete;

  const ExpenseStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.icon,
    required this.highlighted,
    this.isEditable = false,
    this.controller,
    this.initialEditText,
    this.onChanged,
    this.onTextChanged,
    this.onDelete,
  });

  @override
  State<ExpenseStatCard> createState() => _ExpenseStatCardState();
}

class _ExpenseStatCardState extends State<ExpenseStatCard> {
  bool _hovering = false;
  bool _focused = false;
  final FocusNode _focusNode = FocusNode();
  TextEditingController? _internalCtrl;

  TextEditingController? get _effectiveCtrl {
    if (widget.controller != null) return widget.controller;
    if (widget.initialEditText != null) {
      _internalCtrl ??= TextEditingController(text: widget.initialEditText);
      return _internalCtrl;
    }
    return null;
  }

  @override
  void didUpdateWidget(covariant ExpenseStatCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null &&
        widget.initialEditText != null &&
        _internalCtrl != null &&
        !_focused &&
        _internalCtrl!.text != widget.initialEditText) {
      _internalCtrl!.text = widget.initialEditText!;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _internalCtrl?.dispose();
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
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 13, color: accentText),
                        const SizedBox(width: 4),
                      ],
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
                  if (widget.isEditable && _effectiveCtrl != null)
                    Focus(
                      onFocusChange: (hasFocus) => setState(() => _focused = hasFocus),
                      child: TextField(
                        focusNode: _focusNode,
                        controller: _effectiveCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        textAlign: TextAlign.center,
                        onChanged: (val) {
                          widget.onTextChanged?.call(val);
                          widget.onChanged?.call();
                        },
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
              if (widget.isEditable && widget.onDelete != null)
                PositionedDirectional(
                  top: -6,
                  end: -4,
                  child: InkWell(
                    onTap: widget.onDelete,
                    borderRadius: BorderRadius.circular(99),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.danger.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 13,
                        color: AppColors.dangerText(isDark),
                      ),
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
