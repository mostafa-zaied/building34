import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/push_notifications.dart';
import '../../cubit/building_cubit.dart';
import '../../cubit/building_state.dart';
import '../../screens/admin_settings_screen.dart';
import '../../screens/buildings_portal_screen.dart';
import '../../screens/install_app_screen.dart';
import '../dialogs/admin_login_dialog.dart';
import '../dialogs/manage_apartments_dialog.dart';

class AppSideMenu extends StatelessWidget {
  final BuildingCubit cubit;
  final BuildingState state;
  final VoidCallback? onClose;

  const AppSideMenu({
    super.key,
    required this.cubit,
    required this.state,
    this.onClose,
  });

  Future<void> _contactManager(String waNumber) async {
    if (waNumber.isEmpty) return;
    final uri = Uri.parse('https://wa.me/$waNumber');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _close(BuildContext context) {
    if (onClose != null) {
      onClose!();
    } else {
      Navigator.maybePop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = state.s;
    final isDark = state.isDarkMode;
    final waNumber = state.building.normalizedWhatsapp;
    final headerSub = !state.building.isDefaultBuilding
        ? (state.building.city.isNotEmpty
            ? '${state.building.city} • ${state.building.code}'
            : s.buildingCodeBadge(state.building.code))
        : s.splashTagline;

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Menu Header
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.emerald],
                            begin: AlignmentDirectional.topStart,
                            end: AlignmentDirectional.bottomEnd,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.apartment_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.displayBuildingName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.title.copyWith(
                                color: AppColors.textPrimary(isDark),
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              headerSub,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: s.close,
                        onPressed: () => _close(context),
                        icon: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: AppColors.textSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                  if (state.myAptNum != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: isDark ? 0.16 : 0.10),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: isDark ? 0.30 : 0.20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.home_rounded,
                            size: 16,
                            color: AppColors.primaryText(isDark),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              s.drawerMyAptLabel(state.aptLabel(state.myAptNum!)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textPrimary(isDark),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.lg),
              child: Divider(height: 1, color: AppColors.border(isDark)),
            ),

            // Menu Body
            Expanded(
              child: ListView(
                padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                children: [
                  // 1. Extra Sections
                  _sectionHeader(s.drawerExtraSections, isDark),
                  _drawerTile(
                    icon: Icons.bar_chart_rounded,
                    label: s.navAnalytics,
                    isDark: isDark,
                    selected: state.selectedNavIndex == 4,
                    accentColor: AppColors.primaryText(isDark),
                    onTap: () {
                      _close(context);
                      cubit.selectNav(4);
                    },
                  ),
                  _drawerTile(
                    icon: Icons.contact_phone_outlined,
                    label: s.navContactsFull,
                    isDark: isDark,
                    selected: state.selectedNavIndex == 2,
                    onTap: () {
                      _close(context);
                      cubit.selectNav(2);
                    },
                  ),

                  const SizedBox(height: AppSpacing.sm),
                  Divider(height: 1, color: AppColors.border(isDark)),
                  const SizedBox(height: AppSpacing.sm),

                  // 2. App Preferences
                  _sectionHeader(s.drawerPreferences, isDark),
                  _drawerTile(
                    icon: isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                    label: s.drawerThemeLabel,
                    isDark: isDark,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface(isDark),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: AppColors.border(isDark)),
                      ),
                      child: Text(
                        isDark ? s.drawerThemeDark : s.drawerThemeLight,
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(isDark),
                        ),
                      ),
                    ),
                    onTap: cubit.toggleTheme,
                  ),
                  _drawerTile(
                    icon: Icons.language_rounded,
                    label: s.drawerLanguageLabel,
                    isDark: isDark,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface(isDark),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: AppColors.border(isDark)),
                      ),
                      child: Text(
                        state.localeCode == 'ar' ? 'العربية' : 'English',
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(isDark),
                        ),
                      ),
                    ),
                    onTap: () => cubit.setLocale(
                      state.localeCode == 'ar' ? 'en' : 'ar',
                    ),
                  ),
                  Builder(
                    builder: (_) {
                      final isGranted = getPushPermissionStatus() == 'granted';
                      return _drawerTile(
                        icon: isGranted
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_none_rounded,
                        label: s.drawerNotificationsLabel,
                        isDark: isDark,
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isGranted
                                ? AppColors.emerald.withValues(alpha: 0.16)
                                : AppColors.surface(isDark),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(
                              color: isGranted
                                  ? AppColors.emerald.withValues(alpha: 0.4)
                                  : AppColors.border(isDark),
                            ),
                          ),
                          child: Text(
                            isGranted ? s.pushEnabledBadge : s.pushEnableAction,
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isGranted
                                  ? AppColors.emeraldText(isDark)
                                  : AppColors.textSecondary(isDark),
                            ),
                          ),
                        ),
                        onTap: () async {
                          _close(context);
                          await cubit.enablePushNotifications();
                        },
                      );
                    },
                  ),
                  _drawerTile(
                    icon: Icons.install_mobile_rounded,
                    label: s.installAppNavLabel,
                    isDark: isDark,
                    accentColor: AppColors.emeraldText(isDark),
                    onTap: () {
                      _close(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const InstallAppScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.sm),
                  Divider(height: 1, color: AppColors.border(isDark)),
                  const SizedBox(height: AppSpacing.sm),

                  // 3. Administration
                  _sectionHeader(s.drawerAdminSection, isDark),
                  if (!state.isAdminAuthenticated)
                    _drawerTile(
                      icon: Icons.admin_panel_settings_outlined,
                      label: s.drawerAdminLogin,
                      isDark: isDark,
                      accentColor: AppColors.primaryText(isDark),
                      onTap: () async {
                        _close(context);
                        if (!AppConfig.isSupabaseConfigured) {
                          await cubit.openAdmin('admin123');
                          return;
                        }
                        await showAdminLoginDialog(
                          context,
                          s,
                          startWithBiometric: true,
                          onVerifyPassword: (pass) =>
                              cubit.openAdmin(pass, showErrorToast: false),
                        );
                      },
                    )
                  else ...[
                    _drawerTile(
                      icon: Icons.settings_outlined,
                      label: s.settingsBtn,
                      isDark: isDark,
                      accentColor: AppColors.primaryText(isDark),
                      onTap: () {
                        _close(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (settingsCtx) => AdminSettingsScreen(
                              onOpenManageApts: () => showManageApartmentsDialog(
                                context: settingsCtx,
                                cubit: cubit,
                                state: cubit.state,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    _drawerTile(
                      icon: Icons.visibility_outlined,
                      label: s.adminViewsTitle,
                      isDark: isDark,
                      selected: state.selectedNavIndex == 5,
                      accentColor: AppColors.primaryText(isDark),
                      onTap: () {
                        _close(context);
                        cubit.selectNav(5);
                        cubit.refreshPageViewStats(showBusy: false);
                      },
                    ),
                    _drawerTile(
                      icon: Icons.domain_rounded,
                      label: s.buildingsPortalNavLabel,
                      isDark: isDark,
                      accentColor: AppColors.emeraldText(isDark),
                      onTap: () {
                        _close(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const BuildingsPortalScreen(),
                          ),
                        );
                      },
                    ),
                    _drawerTile(
                      icon: Icons.logout_rounded,
                      label: s.adminLogoutBtn,
                      isDark: isDark,
                      accentColor: AppColors.dangerText(isDark),
                      onTap: () async {
                        _close(context);
                        await cubit.logoutAdmin();
                      },
                    ),
                  ],
                ],
              ),
            ),

            // Footer: Contact Manager
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Container(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: isDark ? 0.14 : 0.09),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppColors.emerald.withValues(alpha: isDark ? 0.28 : 0.22),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (waNumber.isNotEmpty)
                      TextButton.icon(
                        onPressed: () => _contactManager(waNumber),
                        icon: Icon(
                          Icons.chat_rounded,
                          size: 16,
                          color: AppColors.emeraldText(isDark),
                        ),
                        label: Text(
                          s.contactManagerBtn,
                          style: AppTypography.label.copyWith(
                            color: AppColors.emeraldText(isDark),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
                      child: Text(
                        'v1.0',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary(isDark),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.xs,
      ),
      child: Text(
        title,
        style: AppTypography.caption.copyWith(
          color: AppColors.textSecondary(isDark),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _drawerTile({
    required IconData icon,
    required String label,
    required bool isDark,
    bool selected = false,
    Color? accentColor,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final fg = selected
        ? AppColors.primaryText(isDark)
        : (accentColor ?? AppColors.textPrimary(isDark));

    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.10)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.md,
            vertical: 11,
          ),
          child: Row(
            children: [
              Icon(icon, size: 19, color: fg),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.label.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
