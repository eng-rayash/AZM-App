import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/azm_tokens.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_typography.dart';
import '../data/shop_models.dart';
import '../providers/shop_providers.dart';
import 'store_workspace_screen.dart';

/// AZM — متجر جديد
///
/// ثلاثة حقول فقط: الاسم، الرابط، واتساب. وما عداها يُضبط بعد الإنشاء
/// — مرحلة أولى قصيرة تُفضي إلى متجر حقيقي أفضل من نموذج طويل يُهجَر
/// في منتصفه.
///
/// واتساب إلزامي لأنه **قناة الطلب** لا بيانًا تعريفيًا: متجر بلا
/// واتساب يستقبل طلبات لا تصل صاحبها.
///
/// ## الرابط يُفحص أثناء الكتابة
///
/// وهو فريد **عبر كل الشركات** لا عبر شركتك: اسم شائع قد يكون محجوزًا
/// لتاجر آخر. والفحص المسبق يعطي بديلًا مقترَحًا من الخادم، بدل رفض
/// يأتي بعد تعبئة النموذج كلّه.
class CreateStoreSheet extends ConsumerStatefulWidget {
  const CreateStoreSheet({super.key});

  @override
  ConsumerState<CreateStoreSheet> createState() => _CreateStoreSheetState();
}

class _CreateStoreSheetState extends ConsumerState<CreateStoreSheet> {
  final _name = TextEditingController();
  final _slug = TextEditingController();
  final _whatsapp = TextEditingController();

  String _sector = 'other';
  bool _submitting = false;
  String? _error;

  SlugCheck? _slugCheck;
  bool _checkingSlug = false;
  Timer? _debounce;

  /// هل لمس المستخدم حقل الرابط؟
  ///
  /// قبل أن يلمسه نترك الخادم يشتقّه من الاسم. وبعد أن يلمسه نرسل ما
  /// كتبه — لأن اشتقاقًا يتجاوز كتابته يبدو كأن التطبيق يتجاهله.
  bool _slugTouched = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _name.dispose();
    _slug.dispose();
    _whatsapp.dispose();
    super.dispose();
  }

  /// يفحص الرابط بعد سكون الكتابة.
  ///
  /// التأخير ليس تحسينًا بصريًا: فحص على كل حرف يرسل عشرة طلبات لكلمة
  /// واحدة، وتعود ردودها بغير ترتيب فيُعرض حكم حرف سابق على نصّ لاحق.
  void _scheduleSlugCheck(String raw) {
    _debounce?.cancel();
    final query = raw.trim();

    if (query.length < 3) {
      setState(() {
        _slugCheck = null;
        _checkingSlug = false;
      });
      return;
    }

    setState(() => _checkingSlug = true);
    _debounce = Timer(const Duration(milliseconds: 450), () async {
      try {
        final result = await ref.read(shopApiProvider).checkSlug(query);
        if (!mounted) return;
        // الردّ قد يصل بعد أن تغيّر النصّ — نتجاهل القديم
        if (query != _slugSource().trim()) return;
        setState(() {
          _slugCheck = result;
          _checkingSlug = false;
        });
      } on ApiException {
        if (!mounted) return;
        // تعذّر الفحص لا يمنع المحاولة: الخادم هو الحكم عند الإنشاء
        setState(() {
          _slugCheck = null;
          _checkingSlug = false;
        });
      }
    });
  }

  String _slugSource() => _slugTouched ? _slug.text : _name.text;

  bool get _canSubmit =>
      !_submitting &&
      _name.text.trim().length >= 2 &&
      _whatsapp.text.trim().length >= 6;

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final store = await ref.read(shopActionsProvider).createStore(
            name: _name.text,
            whatsapp: _whatsapp.text,
            slug: _slugTouched && _slug.text.trim().isNotEmpty
                ? _slug.text.trim()
                : null,
            sector: _sector,
          );

      if (!mounted) return;
      // المعرّف يُضبط ثم نستبدل الورقة بلوحة المتجر: المتجر الجديد
      // فارغ، وإنزال التاجر فيه مباشرةً هو الخطوة التالية الطبيعية.
      ref.read(activeStoreIdProvider.notifier).state = store.id;
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => StoreWorkspaceScreen(storeId: store.id),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        // رسالة الخادم كما هي: «اشترِ خانة متجر إضافي» تقول ما يُفعل،
        // و«تعذّر الإنشاء» لا تقول شيئًا.
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: p.surfaceRaised,
          borderRadius: AzmRadius.sheet,
        ),
        padding: const EdgeInsets.fromLTRB(
          AzmSpace.screenGutter,
          AzmSpace.md,
          AzmSpace.screenGutter,
          AzmSpace.xl,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: p.rule,
                    borderRadius: AzmRadius.pill,
                  ),
                ),
              ),
              const SizedBox(height: AzmSpace.xl),
              Text('متجر جديد', style: AppTypography.h2.copyWith(color: p.ink)),
              const SizedBox(height: AzmSpace.xs),
              Text(
                'ثلاثة حقول تكفي للبدء — والباقي يُضبط من اللوحة.',
                style: AppTypography.body.copyWith(color: p.inkMuted),
              ),
              const SizedBox(height: AzmSpace.xl),

              _Field(
                controller: _name,
                label: 'اسم المتجر',
                hint: 'دار العود',
                onChanged: (v) {
                  setState(() {});
                  if (!_slugTouched) _scheduleSlugCheck(v);
                },
              ),
              const SizedBox(height: AzmSpace.lg),

              _Field(
                controller: _slug,
                label: 'الرابط',
                hint: _slugCheck?.slug.isNotEmpty == true
                    ? _slugCheck!.slug
                    : 'يُشتقّ من الاسم',
                prefix: 'rvios.com/',
                keyboardType: TextInputType.url,
                onChanged: (v) {
                  _slugTouched = true;
                  setState(() {});
                  _scheduleSlugCheck(v);
                },
              ),
              _SlugHint(
                check: _slugCheck,
                checking: _checkingSlug,
                onUseSuggestion: (s) {
                  _slugTouched = true;
                  _slug.text = s;
                  _scheduleSlugCheck(s);
                },
              ),
              const SizedBox(height: AzmSpace.lg),

              _Field(
                controller: _whatsapp,
                label: 'واتساب المتجر',
                hint: '05xxxxxxxx',
                keyboardType: TextInputType.phone,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AzmSpace.xs),
              Text(
                'قناة الطلب — الطلبات تصلك عليه.',
                style: AppTypography.caption.copyWith(color: p.inkFaint),
              ),
              const SizedBox(height: AzmSpace.lg),

              _SectorPicker(
                value: _sector,
                onChanged: (v) => setState(() => _sector = v),
              ),

              if (_error != null) ...[
                const SizedBox(height: AzmSpace.lg),
                _ErrorNote(message: _error!),
              ],

              const SizedBox(height: AzmSpace.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _canSubmit ? _submit : null,
                  child: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('إنشاء المتجر'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// أجزاء
// ─────────────────────────────────────────────

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.onChanged,
    this.hint,
    this.prefix,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? prefix;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: p.inkFaint,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AzmSpace.xs),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: AppTypography.body.copyWith(color: p.ink),
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            prefixStyle: AppTypography.caption.copyWith(color: p.inkFaint),
            isDense: true,
            filled: true,
            fillColor: p.surfaceSunken,
            border: OutlineInputBorder(
              borderRadius: AzmRadius.control,
              borderSide: BorderSide(color: p.hairline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AzmRadius.control,
              borderSide: BorderSide(color: p.hairline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AzmRadius.control,
              borderSide: BorderSide(color: p.accent),
            ),
          ),
        ),
      ],
    );
  }
}

/// حكم الخادم على الرابط — ومعه بديله حين يكون محجوزًا.
class _SlugHint extends StatelessWidget {
  const _SlugHint({
    required this.check,
    required this.checking,
    required this.onUseSuggestion,
  });

  final SlugCheck? check;
  final bool checking;
  final ValueChanged<String> onUseSuggestion;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);

    if (checking) {
      return Padding(
        padding: const EdgeInsets.only(top: AzmSpace.xs),
        child: Text(
          'جارٍ الفحص…',
          style: AppTypography.caption.copyWith(color: p.inkFaint),
        ),
      );
    }

    final c = check;
    if (c == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AzmSpace.xs),
      child: Row(
        children: [
          Icon(
            c.ok ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded,
            size: 14,
            color: c.ok ? p.success : p.warning,
          ),
          const SizedBox(width: AzmSpace.xs),
          Expanded(
            child: Text(
              c.reason,
              style: AppTypography.caption.copyWith(
                color: c.ok ? p.success : p.warning,
              ),
            ),
          ),
          if (!c.ok && (c.suggestion ?? '').isNotEmpty)
            TextButton(
              onPressed: () => onUseSuggestion(c.suggestion!),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: p.accent,
              ),
              child: Text('استخدم ${c.suggestion}'),
            ),
        ],
      ),
    );
  }
}

/// قطاع المتجر — المعرّفات نفسها في `SECTORS` على الخادم.
///
/// الخادم يرفض ما ليس في مجموعته، فالقائمة هنا تطابقها. إضافة قطاع
/// يحتاج الموضعين — والعكس (نصّ حرّ) يُنتج رفضًا بلا سبب ظاهر.
class _SectorPicker extends StatelessWidget {
  const _SectorPicker({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  static const _sectors = <String, String>{
    'fashion': 'أزياء',
    'perfumes': 'عطور',
    'beauty': 'تجميل',
    'electronics': 'إلكترونيات',
    'home': 'منزل',
    'food': 'أغذية',
    'jewelry': 'مجوهرات',
    'kids': 'أطفال',
    'health': 'صحة',
    'auto': 'سيارات',
    'stationery': 'قرطاسية',
    'hardware': 'عُدد',
    'agriculture': 'زراعة',
    'handmade': 'يدوي',
    'toys': 'ألعاب',
    'other': 'أخرى',
  };

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'القطاع',
          style: AppTypography.caption.copyWith(
            color: p.inkFaint,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AzmSpace.sm),
        Wrap(
          spacing: AzmSpace.sm,
          runSpacing: AzmSpace.sm,
          children: _sectors.entries.map((e) {
            final selected = e.key == value;
            return InkWell(
              onTap: () => onChanged(e.key),
              borderRadius: AzmRadius.pill,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AzmSpace.md,
                  vertical: AzmSpace.sm,
                ),
                decoration: BoxDecoration(
                  color: selected ? p.accent : p.surfaceSunken,
                  borderRadius: AzmRadius.pill,
                  border: Border.all(
                    color: selected ? p.accent : p.hairline,
                  ),
                ),
                child: Text(
                  e.value,
                  style: AppTypography.caption.copyWith(
                    color: selected ? p.onAccent : p.inkMuted,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ErrorNote extends StatelessWidget {
  const _ErrorNote({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);

    return Container(
      padding: const EdgeInsets.all(AzmSpace.md),
      decoration: BoxDecoration(
        color: p.dangerSubtle,
        borderRadius: AzmRadius.control,
        border: Border.all(color: p.danger.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: p.danger),
          const SizedBox(width: AzmSpace.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.caption.copyWith(color: p.danger),
            ),
          ),
        ],
      ),
    );
  }
}
