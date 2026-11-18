import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../cubit/building_cubit.dart';
import '../cubit/building_state.dart';
import '../models/building_models.dart';
import '../widgets/common/app_button.dart';
import '../widgets/common/app_card.dart';
import '../widgets/dialogs/confirm_delete_dialog.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  Future<void> _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone.trim());
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _launchWhatsApp(String waNumber) async {
    final uri = Uri.parse('https://wa.me/$waNumber');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _showAddContactDialog(
    BuildContext context,
    BuildingCubit cubit,
    BuildingState state,
  ) async {
    final s = state.s;
    final isDark = state.isDarkMode;
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String? errMsg;
    bool saving = false;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: AppColors.card(isDark),
          title: Text(
            s.addContactTitle,
            style: AppTypography.headline.copyWith(fontSize: 15),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: s.contactNameLabel,
                    hintText: s.contactNameHint,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: roleCtrl,
                  decoration: InputDecoration(
                    labelText: s.contactRoleLabel,
                    hintText: s.contactRoleHint,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: s.contactPhoneLabel,
                    hintText: s.contactPhoneHint,
                  ),
                ),
                if (errMsg != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    errMsg!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(ctx),
              child: Text(s.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryActionBg(isDark),
                foregroundColor: AppColors.onPrimaryAction(isDark),
              ),
              onPressed: saving
                  ? null
                  : () async {
                      if (nameCtrl.text.trim().isEmpty ||
                          phoneCtrl.text.trim().isEmpty) {
                        setModalState(() => errMsg = s.errContactFields);
                        return;
                      }
                      setModalState(() {
                        saving = true;
                        errMsg = null;
                      });
                      final ok = await cubit.addBuildingContact(
                        name: nameCtrl.text,
                        roleDesc: roleCtrl.text,
                        phone: phoneCtrl.text,
                      );
                      if (ok && ctx.mounted) {
                        Navigator.pop(ctx);
                      } else if (ctx.mounted) {
                        setModalState(() => saving = false);
                      }
                    },
              child: saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(s.saveAll),
            ),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 350), () {
      nameCtrl.dispose();
      roleCtrl.dispose();
      phoneCtrl.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuildingCubit, BuildingState>(
      builder: (context, state) {
        final cubit = context.read<BuildingCubit>();
        final s = state.s;
        final isDark = state.isDarkMode;
        final contacts = state.buildingContacts;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Icon(
                            Icons.contact_phone_outlined,
                            size: 20,
                            color: AppColors.primaryText(isDark),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.contactsTitle,
                                style: AppTypography.headline.copyWith(fontSize: 15),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                s.contactsSubtitle,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        AppPrimaryButton(
                          label: s.addContactBtn,
                          icon: Icons.add_rounded,
                          backgroundColor: AppColors.primaryActionBg(isDark),
                          foregroundColor: AppColors.onPrimaryAction(isDark),
                          onPressed: () => _showAddContactDialog(context, cubit, state),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: contacts.isEmpty
                        ? Center(
                            child: AppCard(
                              padding: const EdgeInsetsDirectional.all(AppSpacing.xxxl),
                              child: Text(
                                s.noContactsYet,
                                style: AppTypography.body.copyWith(
                                  color: AppColors.textSecondary(isDark),
                                ),
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsetsDirectional.only(bottom: 90),
                            itemCount: contacts.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (context, index) {
                              final c = contacts[index];
                              return _ContactCard(
                                contact: c,
                                isDark: isDark,
                                isAdmin: state.isAdminOpen,
                                callLabel: s.callBtn,
                                waLabel: s.whatsappBtn,
                                onCall: () => _launchPhone(c.phone),
                                onWhatsApp: c.supportsWhatsApp
                                    ? () => _launchWhatsApp(c.whatsappNumber)
                                    : null,
                                onDelete: state.isAdminOpen
                                    ? () async {
                                        await showConfirmDeleteDialog(
                                          context: context,
                                          s: s,
                                          isDark: isDark,
                                          message: s.confirmDeleteContactBody(c.name),
                                          onConfirm: () => cubit.deleteBuildingContact(c.id),
                                        );
                                      }
                                    : null,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ContactCard extends StatelessWidget {
  final BuildingContact contact;
  final bool isDark;
  final bool isAdmin;
  final String callLabel;
  final String waLabel;
  final VoidCallback onCall;
  final VoidCallback? onWhatsApp;
  final VoidCallback? onDelete;

  const _ContactCard({
    required this.contact,
    required this.isDark,
    required this.isAdmin,
    required this.callLabel,
    required this.waLabel,
    required this.onCall,
    this.onWhatsApp,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surface(isDark),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border(isDark)),
                ),
                child: Icon(
                  Icons.phone_in_talk_outlined,
                  size: 18,
                  color: AppColors.primaryText(isDark),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: AppTypography.title.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    if (contact.roleDesc.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        contact.roleDesc,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary(isDark),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isAdmin && onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: AppColors.dangerText(isDark),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onCall,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryActionBg(isDark),
                    foregroundColor: AppColors.onPrimaryAction(isDark),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  icon: const Icon(Icons.call_rounded, size: 16),
                  label: Text(
                    '$callLabel: ${contact.phone}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onPrimaryAction(isDark),
                    ),
                  ),
                ),
              ),
              if (onWhatsApp != null) ...[
                const SizedBox(width: AppSpacing.sm),
                ElevatedButton.icon(
                  onPressed: onWhatsApp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  icon: const Icon(Icons.chat_rounded, size: 16),
                  label: Text(
                    waLabel,
                    style: AppTypography.label.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
