import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../domain/movements_repository.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/neu_input.dart';

/// Create Movement Screen — تحرك
///
/// Allows the executive to log an outbound movement/dispatch.
class CreateMovementScreen extends ConsumerStatefulWidget {
  const CreateMovementScreen({super.key, this.movementId});

  final int? movementId;

  @override
  ConsumerState<CreateMovementScreen> createState() =>
      _CreateMovementScreenState();
}

class _CreateMovementScreenState
    extends ConsumerState<CreateMovementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _destinationCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _movementType = 0; // 0: خروج, 1: عودة, 2: مهمة خارجية

  bool _isSaving = false;

  static const List<String> _types = ['خروج', 'عودة', 'مهمة خارجية'];

  @override
  void initState() {
    super.initState();
    if (widget.movementId != null) {
      _loadMovement();
    }
  }

  Future<void> _loadMovement() async {
    setState(() => _isSaving = true);
    try {
      final repository = ref.read(movementsRepositoryProvider);
      final movement = await repository.getById(widget.movementId!);
      if (movement != null) {
        setState(() {
          _destinationCtrl.text = movement.destination;
          _purposeCtrl.text = movement.purpose ?? '';
          _notesCtrl.text = movement.notes ?? '';
          _movementType = movement.type;
          _selectedDate = DateTime.tryParse(movement.date) ?? DateTime.now();
          final parts = movement.time.split(':');
          if (parts.length >= 2) {
            _selectedTime = TimeOfDay(
              hour: int.tryParse(parts[0]) ?? 12,
              minute: int.tryParse(parts[1]) ?? 0,
            );
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading movement: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _destinationCtrl.dispose();
    _purposeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final repository = ref.read(movementsRepositoryProvider);
      
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final timeStr = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

      if (widget.movementId != null) {
        await repository.updateMovement(
          id: widget.movementId!,
          destination: _destinationCtrl.text,
          purpose: _purposeCtrl.text.isNotEmpty ? _purposeCtrl.text : null,
          date: dateStr,
          time: timeStr,
          type: _movementType,
          notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
        );
      } else {
        await repository.createMovement(
          destination: _destinationCtrl.text,
          purpose: _purposeCtrl.text.isNotEmpty ? _purposeCtrl.text : null,
          date: dateStr,
          time: timeStr,
          type: _movementType,
          notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
        );
      }

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.movementId != null ? 'تم تعديل التحرك بنجاح' : 'تم تسجيل التحرك بنجاح'),
            backgroundColor: NeuColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: NeuColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr =
        DateFormat('dd/MM/yyyy', 'ar').format(_selectedDate);
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
          widget.movementId != null ? 'تعديل تحرك' : 'تسجيل تحرك',
          style: isDark ? AppTypography.h3Dark : AppTypography.h3,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
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
              AppSpacing.gapMd,

              // Movement Type Selector
              Text(
                'نوع التحرك',
                style: isDark ? AppTypography.labelDark : AppTypography.label,
              ),
              AppSpacing.gapSm,
              NeuCard(
                padding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 8),
                child: Row(
                  children: List.generate(_types.length, (i) {
                    final selected = _movementType == i;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _movementType = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 4),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10),
                          decoration: BoxDecoration(
                            color: selected
                                ? NeuColors.navyDeep
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _types[i],
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall.copyWith(
                              color: selected
                                  ? NeuColors.textOnDark
                                  : (isDark
                                      ? NeuColors.textSecondaryDark
                                      : NeuColors.textSecondary),
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              AppSpacing.gapLg,

              // Destination
              NeuInput(
                controller: _destinationCtrl,
                label: 'الوجهة / المكان',
                hint: 'أدخل المكان أو الوجهة',
                prefixIcon: Icons.location_on_rounded,
                validator: (v) =>
                    v == null || v.isEmpty ? 'الوجهة مطلوبة' : null,
              ),

              AppSpacing.gapLg,

              // Purpose
              NeuInput(
                controller: _purposeCtrl,
                label: 'الغرض / المهمة',
                hint: 'اكتب الغرض من التحرك',
                prefixIcon: Icons.article_rounded,
                maxLines: 2,
              ),

              AppSpacing.gapLg,

              // Date and Time
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('التاريخ', isDark),
                        AppSpacing.gapSm,
                        GestureDetector(
                          onTap: _pickDate,
                          child: NeuCard(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 18,
                                  color: NeuColors.goldAccent,
                                ),
                                AppSpacing.gapHSm,
                                Text(
                                  dateStr,
                                  style: isDark
                                      ? AppTypography.bodyDark
                                      : AppTypography.body,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.gapHMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('الوقت', isDark),
                        AppSpacing.gapSm,
                        GestureDetector(
                          onTap: _pickTime,
                          child: NeuCard(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 18,
                                  color: NeuColors.goldAccent,
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
                      ],
                    ),
                  ),
                ],
              ),

              AppSpacing.gapLg,

              // Notes
              NeuInput(
                controller: _notesCtrl,
                label: 'ملاحظات إضافية',
                hint: 'أي ملاحظات تتعلق بالتحرك...',
                prefixIcon: Icons.notes_rounded,
                maxLines: 3,
              ),

              AppSpacing.gapXxl,

              // Save Button
              NeuButton(
                label: _isSaving ? 'جارف الحفظ...' : (widget.movementId != null ? 'حفظ التعديلات' : 'حفظ التحرك'),
                icon: _isSaving
                    ? null
                    : Icons.save_rounded,
                onPressed: _isSaving ? null : _save,
              ),

              AppSpacing.gapXxl,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) => Text(
        text,
        style: isDark ? AppTypography.labelDark : AppTypography.label,
      );
}