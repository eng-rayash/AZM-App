import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// نوافذ الإرشاد: تظهر مرة واحدة أول ما يفتح التاجر الشاشة، بخطوات قصيرة مصوّرة،
/// ويعيد فتحها زرّ «؟» ([HelpButton]) متى شاء. «إعادة الإرشادات» في الإعدادات تعيدها كلها.
class HelpStep {
  const HelpStep(this.icon, this.title, this.body, {this.color = const Color(0xFFC1272D)});
  final IconData icon;
  final String title;
  final String body;
  final Color color;
}

class HelpTip {
  const HelpTip({required this.id, required this.title, required this.steps});
  final String id;
  final String title;
  final List<HelpStep> steps;
}

class HelpTips {
  HelpTips._();
  static const _prefix = 'rvios.tip.';
  static final _shownThisRun = <String>{};

  /// يعرض الإرشاد إن لم يُرَ من قبل — يُستدعى بعد أول إطار للشاشة.
  static Future<void> maybeShow(BuildContext context, HelpTip tip) async {
    if (_shownThisRun.contains(tip.id)) return;
    _shownThisRun.add(tip.id);
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('$_prefix${tip.id}') == true) return;
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!context.mounted) return;
    await show(context, tip);
    await prefs.setBool('$_prefix${tip.id}', true);
  }

  static Future<void> show(BuildContext context, HelpTip tip) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black54,
        builder: (_) => _HelpSheet(tip: tip),
      );

  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    for (final k in prefs.getKeys().where((k) => k.startsWith(_prefix)).toList()) {
      await prefs.remove(k);
    }
    _shownThisRun.clear();
  }
}

/// يغلّف الشاشة: يعرض إرشادها أول مرة تلقائيًا.
class WithHelp extends StatefulWidget {
  const WithHelp({super.key, required this.tip, required this.child});
  final HelpTip tip;
  final Widget child;
  @override
  State<WithHelp> createState() => _WithHelpState();
}

class _WithHelpState extends State<WithHelp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => HelpTips.maybeShow(context, widget.tip));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// زرّ «؟» يعيد فتح إرشاد الشاشة.
class HelpButton extends StatelessWidget {
  const HelpButton(this.tip, {super.key, this.color});
  final HelpTip tip;
  final Color? color;
  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: 'كيف أستخدم هذه الشاشة؟',
        onPressed: () => HelpTips.show(context, tip),
        icon: Icon(Icons.help_outline_rounded, color: color),
      );
}

class _HelpSheet extends StatefulWidget {
  const _HelpSheet({required this.tip});
  final HelpTip tip;
  @override
  State<_HelpSheet> createState() => _HelpSheetState();
}

class _HelpSheetState extends State<_HelpSheet> {
  final _page = PageController();
  int _i = 0;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.tip.steps;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? const Color(0xFF1C1311) : Colors.white;
    final ink = dark ? Colors.white : const Color(0xFF1F1412);
    final muted = dark ? Colors.white70 : const Color(0xFF6B5E58);
    final last = _i == steps.length - 1;
    final c = steps[_i].color;

    return Container(
      margin: EdgeInsets.fromLTRB(12, 0, 12, 12 + MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(30)),
      clipBehavior: Clip.antiAlias,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // ── الرأس ──
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [c, Color.lerp(c, Colors.black, .45)!]),
          ),
          child: Stack(alignment: Alignment.center, children: [
            Positioned(right: -30, top: -40, child: Container(width: 160, height: 160, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: .08)))),
            Positioned(left: -20, bottom: -50, child: Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: .06)))),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (w, a) => ScaleTransition(scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack), child: FadeTransition(opacity: a, child: w)),
              child: Container(
                key: ValueKey(_i),
                width: 78,
                height: 78,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: .16), shape: BoxShape.circle, border: Border.all(color: Colors.white30)),
                child: Icon(steps[_i].icon, color: Colors.white, size: 38),
              ),
            ),
            Positioned(
              top: 12,
              right: 16,
              child: Text(widget.tip.title, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 12.5)),
            ),
            Positioned(
              top: 2,
              left: 4,
              child: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: Colors.white70)),
            ),
          ]),
        ),
        // ── الخطوات ──
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _page,
            itemCount: steps.length,
            onPageChanged: (i) {
              HapticFeedback.selectionClick();
              setState(() => _i = i);
            },
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(steps[i].title, style: TextStyle(fontFamily: 'Zain', fontSize: 26, fontWeight: FontWeight.w800, color: ink, height: 1.15)),
                const SizedBox(height: 8),
                Text(steps[i].body, style: TextStyle(color: muted, height: 1.65, fontSize: 14)),
              ]),
            ),
          ),
        ),
        // ── التنقّل ──
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
          child: Row(children: [
            for (var i = 0; i < steps.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: i == _i ? 22 : 7,
                height: 7,
                margin: const EdgeInsetsDirectional.only(end: 5),
                decoration: BoxDecoration(color: i == _i ? c : c.withValues(alpha: .25), borderRadius: BorderRadius.circular(99)),
              ),
            const Spacer(),
            if (!last) TextButton(onPressed: () => Navigator.pop(context), child: Text('تخطٍّ', style: TextStyle(color: muted))),
            const SizedBox(width: 6),
            FilledButton(
              onPressed: () => last ? Navigator.pop(context) : _page.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic),
              style: FilledButton.styleFrom(backgroundColor: c, minimumSize: const Size(110, 46), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: Text(last ? 'فهمت، لنبدأ' : 'التالي', style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ]),
        ),
      ]),
    );
  }
}
