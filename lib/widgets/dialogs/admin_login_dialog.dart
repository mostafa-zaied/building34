import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

Future<String?> showAdminLoginDialog(BuildContext context, AppLocalizations s) {
  return showDialog<String>(
    context: context,
    builder: (ctx) => _AdminLoginDialog(s: s),
  );
}

class _AdminLoginDialog extends StatefulWidget {
  final AppLocalizations s;

  const _AdminLoginDialog({required this.s});

  @override
  State<_AdminLoginDialog> createState() => _AdminLoginDialogState();
}

class _AdminLoginDialogState extends State<_AdminLoginDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    return AlertDialog(
      title: Text(s.adminLoginTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      content: TextField(
        controller: _ctrl,
        obscureText: true,
        autofocus: true,
        onSubmitted: (val) => Navigator.pop(context, val),
        decoration: InputDecoration(hintText: s.adminPassHint),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(s.cancel)),
        ElevatedButton(onPressed: () => Navigator.pop(context, _ctrl.text), child: Text(s.login)),
      ],
    );
  }
}
