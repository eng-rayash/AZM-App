import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/azm_tokens.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_typography.dart';
import '../shop/providers/shop_providers.dart';
import '../store_app/kit.dart';
import 'platform_api.dart';
import 'platform_catalog.dart';
import 'platform_widgets.dart';
import 'store_created_screen.dart';
import 'template_preview_screen.dart';

/// افتح متجرك — أربع خطوات كما في منصة المتاجر على الويب، داخل التطبيق:
/// القالب (بمعاينة حية) ← الباقة ← بيانات المتجر ← المراجعة والدفع.
///
/// المجاني يُنشأ فورًا ويعمل. المدفوع يُحجز «طلبًا» ومعه فواتيره، ويفتح واتساب برسالة
/// جاهزة إلى رقم المنصة فيكمل التاجر الدفع ويفعّل الفريق المتجر.
class CreateStoreWizard extends ConsumerStatefulWidget {
  const CreateStoreWizard({super.key, this.initialTemplate, this.initialPlan});
  final String? initialTemplate;
  final PlanId? initialPlan;

  /// بعد «افتح متجرك مجانًا» في الترحيب: الحساب أولًا، ثم يُفتح المعالج تلقائيًا
  /// حين تصل بوابة المتجر بلا متاجر.
  static bool openAfterSignUp = false;

  static Future<void> open(BuildContext context, {String? template, PlanId? plan}) => Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => CreateStoreWizard(initialTemplate: template, initialPlan: plan)),
      );

  @override
  ConsumerState<CreateStoreWizard> createState() => _CreateStoreWizardState();
}

const _steps = ['القالب', 'الباقة', 'بيانات المتجر', 'المراجعة'];
const _colors = [Color(0xFFC1272D), Color(0xFF1F3C88), Color(0xFF2F4A3A), Color(0xFFB08D57), Color(0xFF6B2D5C), Color(0xFF111111), Color(0xFFE59A12), Color(0xFF0E7C86)];

class _CreateStoreWizardState extends ConsumerState<CreateStoreWizard> {
  final _page = PageController();
  int _step = 0;

  late StoreTemplate _tpl = StoreTemplate.byId(widget.initialTemplate ?? 'essential');
  late PlanId _plan = widget.initialPlan ?? (_tpl.isFree ? PlanId.free : PlanId.pro);
  bool _yearly = false;
  String _tier = 'all';

  final _name = TextEditingController();
  final _slug = TextEditingController();
  final _wa = TextEditingController();
  Color _color = _colors.first;
  bool _slugTouched = false;
  Timer? _debounce;
  Map<String, dynamic>? _slugCheck;
  bool _checking = false;

  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _page.dispose();
    _name.dispose();
    _slug.dispose();
    _wa.dispose();
    super.dispose();
  }

  PlatformPricing? get _pricing => ref.read(pricingProvider).valueOrNull;

  num _planPrice(PlanId p) => _pricing?.price(p, yearly: _yearly) ?? switch (p) { PlanId.free => 0, PlanId.pro => _yearly ? 50 : 5, PlanId.biz => _yearly ? 150 : 15 };
  num? _tplCost(StoreTemplate t, PlanId p) =>
      _pricing?.templateCost(t, p) ?? (t.isFree ? 0 : p == PlanId.free ? null : p == PlanId.biz ? (t.tier == 'standard' ? 0 : (t.basePrice * .6).round()) : t.basePrice);
  String get _cur => _pricing?.currency ?? 'USD';
  num get _total => _planPrice(_plan) + (_tplCost(_tpl, _plan) ?? 0);

  String get _finalSlug => '${_slugCheck?['slug'] ?? _slug.text.trim()}';
  bool get _slugOk => _slugCheck?['ok'] == true;
  bool get _detailsOk => _name.text.trim().length >= 2 && _slugOk && _wa.text.replaceAll(RegExp(r'\D'), '').length >= 9;

  void _goto(int s) {
    FocusScope.of(context).unfocus();
    HapticFeedback.selectionClick();
    setState(() {
      _step = s;
      _error = null;
    });
    _page.animateToPage(s, duration: const Duration(milliseconds: 420), curve: Curves.easeOutCubic);
  }

  void _pickTemplate(StoreTemplate t) {
    setState(() {
      _tpl = t;
      // قالب مميز يحتاج باقة مدفوعة
      if (!t.isFree && _plan == PlanId.free) _plan = PlanId.pro;
    });
  }

  void _scheduleSlug() {
    _debounce?.cancel();
    final q = (_slugTouched ? _slug.text : _name.text).trim();
    if (q.length < 2) {
      setState(() {
        _slugCheck = null;
        _checking = false;
      });
      return;
    }
    setState(() => _checking = true);
    _debounce = Timer(const Duration(milliseconds: 450), () async {
      try {
        final r = await ref.read(platformApiProvider).checkSlug(q);
        if (!mounted || q != (_slugTouched ? _slug.text : _name.text).trim()) return;
        setState(() {
          _slugCheck = r;
          _checking = false;
          if (!_slugTouched) _slug.text = '${r['slug'] ?? ''}';
        });
      } catch (_) {
        if (mounted) setState(() => _checking = false);
      }
    });
  }

  Future<void> _create() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final store = await ref.read(platformApiProvider).createStore(
            name: _name.text,
            whatsapp: _wa.text,
            slug: _finalSlug,
            color: '#${_color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
            template: _tpl,
            plan: _plan,
            yearly: _yearly,
          );
      ref.invalidate(storeListProvider);
      ref.read(activeStoreIdProvider.notifier).state = '${store['id']}';
      String? waNumber;
      String? waMessage;
      if (_plan.paid) {
        waNumber = PlatformContact.forPhone(_wa.text);
        waMessage = activationMessage(store: _name.text.trim(), slug: '${store['slug'] ?? _finalSlug}', template: _tpl, plan: _plan, yearly: _yearly, total: _total, currency: _cur);
        await PlatformContact.whatsapp(waNumber, waMessage);
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
        builder: (_) => StoreCreatedScreen(
          storeId: '${store['id']}',
          name: _name.text.trim(),
          slug: '${store['slug'] ?? _finalSlug}',
          template: _tpl,
          plan: _plan,
          total: _total,
          currency: _cur,
          waNumber: waNumber,
          waMessage: waMessage,
        ),
      ));
    } on ApiException catch (e) {
      setState(() {
        _busy = false;
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _busy = false;
        _error = 'تعذّر إنشاء المتجر — تحقّق من الاتصال وحاول مجددًا';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    ref.watch(pricingProvider);
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (did, _) {
        if (!did && _step > 0) _goto(_step - 1);
      },
      child: Scaffold(
        backgroundColor: p.ground,
        body: SafeArea(
          bottom: false,
          child: Column(children: [
            _Header(step: _step, onClose: () => Navigator.of(context).maybePop(), onBack: _step > 0 ? () => _goto(_step - 1) : null, onTap: (i) => i < _step ? _goto(i) : null),
            Expanded(
              child: PageView(
                controller: _page,
                physics: const NeverScrollableScrollPhysics(),
                children: [_templatesStep(p), _planStep(p), _detailsStep(p), _reviewStep(p)],
              ),
            ),
            _BottomBar(
              total: _step == 0 ? null : _total,
              currency: _cur,
              hint: _step == 0 ? 'القالب: ${_tpl.name}' : '${_plan.label}${_plan.paid ? (_yearly ? ' · سنوي' : ' · شهري') : ''} · ${_tpl.name}',
              error: _error,
              child: _step < 3
                  ? FilledButton(
                      onPressed: (_step == 2 && !_detailsOk) ? null : () => _goto(_step + 1),
                      style: FilledButton.styleFrom(backgroundColor: Rv.red, minimumSize: const Size(0, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('متابعة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_back_rounded, size: 20),
                      ]),
                    )
                  : _plan.paid
                      ? WhatsAppButton(label: 'أرسل الطلب للفريق على واتساب', busy: _busy, onPressed: _create)
                      : FilledButton(
                          onPressed: _busy ? null : _create,
                          style: FilledButton.styleFrom(backgroundColor: Rv.red, minimumSize: const Size(0, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                          child: _busy
                              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                              : const Text('أنشئ متجري الآن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── ١. القالب ─────────────────────────────────────────────
  Widget _templatesStep(AzmPalette p) {
    final list = StoreTemplate.all.where((t) => _tier == 'all' || t.tier == _tier).toList();
    return CustomScrollView(slivers: [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
        sliver: SliverToBoxAdapter(
          child: _StepTitle('اختر قالب متجرك', '${StoreTemplate.all.length} قالبًا احترافيًا. الأساسي مجاني مع كل الباقات، والمميزة تُدفع مرة واحدة. اضغط «معاينة حية» لتجرّب المتجر كما يراه عميلك.'),
        ),
      ),
      SliverToBoxAdapter(
        child: SizedBox(
          height: 44,
          child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20), children: [
            for (final (id, label) in const [('all', 'الكل'), ('free', 'مجاني'), ('standard', 'قياسي'), ('signature', 'توقيع ✦')])
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: ChoiceChip(
                  label: Text(label),
                  selected: _tier == id,
                  onSelected: (_) => setState(() => _tier = id),
                  selectedColor: Rv.red,
                  labelStyle: TextStyle(color: _tier == id ? Colors.white : p.ink, fontWeight: FontWeight.w700),
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99), side: BorderSide(color: _tier == id ? Rv.red : p.hairline)),
                ),
              ),
          ]),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: .5),
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final t = list[i];
              return TemplateCard(
                t: t,
                selected: t.id == _tpl.id,
                currency: _cur,
                price: t.isFree ? 0 : _pricing?.templateBase(t),
                onTap: () {
                  HapticFeedback.selectionClick();
                  _pickTemplate(t);
                },
                onPreview: () => TemplatePreviewScreen.open(
                  context,
                  templates: list,
                  initial: t,
                  currency: _cur,
                  priceOf: (x) => x.isFree ? 0 : _pricing?.templateBase(x),
                  onPick: (x) {
                    _pickTemplate(x);
                    _goto(1);
                  },
                ),
              );
            },
            childCount: list.length,
          ),
        ),
      ),
    ]);
  }

  // ── ٢. الباقة ─────────────────────────────────────────────
  Widget _planStep(AzmPalette p) {
    return ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 24), children: [
      const _StepTitle('اختر الباقة', 'ابدأ مجانًا وترقَّ متى شئت. المبالغ للمنصة وحدها — أموال مبيعاتك تبقى بينك وبين عميلك، بلا عمولة.'),
      BillingToggle(yearly: _yearly, monthsFree: _pricing?.yearlyMonthsFree ?? 2, onChanged: (v) => setState(() => _yearly = v)),
      const SizedBox(height: 16),
      for (final plan in PlanId.values)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PlanCard(
            plan: plan,
            price: _planPrice(plan),
            currency: _cur,
            yearly: _yearly,
            selected: _plan == plan,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _plan = plan);
            },
            lockedReason: plan == PlanId.free && !_tpl.isFree ? 'المجانية تشمل القالب الأساسي فقط — قالب «${_tpl.name}» يحتاج باقة مدفوعة' : null,
          ),
        ),
      if (!_tpl.isFree)
        TextButton.icon(
          onPressed: () => setState(() {
            _tpl = StoreTemplate.byId('essential');
            _plan = PlanId.free;
          }),
          icon: const Icon(Icons.swap_horiz_rounded),
          label: const Text('أبدأ مجانًا بالقالب الأساسي بدلًا منه'),
        ),
      if (_plan.paid && !_tpl.isFree)
        RvCard(
          color: Rv.gold.withValues(alpha: .1),
          child: Row(children: [
            const Icon(Icons.palette_outlined, color: Color(0xFF8A5A00)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                switch (_tplCost(_tpl, _plan)) {
                  0 => 'قالب «${_tpl.name}» مشمول مجانًا في باقة ${_plan.label} 🎉',
                  final c => 'قالب «${_tpl.name}»: ${currencyLabel(_cur)}${fmtMoney(c ?? 0)} دفعة واحدة${_plan == PlanId.biz ? ' (بخصم الأعمال ٤٠٪)' : ''}',
                },
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ]),
        ),
    ]);
  }

  // ── ٣. البيانات ───────────────────────────────────────────
  Widget _detailsStep(AzmPalette p) {
    final checking = _checking;
    final ok = _slugOk;
    final reason = '${_slugCheck?['reason'] ?? ''}';
    final suggestion = _slugCheck?['suggestion'];
    return ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 24), children: [
      const _StepTitle('بيانات متجرك', 'الاسم والرابط وواتساب الطلبات. الشعار والغلاف والنصوص تعدّلها بعدها من «تصميم المتجر».'),
      _field(p, _name, 'اسم المتجر', Icons.storefront_outlined, hint: 'مثال: عطور السبعة', onChanged: (_) {
        if (!_slugTouched) _scheduleSlug();
        setState(() {});
      }),
      const SizedBox(height: 14),
      _field(
        p,
        _slug,
        'رابط متجرك',
        Icons.link_rounded,
        ltr: true,
        hint: 'mystore',
        suffix: Padding(padding: const EdgeInsets.only(left: 12, right: 4), child: Text('.rvios.store', style: TextStyle(color: p.inkMuted, fontWeight: FontWeight.w600))),
        onChanged: (v) {
          _slugTouched = true;
          _scheduleSlug();
        },
      ),
      const SizedBox(height: 6),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Row(key: ValueKey('$checking$ok$reason'), children: [
          if (checking)
            const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
          else
            Icon(ok ? Icons.check_circle_rounded : (_slugCheck == null ? Icons.info_outline_rounded : Icons.error_outline_rounded),
                size: 16, color: ok ? const Color(0xFF0F9D6B) : (_slugCheck == null ? p.inkFaint : p.danger)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              checking
                  ? 'نتحقق من الرابط…'
                  : ok
                      ? 'متاح! متجرك على $_finalSlug.rvios.store'
                      : _slugCheck == null
                          ? 'أحرف إنجليزية صغيرة وأرقام وشرطة — يُقترح من الاسم تلقائيًا'
                          : (reason.isEmpty ? 'هذا الرابط غير متاح' : reason),
              style: AppTypography.caption.copyWith(color: ok ? const Color(0xFF0F9D6B) : (_slugCheck == null ? p.inkMuted : p.danger)),
            ),
          ),
          if (!ok && suggestion != null)
            TextButton(
              onPressed: () {
                _slugTouched = true;
                _slug.text = '$suggestion';
                _scheduleSlug();
              },
              child: Text('استخدم $suggestion', textDirection: TextDirection.ltr),
            ),
        ]),
      ),
      const SizedBox(height: 14),
      _field(p, _wa, 'رقم واتساب لاستقبال الطلبات', Icons.chat_outlined, ltr: true, phone: true, hint: '+967 7XX XXX XXX', onChanged: (_) => setState(() {})),
      const SizedBox(height: 4),
      Text('تصلك عليه طلبات العملاء، ويتواصل معك فريق RVIOS. اكتبه برمز الدولة.', style: AppTypography.caption.copyWith(color: p.inkMuted)),
      const SizedBox(height: 20),
      Text('لون متجرك', style: TextStyle(fontWeight: FontWeight.w800, color: p.ink)),
      const SizedBox(height: 10),
      Wrap(spacing: 10, runSpacing: 10, children: [
        for (final c in _colors)
          GestureDetector(
            onTap: () => setState(() => _color = c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(color: _color == c ? p.ink : Colors.transparent, width: 3),
                boxShadow: _color == c ? [BoxShadow(color: c.withValues(alpha: .45), blurRadius: 12)] : null,
              ),
              child: _color == c ? const Icon(Icons.check_rounded, color: Colors.white, size: 20) : null,
            ),
          ),
      ]),
      const SizedBox(height: 22),
      // بطاقة الرابط الحي
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: LinearGradient(colors: [_color, Color.lerp(_color, Colors.black, .45)!])),
        child: Row(children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white,
            child: Text(_name.text.trim().isEmpty ? '؟' : _name.text.trim().characters.first, style: TextStyle(color: _color, fontWeight: FontWeight.w800, fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_name.text.trim().isEmpty ? 'اسم متجرك' : _name.text.trim(), style: const TextStyle(color: Colors.white, fontFamily: 'Zain', fontSize: 22, fontWeight: FontWeight.w800, height: 1.1)),
              Text('${_finalSlug.isEmpty ? 'yourstore' : _finalSlug}.rvios.store', textDirection: TextDirection.ltr, style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
            ]),
          ),
          const Icon(Icons.verified_rounded, color: Colors.white70),
        ]),
      ),
    ]);
  }

  // ── ٤. المراجعة والدفع ────────────────────────────────────
  Widget _reviewStep(AzmPalette p) {
    final tplCost = _tplCost(_tpl, _plan) ?? 0;
    final accounts = _pricing?.accounts ?? const [];
    return ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 24), children: [
      _StepTitle(_plan.paid ? 'المراجعة والدفع' : 'كل شيء جاهز', _plan.paid
          ? 'نحجز متجرك ورابطه الآن، ونفتح واتساب برسالة جاهزة إلى فريق RVIOS. حوّل المبلغ لأحد الحسابات أدناه وأرسل الإيصال، فيتفعّل متجرك.'
          : 'متجر مجاني للأبد، يُنشأ فورًا برابطه الخاص. أضف منتجاتك وشارك الرابط.'),
      RvCard(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          SizedBox(width: 74, height: 140, child: TemplateShot(_tpl, radius: 14)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_name.text.trim(), style: TextStyle(fontFamily: 'Zain', fontSize: 24, fontWeight: FontWeight.w800, color: p.ink, height: 1.1)),
              Text('$_finalSlug.rvios.store', textDirection: TextDirection.ltr, style: AppTypography.caption.copyWith(color: p.inkMuted)),
              const SizedBox(height: 8),
              SummaryRow('القالب', tplCost == 0 ? (_tpl.isFree ? 'مجاني' : 'مشمول') : '${currencyLabel(_cur)}${fmtMoney(tplCost)}', hint: _tpl.name),
              SummaryRow('الباقة', _plan.paid ? '${currencyLabel(_cur)}${fmtMoney(_planPrice(_plan))}' : 'مجانية', hint: _plan.paid ? '${_plan.label} · ${_yearly ? 'سنوي' : 'شهري'}' : _plan.label),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 10),
      RvCard(child: SummaryRow('الإجمالي', '${currencyLabel(_cur)}${fmtMoney(_total)}', strong: true, hint: _plan.paid ? 'يُدفع مرة عند التفعيل' : 'بلا بطاقة ولا عمولة')),
      if (_plan.paid) ...[
        const SizedBox(height: 22),
        const HowSteps([
          ('اضغط «أرسل الطلب للفريق على واتساب»', 'نحجز متجرك ويفتح واتساب برسالة فيها تفاصيل الطلب والمبلغ.'),
          ('حوّل المبلغ وأرسل الإيصال', 'إلى أحد الحسابات أدناه، ثم صورة الإيصال في المحادثة نفسها.'),
          ('يتفعّل متجرك', 'تتفعّل الباقة والقالب ويظهر متجرك للعملاء، ويصلك إشعار.'),
        ]),
        const SizedBox(height: 6),
        Text('حسابات الدفع', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: p.ink)),
        const SizedBox(height: 10),
        if (accounts.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
        else
          for (final a in accounts) PayAccountCard(a),
      ],
    ]);
  }

  Widget _field(AzmPalette p, TextEditingController c, String label, IconData icon,
      {String? hint, bool ltr = false, bool phone = false, Widget? suffix, ValueChanged<String>? onChanged}) {
    return TextField(
      controller: c,
      onChanged: onChanged,
      textDirection: ltr ? TextDirection.ltr : null,
      keyboardType: phone ? TextInputType.phone : (ltr ? TextInputType.url : TextInputType.text),
      inputFormatters: ltr && !phone ? [FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9-]')), LowerCase()] : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffix: suffix,
        filled: true,
        fillColor: p.surfaceRaised,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: p.hairline)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: p.hairline)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Rv.red, width: 1.6)),
      ),
    );
  }
}

class LowerCase extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) => n.copyWith(text: n.text.toLowerCase());
}

class _StepTitle extends StatelessWidget {
  const _StepTitle(this.title, this.body);
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontFamily: 'Zain', fontSize: 32, fontWeight: FontWeight.w800, color: p.ink, height: 1.15)),
        const SizedBox(height: 6),
        Text(body, style: TextStyle(color: p.inkMuted, height: 1.6, fontSize: 13.5)),
      ]),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.step, required this.onClose, required this.onBack, required this.onTap});
  final int step;
  final VoidCallback onClose;
  final VoidCallback? onBack;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
      child: Column(children: [
        Row(children: [
          IconButton(onPressed: onBack ?? onClose, icon: Icon(onBack == null ? Icons.close_rounded : Icons.arrow_forward_rounded)),
          Expanded(child: Text('افتح متجرك', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: p.ink))),
          Padding(padding: const EdgeInsetsDirectional.only(end: 14), child: Text('${step + 1} / ${_steps.length}', style: TextStyle(color: p.inkMuted, fontWeight: FontWeight.w700))),
        ]),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(children: [
            for (var i = 0; i < _steps.length; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  child: Column(children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(color: i <= step ? Rv.red : p.hairline, borderRadius: BorderRadius.circular(99)),
                    ),
                    const SizedBox(height: 6),
                    Text(_steps[i], style: TextStyle(fontSize: 11, fontWeight: i == step ? FontWeight.w800 : FontWeight.w500, color: i <= step ? Rv.red : p.inkFaint)),
                  ]),
                ),
              ),
          ]),
        ),
      ]),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.total, required this.currency, required this.hint, required this.child, this.error});
  final num? total;
  final String currency;
  final String hint;
  final Widget child;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: p.surfaceRaised,
        border: Border(top: BorderSide(color: p.hairline)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .06), blurRadius: 20, offset: const Offset(0, -6))],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (error != null)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: p.dangerSubtle, borderRadius: BorderRadius.circular(12)),
            child: Text(error!, style: TextStyle(color: p.danger, fontWeight: FontWeight.w600)),
          ),
        Row(children: [
          Expanded(child: Text(hint, style: AppTypography.caption.copyWith(color: p.inkMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
          if (total != null)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
              child: Text(total == 0 ? 'مجاني' : '${currencyLabel(currency)}${fmtMoney(total!)}',
                  key: ValueKey(total), style: const TextStyle(fontFamily: 'Zain', fontSize: 26, fontWeight: FontWeight.w800, color: Rv.red, height: 1)),
            ),
        ]),
        const SizedBox(height: 10),
        child,
      ]),
    );
  }
}
