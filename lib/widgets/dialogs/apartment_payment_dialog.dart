import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../config.dart';
import '../../cubit/building_cubit.dart';
import '../../cubit/building_state.dart';
import '../../models/building_models.dart';

Future<void> showApartmentPaymentDialog({
  required BuildContext context,
  required BuildingCubit cubit,
  required BuildingState state,
  required MonthBill month,
  required int aptNum,
  required ImagePicker picker,
}) async {
  final s = state.s;
  final isDark = state.isDarkMode;
  final innerSurface = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

  final existing = month.payments[aptNum];
  if (existing != null) {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${state.aptLabel(aptNum)} — ${s.paidBadge}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(s.fileLabel(existing.fileName), style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black54)),
            const SizedBox(height: 12),
            if (existing.localBytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(existing.localBytes!, height: 220, fit: BoxFit.contain),
              )
            else if (existing.receiptUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(existing.receiptUrl!, height: 220, fit: BoxFit.contain),
              )
            else
              Text(s.receiptAttachedPreviously, style: const TextStyle(color: Color(0xFF22C55E))),
          ],
        ),
        actions: [
          if (state.isAdminOpen)
            TextButton(
              onPressed: () async {
                await cubit.cancelPayment(aptNum);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(s.cancelPaymentAdmin, style: const TextStyle(color: Colors.redAccent)),
            ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s.close)),
        ],
      ),
    );
    return;
  }

  final passCtrl = TextEditingController();
  Uint8List? pickedBytes;
  String? pickedName;
  String? errMsg;
  bool submitting = false;

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModalState) => AlertDialog(
        title: Text(s.dueDialogTitle(state.aptLabel(aptNum), month.sharePerApt), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                s.step1Passcode(!AppConfig.isSupabaseConfigured ? ' (${1000 + aptNum})' : ''),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: s.enterPassHint,
                  filled: true,
                  fillColor: innerSurface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),
              Text(s.step2Image, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  final XFile? file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                  if (file != null) {
                    final bytes = await file.readAsBytes();
                    setModalState(() {
                      pickedBytes = bytes;
                      pickedName = file.name;
                      errMsg = null;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: innerSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: pickedBytes != null ? const Color(0xFF22C55E) : (isDark ? Colors.white24 : Colors.black26),
                      width: 1.5,
                    ),
                  ),
                  child: pickedBytes == null
                      ? Text(s.pickImagePrompt, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12))
                      : Column(
                          children: [
                            Text(s.chosenFile(pickedName ?? ''), style: const TextStyle(fontSize: 12, color: Color(0xFF22C55E), fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(pickedBytes!, height: 110, fit: BoxFit.contain),
                            ),
                          ],
                        ),
                ),
              ),
              if (errMsg != null) ...[
                const SizedBox(height: 10),
                Text(errMsg!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s.cancel)),
          ElevatedButton(
            onPressed: submitting
                ? null
                : () async {
                    if (pickedBytes == null) {
                      setModalState(() => errMsg = s.errMissingImage);
                      return;
                    }
                    setModalState(() => submitting = true);
                    final resErr = await cubit.submitPayment(
                      aptNum: aptNum,
                      passcode: passCtrl.text,
                      imageBytes: pickedBytes!,
                      fileName: pickedName ?? 'receipt.jpg',
                    );
                    if (resErr != null) {
                      setModalState(() {
                        submitting = false;
                        errMsg = '❌ $resErr';
                      });
                      return;
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
            child: Text(submitting ? s.uploadingBtn : s.confirmPaymentBtn),
          ),
        ],
      ),
    ),
  );
  Future.delayed(const Duration(milliseconds: 350), passCtrl.dispose);
}
