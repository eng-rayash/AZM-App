import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/constants/enums.dart';
import '../domain/follow_ups_repository.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/neu_input.dart';

/// Create / Edit Follow-up Screen (ERP Enhanced).
///
/// Phase 4 update: adds FollowupType selector (category badge chips) +
/// linked entity context field + time picker for precise scheduling.
class CreateFollowupScreen extends ConsumerStatefulWidget {
  const CreateFollowupScreen({super.key, this.followupId});
  final int? followupId;

  @override
  ConsumerState<CreateFollowupScreen> createState() =>
      _CreateFollowupScreenState();
}

class _CreateFollowupScreenState extends ConsumerState<CreateFollowupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _assignedToCtrl = TextEditingController();
  final _linkedEntityCtrl = TextEditingController();

  Priority _priority = Priority.medium;
  FollowUpEntityType _entityType = FollowUpEntityType.other;
  FollowupType _followupType = FollowupType.followup;
  DateTime _targetDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay? _targetTime;
  bool _isSubmitting = false;

  // ── FollowupType metadata ──────────────────────────────────────────
  static const _typesMeta = [
    (FollowupType.followup, Icons.replay_rounded, Color(0xFF22549E)),
    (FollowupType.task, Icons.task_alt_rounded, Color(0xFF0984E3)),
    (FollowupType.clientFollowup, Icons.supervisor_account_rounded, Color(0xFF00B894)),
    (FollowupType.projectFollowup, Icons.work_rounded, Color(0xFFE17055)),
    (FollowupType.employeeFollowup, Icons.badge_rounded, Color(0xFF6C5CE7)),
    (FollowupType.financeFollowup, Icons.monetization_on_rounded, Color(0xFFFDCB6E)),
    (FollowupType.other, Icons.more_horiz_rounded, Color(0xFF636E72)),
  ];

  // ── Priority metadata ──────────────────────────────────────────────
  static const _priorityMeta = [
    (Priority.critical, Icons.error_rounded, NeuColors.priorityCritical),
    (Priority.high, Icons.warning_amber_rounded, NeuColors.priorityHigh),
    (Priority.medium, Icons.info_outline_rounded, NeuColors.priorityMedium),
    (Priority.low, Icons.check_circle_outline_rounded, NeuColors.priorityLow),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.followupId != null) _loadFollowup();
  }

  Future<void> _loadFollowup() async {
    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(followUpsRepositoryProvider);
      final f = await repo.getById(widget.followupId!);
      if (f != null) {
        setState(() {
          _titleCtrl.text = f.title;
          _notesCtrl.text = f.notes ?? '';
          _assignedToCtrl.text = f.assignedTo ?? '';
          _linkedEntityCtrl.text = f.linkedEntityLabel ?? '';
          _priority = Priority.values.firstWhere(
            (p) => p.value == f.priority, orElse: () => Priority.medium);
          _entityType = FollowUpEntityType.values.firstWhere(
            (t) => t.value == f.entityType, orElse: () => FollowUpEntityType.other);
          _followupType = FollowupType.values.firstWhere(
            (t) => t.value == f.followupType, orElse: () => FollowupType.followup);
          if (f.targetDate != null) {
            _targetDate = DateTime.tryParse(f.targetDate!) ?? DateTime.now();
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading followup: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _notesCtrl.dispose();
    _assignedToCtrl.dispose(); _linkedEntityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ar'),
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _targetTime ?? TimeOfDay.now(),
      builder: (ctx, child) => Directionality(
          textDirection: TextDirection.rtl, child: child!),
    );
    if (picked != null) setState(() => _targetTime = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(followUpsRepositoryProvider);
      final dateStr = _targetDate.toIso8601String().split('T').first;

      if (widget.followupId != null) {
        await repo.updateFollowUp(
          id: widget.followupId!,
          title: _titleCtrl.text.trim(),
          type: _entityType,
          followupType: _followupType,
          priority: _priority,
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          targetDate: dateStr,
          assignedTo: _assignedToCtrl.text.trim().isEmpty ? null : _assignedToCtrl.text.trim(),
          linkedEntityName: _linkedEntityCtrl.text.trim().isEmpty ? null : _linkedEntityCtrl.text.trim(),
        );
      } else {
        await repo.createFollowUp(
          title: _titleCtrl.text.trim(),
          type: _entityType,
          followupType: _followupType,
          priority: _priority,
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          targetDate: dateStr,
          assignedTo: _assignedToCtrl.text.trim().isEmpty ? null : _assignedToCtrl.text.trim(),
          linkedEntityName: _linkedEntityCtrl.text.trim().isEmpty ? null : _linkedEntityCtrl.text.trim(),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.followupId != null
              ? 'تم تعديل المتابعة ✓' : 'تمت إضافة المتابعة ✓'),
          backgroundColor: NeuColors.success,
        ));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ: $e'),
                backgroundColor: NeuColors.danger));
        setState(() => _isSubmitting = false);
      }
    }
  }

  Color get _typeColor => _typesMeta
      .firstWhere((m) => m.$1 == _followupType,
          orElse: () => _typesMeta.last)
      .$3;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary;
    final bg = isDark ? NeuColors.bgColorDark : NeuColors.bgColor;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.followupId != null ? 'تعديل المتابعة' : 'متابعة جديدة',
          style: (isDark ? AppTypography.h3Dark : AppTypography.h3),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: TextButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('حفظ'),
              style: TextButton.styleFrom(
                foregroundColor: _typeColor,
                textStyle: AppTypography.labelMedium
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: AppSpacing.screen,
            children: [
              // ── Followup Type — البادج الكبير ──────────────────────
              _SectionHeader(label: 'نوع المتابعة', isDark: isDark),
              const SizedBox(height: 10),
              _FollowupTypeGrid(
                selected: _followupType,
                meta: _typesMeta,
                isDark: isDark,
                onSelect: (t) => setState(() => _followupType = t),
              ),
              AppSpacing.gapLg,

              // ── Title ─────────────────────────────────────────────
              NeuInput(
                controller: _titleCtrl,
                label: 'موضوع المتابعة *',
                hint: 'وصف موجز للمتابعة',
                prefixIcon: Icons.replay_rounded,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
              ),
              AppSpacing.gapMd,

              // ── Notes ─────────────────────────────────────────────
              NeuInput(
                controller: _notesCtrl,
                label: 'ملاحظات',
                hint: 'تفاصيل وملاحظات إضافية',
                maxLines: 3,
                prefixIcon: Icons.notes_rounded,
              ),
              AppSpacing.gapMd,

              // ── Assigned To + Linked Entity ───────────────────────
              Row(children: [
                Expanded(
                  child: NeuInput(
                    controller: _assignedToCtrl,
                    label: 'جهة المتابعة',
                    hint: 'شخص / جهة',
                    prefixIcon: Icons.business_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: NeuInput(
                    controller: _linkedEntityCtrl,
                    label: 'مرتبطة بـ',
                    hint: 'اسم العميل / المشروع / الموظف',
                    prefixIcon: Icons.link_rounded,
                  ),
                ),
              ]),
              AppSpacing.gapLg,

              // ── Target Date + Time ─────────────────────────────────
              _SectionHeader(label: 'الموعد المستهدف', isDark: isDark),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: NeuCard(
                      isDark: isDark,
                      margin: EdgeInsets.zero,
                      radius: 14,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      child: Row(children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 18,
                            color: isDark
                                ? NeuColors.goldAccent
                                : NeuColors.navyMid),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            DateFormat('EEE d MMM yyyy', 'ar')
                                .format(_targetDate),
                            style: AppTypography.bodySmall.copyWith(
                              color: textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickTime,
                    child: NeuCard(
                      isDark: isDark,
                      margin: EdgeInsets.zero,
                      radius: 14,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 14),
                      child: Row(children: [
                        Icon(Icons.schedule_rounded,
                            size: 18,
                            color: isDark
                                ? NeuColors.goldAccent
                                : NeuColors.navyMid),
                        const SizedBox(width: 8),
                        Text(
                          _targetTime != null
                              ? _targetTime!.format(context)
                              : 'وقت',
                          style: AppTypography.bodySmall.copyWith(
                            color: _targetTime != null
                                ? textPrimary
                                : NeuColors.textHint,
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
              ]),
              AppSpacing.gapLg,

              // ── Entity Type ──────────────────────────────────────
              _SectionHeader(label: 'الكيان المرتبط', isDark: isDark),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: FollowUpEntityType.values.map((t) {
                  final selected = _entityType == t;
                  return GestureDetector(
                    onTap: () => setState(() => _entityType = t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? _typeColor
                            : (isDark
                                ? NeuColors.surfaceDark
                                : NeuColors.surface),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              selected ? _typeColor : _typeColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        t.arabicLabel,
                        style: AppTypography.bodySmall.copyWith(
                          color: selected ? Colors.white : _typeColor,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              AppSpacing.gapLg,

              // ── Priority ─────────────────────────────────────────
              _SectionHeader(label: 'الأولوية', isDark: isDark),
              const SizedBox(height: 10),
              Row(children: _priorityMeta.map((m) {
                final selected = _priority == m.$1;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _priority = m.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsetsDirectional.only(end: 6),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? m.$3.withValues(alpha: 0.15)
                            : (isDark
                                ? NeuColors.surfaceDark
                                : NeuColors.surface),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? m.$3 : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Column(children: [
                        Icon(m.$2, size: 20, color: m.$3),
                        const SizedBox(height: 4),
                        Text(
                          m.$1.arabicLabel,
                          style: AppTypography.labelSmall.copyWith(
                            color: selected ? m.$3 : NeuColors.textHint,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ]),
                    ),
                  ),
                );
              }).toList()),
              AppSpacing.gapXxl,

              // ── Submit ────────────────────────────────────────────
              NeuButton(
                label: widget.followupId != null
                    ? 'حفظ التعديلات'
                    : 'إضافة المتابعة',
                onPressed: _isSubmitting ? null : _submit,
                isLoading: _isSubmitting,
                icon: Icons.check_rounded,
              ),
              AppSpacing.gapXxl,
            ],
          ),
        ),
      ),
    );
  }
}

// ── Supporting Widgets ─────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.isDark});
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 3, height: 14,
        decoration: BoxDecoration(
          color: NeuColors.navyDeep,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 8),
      Text(label,
          style: AppTypography.labelMedium.copyWith(
            color: isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary,
            fontWeight: FontWeight.w700,
          )),
    ]);
  }
}

class _FollowupTypeGrid extends StatelessWidget {
  const _FollowupTypeGrid({
    required this.selected,
    required this.meta,
    required this.isDark,
    required this.onSelect,
  });
  final FollowupType selected;
  final List<(FollowupType, IconData, Color)> meta;
  final bool isDark;
  final ValueChanged<FollowupType> onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 0.9,
      children: meta.map((m) {
        final isSelected = selected == m.$1;
        return GestureDetector(
          onTap: () => onSelect(m.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? m.$3
                  : (isDark ? NeuColors.surfaceDark : NeuColors.surface),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? m.$3 : m.$3.withValues(alpha: 0.25),
                width: isSelected ? 0 : 1,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: m.$3.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3))]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(m.$2,
                    color: isSelected ? Colors.white : m.$3, size: 22),
                const SizedBox(height: 6),
                Text(
                  m.$1.arabicLabel,
                  style: AppTypography.labelSmall.copyWith(
                    color: isSelected ? Colors.white : m.$3,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}