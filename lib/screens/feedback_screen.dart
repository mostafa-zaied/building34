import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/building_cubit.dart';
import '../cubit/building_state.dart';

class FeedbackScreen extends StatefulWidget {
  final String type; // 'complaint' or 'improvement'

  const FeedbackScreen({super.key, required this.type});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _msgCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isAnonymous = true;
  int _selectedApt = 1;
  bool _submitting = false;

  @override
  void dispose() {
    _msgCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildingCubit cubit) async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _submitting = true);
    final ok = await cubit.submitFeedbackPost(
      type: widget.type,
      message: text,
      aptNum: _isAnonymous ? null : _selectedApt,
      passcode: _isAnonymous ? null : _passCtrl.text,
    );
    if (!mounted) return;
    if (ok) {
      _msgCtrl.clear();
      _passCtrl.clear();
    }
    setState(() => _submitting = false);
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$y-$m-$d  $h:$min';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuildingCubit, BuildingState>(
      builder: (context, state) {
        final cubit = context.read<BuildingCubit>();
        final s = state.s;
        final isDark = state.isDarkMode;
        final cardBg = Theme.of(context).cardColor;
        final innerBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
        final borderCol = isDark ? Colors.white12 : Colors.black12;

        final isComplaint = widget.type == 'complaint';
        final accent = isComplaint ? const Color(0xFFF59E0B) : const Color(0xFF10B981);
        final aptsCount = state.currentMonth?.aptsCount ?? 13;
        if (_selectedApt > aptsCount) _selectedApt = 1;

        final posts = state.feedbackPosts.where((p) => p.type == widget.type).toList();

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Composer Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: borderCol),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          isComplaint ? s.complaintsTitle : s.improvementsTitle,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _msgCtrl,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: isComplaint ? s.writeComplaintHint : s.writeImprovementHint,
                            filled: true,
                            fillColor: innerBg,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: borderCol),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                s.postAnonymously,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                            Switch.adaptive(
                              value: _isAnonymous,
                              onChanged: (v) => setState(() => _isAnonymous = v),
                              activeTrackColor: accent,
                            ),
                          ],
                        ),
                        if (!_isAnonymous) ...[
                          const SizedBox(height: 6),
                          DropdownButtonFormField<int>(
                            initialValue: _selectedApt,
                            decoration: InputDecoration(
                              labelText: s.selectApartment,
                              isDense: true,
                              filled: true,
                              fillColor: innerBg,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            items: List.generate(aptsCount, (i) {
                              final num = i + 1;
                              return DropdownMenuItem(
                                value: num,
                                child: Text(state.aptLabel(num)),
                              );
                            }),
                            onChanged: (v) {
                              if (v != null) setState(() => _selectedApt = v);
                            },
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passCtrl,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: s.passcodeLabel,
                              hintText: s.enterPassHint,
                              isDense: true,
                              filled: true,
                              fillColor: innerBg,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        ElevatedButton.icon(
                          onPressed: _submitting ? null : () => _submit(cubit),
                          icon: Icon(isComplaint ? Icons.campaign_outlined : Icons.lightbulb_outline, size: 18),
                          label: Text(
                            _submitting ? s.saving : s.submitPostBtn,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Posts List
                  if (posts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: borderCol),
                      ),
                      child: Text(
                        s.noPostsYet,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
                      ),
                    )
                  else
                    ...posts.map((post) {
                      final isAnon = post.authorLabel == null || post.authorLabel!.trim().isEmpty;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderCol),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: innerBg,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: accent.withValues(alpha: 0.5)),
                                  ),
                                  child: Text(
                                    isAnon ? s.anonymousAuthor : '🏠 ${post.authorLabel}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isAnon
                                          ? (isDark ? Colors.white70 : Colors.black54)
                                          : accent,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _formatDate(post.createdAt),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isDark ? Colors.white54 : Colors.black45,
                                      ),
                                    ),
                                    if (state.isAdminOpen) ...[
                                      const SizedBox(width: 4),
                                      IconButton(
                                        onPressed: () => cubit.deleteFeedbackPost(post.id),
                                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              post.message,
                              style: const TextStyle(fontSize: 13, height: 1.5),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
