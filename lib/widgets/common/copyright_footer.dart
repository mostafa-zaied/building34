import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class CopyrightFooter extends StatefulWidget {
  final bool isDark;

  const CopyrightFooter({super.key, required this.isDark});

  @override
  State<CopyrightFooter> createState() => _CopyrightFooterState();
}

class _CopyrightFooterState extends State<CopyrightFooter>
    with SingleTickerProviderStateMixin {
  static const String _copyrightText = '© Mostafa Zaied';
  static final Uri _whatsAppUri = Uri.parse('https://wa.me/201021950445');

  late final AnimationController _animCtrl;
  late final Animation<double> _iconScale;
  bool _hovering = false;

  bool get _isWidgetTest =>
      WidgetsBinding.instance.runtimeType.toString() ==
      'AutomatedTestWidgetsFlutterBinding';

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _iconScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.94, end: 1.10)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.10, end: 0.94)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_animCtrl);

    if (!_isWidgetTest) {
      _animCtrl.repeat();
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _openWhatsApp() async {
    try {
      await launchUrl(_whatsAppUri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final style = AppTypography.caption.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.35,
    );

    final baseColor = AppColors.textSecondary(isDark);
    final highlightColor = AppColors.primaryText(isDark);
    final accentColor = AppColors.emeraldText(isDark);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Center(
          child: MouseRegion(
            onEnter: (_) => setState(() => _hovering = true),
            onExit: (_) => setState(() => _hovering = false),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _openWhatsApp,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md + 2,
                    vertical: AppSpacing.xs + 2,
                  ),
                  decoration: BoxDecoration(
                    color: _hovering
                        ? AppColors.surface(isDark)
                        : AppColors.card(isDark),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                      color: _hovering
                          ? highlightColor.withValues(alpha: 0.45)
                          : AppColors.border(isDark),
                    ),
                    boxShadow: _hovering
                        ? AppShadows.accentGlow(
                            AppColors.primary,
                            active: true,
                            isDark: isDark,
                          )
                        : AppShadows.card(isDark),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: _iconScale,
                        child: Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 13.5,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs + 1),
                      _isWidgetTest
                          ? Text(
                              _copyrightText,
                              style: style.copyWith(color: baseColor),
                            )
                          : AnimatedBuilder(
                              animation: _animCtrl,
                              builder: (_, child) {
                                final t = _animCtrl.value;
                                return ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                      begin: Alignment(-1.6 + (t * 3.2), 0),
                                      end: Alignment(-0.2 + (t * 3.2), 0),
                                      colors: [
                                        baseColor,
                                        highlightColor,
                                        accentColor,
                                        baseColor,
                                      ],
                                    ).createShader(bounds);
                                  },
                                  child: child,
                                );
                              },
                              child: Text(_copyrightText, style: style),
                            ),
                    ],
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
