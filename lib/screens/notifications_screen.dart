import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../cubit/building_cubit.dart';
import '../cubit/building_state.dart';
import '../l10n/app_localizations.dart';
import '../models/building_models.dart';
import '../widgets/common/app_card.dart';
import '../widgets/dialogs/confirm_delete_dialog.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _onlyUnread = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BuildingCubit>().refreshNotifications();
      }
    });
  }

  ({IconData icon, Color color, String typeLabel}) _metaForEvent(
    String eventType,
    AppLocalizations s,
  ) {
    switch (eventType) {
      case 'announcement':
        return (
          icon: Icons.campaign_rounded,
          color: AppColors.amber,
          typeLabel: s.notifTypeAnnouncement,
        );
      case 'new_month':
        return (
          icon: Icons.calendar_month_rounded,
          color: AppColors.primary,
          typeLabel: s.notifTypeNewMonth,
        );
      case 'payment_uploaded':
        return (
          icon: Icons.receipt_long_rounded,
          color: AppColors.emerald,
          typeLabel: s.notifTypePayment,
        );
      case 'feedback_submitted':
        return (
          icon: Icons.forum_rounded,
          color: const Color(0xFF8B5CF6),
          typeLabel: s.notifTypeFeedback,
        );
      default:
        return (
          icon: Icons.notifications_active_rounded,
          color: AppColors.primary,
          typeLabel: s.notifTypeGeneral,
        );
    }
  }

  String _formatTimestamp(DateTime dt, String locale) {
    final local = dt.toLocal();
    return DateFormat('d MMM yyyy • h:mm a', locale).format(local);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuildingCubit, BuildingState>(
      builder: (context, state) {
        final cubit = context.read<BuildingCubit>();
        final s = state.s;
        final isDark = state.isDarkMode;
        final locale = state.localeCode;
        final all = state.notifications;
        final unreadCount = state.unreadNotificationsCount;
        final visible = _onlyUnread
            ? all.where((n) => !state.readNotificationIds.contains(n.id)).toList()
            : all;

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
          appBar: AppBar(
            backgroundColor: AppColors.surface(isDark),
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              s.notifHistoryTitle,
              style: AppTypography.headline.copyWith(
                fontSize: 16,
                color: AppColors.textPrimary(isDark),
              ),
            ),
            centerTitle: true,
            actions: [
              if (unreadCount > 0)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: AppSpacing.xs),
                  child: TextButton(
                    onPressed: cubit.markAllNotificationsRead,
                    child: Text(
                      s.notifMarkAllReadBtn,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primaryText(isDark),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, color: AppColors.border(isDark)),
            ),
          ),
          body: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Filter Chips Toolbar
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.xs,
                      ),
                      child: Row(
                        children: [
                          _FilterChipPill(
                            label: s.notifFilterAll(all.length),
                            selected: !_onlyUnread,
                            isDark: isDark,
                            onTap: () => setState(() => _onlyUnread = false),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _FilterChipPill(
                            label: s.notifFilterUnread(unreadCount),
                            selected: _onlyUnread,
                            isDark: isDark,
                            onTap: () => setState(() => _onlyUnread = true),
                          ),
                          const Spacer(),
                          IconButton(
                            tooltip: s.refreshTooltip,
                            visualDensity: VisualDensity.compact,
                            onPressed: cubit.refreshNotifications,
                            icon: Icon(
                              Icons.refresh_rounded,
                              size: 19,
                              color: AppColors.textSecondary(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Notifications List
                    Expanded(
                      child: visible.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.xl),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.notifications_none_rounded,
                                        size: 30,
                                        color: AppColors.primaryText(isDark),
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Text(
                                      _onlyUnread ? s.notifEmptyUnread : s.notifEmptyAll,
                                      textAlign: TextAlign.center,
                                      style: AppTypography.body.copyWith(
                                        color: AppColors.textSecondary(isDark),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                              itemCount: visible.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (context, idx) {
                                final item = visible[idx];
                                final isUnread =
                                    !state.readNotificationIds.contains(item.id);
                                final meta = _metaForEvent(item.eventType, s);

                                return _NotificationCard(
                                  item: item,
                                  isUnread: isUnread,
                                  icon: meta.icon,
                                  accentColor: meta.color,
                                  typeLabel: meta.typeLabel,
                                  timeLabel: _formatTimestamp(item.createdAt, locale),
                                  isDark: isDark,
                                  isAdmin: state.isAdminAuthenticated,
                                  deleteLabel: s.confirmDeleteBtn,
                                  onTap: () => cubit.markNotificationRead(item.id),
                                  onDelete: () async {
                                    await showConfirmDeleteDialog(
                                      context: context,
                                      s: s,
                                      isDark: isDark,
                                      message: s.confirmDeleteNotifBody,
                                      onConfirm: () =>
                                          cubit.deleteAppNotification(item.id),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FilterChipPill extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterChipPill({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: isDark ? 0.20 : 0.12)
                : AppColors.card(isDark),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.45)
                  : AppColors.border(isDark),
            ),
          ),
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w800,
              color: selected
                  ? AppColors.primaryText(isDark)
                  : AppColors.textSecondary(isDark),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotificationItem item;
  final bool isUnread;
  final IconData icon;
  final Color accentColor;
  final String typeLabel;
  final String timeLabel;
  final bool isDark;
  final bool isAdmin;
  final String deleteLabel;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.item,
    required this.isUnread,
    required this.icon,
    required this.accentColor,
    required this.typeLabel,
    required this.timeLabel,
    required this.isDark,
    required this.isAdmin,
    required this.deleteLabel,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        borderColor: isUnread
            ? AppColors.primary.withValues(alpha: isDark ? 0.45 : 0.35)
            : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, size: 20, color: accentColor),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppTypography.label.copyWith(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary(isDark),
                          ),
                        ),
                      ),
                      if (isUnread) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.6),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: AppTypography.body.copyWith(
                      fontSize: 12.5,
                      color: AppColors.textSecondary(isDark),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$typeLabel • $timeLabel',
                          style: AppTypography.caption.copyWith(
                            fontSize: 11,
                            color: AppColors.textSecondary(isDark),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (isAdmin)
                        InkWell(
                          onTap: onDelete,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.delete_outline_rounded,
                                  size: 13,
                                  color: AppColors.dangerText(isDark),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  deleteLabel,
                                  style: AppTypography.caption.copyWith(
                                    fontSize: 10.5,
                                    color: AppColors.dangerText(isDark),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
