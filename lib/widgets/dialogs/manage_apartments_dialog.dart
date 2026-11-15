import 'package:flutter/material.dart';

import '../../cubit/building_cubit.dart';
import '../../cubit/building_state.dart';
import '../../models/building_models.dart';

Future<void> showManageApartmentsDialog({
  required BuildContext context,
  required BuildingCubit cubit,
  required BuildingState state,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ManageApartmentsDialog(cubit: cubit, state: state),
  );
}

class _ManageApartmentsDialog extends StatefulWidget {
  final BuildingCubit cubit;
  final BuildingState state;

  const _ManageApartmentsDialog({
    required this.cubit,
    required this.state,
  });

  @override
  State<_ManageApartmentsDialog> createState() => _ManageApartmentsDialogState();
}

class _ManageApartmentsDialogState extends State<_ManageApartmentsDialog> {
  final _scrollCtrl = ScrollController();
  final Map<int, TextEditingController> _nameCtrls = {};
  final Map<int, TextEditingController> _passCtrls = {};

  List<ApartmentInfo> _apts = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await widget.cubit.fetchAdminApartments();
    if (!mounted) return;
    if (res.error != null || res.apartments == null) {
      setState(() {
        _loading = false;
        _error = res.error ?? 'Error';
      });
      return;
    }

    final apts = List<ApartmentInfo>.from(res.apartments!);
    for (final a in apts) {
      _nameCtrls[a.aptNum] = TextEditingController(text: a.displayName);
      _passCtrls[a.aptNum] = TextEditingController(text: a.passcode);
    }
    setState(() {
      _apts = apts;
      _loading = false;
    });
  }

  void _addNewApartment() {
    final nextNum = _apts.isEmpty ? 1 : _apts.last.aptNum + 1;
    final newApt = ApartmentInfo(aptNum: nextNum, passcode: '${1000 + nextNum}');
    _nameCtrls[nextNum] = TextEditingController(text: '');
    _passCtrls[nextNum] = TextEditingController(text: newApt.passcode);
    setState(() {
      _apts = [..._apts, newApt];
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _deleteApartment(int index) {
    if (_apts.length <= 1) return;
    final oldCtrls = <(String, String)>[];
    for (int i = 0; i < _apts.length; i++) {
      if (i == index) continue;
      final num = _apts[i].aptNum;
      oldCtrls.add((_nameCtrls[num]?.text ?? '', _passCtrls[num]?.text ?? '${1000 + num}'));
    }

    for (final c in _nameCtrls.values) {
      c.dispose();
    }
    for (final c in _passCtrls.values) {
      c.dispose();
    }
    _nameCtrls.clear();
    _passCtrls.clear();

    final updated = <ApartmentInfo>[];
    for (int i = 0; i < oldCtrls.length; i++) {
      final aptNum = i + 1;
      final (name, pass) = oldCtrls[i];
      _nameCtrls[aptNum] = TextEditingController(text: name);
      _passCtrls[aptNum] = TextEditingController(text: pass);
      updated.add(ApartmentInfo(aptNum: aptNum, displayName: name, passcode: pass));
    }

    setState(() {
      _apts = updated;
    });
  }

  Future<void> _saveAll() async {
    setState(() => _saving = true);
    final m = widget.state.currentMonth;
    if (m != null && _apts.length != m.aptsCount) {
      widget.cubit.updateCurrentMonthFields(
        water: m.water,
        elec: m.elec,
        elev: m.elev,
        clean: m.clean,
        forEmerg: m.forEmerg,
        aptsCount: _apts.length,
        baseEmergency: widget.state.baseEmergency,
      );
      await widget.cubit.saveAdminChanges();
    }

    final names = {for (final a in _apts) a.aptNum: _nameCtrls[a.aptNum]?.text ?? ''};
    final passcodes = {for (final a in _apts) a.aptNum: _passCtrls[a.aptNum]?.text ?? ''};
    await widget.cubit.saveAllApartments(apts: _apts, names: names, passcodes: passcodes);
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    for (final c in _nameCtrls.values) {
      c.dispose();
    }
    for (final c in _passCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state.s;
    final isDark = widget.state.isDarkMode;
    final innerSurface = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final innerBorder = isDark ? Colors.white12 : Colors.black12;

    return AlertDialog(
      title: Text(s.manageAptsTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 440,
        height: 400,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: SelectableText(
                      '❌ $_error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ListView.separated(
                          controller: _scrollCtrl,
                          itemCount: _apts.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (_, idx) {
                            final a = _apts[idx];
                            return Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: innerSurface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: innerBorder),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 54,
                                    child: Text(
                                      s.defaultAptName(a.aptNum),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF6366F1),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    flex: 3,
                                    child: TextField(
                                      controller: _nameCtrls[a.aptNum],
                                      style: const TextStyle(fontSize: 12),
                                      decoration: InputDecoration(
                                        labelText: s.optionalName,
                                        hintText: s.nameHint(a.aptNum),
                                        isDense: true,
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    flex: 2,
                                    child: TextField(
                                      controller: _passCtrls[a.aptNum],
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      decoration: InputDecoration(
                                        labelText: s.passcodeLabel,
                                        isDense: true,
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    onPressed: _saving || _apts.length <= 1 ? null : () => _deleteApartment(idx),
                                    icon: const Icon(Icons.delete_outline, size: 18),
                                    color: Colors.redAccent,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                    tooltip: s.deleteTooltip,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: _saving ? null : _addNewApartment,
                        icon: const Icon(Icons.add_home_outlined, size: 16),
                        label: Text(s.addApartmentBtn, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF22C55E),
                          side: const BorderSide(color: Color(0xFF22C55E)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: Text(s.cancel)),
        if (!_loading && _error == null)
          ElevatedButton(
            onPressed: _saving ? null : _saveAll,
            child: Text(_saving ? s.saving : s.saveAll),
          ),
      ],
    );
  }
}
