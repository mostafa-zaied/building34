import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/building_cubit.dart';
import '../cubit/building_state.dart';
import '../models/building_models.dart';

class FeedbackScreen extends StatefulWidget {
  final String type; // 'complaint' or 'improvement'

  const FeedbackScreen({super.key, required this.type});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final _msgCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isAnonymous = true;
  int _selectedApt = 1;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
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
      _tabCtrl.animateTo(0);
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
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header + Pill TabBar
                  Container(
                    padding: const EdgeInsets.all(12),
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
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: innerBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderCol),
                          ),
                          child: TabBar(
                            controller: _tabCtrl,
                            dividerColor: Colors.transparent,
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            labelColor: Colors.black,
                            unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
                            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            tabs: [
                              Tab(
                                text: isComplaint
                                    ? s.tabViewComplaints(posts.length)
                                    : s.tabViewImprovements(posts.length),
                              ),
                              Tab(
                                text: isComplaint ? s.tabAddComplaint : s.tabAddImprovement,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tab Views
                  Expanded(
                    child: TabBarView(
                      controller: _tabCtrl,
                      children: [
                        // Tab 0: List of Complaints / Suggestions
                        _buildPostsList(
                          posts: posts,
                          isDark: isDark,
                          cardBg: cardBg,
                          innerBg: innerBg,
                          borderCol: borderCol,
                          accent: accent,
                          isComplaint: isComplaint,
                          state: state,
                          cubit: cubit,
                        ),

                        // Tab 1: Add New Complaint / Suggestion
                        _buildComposerTab(
                          isDark: isDark,
                          cardBg: cardBg,
                          innerBg: innerBg,
                          borderCol: borderCol,
                          accent: accent,
                          isComplaint: isComplaint,
                          aptsCount: aptsCount,
                          state: state,
                          cubit: cubit,
                        ),
                      ],
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

  Widget _buildPostsList({
    required List<FeedbackPost> posts,
    required bool isDark,
    required Color cardBg,
    required Color innerBg,
    required Color borderCol,
    required Color accent,
    required bool isComplaint,
    required BuildingState state,
    required BuildingCubit cubit,
  }) {
    final s = state.s;
    if (posts.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderCol),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isComplaint ? Icons.campaign_outlined : Icons.lightbulb_outline,
                size: 40,
                color: accent.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 10),
              Text(
                s.noPostsYet,
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () => _tabCtrl.animateTo(1),
                icon: const Icon(Icons.add, size: 16),
                label: Text(
                  isComplaint ? s.tabAddComplaint : s.tabAddImprovement,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: posts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final post = posts[index];
        final isAnon = post.authorLabel == null || post.authorLabel!.trim().isEmpty;
        return Container(
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
                        color: isAnon ? (isDark ? Colors.white70 : Colors.black54) : accent,
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
      },
    );
  }

  Widget _buildComposerTab({
    required bool isDark,
    required Color cardBg,
    required Color innerBg,
    required Color borderCol,
    required Color accent,
    required bool isComplaint,
    required int aptsCount,
    required BuildingState state,
    required BuildingCubit cubit,
  }) {
    final s = state.s;
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderCol),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _msgCtrl,
              maxLines: 4,
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
            const SizedBox(height: 10),
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
              const SizedBox(height: 8),
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
              const SizedBox(height: 12),
            ] else
              const SizedBox(height: 6),
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
    );
  }
}
