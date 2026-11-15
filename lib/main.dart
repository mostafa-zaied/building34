import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'models/building_models.dart';
import 'services/building_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppConfig.isSupabaseConfigured) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey, // ignore: deprecated_member_use
    );
  }

  runApp(const AmaratyApp());
}

class AmaratyApp extends StatelessWidget {
  const AmaratyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مصاريف العمارة',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E293B),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF22C55E),
          surface: Color(0xFF1E293B),
        ),
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const BuildingHomePage(),
    );
  }
}

class BuildingHomePage extends StatefulWidget {
  const BuildingHomePage({super.key});

  @override
  State<BuildingHomePage> createState() => _BuildingHomePageState();
}

class _BuildingHomePageState extends State<BuildingHomePage> {
  final BuildingService _service = BuildingService();
  final ImagePicker _picker = ImagePicker();

  bool _loading = true;
  bool _isAdminOpen = false;
  String _adminPass = 'admin123';

  double _baseEmergency = 2550;
  List<MonthBill> _months = [];
  int _selectedMonthIndex = 0;

  // Highlight state when Admin focuses/hovers a field
  String? _highlightedKey;
  String? _copiedPreview;

  // Controllers for Admin panel
  final _waterCtrl = TextEditingController();
  final _elecCtrl = TextEditingController();
  final _elevCtrl = TextEditingController();
  final _cleanCtrl = TextEditingController();
  final _forEmergCtrl = TextEditingController();
  final _aptsCtrl = TextEditingController();
  final _baseEmergCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _waterCtrl.dispose();
    _elecCtrl.dispose();
    _elevCtrl.dispose();
    _cleanCtrl.dispose();
    _forEmergCtrl.dispose();
    _aptsCtrl.dispose();
    _baseEmergCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final data = await _service.fetchAll();
      _baseEmergency = data.baseEmergencyFund;
      _months = data.months;
      final novIndex = _months.indexWhere((m) => m.monthNum == 11);
      _selectedMonthIndex = novIndex >= 0 ? novIndex : (_months.isNotEmpty ? _months.length - 1 : 0);
      _syncControllers();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  MonthBill? get _currentMonth =>
      _months.isEmpty ? null : _months[_selectedMonthIndex];

  void _syncControllers() {
    final m = _currentMonth;
    if (m == null) return;
    _waterCtrl.text = m.water.toInt().toString();
    _elecCtrl.text = m.elec.toInt().toString();
    _elevCtrl.text = m.elev.toInt().toString();
    _cleanCtrl.text = m.clean.toInt().toString();
    _forEmergCtrl.text = m.forEmerg.toInt().toString();
    _aptsCtrl.text = m.aptsCount.toString();
    _baseEmergCtrl.text = _baseEmergency.toInt().toString();
  }

  void _onAdminFieldChanged() {
    final m = _currentMonth;
    if (m == null) return;
    setState(() {
      m.water = double.tryParse(_waterCtrl.text) ?? 0;
      m.elec = double.tryParse(_elecCtrl.text) ?? 0;
      m.elev = double.tryParse(_elevCtrl.text) ?? 0;
      m.clean = double.tryParse(_cleanCtrl.text) ?? 0;
      m.forEmerg = double.tryParse(_forEmergCtrl.text) ?? 0;
      m.aptsCount = (int.tryParse(_aptsCtrl.text) ?? 1).clamp(1, 50);
      _baseEmergency = double.tryParse(_baseEmergCtrl.text) ?? 0;
    });
  }

  Future<void> _saveAdminChanges() async {
    final m = _currentMonth;
    if (m == null) return;
    final err = await _service.updateMonthAsAdmin(
      adminPass: _adminPass,
      month: m,
      baseEmergency: _baseEmergency,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(err ?? '✅ تم حفظ تعديلات الشهر بنجاح'),
        backgroundColor: err != null ? Colors.redAccent : const Color(0xFF22C55E),
      ),
    );
  }

  String _buildWhatsAppMessage(MonthBill m) {
    final paidList = <int>[];
    final unpaidList = <int>[];
    for (int i = 1; i <= m.aptsCount; i++) {
      if (m.payments.containsKey(i)) {
        paidList.add(i);
      } else {
        unpaidList.add(i);
      }
    }
    final newEmergTotal = (_baseEmergency + m.forEmerg).toInt();

    final lines = <String>[
      'مصاريف العمارة لشهر ${m.monthNum}:',
      '* مياه: ${m.water.toInt()} ج | كهرباء: ${m.elec.toInt()} ج | أسانسير: ${m.elev.toInt()} ج | منظفات: ${m.clean.toInt()} ج${m.forEmerg > 0 ? ' | للطوارئ: ${m.forEmerg.toInt()} ج' : ''}',
      '* إجمالي المصاريف: ${m.totalExpenses.toInt()} ج',
      '(مقسومة على ${m.aptsCount} شقة = نصيب الشقة ${m.sharePerApt} ج)',
      '* إجمالي صندوق الطوارئ: $newEmergTotal ج (المتاح سابقاً ${_baseEmergency.toInt()} ج + ${m.forEmerg.toInt()} ج هذا الشهر)',
      '------------------',
      '✅ تم السداد (${paidList.length} من ${m.aptsCount} شقة): ${paidList.isEmpty ? 'لا يوجد بعد' : paidList.map((e) => 'شقة $e').join('، ')}',
    ];
    if (unpaidList.isNotEmpty) {
      lines.add('⏳ متبقي (${unpaidList.length} شقة): ${unpaidList.map((e) => 'شقة $e').join('، ')}');
    }
    return lines.join('\n');
  }

  Future<void> _copyWhatsApp(MonthBill m) async {
    final text = _buildWhatsAppMessage(m);
    await Clipboard.setData(ClipboardData(text: text));
    setState(() => _copiedPreview = text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ تم نسخ تفاصيل الشهر المحدثة للواتساب'),
        backgroundColor: Color(0xFF22C55E),
      ),
    );
  }

  Future<void> _toggleAdminPanel() async {
    if (_isAdminOpen) {
      setState(() => _isAdminOpen = false);
      return;
    }

    if (!AppConfig.isSupabaseConfigured) {
      setState(() => _isAdminOpen = true);
      return;
    }

    final ctrl = TextEditingController();
    final pass = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🔐 دخول المدير', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'أدخل كلمة سر المدير...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('دخول')),
        ],
      ),
    );

    if (pass != null && pass.trim().isNotEmpty) {
      setState(() {
        _adminPass = pass.trim();
        _isAdminOpen = true;
      });
    }
  }

  Future<void> _openApartmentDialog(MonthBill m, int aptNum) async {
    final existing = m.payments[aptNum];
    if (existing != null) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('شقة $aptNum — ✅ تم الدفع', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('الملف: ${existing.fileName}', style: const TextStyle(fontSize: 12, color: Colors.white70)),
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
                const Text('تم إرفاق الإيصال مسبقاً', style: TextStyle(color: Color(0xFF22C55E))),
            ],
          ),
          actions: [
            if (_isAdminOpen)
              TextButton(
                onPressed: () async {
                  final err = await _service.cancelPaymentAsAdmin(
                    adminPass: _adminPass,
                    month: m,
                    aptNum: aptNum,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    setState(() {});
                    if (err != null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                    }
                  }
                },
                child: const Text('❌ إلغاء الدفع (مدير)', style: TextStyle(color: Colors.redAccent)),
              ),
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
          ],
        ),
      );
      return;
    }

    // Unpaid apartment: Password + Real Image Picker
    final passCtrl = TextEditingController();
    Uint8List? pickedBytes;
    String? pickedName;
    String? errMsg;
    bool submitting = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          title: Text('شقة $aptNum — مطلوب ${m.sharePerApt} ج', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '1. كلمة سر الشقة ${!AppConfig.isSupabaseConfigured ? '(للتجربة: ${1000 + aptNum})' : ''}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: passCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'اكتب كلمة السر...',
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('2. إرفاق صورة التحويل من جهازك (إجباري)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    final XFile? file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
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
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: pickedBytes != null ? const Color(0xFF22C55E) : Colors.white24,
                        width: 1.5,
                      ),
                    ),
                    child: pickedBytes == null
                        ? const Text('📸 اضغط هنا لاختيار صورة الإيصال', textAlign: TextAlign.center, style: TextStyle(fontSize: 12))
                        : Column(
                            children: [
                              Text('✅ تم اختيار: $pickedName', style: const TextStyle(fontSize: 12, color: Color(0xFF22C55E), fontWeight: FontWeight.bold)),
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
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: submitting
                  ? null
                  : () async {
                      if (pickedBytes == null) {
                        setModalState(() => errMsg = '❌ يجب إرفاق صورة التحويل أولاً!');
                        return;
                      }
                      setModalState(() => submitting = true);
                      final resErr = await _service.submitApartmentPayment(
                        month: m,
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
                      await _loadData();
                    },
              child: Text(submitting ? 'جاري الرفع...' : '✅ تأكيد الدفع'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = _currentMonth;

    return Scaffold(
      body: SafeArea(
        child: _loading || m == null
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!AppConfig.isSupabaseConfigured)
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFACC15).withValues(alpha: 0.5)),
                            ),
                            child: const Text(
                              '🧪 وضع التجربة المحلي — أضف بيانات Supabase في lib/config.dart للنشر الفعلي',
                              style: TextStyle(fontSize: 11, color: Color(0xFFFACC15)),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        // 1. TOP BAR
                        _buildTopBar(m),
                        const SizedBox(height: 12),

                        // 2. BILL CARD
                        _buildBillCard(m),
                        const SizedBox(height: 12),

                        // 3. APARTMENTS GRID
                        _buildApartmentsGrid(m),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTopBar(MonthBill m) {
    final newEmergTotal = (_baseEmergency + m.forEmerg).toInt();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏢', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedMonthIndex,
                  dropdownColor: const Color(0xFF1E293B),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                  items: List.generate(_months.length, (i) {
                    final item = _months[i];
                    return DropdownMenuItem(
                      value: i,
                      child: Text('شهر ${item.monthNum} (${item.yearNum})'),
                    );
                  }),
                  onChanged: (idx) {
                    if (idx != null) {
                      setState(() {
                        _selectedMonthIndex = idx;
                        _copiedPreview = null;
                        _syncControllers();
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _GlowBox(
                glowColor: const Color(0xFF22C55E),
                isHighlighted: _highlightedKey == 'top-emerg' || _highlightedKey == 'emerg',
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Text(
                  '🛡️ الطوارئ: $newEmergTotal ج',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF22C55E)),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _toggleAdminPanel,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    _isAdminOpen ? '✓ إغلاق' : '⚙️ تعديل',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillCard(MonthBill m) {
    final newEmergTotal = (_baseEmergency + m.forEmerg).toInt();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Text('مصاريف العمارة لشهر ${m.monthNum}:', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _copyWhatsApp(m),
                icon: const Icon(Icons.copy, size: 14),
                label: const Text('نسخ للواتساب', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 5 Glowing Cards
          Row(
            children: [
              Expanded(child: _ExpenseStatCard(label: '💧 مياه', value: '${m.water.toInt()}', color: const Color(0xFF38BDF8), highlighted: _highlightedKey == 'water')),
              const SizedBox(width: 6),
              Expanded(child: _ExpenseStatCard(label: '⚡ كهرباء', value: '${m.elec.toInt()}', color: const Color(0xFFFACC15), highlighted: _highlightedKey == 'elec')),
              const SizedBox(width: 6),
              Expanded(child: _ExpenseStatCard(label: '🛗 أسانسير', value: '${m.elev.toInt()}', color: const Color(0xFFA855F7), highlighted: _highlightedKey == 'elev')),
              const SizedBox(width: 6),
              Expanded(child: _ExpenseStatCard(label: '🧹 منظفات', value: '${m.clean.toInt()}', color: const Color(0xFFF472B6), highlighted: _highlightedKey == 'clean')),
              const SizedBox(width: 6),
              Expanded(child: _ExpenseStatCard(label: '🛡️ للطوارئ', value: '${m.forEmerg.toInt()}', color: const Color(0xFF22C55E), highlighted: _highlightedKey == 'emerg')),
            ],
          ),
          const SizedBox(height: 12),

          // Summary Box
          _GlowBox(
            glowColor: const Color(0xFF6366F1),
            isHighlighted: _highlightedKey == 'apts',
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• إجمالي المصاريف: ${m.totalExpenses.toInt()} ج (÷ ${m.aptsCount} شقة)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        '• صندوق الطوارئ: $newEmergTotal ج (${_baseEmergency.toInt()} متاح + ${m.forEmerg.toInt()} هذا الشهر)',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF22C55E), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('نصيب الشقة', style: TextStyle(fontSize: 11, color: Colors.white60)),
                    Text('${m.sharePerApt} ج', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF818CF8))),
                  ],
                ),
              ],
            ),
          ),

          if (_copiedPreview != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF22C55E)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('✅ الرسالة المنسوخة للواتساب:', style: TextStyle(fontSize: 11, color: Color(0xFF22C55E), fontWeight: FontWeight.bold)),
                      InkWell(
                        onTap: () => setState(() => _copiedPreview = null),
                        child: const Icon(Icons.close, size: 16, color: Colors.white54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SelectableText(_copiedPreview!, style: const TextStyle(fontSize: 11, height: 1.5)),
                ],
              ),
            ),
          ],

          // Admin Panel
          if (_isAdminOpen) ...[
            const Divider(height: 24, color: Colors.white12),
            const Text('⚙️ تعديل بنود الشهر (الوقوف على أي خانة ينير الكارت المقابل بالأعلى):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF818CF8))),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 3.1,
              children: [
                _AdminInputField(label: '💧 مياه:', controller: _waterCtrl, color: const Color(0xFF38BDF8), onFocusKey: 'water', onHighlight: (k) => setState(() => _highlightedKey = k), onChanged: _onAdminFieldChanged),
                _AdminInputField(label: '⚡ كهرباء:', controller: _elecCtrl, color: const Color(0xFFFACC15), onFocusKey: 'elec', onHighlight: (k) => setState(() => _highlightedKey = k), onChanged: _onAdminFieldChanged),
                _AdminInputField(label: '🛗 أسانسير:', controller: _elevCtrl, color: const Color(0xFFA855F7), onFocusKey: 'elev', onHighlight: (k) => setState(() => _highlightedKey = k), onChanged: _onAdminFieldChanged),
                _AdminInputField(label: '🧹 منظفات:', controller: _cleanCtrl, color: const Color(0xFFF472B6), onFocusKey: 'clean', onHighlight: (k) => setState(() => _highlightedKey = k), onChanged: _onAdminFieldChanged),
                _AdminInputField(label: '🛡️ للطوارئ:', controller: _forEmergCtrl, color: const Color(0xFF22C55E), onFocusKey: 'emerg', onHighlight: (k) => setState(() => _highlightedKey = k), onChanged: _onAdminFieldChanged),
                _AdminInputField(label: '🏠 عدد الشقق:', controller: _aptsCtrl, color: const Color(0xFF6366F1), onFocusKey: 'apts', onHighlight: (k) => setState(() => _highlightedKey = k), onChanged: _onAdminFieldChanged),
              ],
            ),
            const SizedBox(height: 8),
            _AdminInputField(label: '💰 رصيد الطوارئ المتاح سابقاً:', controller: _baseEmergCtrl, color: const Color(0xFF22C55E), onFocusKey: 'top-emerg', onHighlight: (k) => setState(() => _highlightedKey = k), onChanged: _onAdminFieldChanged),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveAdminChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('💾 حفظ التعديلات', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildApartmentsGrid(MonthBill m) {
    final paidCount = m.payments.length;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              const Text('اضغط على شقتك لتسجيل الدفع', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text('دفع $paidCount من ${m.aptsCount}', style: const TextStyle(fontSize: 12, color: Color(0xFF22C55E), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: m.aptsCount,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.55,
            ),
            itemBuilder: (context, idx) {
              final aptNum = idx + 1;
              final isPaid = m.payments.containsKey(aptNum);
              return _ApartmentCard(
                aptNum: aptNum,
                sharePerApt: m.sharePerApt,
                isPaid: isPaid,
                onTap: () => _openApartmentDialog(m, aptNum),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GlowBox extends StatefulWidget {
  final Color glowColor;
  final bool isHighlighted;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const _GlowBox({
    required this.glowColor,
    required this.isHighlighted,
    required this.padding,
    required this.child,
  });

  @override
  State<_GlowBox> createState() => _GlowBoxState();
}

class _GlowBoxState extends State<_GlowBox> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final active = _hovering || widget.isHighlighted;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        transform: active ? Matrix4.translationValues(0.0, -3.0, 0.0) : Matrix4.identity(),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? widget.glowColor : widget.glowColor.withValues(alpha: 0.45),
            width: active ? 2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.glowColor.withValues(alpha: active ? 0.55 : 0.18),
              blurRadius: active ? 16 : 6,
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

class _ExpenseStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool highlighted;

  const _ExpenseStatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    return _GlowBox(
      glowColor: color,
      isHighlighted: highlighted,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _AdminInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color color;
  final String onFocusKey;
  final ValueChanged<String?> onHighlight;
  final VoidCallback onChanged;

  const _AdminInputField({
    required this.label,
    required this.controller,
    required this.color,
    required this.onFocusKey,
    required this.onHighlight,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHighlight(onFocusKey),
      onExit: (_) => onHighlight(null),
      child: Focus(
        onFocusChange: (hasFocus) => onHighlight(hasFocus ? onFocusKey : null),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.7)),
          ),
          child: Row(
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.left,
                  onChanged: (_) => onChanged(),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApartmentCard extends StatefulWidget {
  final int aptNum;
  final int sharePerApt;
  final bool isPaid;
  final VoidCallback onTap;

  const _ApartmentCard({
    required this.aptNum,
    required this.sharePerApt,
    required this.isPaid,
    required this.onTap,
  });

  @override
  State<_ApartmentCard> createState() => _ApartmentCardState();
}

class _ApartmentCardState extends State<_ApartmentCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.isPaid
        ? const Color(0xFF22C55E)
        : (_hovering ? const Color(0xFF6366F1) : Colors.white24);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          transform: _hovering ? Matrix4.translationValues(0.0, -3.0, 0.0) : Matrix4.identity(),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: widget.isPaid || _hovering ? 1.8 : 1),
            boxShadow: _hovering || widget.isPaid
                ? [
                    BoxShadow(
                      color: borderColor.withValues(alpha: _hovering ? 0.45 : 0.2),
                      blurRadius: _hovering ? 14 : 6,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('شقة ${widget.aptNum}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                widget.isPaid ? '✅ دفعت' : '⏳ ${widget.sharePerApt} ج',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: widget.isPaid ? const Color(0xFF22C55E) : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
