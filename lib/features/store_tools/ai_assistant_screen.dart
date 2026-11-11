import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/design/azm_tokens.dart';
import '../../core/theme/app_typography.dart';
import 'store_tools_api.dart';

class _Msg {
  _Msg(this.mine, this.text);
  final bool mine;
  String text;
  bool error = false;
}

/// مساعد RVIOS AI في تطبيق عزم — المحادثة نفسها التي في لوحة الويب، على
/// بيانات المتجر الحقيقية. استشاري فقط: يقترح ويكتب، ولا يغيّر شيئًا وحده.
class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key, required this.storeId, required this.storeName});
  final String storeId;
  final String storeName;

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _api = StoreToolsApi();
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _msgs = <_Msg>[];
  String? _conversation;
  StreamSubscription<AiEvent>? _sub;
  String? _quota;

  static const _starters = [
    'حلّل أداء متجري هذا الشهر واقترح ٣ خطوات',
    'اكتب وصفًا جذابًا لمنتج جديد',
    'اقترح عرضًا لنهاية الأسبوع يرفع المبيعات',
    'كيف أحسّن ظهور متجري في Google؟',
  ];

  @override
  void dispose() {
    _sub?.cancel();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send([String? preset]) {
    final text = (preset ?? _input.text).trim();
    if (text.isEmpty || _sub != null) return;
    _input.clear();
    final reply = _Msg(false, '');
    setState(() {
      _msgs.add(_Msg(true, text));
      _msgs.add(reply);
    });
    _sub = _api
        .chat(widget.storeId, conversationId: _conversation, message: text, mode: _msgs.length <= 2 && preset == _starters.first ? 'insights' : 'chat')
        .listen(
      (ev) {
        switch (ev.type) {
          case 'start':
            _conversation = ev.data['conversationId'] as String?;
          case 'delta':
            setState(() => reply.text += '${ev.data['text'] ?? ''}');
            _toEnd();
          case 'done':
            final used = ev.data['used'], limit = ev.data['limit'];
            if (used != null && limit != null) setState(() => _quota = 'استخدمت $used من $limit رسالة هذا الشهر');
          case 'error':
            setState(() {
              reply.text = '${ev.data['message'] ?? 'تعذّر الرد الآن'}';
              reply.error = true;
            });
        }
      },
      onError: (_) => setState(() {
        reply.text = 'انقطع الاتصال — حاول مجددًا.';
        reply.error = true;
      }),
      onDone: () => setState(() => _sub = null),
    );
  }

  void _toEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    return Scaffold(
      backgroundColor: p.ground,
      appBar: AppBar(
        backgroundColor: p.ground,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('RVIOS AI', style: AppTypography.h3.copyWith(color: p.ink)),
          Text(widget.storeName, style: AppTypography.caption.copyWith(color: p.inkFaint)),
        ]),
        actions: [
          if (_msgs.isNotEmpty)
            IconButton(
              tooltip: 'محادثة جديدة',
              icon: const Icon(Icons.add_comment_outlined),
              onPressed: _sub != null
                  ? null
                  : () => setState(() {
                        _msgs.clear();
                        _conversation = null;
                      }),
            ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: _msgs.isEmpty
              ? ListView(padding: const EdgeInsets.all(AzmSpace.screenGutter), children: [
                  const SizedBox(height: AzmSpace.xl),
                  Icon(Icons.auto_awesome, size: 40, color: p.accent),
                  const SizedBox(height: AzmSpace.md),
                  Text('مساعد متجرك الذكي', textAlign: TextAlign.center, style: AppTypography.h3.copyWith(color: p.ink)),
                  const SizedBox(height: AzmSpace.xs),
                  Text('يقرأ أرقام متجرك ومنتجاته، ويقترح ويكتب لك. لا يغيّر شيئًا في متجرك من تلقاء نفسه.',
                      textAlign: TextAlign.center, style: AppTypography.bodySmall.copyWith(color: p.inkMuted)),
                  const SizedBox(height: AzmSpace.xl),
                  for (final s in _starters)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AzmSpace.sm),
                      child: OutlinedButton(onPressed: () => _send(s), child: Align(alignment: AlignmentDirectional.centerStart, child: Text(s))),
                    ),
                ])
              : ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(AzmSpace.lg),
                  itemCount: _msgs.length,
                  itemBuilder: (context, i) {
                    final m = _msgs[i];
                    return Align(
                      alignment: m.mine ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .84),
                        margin: const EdgeInsets.only(bottom: AzmSpace.sm),
                        padding: const EdgeInsets.symmetric(horizontal: AzmSpace.md, vertical: AzmSpace.sm + 2),
                        decoration: BoxDecoration(
                          color: m.mine ? p.accent : (m.error ? p.dangerSubtle : p.surfaceRaised),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: m.text.isEmpty
                            ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: p.inkFaint))
                            : SelectableText(m.text, style: AppTypography.body.copyWith(color: m.mine ? p.onAccent : (m.error ? p.danger : p.ink), height: 1.7)),
                      ),
                    );
                  },
                ),
        ),
        if (_quota != null) Padding(padding: const EdgeInsets.only(bottom: AzmSpace.xs), child: Text(_quota!, style: AppTypography.caption.copyWith(color: p.inkFaint))),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AzmSpace.md, AzmSpace.xs, AzmSpace.md, AzmSpace.md),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _input,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: const InputDecoration(hintText: 'اسأل عن متجرك…'),
                ),
              ),
              const SizedBox(width: AzmSpace.sm),
              IconButton.filled(
                onPressed: _sub != null ? () => _sub?.cancel().then((_) => setState(() => _sub = null)) : () => _send(),
                icon: Icon(_sub != null ? Icons.stop : Icons.send),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
