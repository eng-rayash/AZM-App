import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/neu_input.dart';
import '../domain/contacts_repository.dart';

/// Screen for creating a new contact
class CreateContactScreen extends ConsumerStatefulWidget {
  const CreateContactScreen({super.key, this.contactId});

  final int? contactId;

  @override
  ConsumerState<CreateContactScreen> createState() => _CreateContactScreenState();
}

class _CreateContactScreenState extends ConsumerState<CreateContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _positionController = TextEditingController();
  final _companyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isVip = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.contactId != null) {
      _loadContact();
    }
  }

  Future<void> _loadContact() async {
    setState(() => _isLoading = true);
    try {
      final repository = ref.read(contactsRepositoryProvider);
      final contact = await repository.getById(widget.contactId!);
      if (contact != null) {
        setState(() {
          _nameController.text = contact.name;
          _positionController.text = contact.position ?? '';
          _companyController.text = contact.company ?? '';
          _phoneController.text = contact.phoneNumber ?? '';
          _emailController.text = contact.email ?? '';
          _isVip = contact.isVip;
        });
      }
    } catch (e) {
      debugPrint('Error loading contact: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _positionController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(contactsRepositoryProvider);
      if (widget.contactId != null) {
        await repository.updateContact(
          id: widget.contactId!,
          name: _nameController.text.trim(),
          position: _positionController.text.trim().isNotEmpty ? _positionController.text.trim() : null,
          company: _companyController.text.trim().isNotEmpty ? _companyController.text.trim() : null,
          phoneNumber: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
          email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
          isVip: _isVip,
        );
      } else {
        await repository.createContact(
          name: _nameController.text.trim(),
          position: _positionController.text.trim().isNotEmpty ? _positionController.text.trim() : null,
          company: _companyController.text.trim().isNotEmpty ? _companyController.text.trim() : null,
          phoneNumber: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
          email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
          isVip: _isVip,
        );
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.contactId != null ? 'تم تعديل جهة الاتصال بنجاح' : 'تمت إضافة جهة الاتصال بنجاح')),
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
        title: Text(widget.contactId != null ? 'تعديل جهة الاتصال' : 'إضافة جهة اتصال', style: isDark ? AppTypography.h3Dark : AppTypography.h3),
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
                controller: _nameController,
                label: 'الاسم الكامل *',
                hint: 'أدخل الاسم',
                prefixIcon: Icons.person_rounded,
                validator: (value) =>
                    value == null || value.isEmpty ? 'حقل مطلوب' : null,
              ),
              AppSpacing.gapLg,
              NeuInput(
                controller: _positionController,
                label: 'المنصب / الصفة',
                hint: 'مثال: المدير التنفيذي',
                prefixIcon: Icons.badge_rounded,
              ),
              AppSpacing.gapLg,
              NeuInput(
                controller: _companyController,
                label: 'الجهة / الشركة',
                hint: 'اسم الشركة',
                prefixIcon: Icons.business_rounded,
              ),
              AppSpacing.gapLg,
              NeuInput(
                controller: _phoneController,
                label: 'رقم الهاتف',
                hint: 'رقم للتواصل',
                prefixIcon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
              ),
              AppSpacing.gapLg,
              NeuInput(
                controller: _emailController,
                label: 'البريد الإلكتروني',
                hint: 'البريد',
                prefixIcon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              AppSpacing.gapXxl,
              
              // VIP Toggle
              NeuCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star_rounded, 
                          color: _isVip ? NeuColors.priorityCritical : NeuColors.textHint),
                        const SizedBox(width: 12),
                        Text(
                          'جهة اتصال VIP',
                          style: isDark ? AppTypography.bodyDark : AppTypography.body,
                        ),
                      ],
                    ),
                    Switch.adaptive(
                      value: _isVip,
                      onChanged: (val) => setState(() => _isVip = val),
                      activeThumbColor: NeuColors.priorityCritical,
                    ),
                  ],
                ),
              ),
              
              AppSpacing.gapXxl,
              NeuButton(
                onPressed: _isLoading ? null : _submit,
                isLoading: _isLoading,
                label: widget.contactId != null ? 'حفظ التعديلات' : 'حفظ جهة الاتصال',
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