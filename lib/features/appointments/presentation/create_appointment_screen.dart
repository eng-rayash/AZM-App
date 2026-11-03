import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/neu_input.dart';
import '../domain/appointments_repository.dart';
import '../../../core/design/azm_tokens.dart';

/// Screen for creating or editing an appointment
class CreateAppointmentScreen extends ConsumerStatefulWidget {
  const CreateAppointmentScreen({super.key, this.appointmentId});

  final int? appointmentId;

  @override
  ConsumerState<CreateAppointmentScreen> createState() => _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState extends ConsumerState<CreateAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _hoursController = TextEditingController(text: '0');
  final _minutesController = TextEditingController(text: '30');

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.appointmentId != null) {
      _loadAppointmentData();
    }
  }

  Future<void> _loadAppointmentData() async {
    final appt = await ref
        .read(appointmentsRepositoryProvider)
        .getById(widget.appointmentId!);
    if (appt != null) {
      setState(() {
        _titleController.text = appt.title;
        _locationController.text = appt.location ?? '';
        final totalMin = appt.durationMinutes;
        _hoursController.text = (totalMin ~/ 60).toString();
        _minutesController.text = (totalMin % 60).toString();
        _selectedDate = DateTime.tryParse(appt.date) ?? DateTime.now();
        final timeParts = appt.time.split(':');
        if (timeParts.length >= 2) {
          _selectedTime = TimeOfDay(
            hour: int.tryParse(timeParts[0]) ?? 12,
            minute: int.tryParse(timeParts[1]) ?? 0,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(appointmentsRepositoryProvider);
      final formattedTime = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
      final hrs = int.tryParse(_hoursController.text) ?? 0;
      final mins = int.tryParse(_minutesController.text) ?? 0;
      final duration = hrs * 60 + mins;

      if (widget.appointmentId != null) {
        await repository.updateAppointment(
          id: widget.appointmentId!,
          title: _titleController.text.trim(),
          date: _selectedDate,
          time: formattedTime,
          durationMinutes: duration,
          location: _locationController.text.trim(),
        );
      } else {
        await repository.createAppointment(
          title: _titleController.text.trim(),
          date: _selectedDate,
          time: formattedTime,
          durationMinutes: duration,
          location: _locationController.text.trim(),
        );
      }

      if (mounted) {
        context.pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.appointmentId != null ? 'تم تعديل الموعد بنجاح' : 'تم جدولة الموعد بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
          icon: Icon(Icons.close_rounded, color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(widget.appointmentId != null ? 'تعديل الموعد' : 'موعد جديد', style: isDark ? AppTypography.h3Dark : AppTypography.h3),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: AppSpacing.screen,
            children: [
              NeuInput(
                controller: _titleController,
                label: 'عنوان الموعد *',
                hint: 'أدخل عنوان الموعد',
                prefixIcon: Icons.title_rounded,
                validator: (value) =>
                    value == null || value.isEmpty ? 'حقل مطلوب' : null,
              ),
              AppSpacing.gapLg,

              // Date & Time Row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: NeuCard(
                        margin: EdgeInsets.zero,
                        radius: AzmRadius.sm,
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 18, color: isDark ? NeuColors.goldAccent : NeuColors.navyMid),
                            AppSpacing.gapHSm,
                            Text(DateFormat('d MMM yyyy', 'ar').format(_selectedDate), style: isDark ? AppTypography.bodyDark : AppTypography.body),
                          ],
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.gapHMd,
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickTime,
                      child: NeuCard(
                        margin: EdgeInsets.zero,
                        radius: AzmRadius.sm,
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 18, color: isDark ? NeuColors.goldAccent : NeuColors.navyMid),
                            AppSpacing.gapHSm,
                            Text(_selectedTime.format(context), style: isDark ? AppTypography.bodyDark : AppTypography.body),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.gapLg,

              Row(
                children: [
                  Expanded(
                    child: NeuInput(
                      controller: _hoursController,
                      label: 'المدة (ساعات)',
                      hint: 'مثال: 1',
                      prefixIcon: Icons.hourglass_empty_rounded,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                          return 'أدخل رقماً صحيحاً';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: NeuInput(
                      controller: _minutesController,
                      label: 'المدة (دقائق)',
                      hint: 'مثال: 30',
                      prefixIcon: Icons.timer_rounded,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                          return 'أدخل رقماً صحيحاً';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              AppSpacing.gapLg,

              NeuInput(
                controller: _locationController,
                label: 'المكان',
                hint: 'الموقع أو الرابط',
                prefixIcon: Icons.location_on_outlined,
              ),
              AppSpacing.gapXxl,
              
              NeuButton(
                onPressed: _isLoading ? null : _submit,
                isLoading: _isLoading,
                label: widget.appointmentId != null ? 'حفظ التعديلات' : 'جدولة الموعد',
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