import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/constants/enums.dart';
import '../domain/meetings_repository.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/neu_input.dart';
import '../../../core/design/azm_tokens.dart';

/// Create Encounter Screen — نموذج اللقاءات
///
/// Simplified meeting form focused on encounters with specific fields:
/// - مع من اللقاء (Who)
/// - متى وأين اللقاء (When & Where)
/// - سبب اللقاء (Reason)
/// - الملاحظات (Notes)
///
/// Persists as a Meeting record with type [MeetingType.external_].
class CreateEncounterScreen extends ConsumerStatefulWidget {
  const CreateEncounterScreen({super.key});

  @override
  ConsumerState<CreateEncounterScreen> createState() =>
      _CreateEncounterScreenState();
}

class _CreateEncounterScreenState
    extends ConsumerState<CreateEncounterScreen> {
  final _formKey = GlobalKey<FormState>();

  // ─── Controllers ───────────────────────────────────────────────
  final _personCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // ─── State ─────────────────────────────────────────────────────
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _personCtrl.dispose();
    _locationCtrl.dispose();
    _reasonCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ─── Date / Time Pickers ───────────────────────────────────────

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

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  // ─── Submit ────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(meetingsRepositoryProvider);
      final formattedTime =
          '${_selectedTime.hour.toString().padLeft(2, '0')}:'
          '${_selectedTime.minute.toString().padLeft(2, '0')}';

      // Build a descriptive title from the person name
      final title = 'لقاء مع ${_personCtrl.text}';

      await repository.createMeeting(
        title: title,
        type: MeetingType.external_,
        date: _selectedDate,
        time: formattedTime,
        priority: Priority.medium,
        location: _locationCtrl.text.isNotEmpty
            ? _locationCtrl.text
            : null,
        objective: _reasonCtrl.text.isNotEmpty
            ? _reasonCtrl.text
            : null,
        notes: _notesCtrl.text.isNotEmpty
            ? _notesCtrl.text
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تسجيل اللقاء بنجاح'),
            backgroundColor: NeuColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: NeuColors.danger,
          ),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  // ─── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr =
        DateFormat('EEEE، d MMMM yyyy', 'ar').format(_selectedDate);
    final timeStr = _selectedTime.format(context);

    return Scaffold(
      backgroundColor:
          isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor:
            isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'لقاء جديد',
          style: isDark ? AppTypography.h3Dark : AppTypography.h3,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: AppSpacing.screen,
            children: [
              // ── Section Header: مع من اللقاء ──────────────────
              _buildSectionHeader(
                icon: Icons.person_rounded,
                label: 'مع من اللقاء',
                isDark: isDark,
              ),
              AppSpacing.gapSm,
              NeuInput(
                controller: _personCtrl,
                hint: 'اسم الشخص أو الجهة',
                prefixIcon: Icons.badge_rounded,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'يرجى إدخال اسم الشخص' : null,
              ),

              AppSpacing.gapXxl,

              // ── Section Header: متى وأين اللقاء ───────────────
              _buildSectionHeader(
                icon: Icons.schedule_rounded,
                label: 'متى وأين اللقاء',
                isDark: isDark,
              ),
              AppSpacing.gapSm,

              // Date & Time Row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: NeuCard(
                        margin: EdgeInsets.zero,
                        radius: AzmRadius.sm,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 18,
                              color: isDark
                                  ? NeuColors.accentMuted
                                  : NeuColors.navyMid,
                            ),
                            AppSpacing.gapHSm,
                            Expanded(
                              child: Text(
                                dateStr,
                                style: isDark
                                    ? AppTypography.bodyDark
                                    : AppTypography.body,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.gapHMd,
                  SizedBox(
                    width: 120,
                    child: GestureDetector(
                      onTap: _pickTime,
                      child: NeuCard(
                        margin: EdgeInsets.zero,
                        radius: AzmRadius.sm,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 18,
                              color: isDark
                                  ? NeuColors.accentMuted
                                  : NeuColors.navyMid,
                            ),
                            AppSpacing.gapHSm,
                            Text(
                              timeStr,
                              style: isDark
                                  ? AppTypography.bodyDark
                                  : AppTypography.body,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              AppSpacing.gapLg,

              // Location
              NeuInput(
                controller: _locationCtrl,
                hint: 'مكان اللقاء (اختياري)',
                prefixIcon: Icons.location_on_rounded,
              ),

              AppSpacing.gapXxl,

              // ── Section Header: سبب اللقاء ────────────────────
              _buildSectionHeader(
                icon: Icons.help_outline_rounded,
                label: 'سبب اللقاء',
                isDark: isDark,
              ),
              AppSpacing.gapSm,
              NeuInput(
                controller: _reasonCtrl,
                hint: 'اكتب سبب أو هدف اللقاء',
                prefixIcon: Icons.flag_rounded,
                maxLines: 3,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'يرجى إدخال سبب اللقاء' : null,
              ),

              AppSpacing.gapXxl,

              // ── Section Header: الملاحظات ──────────────────────
              _buildSectionHeader(
                icon: Icons.notes_rounded,
                label: 'الملاحظات',
                isDark: isDark,
              ),
              AppSpacing.gapSm,
              NeuInput(
                controller: _notesCtrl,
                hint: 'ملاحظات إضافية (اختياري)',
                prefixIcon: Icons.edit_note_rounded,
                maxLines: 4,
              ),

              AppSpacing.gapXxl,

              // ── Submit Button ──────────────────────────────────
              NeuButton(
                label: _isSubmitting ? 'جارف الحفظ...' : 'حفظ اللقاء',
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

  // ─── Section Header Builder ────────────────────────────────────

  Widget _buildSectionHeader({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isDark ? NeuColors.goldAccent : NeuColors.navyDeep)
                .withAlpha(isDark ? 25 : 15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
          ),
        ),
        AppSpacing.gapHSm,
        Text(
          label,
          style: isDark ? AppTypography.h4Dark : AppTypography.h4,
        ),
      ],
    );
  }
}