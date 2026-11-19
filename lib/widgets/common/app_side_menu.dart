import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../cubit/building_cubit.dart';
import '../../cubit/building_state.dart';
import '../../screens/admin_settings_screen.dart';
import '../dialogs/admin_login_dialog.dart';
import '../dialogs/manage_apartments_dialog.dart';

class AppSideMenu extends StatelessWidget {
  final BuildingCubit cubit;
  final BuildingState state;

  const AppSideMenu({
    super.key,
    required this.cubit,
    required this.state,
  });

  static const String _managerWhatsApp = '201021950445';

  Future<void> _contactManager() async {
    final uri = Uri.parse('https://wa.me/$_managerWhatsApp');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final s = state.s;
    final isDark = state.isDarkMode;

    return Drawer(
      backgroundColor: AppColors.card(isDark),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drawer Header
            Container(
              padding: EdgeInsetsDirectional.fromSTEB(
                AppSpacing.lg,
                MediaQuery.paddingOf(context).top + AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppRadius.md),
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
                              s.appTitle,
                              style: AppTypography.title.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              s.splashTagline,
                              style: AppTypography.caption.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
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
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.home_outlined,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              s.drawerMyAptLabel(state.aptLabel(state.myAptNum!)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption.copyWith(
                                color: Colors.white,
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

            // Drawer Body
            Expanded(
              child: ListView(
                padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                children: [
                  // 1. Extra Sections
                  _sectionHeader(s.drawerExtraSections, isDark),
                  _drawerTile(
                    icon: Icons.contact_phone_outlined,
                    label: s.navContactsFull,
                    isDark: isDark,
                    selected: state.selectedNavIndex == 2,
                    onTap: () {
                      Navigator.pop(context);
                      cubit.selectNav(2);
                    },
                  ),
                  _drawerTile(
                    icon: Icons.explore_outlined,
                    label: s.navServicesFull,
                    isDark: isDark,
                    selected: state.selectedNavIndex == 4,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.amber,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        s.soonBadge,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      cubit.selectNav(4);
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
                        final rootNav = Navigator.of(context);
                        final navContext = rootNav.context;
                        rootNav.pop();
                        final pass = await showAdminLoginDialog(navContext, s);
                        if (pass != null && pass.trim().isNotEmpty) {
                          await cubit.openAdmin(pass.trim());
                        }
                      },
                    )
                  else ...[
                    _drawerTile(
                      icon: Icons.settings_outlined,
                      label: s.settingsBtn,
                      isDark: isDark,
                      accentColor: AppColors.primaryText(isDark),
                      onTap: () {
                        final nav = Navigator.of(context);
                        nav.pop();
                        nav.push(
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
                      icon: Icons.logout_rounded,
                      label: s.adminLogoutBtn,
                      isDark: isDark,
                      accentColor: AppColors.dangerText(isDark),
                      onTap: () async {
                        Navigator.pop(context);
                        await cubit.logoutAdmin();
                      },
                    ),
                  ],
                ],
              ),
            ),

            // Footer: Contact Manager
            Container(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface(isDark),
                border: Border(
                  top: BorderSide(color: AppColors.border(isDark)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _contactManager,
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
                  ),
                  Text(
                    'v1.0',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                ],
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
