import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../core/utils/image_saver.dart';
import '../cubit/building_cubit.dart';
import '../cubit/building_state.dart';
import '../models/building_models.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  final GlobalKey _reportKey = GlobalKey();
  int? _selectedMonthId;
  bool _showExpenses = true;
  bool _showApts = true;
  bool _showEmergency = true;
  bool _savingImg = false;

  String _formatMonthTitle(MonthBill m, String locale) {
    final dt = DateTime(m.yearNum, m.monthNum, 1);
    return '${DateFormat.MMMM(locale).format(dt)} ${m.yearNum}';
  }

  Future<void> _saveReportAsPng(MonthBill month, BuildingState state) async {
    if (_savingImg) return;
    setState(() => _savingImg = true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 40));
      final boundary =
          _reportKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 2.5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final pngBytes = byteData.buffer.asUint8List();
      final fileName =
          'MABNA_CARE_Statement_${month.yearNum}_${month.monthNum}.png';
      final saved = await savePngImage(pngBytes, fileName);
      if (!mounted) return;
      final s = state.s;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(saved ? s.reportSavedToast : s.receiptSaveNotSupported),
          backgroundColor: saved ? AppColors.emerald : AppColors.primary,
        ),
      );
    } finally {
      if (mounted) setState(() => _savingImg = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuildingCubit, BuildingState>(
      builder: (context, state) {
        final s = state.s;
        final isDark = state.isDarkMode;
        final locale = state.localeCode;

        final months = state.months;
        final MonthBill? month = months.isEmpty
            ? null
            : months.firstWhere(
                (m) => m.id == _selectedMonthId,
                orElse: () => state.currentMonth ?? months.last,
              );

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
          appBar: AppBar(
            backgroundColor: AppColors.surface(isDark),
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              s.monthlyReportScreenTitle,
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
          body: month == null
              ? Center(
                  child: Text(
                    s.analyticsNoData,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Top Controls: Month Picker + Section Toggles
                    Container(
                      width: double.infinity,
                      color: AppColors.surface(isDark),
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        AppSpacing.md,
                        AppSpacing.sm,
                        AppSpacing.md,
                        AppSpacing.sm,
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 540),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month_rounded,
                                    size: 16,
                                    color: AppColors.primaryText(isDark),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Expanded(
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        value: month.id,
                                        isDense: true,
                                        dropdownColor: AppColors.cardElevated(isDark),
                                        style: AppTypography.label.copyWith(
                                          color: AppColors.textPrimary(isDark),
                                          fontWeight: FontWeight.w800,
                                        ),
                                        items: months
                                            .map(
                                              (m) => DropdownMenuItem<int>(
                                                value: m.id,
                                                child: Text(
                                                  '${_formatMonthTitle(m, locale)} (${s.monthOption(m.monthNum, m.yearNum)})',
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (id) {
                                          if (id != null) {
                                            setState(() => _selectedMonthId = id);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  _toggleChip(
                                    label: s.reportChipExpenses,
                                    selected: _showExpenses,
                                    isDark: isDark,
                                    onTap: () => setState(
                                      () => _showExpenses = !_showExpenses,
                                    ),
                                  ),
                                  _toggleChip(
                                    label: s.reportChipApts,
                                    selected: _showApts,
                                    isDark: isDark,
                                    onTap: () =>
                                        setState(() => _showApts = !_showApts),
                                  ),
                                  _toggleChip(
                                    label: s.reportChipEmergency,
                                    selected: _showEmergency,
                                    isDark: isDark,
                                    onTap: () => setState(
                                      () => _showEmergency = !_showEmergency,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Divider(height: 1, color: AppColors.border(isDark)),

                    // Scrollable Executive White Statement Preview (Style A)
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 540),
                            child: RepaintBoundary(
                              key: _reportKey,
                              child: _StatementPaperA(
                                state: state,
                                month: month,
                                monthTitle: _formatMonthTitle(month, locale),
                                showExpenses: _showExpenses,
                                showApts: _showApts,
                                showEmergency: _showEmergency,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Sticky Bottom Save Image Bar
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface(isDark),
                        border: Border(
                          top: BorderSide(color: AppColors.border(isDark)),
                        ),
                      ),
                      child: SafeArea(
                        top: false,
                        child: Align(
                          alignment: Alignment.center,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 540),
                            child: SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _savingImg
                                    ? null
                                    : () => _saveReportAsPng(month, state),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.md,
                                    ),
                                  ),
                                ),
                                icon: _savingImg
                                    ? const SizedBox(
                                        width: 17,
                                        height: 17,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.download_rounded,
                                        size: 19,
                                      ),
                                label: Text(
                                  s.reportSavePngBtn,
                                  style: AppTypography.label.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _toggleChip({
    required String label,
    required bool selected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(
        label,
        style: AppTypography.caption.copyWith(
          fontWeight: FontWeight.w700,
          color: selected
              ? AppColors.primaryText(isDark)
              : AppColors.textSecondary(isDark),
        ),
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary.withValues(alpha: 0.16),
      backgroundColor: AppColors.card(isDark),
      checkmarkColor: AppColors.primaryText(isDark),
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.border(isDark),
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}

/// Executive Formal Statement Paper (Style A) — crisp white layout designed
/// specifically for clean WhatsApp sharing and readability on any phone.
class _StatementPaperA extends StatelessWidget {
  final BuildingState state;
  final MonthBill month;
  final String monthTitle;
  final bool showExpenses;
  final bool showApts;
  final bool showEmergency;

  const _StatementPaperA({
    required this.state,
    required this.month,
    required this.monthTitle,
    required this.showExpenses,
    required this.showApts,
    required this.showEmergency,
  });

  @override
  Widget build(BuildContext context) {
    final s = state.s;
    final totalExp = month.totalExpenses.round();
    final share = month.sharePerApt;
    final collected = month.totalCollected;
    final expected = month.totalExpected;
    final remaining = month.totalRemaining;
    final paidCount = month.payments.keys
        .where((k) => k >= 1 && k <= month.aptsCount)
        .length;
    final unpaidCount = month.unpaidCount;
    final pct =
        expected > 0 ? ((collected / expected) * 100).round().clamp(0, 100) : 0;
    final issuedDate = DateFormat('d/M/yyyy').format(DateTime.now());

    final expenseRows = <({String label, int amount})>[
      (label: s.waterLabel, amount: month.water.round()),
      (label: s.elecLabel, amount: month.elec.round()),
      (label: s.elevLabel, amount: month.elev.round()),
      (label: s.cleanLabel, amount: month.clean.round()),
      for (final ce in month.customExpenses)
        (label: ce.name, amount: ce.amount.round()),
    ];

    final recentTx = state.emergencyTransactions.take(4).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Official Navy-Blue Header Banner
          Container(
            padding: const EdgeInsetsDirectional.all(18),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF1E3A8A),
                  Color(0xFF1D4ED8),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.28),
                    ),
                  ),
                  child: const Icon(
                    Icons.apartment_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.displayBuildingName,
                        style: AppTypography.headline.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        state.building.isDefaultBuilding
                            ? s.reportDocSubtitle
                            : '${s.reportDocSubtitle} • ${s.appTitle}',
                        style: AppTypography.caption.copyWith(
                          color: const Color(0xFFDBEAFE),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        monthTitle,
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.reportIssuedLabel(issuedDate),
                      style: const TextStyle(
                        color: Color(0xFFBFDBFE),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Paper Body
          Padding(
            padding: const EdgeInsetsDirectional.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 2. 2x2 KPI Strip
                Row(
                  children: [
                    Expanded(
                      child: _kpiBox(
                        label: s.reportTotalExpensesKpi,
                        value: s.currency(totalExp),
                        bg: const Color(0xFFF8FAFC),
                        border: const Color(0xFFE2E8F0),
                        labelColor: const Color(0xFF64748B),
                        valueColor: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _kpiBox(
                        label: s.sharePerAptLabel,
                        value: s.currency(share),
                        bg: const Color(0xFFEFF6FF),
                        border: const Color(0xFFBFDBFE),
                        labelColor: const Color(0xFF2563EB),
                        valueColor: const Color(0xFF1E3A8A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _kpiBox(
                        label: '${s.analyticsCollectedLabel} ($pct%)',
                        value: '${s.currency(collected)} ($paidCount/${month.aptsCount})',
                        bg: const Color(0xFFECFDF5),
                        border: const Color(0xFFA7F3D0),
                        labelColor: const Color(0xFF047857),
                        valueColor: const Color(0xFF064E3B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _kpiBox(
                        label: s.analyticsRemainingLabel,
                        value: '${s.currency(remaining)} ($unpaidCount)',
                        bg: const Color(0xFFFFFBEB),
                        border: const Color(0xFFFDE68A),
                        labelColor: const Color(0xFFB45309),
                        valueColor: const Color(0xFF78350F),
                      ),
                    ),
                  ],
                ),

                // 3. Monthly Expenses Table
                if (showExpenses) ...[
                  const SizedBox(height: 16),
                  _sectionTitle(
                    title: s.reportSectionExpenses,
                    trailing: s.reportAptsCountUnit(month.aptsCount),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          for (int i = 0; i < expenseRows.length; i++)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              color: i.isEven
                                  ? const Color(0xFFF8FAFC)
                                  : Colors.white,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      expenseRows[i].label,
                                      style: const TextStyle(
                                        color: Color(0xFF334155),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    s.currency(expenseRows[i].amount),
                                    style: const TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      fontFeatures: [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEFF6FF),
                              border: Border(
                                top: BorderSide(
                                  color: Color(0xFF93C5FD),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  s.reportTotalRow,
                                  style: const TextStyle(
                                    color: Color(0xFF1E3A8A),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  s.currency(totalExp),
                                  style: const TextStyle(
                                    color: Color(0xFF1E3A8A),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    fontFeatures: [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // 4. Formal Apartments Payment Table (Style A)
                if (showApts) ...[
                  const SizedBox(height: 16),
                  _sectionTitle(
                    title: s.reportSectionApts,
                    trailing: '$paidCount / ${month.aptsCount}',
                    trailingColor: const Color(0xFF047857),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        // Table Header
                        Container(
                          color: const Color(0xFFF1F5F9),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 22,
                                child: Text(
                                  '#',
                                  style: TextStyle(
                                    color: Color(0xFF475569),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Text(
                                  s.reportColApt,
                                  style: const TextStyle(
                                    color: Color(0xFF475569),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  s.reportColDue,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF475569),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  s.reportColStatus,
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                    color: Color(0xFF475569),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Rows
                        for (int aptNum = 1;
                            aptNum <= month.aptsCount;
                            aptNum++) ...[
                          Builder(
                            builder: (_) {
                              final isPaid = month.payments.containsKey(aptNum);
                              final extra = month.extraTotalFor(aptNum);
                              final due = month.dueFor(aptNum);
                              final isOverdue = !isPaid && month.isPastDue;
                              final statusLabel = isPaid
                                  ? '${s.paidBadge} ✓'
                                  : (isOverdue
                                      ? s.overdueBadge
                                      : s.pendingPaymentBadge);
                              final badgeBg = isPaid
                                  ? const Color(0xFFD1FAE5)
                                  : (isOverdue
                                      ? const Color(0xFFFEE2E2)
                                      : const Color(0xFFFEF3C7));
                              final badgeFg = isPaid
                                  ? const Color(0xFF065F46)
                                  : (isOverdue
                                      ? const Color(0xFFB91C1C)
                                      : const Color(0xFF92400E));
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: aptNum.isEven
                                      ? const Color(0xFFF8FAFC)
                                      : Colors.white,
                                  border: const Border(
                                    top: BorderSide(
                                      color: Color(0xFFF1F5F9),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 22,
                                      child: Text(
                                        '$aptNum',
                                        style: const TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              state.aptLabel(aptNum),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Color(0xFF0F172A),
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          if (extra > 0) ...[
                                            const SizedBox(width: 4),
                                            Text(
                                              '(+$extra)',
                                              style: const TextStyle(
                                                color: Color(0xFFD97706),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        s.currency(due),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Color(0xFF334155),
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w800,
                                          fontFeatures: [
                                            FontFeature.tabularFigures(),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Align(
                                        alignment: AlignmentDirectional.centerEnd,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: badgeBg,
                                            borderRadius: BorderRadius.circular(
                                              99,
                                            ),
                                          ),
                                          child: Text(
                                            statusLabel,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: badgeFg,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                // 5. Emergency Fund Summary
                if (showEmergency) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsetsDirectional.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.shield_rounded,
                                  size: 16,
                                  color: Color(0xFF047857),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  s.reportEmergencyBalanceTitle,
                                  style: const TextStyle(
                                    color: Color(0xFF064E3B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              s.currency(state.baseEmergency.round()),
                              style: const TextStyle(
                                color: Color(0xFF065F46),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                        if (recentTx.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Divider(height: 1, color: Color(0xFFA7F3D0)),
                          const SizedBox(height: 6),
                          for (final tx in recentTx)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 3),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '• ${tx.reason} (${DateFormat('d/M').format(tx.createdAt.toLocal())})',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF334155),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${tx.amount < 0 ? '+' : '-'}${s.currency(tx.amount.abs().round())}',
                                    style: TextStyle(
                                      color: tx.amount < 0
                                          ? const Color(0xFF047857)
                                          : const Color(0xFFB91C1C),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ],

                // 6. Official Verified Footer
                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 14,
                          color: Color(0xFF059669),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${s.receiptStampTitle} • ${state.displayBuildingName}',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'mabna-care.web.app',
                      style: TextStyle(
                        color: Color(0xFF1D4ED8),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kpiBox({
    required String label,
    required String value,
    required Color bg,
    required Color border,
    required Color labelColor,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: labelColor,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle({
    required String title,
    required String trailing,
    Color trailingColor = const Color(0xFF64748B),
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 12.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          trailing,
          style: TextStyle(
            color: trailingColor,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
