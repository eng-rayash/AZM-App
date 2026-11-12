import 'package:flutter/material.dart';

import '../../shared/widgets/help_tips.dart';

/// نصوص الإرشاد لشاشات المتجر — في مكان واحد ليسهل تحريرها.
class StoreHelp {
  StoreHelp._();

  static const _green = Color(0xFF0F766E);
  static const _blue = Color(0xFF2F6FB3);
  static const _violet = Color(0xFF7C3AED);
  static const _amber = Color(0xFFD97706);
  static const _teal = Color(0xFF0E7C86);

  static const home = HelpTip(id: 'home', title: 'لوحة متجرك', steps: [
    HelpStep(Icons.storefront_rounded, 'أهلًا بك في متجرك', 'هنا صحة متجرك في نظرة: مبيعات الشهر، والطلبات التي تنتظرك، والزيارات، وسعة باقتك.'),
    HelpStep(Icons.brush_rounded, 'صمّم متجرك من جوالك', 'من «صمّم متجرك» تغيّر الشعار والغلاف والألوان والنصوص والقالب بمعاينة حية — بشكل الجوال والمتصفح.', color: _violet),
    HelpStep(Icons.notifications_active_rounded, 'لا تفوّت طلبًا', 'يصلك إشعار مع كل طلب جديد. الرد السريع على العميل هو ما يصنع البيع.', color: _amber),
    HelpStep(Icons.menu_rounded, 'كل الأدوات في القائمة', 'افتح القائمة الجانبية (☰) لتصل إلى العملاء والتوصيل والتحليلات والباقة وطرق الدفع.', color: _blue),
  ]);

  static const orders = HelpTip(id: 'orders', title: 'الطلبات', steps: [
    HelpStep(Icons.receipt_long_rounded, 'كل طلب محفوظ هنا', 'يصل الطلب «قيد التأكيد». افتحه لترى المنتجات والعنوان ورقم العميل.'),
    HelpStep(Icons.chat_rounded, 'تواصل بلمسة', 'زر واتساب في الطلب يفتح محادثة العميل برسالة جاهزة لتأكيد الطلب والتوصيل.', color: Color(0xFF1FAF5A)),
    HelpStep(Icons.local_shipping_rounded, 'حرّك الطلب خطوة خطوة', 'أكّد الطلب ثم «تم التسليم» — وعلّمه مدفوعًا حين تستلم المبلغ. هكذا تبقى أرقامك صحيحة.', color: _green),
  ]);

  static const products = HelpTip(id: 'products', title: 'المنتجات', steps: [
    HelpStep(Icons.add_photo_alternate_rounded, 'أضف منتجك بصوره', 'اضغط «منتج جديد»، أضف حتى ٨ صور من المعرض أو الكاميرا، والسعر والوصف والتصنيف.'),
    HelpStep(Icons.bolt_rounded, 'صور خفيفة تلقائيًا', 'نصغّر الصور ونحوّلها إلى WebP قبل الرفع، فيفتح متجرك بسرعة حتى على الشبكات الضعيفة.', color: _amber),
    HelpStep(Icons.visibility_rounded, 'اعرض أو أخفِ', 'المنتج المخفي يبقى محفوظًا ولا يراه العملاء. والمخزون المنخفض ينبّهك قبل نفاده.', color: _green),
  ]);

  static const design = HelpTip(id: 'design', title: 'تصميم المتجر', steps: [
    HelpStep(Icons.phone_iphone_rounded, 'معاينة حية بشكلين', 'متجرك يعمل أعلى الشاشة. بدّل بين «جوال» و«متصفح» لترى كيف يظهر لكل عميل.', color: _violet),
    HelpStep(Icons.touch_app_rounded, 'المحرر المرئي الكامل', 'اضغط أي نص أو صورة في متجرك لتعدّله، وأخفِ الأقسام، وغيّر الخطوط وروابط التواصل.'),
    HelpStep(Icons.tune_rounded, 'الهوية والإضافات', 'الشعار والغلاف واللون، وشريط الإعلان، وزر واتساب، والظهور في Google، والسياسات — كلها هنا.', color: _blue),
    HelpStep(Icons.save_rounded, 'احفظ وانشر', '«حفظ ونشر» يحدّث متجرك فورًا. تعديلات المحرر المرئي تُقفل أسبوعًا بعد كل حفظ — راجعها قبل الحفظ.', color: _green),
  ]);

  static const templates = HelpTip(id: 'templates', title: 'القوالب', steps: [
    HelpStep(Icons.dashboard_customize_rounded, '١٨ قالبًا احترافيًا', 'القالب يغيّر شكل متجرك كله ويبقي منتجاتك وطلباتك كما هي.', color: _violet),
    HelpStep(Icons.play_circle_rounded, 'جرّب قبل أن تختار', '«معاينة حية» تفتح متجر عرض حقيقيًا للقالب — تصفّحه كعميل، وبدّل بين الجوال والمتصفح.'),
    HelpStep(Icons.auto_awesome_rounded, 'المجاني والمميز', 'الأساسي مجاني دائمًا. القياسي والتوقيع يُشتريان مرة واحدة، وباقة «أعمال» تشمل القياسي مجانًا.', color: _amber),
  ]);

  static const plan = HelpTip(id: 'plan', title: 'الباقة والاشتراك', steps: [
    HelpStep(Icons.workspace_premium_rounded, 'باقتك وأيامها', 'ترى باقتك الحالية ومتى تتجدّد. المجانية للأبد، والمدفوعة تفتح منتجات وقوالب ودومينًا خاصًا.'),
    HelpStep(Icons.chat_rounded, 'الترقية برسالة', 'اختر الباقة واضغط الزر — تُنشأ فاتورتك ويفتح واتساب برسالة جاهزة لفريق RVIOS.', color: Color(0xFF1FAF5A)),
    HelpStep(Icons.upload_rounded, 'ارفع الإيصال', 'بعد التحويل ارفع صورة الإيصال من هنا، فيراجعها الفريق ويفعّل طلبك.', color: _teal),
  ]);

  static const wizard = HelpTip(id: 'wizard', title: 'افتح متجرك', steps: [
    HelpStep(Icons.storefront_rounded, 'أربع خطوات فقط', 'القالب، ثم الباقة، ثم اسم متجرك ورابطه وواتساب، ثم المراجعة.'),
    HelpStep(Icons.play_circle_rounded, 'عاين القوالب حيّة', 'اضغط «معاينة حية» على أي قالب لترى متجرًا حقيقيًا به قبل أن تختار.', color: _violet),
    HelpStep(Icons.rocket_launch_rounded, 'المجاني فوري', 'المتجر المجاني يعمل فور الإنشاء. والمدفوع يُحجز ويفتح واتساب لإكمال الدفع مع الفريق.', color: _green),
  ]);

  static const business = HelpTip(id: 'business', title: 'أعمالي', steps: [
    HelpStep(Icons.business_center_rounded, 'ما حول متجرك', 'متاجرك، وعملاء متجرك، ودفتر عملائك، ومورّدوك، وروتين يومك — في مكان واحد.', color: _blue),
    HelpStep(Icons.repeat_rounded, 'روتين المتجر', 'أضف مهامك المتكررة (تجهيز الطلبات، تحديث المخزون…) ويذكّرك التطبيق بها كل يوم.', color: _violet),
  ]);
}
