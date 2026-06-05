import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/constants/enums.dart';
import '../domain/tasks_repository.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/neu_input.dart';

import '../../followups/domain/follow_ups_repository.dart';

/// Create Task Screen — form for adding a new task.
class CreateTaskScreen extends ConsumerStatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _assignedToController = TextEditingController();

  Priority _selectedPriority = Priority.medium;
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;
  bool _promoteToFollowUp = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assignedToController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ar'),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(tasksRepositoryProvider);
      
      final taskId = await repository.createTask(
        title: _titleController.text,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        priority: _selectedPriority,
        dueDate: _selectedDate.toIso8601String().split('T').first,
        assignedTo: _assignedToController.text.isNotEmpty ? _assignedToController.text : null,
      );

      if (_promoteToFollowUp) {
        final followupRepo = ref.read(followUpsRepositoryProvider);
        await followupRepo.createFollowUp(
          title: 'متابعة مهمة: ${_titleController.text.trim()}',
          type: FollowUpEntityType.task,
          priority: _selectedPriority,
          notes: _descriptionController.text.isNotEmpty ? _descriptionController.text : 'متابعة تفاصيل المهمة المستندة',
          targetDate: _selectedDate.toIso8601String().split('T').first,
          entityId: taskId,
          assignedTo: _assignedToController.text.isNotEmpty ? _assignedToController.text : 'غير محدد',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة المهمة بنجاح')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'إضافة مهمة جديدة', 
          style: isDark ? AppTypography.h3Dark : AppTypography.h3,
        ),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: AppSpacing.screen,
            children: [
              // Title
              NeuInput(
                controller: _titleController,
                label: 'عنوان المهمة',
                hint: 'أدخل عنوان المهمة',
                prefixIcon: Icons.task_alt_rounded,
                validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
              ),
              AppSpacing.gapLg,

              // Description
              NeuInput(
                controller: _descriptionController,
                label: 'الوصف',
                hint: 'تفاصيل المهمة (اختياري)',
                maxLines: 3,
                prefixIcon: Icons.notes_rounded,
              ),
              AppSpacing.gapLg,

              // Assigned To
              NeuInput(
                controller: _assignedToController,
                label: 'المسؤول التنفيذي',
                hint: 'اسم الشخص أو الجهة (اختياري)',
                prefixIcon: Icons.person_outline_rounded,
              ),
              AppSpacing.gapLg,

              // Date
              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: NeuCard(
                      margin: EdgeInsets.zero, radius: 16,
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        Icon(
                          Icons.calendar_today_rounded, 
                          size: 18, 
                          color: isDark ? NeuColors.goldAccent : NeuColors.navyMid,
                        ),
                        AppSpacing.gapHSm,
                        Text(
                          DateFormat('d MMM yyyy', 'ar').format(_selectedDate), 
                          style: isDark ? AppTypography.bodyDark : AppTypography.body,
                        ),
                      ]),
                    ),
                  ),
                ),
              ]),
              AppSpacing.gapLg,

              // Priority
              Text(
                'الأولوية', 
                style: isDark ? AppTypography.labelDark : AppTypography.label,
              ),
              AppSpacing.gapSm,
              Row(children: Priority.values.map((p) {
                final colors = {
                  Priority.critical: NeuColors.priorityCritical,
                  Priority.high: NeuColors.priorityHigh,
                  Priority.medium: NeuColors.priorityMedium,
                  Priority.low: NeuColors.priorityLow,
                };
                final c = colors[p]!;
                final selected = _selectedPriority == p;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPriority = p),
                    child: Container(
                      margin: const EdgeInsetsDirectional.only(end: 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected 
                            ? c.withValues(alpha: 0.15) 
                            : (isDark ? NeuColors.surfaceDark : NeuColors.surface),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? c : Colors.transparent, 
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        p.arabicLabel, 
                        style: (isDark ? AppTypography.captionDark : AppTypography.caption).copyWith(
                          color: selected 
                              ? c 
                              : (isDark ? NeuColors.textHintDark : NeuColors.textHint), 
                          fontWeight: FontWeight.w600,
                        ), 
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }).toList()),
              AppSpacing.gapXxl,

              // ── Promote to Follow-up Switch ────────────────────
              NeuCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                      size: 22,
                    ),
                    AppSpacing.gapHMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'رفع المهمة للمتابعة',
                            style: isDark ? AppTypography.bodyDark : AppTypography.body,
                          ),
                          Text(
                            'إضافة المهمة تلقائياً لقسم المتابعة الذكية وتتبع إنجازها',
                            style: isDark ? AppTypography.captionDark : AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _promoteToFollowUp,
                      onChanged: (val) => setState(() => _promoteToFollowUp = val),
                      activeTrackColor: NeuColors.goldAccent,
                      activeThumbColor: NeuColors.navyDeep,
                    ),
                  ],
                ),
              ),
              AppSpacing.gapXxl,

              // Submit Button
              NeuButton(label: 'حفظ المهمة', onPressed: _isSubmitting ? null : _submit, isLoading: _isSubmitting, icon: Icons.check_rounded),
              AppSpacing.gapXxl,
            ],
          ),
        ),
      ),
    );
  }
}
