import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/image_saver.dart';
import '../../cubit/building_state.dart';
import '../../models/building_models.dart';
import '../common/confetti_overlay.dart';

/// Opens the full-screen InstaPay-style MABNA CARE Digital Payment Receipt.
Future<void> showDigitalReceiptScreen({
  required BuildContext context,
  required BuildingState state,
  required MonthBill month,
  required int aptNum,
  required PaymentRecord payment,
  bool celebrate = false,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => DigitalReceiptScreen(
        state: state,
        month: month,
        aptNum: aptNum,
        payment: payment,
        celebrate: celebrate,
      ),
    ),
  );
}

class DigitalReceiptScreen extends StatefulWidget {
  final BuildingState state;
  final MonthBill month;
  final int aptNum;
  final PaymentRecord payment;
  final bool celebrate;

  const DigitalReceiptScreen({
    super.key,
    required this.state,
    required this.month,
    required this.aptNum,
    required this.payment,
    this.celebrate = false,
  });

  @override
  State<DigitalReceiptScreen> createState() => _DigitalReceiptScreenState();
}

class _DigitalReceiptScreenState extends State<DigitalReceiptScreen> {
  final GlobalKey _receiptKey = GlobalKey();
  bool _savingImg = false;

  @override
  void initState() {
    super.initState();
    if (widget.celebrate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showConfettiCelebration(context);
      });
    }
  }

  String _formatMonthName() {
    final locale = widget.state.localeCode;
    final dt = DateTime(widget.month.yearNum, widget.month.monthNum, 1);
    final monthName = DateFormat.MMMM(locale).format(dt);
    return '$monthName ${widget.month.yearNum} (${widget.month.monthNum})';
  }

  String _formatPaidAt() {
    final locale = widget.state.localeCode;
    final local = widget.payment.paidAt.toLocal();
    return DateFormat('d MMM yyyy • h:mm a', locale).format(local);
  }

  Future<void> _saveAsPng() async {
    if (_savingImg) return;
    setState(() => _savingImg = true);
    try {
      final boundary =
          _receiptKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final pngBytes = byteData.buffer.asUint8List();
      final fileName =
          'MABNA_CARE_Apt${widget.aptNum}_${widget.month.yearNum}_${widget.month.monthNum}.png';
      final saved = await savePngImage(pngBytes, fileName);
      if (!mounted) return;
      final s = widget.state.s;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(saved ? s.receiptSavedToast : s.receiptSaveNotSupported),
          backgroundColor: saved ? AppColors.emerald : AppColors.primary,
        ),
      );
    } finally {
      if (mounted) setState(() => _savingImg = false);
    }
  }

  Future<void> _shareWhatsApp() async {
    final s = widget.state.s;
    final aptLabel = widget.state.aptLabel(widget.aptNum);
    final totalDue = widget.month.dueFor(widget.aptNum);
    final text = s.receiptWhatsAppText(
      aptLabel,
      _formatMonthName(),
      s.currency(totalDue),
    );
    final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state.s;
    final isDark = widget.state.isDarkMode;
    final aptLabel = widget.state.aptLabel(widget.aptNum);
    final monthShare = widget.month.sharePerApt;
    final extras = widget.month.extraChargesFor(widget.aptNum);
    final totalDue = widget.month.dueFor(widget.aptNum);
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.surface(isDark),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          s.digitalReceiptTitle,
          style: AppTypography.headline.copyWith(
            fontSize: 16,
            color: AppColors.textPrimary(isDark),
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border(isDark)),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RepaintBoundary(
                    key: _receiptKey,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.card(isDark),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: AppColors.border(isDark)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top Gradient Hero
                          Container(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                              AppSpacing.lg,
                              AppSpacing.xl,
                              AppSpacing.lg,
                              AppSpacing.xl,
                            ),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: AlignmentDirectional.topStart,
                                end: AlignmentDirectional.bottomEnd,
                                colors: [
                                  Color(0xFF1E3A8A),
                                  Color(0xFF0F172A),
                                  Color(0xFF064E3B),
                                ],
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.emerald.withValues(alpha: 0.22),
                                    border: Border.all(
                                      color: AppColors.emerald,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.emerald.withValues(alpha: 0.4),
                                        blurRadius: 22,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: Color(0xFF6EE7B7),
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  s.digitalReceiptBrand,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.caption.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  s.currency(totalDue),
                                  style: AppTypography.headline.copyWith(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.emerald.withValues(alpha: 0.22),
                                    borderRadius: BorderRadius.circular(AppRadius.pill),
                                    border: Border.all(
                                      color: AppColors.emerald.withValues(alpha: 0.45),
                                    ),
                                  ),
                                  child: Text(
                                    s.digitalReceiptStatus,
                                    style: AppTypography.caption.copyWith(
                                      color: const Color(0xFF6EE7B7),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Perforated Ticket Cutout Divider
                          _TicketDivider(
                            notchColor: bgColor,
                            lineColor: AppColors.border(isDark),
                          ),

                          // Receipt Details Body (no reference number)
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                              AppSpacing.lg,
                              AppSpacing.xs,
                              AppSpacing.lg,
                              AppSpacing.lg,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _infoRow(s.receiptAptLabel, aptLabel, isDark),
                                const SizedBox(height: AppSpacing.sm),
                                _infoRow(s.receiptMonthLabel, _formatMonthName(), isDark),
                                const SizedBox(height: AppSpacing.sm),
                                _infoRow(s.receiptPaidAtLabel, _formatPaidAt(), isDark),
                                const SizedBox(height: AppSpacing.md),

                                // Breakdown Box
                                Container(
                                  padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface(isDark),
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                    border: Border.all(color: AppColors.border(isDark)),
                                  ),
                                  child: Column(
                                    children: [
                                      _breakdownRow(
                                        s.monthShareLine,
                                        s.currency(monthShare),
                                        isDark,
                                      ),
                                      for (final ex in extras) ...[
                                        const SizedBox(height: 6),
                                        _breakdownRow(
                                          ex.reason.isNotEmpty
                                              ? ex.reason
                                              : s.extraChargesBtn,
                                          '+${s.currency(ex.amount.round())}',
                                          isDark,
                                          valueColor: AppColors.amber,
                                        ),
                                      ],
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: AppSpacing.sm,
                                        ),
                                        child: Divider(
                                          height: 1,
                                          color: AppColors.border(isDark),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            s.receiptTotalPaidLabel,
                                            style: AppTypography.label.copyWith(
                                              color: AppColors.textPrimary(isDark),
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          Text(
                                            s.currency(totalDue),
                                            style: AppTypography.title.copyWith(
                                              color: AppColors.emeraldText(isDark),
                                              fontWeight: FontWeight.w900,
                                              fontFeatures: const [
                                                FontFeature.tabularFigures(),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: AppSpacing.md),
                                Divider(height: 1, color: AppColors.border(isDark)),
                                const SizedBox(height: AppSpacing.md),

                                // Verified Footer Stamp
                                Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [AppColors.primary, AppColors.emerald],
                                        ),
                                        borderRadius: BorderRadius.circular(AppRadius.md),
                                      ),
                                      child: const Icon(
                                        Icons.apartment_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            s.receiptStampTitle,
                                            style: AppTypography.label.copyWith(
                                              color: AppColors.textPrimary(isDark),
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          Text(
                                            '${s.appTitle} • ${s.splashTagline}',
                                            style: AppTypography.caption.copyWith(
                                              color: AppColors.textSecondary(isDark),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.verified_rounded,
                                      color: AppColors.emeraldText(isDark),
                                      size: 26,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Action Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _savingImg ? null : _saveAsPng,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          icon: _savingImg
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.download_rounded, size: 18),
                          label: Text(
                            s.receiptSaveImageBtn,
                            style: AppTypography.label.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _shareWhatsApp,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.emerald.withValues(
                              alpha: isDark ? 0.14 : 0.10,
                            ),
                            foregroundColor: AppColors.emeraldText(isDark),
                            side: BorderSide(
                              color: AppColors.emerald.withValues(alpha: 0.4),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          icon: const Icon(Icons.chat_rounded, size: 18),
                          label: Text(
                            s.receiptShareWhatsAppBtn,
                            style: AppTypography.label.copyWith(
                              color: AppColors.emeraldText(isDark),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary(isDark),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTypography.label.copyWith(
              color: AppColors.textPrimary(isDark),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _breakdownRow(
    String label,
    String value,
    bool isDark, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary(isDark),
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          value,
          style: AppTypography.caption.copyWith(
            color: valueColor ?? AppColors.textPrimary(isDark),
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _TicketDivider extends StatelessWidget {
  final Color notchColor;
  final Color lineColor;

  const _TicketDivider({
    required this.notchColor,
    required this.lineColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: LayoutBuilder(
              builder: (_, c) {
                const dashW = 6.0;
                const gap = 5.0;
                final count = (c.maxWidth / (dashW + gap)).floor().clamp(1, 80);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    count,
                    (_) => Container(width: dashW, height: 1.5, color: lineColor),
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: -12,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: notchColor,
                shape: BoxShape.circle,
                border: Border.all(color: lineColor),
              ),
            ),
          ),
          Positioned(
            right: -12,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: notchColor,
                shape: BoxShape.circle,
                border: Border.all(color: lineColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
