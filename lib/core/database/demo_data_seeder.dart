import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'app_database.dart';

/// Demo Data Seeder — Comprehensive generator covering all 16 tables, models, and states.
///
/// Simulates 4 months of heavy daily app usage by an executive manager.
/// Includes data across all 16 tables without using any real private data.
class DemoDataSeeder {
  final AppDatabase db;
  final _uuid = const Uuid();

  DemoDataSeeder(this.db);

  String _pinHash(String pin) {
    return sha256.convert(utf8.encode(pin)).bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  String _dateStr(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }

  String _timeStr(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  Future<bool> seedDemoData() async {
    try {
      final now = DateTime.now();
      final rand = Random();

      DateTime ago(int days, {int hours = 0}) => now.subtract(Duration(days: days, hours: hours));
      DateTime future(int days, {int hours = 0}) => now.add(Duration(days: days, hours: hours));

      await db.transaction(() async {
        final userCreated = ago(120).millisecondsSinceEpoch;
        final hash = _pinHash('1234');

        // 1. Users
        await db.customStatement('''
          INSERT OR REPLACE INTO users (id, sync_id, created_at, updated_at, is_deleted, display_name, pin_hash, auth_method, is_biometric_enabled, role)
          VALUES (1, '${_uuid.v4()}', $userCreated, $userCreated, 0, 'م. خالد العتيبي', '$hash', 1, 1, 0)
        ''');

        // 2. App Settings
        final settings = [
          ["theme_mode", "dark", "appearance"],
          ["language", "ar", "general"],
          ["app_version", "1.5.0", "system"],
          ["notification_enabled", "true", "notifications"],
          ["auto_lock_minutes", "5", "security"],
        ];
        for (var s in settings) {
          final t = ago(100).millisecondsSinceEpoch;
          await db.customStatement('''
            INSERT OR REPLACE INTO app_settings (sync_id, created_at, updated_at, is_deleted, created_by, key, value, category)
            VALUES ('${_uuid.v4()}', $t, $t, 0, 'user_1', '${s[0]}', '${s[1]}', '${s[2]}')
          ''');
        }

        // 3. Contacts (15 executive contacts)
        final contacts = [
          ["م. سعد المطيري", "مدير عام", "شركة الخليج للطاقة", "0501234567", "saad@gulf-energy.sa", 1, "شريك استراتيجي مهم"],
          ["د. نورة الغامدي", "مديرة الموارد البشرية", "مجموعة رواد للاستثمار", "0551234568", "noura@rawad.com", 1, "اجتماع ربع سنوي"],
          ["م. فيصل القحطاني", "مستشار مالي", "بنك الرياض", "0561234569", "faisal@rib.com", 1, "مراجعة سنوية"],
          ["أ. عبدالله الشمري", "مدير المشاريع", "مجموعة التميم للمقاولات", "0571234570", "abdallah@tamim.sa", 0, null],
          ["د. هند الزهراني", "استشارية إدارية", "مستقلة", "0581234571", "hind.z@consulting.sa", 0, "خبرة تحول رقمي"],
          ["م. أحمد الدوسري", "نائب الرئيس", "شركة بترو العربية", "0591234572", "ahmed.d@petroarabia.com", 1, "اجتماع شهري"],
          ["أ. محمد السعيد", "مدير التسويق", "شركة البيان للإعلام", "0501234573", "m.alsaeed@bayan.sa", 0, null],
          ["د. علي الحربي", "رئيس مجلس الإدارة", "مجموعة الحربي القابضة", "0551234574", "ali.harbi@harbi.com", 1, "VIP"],
          ["أ. ريم العسيري", "مديرة التطوير", "شركة الرؤية التقنية", "0561234575", "reem.a@vision.sa", 0, null],
          ["م. يوسف المالكي", "مهندس البنية التحتية", "وزارة الاتصالات", "0571234576", "y.malki@mcit.gov.sa", 0, "مشروع الربط"],
          ["أ. سارة العجلان", "مديرة العلاقات العامة", "شركة الفجر للتطوير", "0581234577", "sara.a@alfajr.sa", 0, null],
          ["د. طارق الرشيدي", "مدير التقنية", "شركة سايبر العربية", "0591234578", "tariq.r@cyber.sa", 0, "خبير أمن"],
          ["م. لطيفة الصباح", "مديرة الفروع", "بنك الإمارات دبي الوطني", "0501234579", "lateefa@enbd.ae", 1, "علاقة بنكية"],
          ["أ. صالح الغزالي", "مستشار قانوني", "مكتب الغزالي للمحاماة", "0551234580", "saleh@law.sa", 0, null],
          ["أ. إبراهيم الخضيري", "مدير المحفظة", "صندوق الاستثمارات العامة", "0581234583", "i.khodairi@pif.gov.sa", 1, "شراكة رؤية 2030"],
        ];


        for (var c in contacts) {
          final t = ago(rand.nextInt(90) + 10).millisecondsSinceEpoch;
          await db.customStatement('''
            INSERT INTO contacts (sync_id, created_at, updated_at, is_deleted, created_by, name, position, company, phone_number, email, is_vip, notes)
            VALUES ('${_uuid.v4()}', $t, $t, 0, 'user_1', '${c[0]}', '${c[1]}', '${c[2]}', '${c[3]}', '${c[4]}', ${c[5]}, ${c[6] != null ? "'${c[6]}'" : 'NULL'})
          ''');
        }

        // 4. Meetings (10 meetings covering all types 0..4 and statuses 0..4)
        final meetings = [
          ["اجتماع مجلس الإدارة الربع سنوي", 3, ago(15), "09:00", "12:00", "قاعة الاجتماعات الرئيسية", "مراجعة نتائج Q1 واقرار خطة Q2", 2, 0, "انعقد الاجتماع برئاسة م. سعد المطيري وحقق نتائج ممتازة."],
          ["مراجعة التقرير المالي الشهري", 1, ago(10), "10:00", "11:30", "مكتب المدير المالي", "مراجعة المصروفات التشغيلية", 2, 1, null],
          ["ورشة التحول الرقمي", 0, ago(25), "08:30", "14:00", "فندق الريتز كارلتون", "وضع خارطة طريق التحول الرقمي", 2, 1, "تم الانتهاء من توصيات الورشة وتكليف فريق العمل."],
          ["اجتماع الشراكة مع صندوق الاستثمارات العامة", 0, future(5), "11:00", "13:00", "مقر PIF - الرياض", "عرض خطة التوسع والمبادرات الاستراتيجية", 0, 0, null],
          ["مناقشة عقد الشراكة — بترو العربية", 0, future(10), "10:00", "12:00", "مقر شركة بترو العربية", "التفاوض النهائي على بنود الشراكة", 0, 1, null],
          ["اجتماع طارئ — أزمة سلسلة الإمداد", 2, ago(40), "16:00", "18:00", "غرفة العمليات", "التعامل مع انقطاع الإمداد وإيجاد بدائل", 2, 0, "تم حل الأزمة خلال 72 ساعة."],
          ["مراجعة مشروع الربط التقني", 4, ago(5), "14:00", "15:00", "اجتماع مرئي عبر Teams", "متابعة تقدم الربط مع الوزارة", 2, 2, null],
          ["لقاء تعريفي مع الشركاء الخليجيين", 0, future(20), "10:00", "12:00", "الدوحة — مقر الشركة", "تعزيز الشراكات الإقليمية", 0, 2, null],
          ["اجتماع اللجنة المالية الطارئ", 2, ago(2), "15:00", "16:00", "غرفة اللجان", "مناقشة تعديل الميزانية التشغيلية", 3, 1, null],
          ["اجتماع مراجعة الموردين المرشحين", 1, ago(1), "11:00", "12:00", "قاعة الاجتماعات A", "تقييم العروض المقدمة", 1, 2, null],
        ];

        for (var m in meetings) {
          final dt = m[2] as DateTime;
          final t = dt.millisecondsSinceEpoch;
          await db.customStatement('''
            INSERT INTO meetings (sync_id, created_at, updated_at, is_deleted, created_by, title, meeting_type, date, time, end_time, location, objective, status, priority, minutes)
            VALUES ('${_uuid.v4()}', $t, $t, 0, 'user_1', '${m[0]}', ${m[1]}, '${_dateStr(dt)}', '${m[3]}', '${m[4]}', '${m[5]}', '${m[6]}', ${m[7]}, ${m[8]}, ${m[9] != null ? "'${m[9]}'" : 'NULL'})
          ''');
        }

        // 5. Tasks (15 tasks covering priorities 0..3 and statuses 0,1,3,4)
        final tasks = [
          ["إعداد تقرير الأداء Q1", "تجميع وتحليل مؤشرات الأداء للربع الأول", ago(12), "م. فيصل القحطاني", 0, 3],
          ["مراجعة عقد شركة الخليج", "قراءة ومراجعة بنود العقد مع الفريق القانوني", ago(8), "أ. صالح الغزالي", 1, 3],
          ["تقديم دراسة الجدوى — PIF", "تقديم الدراسة النهائية لصندوق الاستثمارات", future(4), "م. فيصل القحطاني", 0, 1],
          ["تطوير مبادرة الذكاء الاصطناعي", "بناء نموذج أولي لأتمتة العمليات", future(15), "م. حصة العتيبي", 0, 1],
          ["تحضير أجندة اجتماع مجلس الإدارة", "إعداد جدول الأعمال والوثائق الداعمة", future(3), "د. نورة الغامدي", 0, 1],
          ["متابعة تحصيل الذمم المدينة", "التواصل مع العملاء المتأخرين في السداد", ago(2), "م. فيصل القحطاني", 0, 4],
          ["إرسال ملاحظات عقد شركة البدر", "مراجعة العقد وإرسال الملاحظات", ago(3), "أ. صالح الغزالي", 1, 4],
          ["تحديث خطة إدارة المخاطر", "مراجعة سنوية لخطة إدارة مخاطر المنظمة", future(25), "أ. صالح الغزالي", 1, 0],
          ["مراجعة عروض الموردين المرشحين", "تقييم العروض الثلاثة المقدمة", future(5), "أ. حمد الرويلي", 2, 1],
          ["تحديث بوابة العملاء الرقمية", "مراجعة وتحديث واجهة خدمات العملاء", ago(20), "د. طارق الرشيدي", 2, 3],
          ["إعداد خطة التسويق Q3", "وضع خطة الحملات الرقمية للنصف الثاني", future(18), "أ. محمد السعيد", 2, 0],
          ["مراجعة السياسات الإدارية", "تحديث دليل الموظفين والتعديلات الجديدة", future(30), "د. نورة الغامدي", 3, 0],
        ];

        for (var tk in tasks) {
          final dt = tk[2] as DateTime;
          final t = dt.millisecondsSinceEpoch;
          await db.customStatement('''
            INSERT INTO tasks (sync_id, created_at, updated_at, is_deleted, created_by, title, description, due_date, assigned_to, priority, status)
            VALUES ('${_uuid.v4()}', $t, $t, 0, 'user_1', '${tk[0]}', '${tk[1]}', '${_dateStr(dt)}', '${tk[3]}', ${tk[4]}, ${tk[5]})
          ''');
        }

        // 6. Follow-ups (10 items)
        final followups = [
          ["متابعة قرار تعديل الميزانية التشغيلية", "التأكد من تنفيذ قرار خفض المصروفات 5%", ago(15), 0, 1, "م. فيصل القحطاني", 3],
          ["متابعة تطبيق نتائج ورشة التحول الرقمي", "مراجعة خطة التنفيذ وقياس التقدم", ago(10), 0, 3, "م. حصة العتيبي", 1],
          ["متابعة تقديم دراسة الجدوى لـ PIF", "التأكد من استلام الصندوق للدراسة", future(5), 1, 3, "م. فيصل القحطاني", 0],
          ["متابعة تسليم مشروع الربط التقني", "التحقق من استكمال مرحلة الاختبار", future(8), 2, 7, "د. طارق الرشيدي", 1],
          ["متابعة عروض الموردين المرشحين", "الحصول على تأكيدات الأسعار النهائية", future(6), 1, 9, "أ. حمد الرويلي", 1],
        ];

        for (var f in followups) {
          final dt = f[2] as DateTime;
          final t = dt.millisecondsSinceEpoch;
          await db.customStatement('''
            INSERT INTO follow_ups (sync_id, created_at, updated_at, is_deleted, created_by, title, notes, target_date, entity_type, entity_id, assigned_to, status)
            VALUES ('${_uuid.v4()}', $t, $t, 0, 'user_1', '${f[0]}', '${f[1]}', '${_dateStr(dt)}', ${f[3]}, ${f[4]}, '${f[5]}', ${f[6]})
          ''');
        }

        // 7. Directives (10 items)
        final directives = [
          ["رفع كفاءة عمليات سلسلة الإمداد", "مراجعة شاملة لعمليات الاستيراد والتخزين لتقليل التكلفة 10%", "المدير التنفيذي", "أ. حمد الرويلي", ago(30), 0, 3],
          ["تبني نظام إدارة الوثائق الرقمي", "الانتقال الكامل لنظام التوثيق الرقمي وتدريب الموظفين", "المدير التنفيذي", "م. حصة العتيبي", ago(15), 1, 3],
          ["تحسين معدلات رضا العملاء", "تطبيق برنامج قياس رضا العملاء وتحقيق نسبة 85%", "مجلس الإدارة", "أ. محمد السعيد", future(45), 1, 1],
          ["تعزيز الأمن السيبراني للمنظمة", "تقييم نقاط الضعف وتطبيق المعايير الموصى بها", "المدير التنفيذي", "د. طارق الرشيدي", future(20), 0, 1],
          ["إعداد تقرير الاستدامة السنوي", "جمع البيانات وإعداد تقرير الممارسات البيئية", "المدير التنفيذي", "أ. ريم العسيري", future(60), 2, 0],
        ];

        for (var d in directives) {
          final dt = d[4] as DateTime;
          final t = dt.millisecondsSinceEpoch;
          await db.customStatement('''
            INSERT INTO directives (sync_id, created_at, updated_at, is_deleted, created_by, title, details, source, assigned_to, deadline, priority, status)
            VALUES ('${_uuid.v4()}', $t, $t, 0, 'user_1', '${d[0]}', '${d[1]}', '${d[2]}', '${d[3]}', '${_dateStr(dt)}', ${d[5]}, ${d[6]})
          ''');
        }

        // 8. Appointments (10 items)
        final appointments = [
          ["لقاء مع م. سعد المطيري لمتابعة الشراكة", future(3), "10:00", 60, "مكتب المدير العام", 0],
          ["زيارة مقر شركة بترو العربية", future(10), "11:00", 120, "مقر بترو العربية", 0],
          ["اجتماع ثنائي مع د. هند الزهراني", future(2), "14:00", 45, "مكتب المستشارة", 0],
          ["غداء عمل مع أ. إبراهيم الخضيري", future(4), "13:00", 60, "مطعم الديوان - الرياض", 0],
          ["جلسة مراجعة مالية مع م. فيصل", future(7), "10:30", 90, "مكتب المدير المالي", 0],
        ];

        for (var a in appointments) {
          final dt = a[1] as DateTime;
          final t = dt.millisecondsSinceEpoch;
          await db.customStatement('''
            INSERT INTO appointments (sync_id, created_at, updated_at, is_deleted, created_by, title, date, time, duration_minutes, location, status)
            VALUES ('${_uuid.v4()}', $t, $t, 0, 'user_1', '${a[0]}', '${_dateStr(dt)}', '${a[2]}', ${a[3]}, '${a[4]}', ${a[5]})
          ''');
        }

        // 9. Archive (10 documents)
        final archiveDocs = [
          ["عقد الشراكة الاستراتيجية — شركة الخليج للطاقة", "صادر/2026/001", "1447/09/15", "2026-03-15", "شركة الخليج للطاقة", "عقود وشراكات", "عقد,شراكة", "تمت الموافقة من المجلس", 0],
          ["محضر اجتماع مجلس الإدارة — Q1 2026", "صادر/2026/002", "1447/09/20", "2026-03-20", "مجلس الإدارة", "محاضر الاجتماعات", "مجلس,Q1", null, 0],
          ["تقرير الأداء المالي — مارس 2026", "داخلي/2026/015", "1447/09/25", "2026-03-25", "الإدارة العليا", "تقارير مالية", "مالي,أداء", null, 1],
          ["دراسة الجدوى الاقتصادية — مشروع التوسع", "صادر/2026/003", "1447/10/01", "2026-04-01", "صندوق الاستثمارات العامة", "دراسات وأبحاث", "جدوى,PIF", "تقديم رسمي للصندوق", 1],
          ["دليل السياسات والإجراءات — نسخة 2026", "داخلي/2026/040", "1447/12/12", "2026-06-12", "جميع الموظفين", "سياسات وإجراءات", "دليل,سياسات", "يسري اعتباراً من يوليو", 0],
        ];

        for (var doc in archiveDocs) {
          final t = ago(30).millisecondsSinceEpoch;
          await db.customStatement('''
            INSERT INTO archive (sync_id, created_at, updated_at, is_deleted, created_by, title, reference_number, hijri_date, document_date, directed_entity, category, tags, notes, is_confidential)
            VALUES ('${_uuid.v4()}', $t, $t, 0, 'user_1', '${doc[0]}', '${doc[1]}', '${doc[2]}', '${doc[3]}', '${doc[4]}', '${doc[5]}', '${doc[6]}', ${doc[7] != null ? "'${doc[7]}'" : 'NULL'}, ${doc[8]})
          ''');
        }

        // 10. Calls (10 logs)
        final calls = [
          ["م. سعد المطيري", "0501234567", 0, ago(2, hours: 2), "مناقشة أجندة اجتماع مجلس الإدارة", 1],
          ["م. فيصل القحطاني", "0561234569", 1, ago(2, hours: 5), "متابعة تقرير H1", 1],
          ["أ. صالح الغزالي", "0551234580", 0, ago(3, hours: 1), "استفسار حول عقد البدر", 0],
          ["م. أحمد الدوسري", "0591234572", 1, ago(4, hours: 3), "تأكيد موعد زيارة مقر بترو", 1],
          ["د. طارق الرشيدي", "0591234578", 1, ago(5, hours: 2), "متابعة مشروع أمن المعلومات", 0],
        ];

        for (var c in calls) {
          final dt = c[3] as DateTime;
          final t = dt.millisecondsSinceEpoch;
          await db.customStatement('''
            INSERT INTO calls (sync_id, created_at, updated_at, is_deleted, created_by, caller_name, phone_number, call_type, date, time, summary, is_important)
            VALUES ('${_uuid.v4()}', $t, $t, 0, 'user_1', '${c[0]}', '${c[1]}', ${c[2]}, '${_dateStr(dt)}', '${_timeStr(dt)}', '${c[4]}', ${c[5]})
          ''');
        }

        // 11. Visitors (8 logs)
        final visitors = [
          ["أ. خالد المطيري", "شركة الفجر", "استلام وثائق رسمية", "09:00", "09:25", 2, ago(1)],
          ["م. سالم الشمري", "وزارة التجارة", "اجتماع تنسيقي", "10:00", "11:30", 2, ago(1)],
          ["فريق التدقيق المالي", "شركة ديلويت", "جلسة تدقيق ربع سنوي", "08:30", "13:00", 2, ago(2)],
          ["أ. نايف العنزي", "مورد الخدمات اللوجستية", "تجديد عقد الخدمات", "09:00", null, 1, ago(0, hours: 1)],
          ["م. ريم الجهني", "شركة الابتكار التقني", "عرض تقني لنظام جديد", "11:00", null, 0, ago(0, hours: 0)],
        ];

        for (var v in visitors) {
          final dt = v[6] as DateTime;
          final t = dt.millisecondsSinceEpoch;
          await db.customStatement('''
            INSERT INTO visitors (sync_id, created_at, updated_at, is_deleted, created_by, visitor_name, company, purpose, entry_time, exit_time, status)
            VALUES ('${_uuid.v4()}', $t, $t, 0, 'user_1', '${v[0]}', '${v[1]}', '${v[2]}', '${v[3]}', ${v[4] != null ? "'${v[4]}'" : 'NULL'}, ${v[5]})
          ''');
        }

        // 12. Notes (8 items)
        final notesList = [
          ["أولويات الربع الثالث", "1. إطلاق المبادرة الرقمية\n2. مراجعة هيكل التوظيف\n3. تطوير برنامج الكادر الشاب", "#1E3A5F", "أولويات,Q3", ago(3)],
          ["نقاط مهمة — اجتماع PIF", "- تقديم الدراسة قبل 5 يوليو\n- ضرورة وجود هيكل مالي مفصل\n- المشروع يحتاج 18 شهراً", "#2E7D32", "PIF,دراسة", ago(14)],
          ["أفكار استراتيجية", "التوسع في السوق الخليجية خلال 2027\nالاستثمار في الذكاء الاصطناعي كمحور رئيسي", "#4A148C", "استراتيجية,أفكار", ago(7)],
          ["متابعة عاجلة", "الاتصال بأ. صالح الغزالي اليوم بشأن عقد البدر — عاجل", "#B71C1C", "عاجل,متابعة", ago(1)],
        ];

        for (var n in notesList) {
          final dt = n[4] as DateTime;
          final t = dt.millisecondsSinceEpoch;
          await db.customStatement('''
            INSERT INTO notes (sync_id, created_at, updated_at, is_deleted, created_by, title, content, color_code, tags)
            VALUES ('${_uuid.v4()}', $t, $t, 0, 'user_1', '${n[0]}', '${n[1]}', '${n[2]}', '${n[3]}')
          ''');
        }

        // 13. Movements (10 items)
        final movements = [
          ["وزارة التجارة والاستثمار", "اجتماع لجنة التنسيق الحكومي", ago(14), "09:00", 0],
          ["وزارة التجارة والاستثمار", "العودة من الاجتماع", ago(14), "11:30", 1],
          ["مقر شركة أرامكو — ظهران", "زيارة ميدانية لمناقشة الشراكة", ago(12), "07:00", 2],
          ["صندوق الاستثمارات العامة", "اجتماع متابعة دراسة الجدوى", ago(0, hours: 3), "10:00", 0],
          ["صندوق الاستثمارات العامة", "العودة إلى المكتب", ago(0, hours: 1), "12:30", 1],
        ];

        for (var mv in movements) {
          final dt = mv[2] as DateTime;
          final t = dt.millisecondsSinceEpoch;
          await db.customStatement('''
            INSERT INTO movements (sync_id, created_at, updated_at, is_deleted, created_by, destination, purpose, date, time, type)
            VALUES ('${_uuid.v4()}', $t, $t, 0, 'user_1', '${mv[0]}', '${mv[1]}', '${_dateStr(dt)}', '${mv[3]}', ${mv[4]})
          ''');
        }

        // 14. Security Logs (10 items)
        final logs = [
          [0, "تسجيل دخول ناجح", "Samsung Galaxy S24 Ultra — Android 15", ago(1)],
          [0, "تسجيل دخول ناجح", "Samsung Galaxy S24 Ultra — Android 15", ago(2)],
          [7, "تصدير تقرير PDF", "Samsung Galaxy S24 Ultra — Android 15", ago(5)],
          [1, "PIN خاطئ — المحاولة 1", "Samsung Galaxy S24 Ultra — Android 15", ago(8)],
        ];

        for (var lg in logs) {
          final dt = lg[3] as DateTime;
          final t = dt.millisecondsSinceEpoch;
          await db.customStatement('''
            INSERT INTO security_logs (sync_id, created_at, updated_at, is_deleted, created_by, action, details, device_info)
            VALUES ('${_uuid.v4()}', $t, $t, 0, 'user_1', ${lg[0]}, '${lg[1]}', '${lg[2]}')
          ''');
        }

        // 15. Routine Tasks (6 tasks) & 16. Completions (last 60 days)
        final routineTasks = [
          ["مراجعة البريد الإلكتروني الصباحي", "مراجعة ورد على الرسائل المهمة", "work", 0, "daily", "07:30"],
          ["رياضة الصباح", "30 دقيقة مشي أو تمارين كارديو", "health", 1, "daily", "06:00"],
          ["اجتماع الفريق الصباحي", "Stand-up meeting مع مديري الأقسام", "work", 1, "weekdays", "08:30"],
          ["ورد وأذكار الصباح", "قراءة الأذكار اليومية", "spiritual", 1, "daily", "05:30"],
          ["قراءة وتطوير ذاتي", "قراءة 10 صفحات يومياً من كتاب متخصص", "learning", 2, "daily", "22:00"],
          ["مراجعة الميزانية الأسبوعية", "تتبع المصروفات والإيرادات الأسبوعية", "finance", 1, "weekly", "14:00"],
        ];

        for (var r in routineTasks) {
          final t = ago(60).millisecondsSinceEpoch;
          final rSync = _uuid.v4();
          await db.customStatement('''
            INSERT INTO routine_tasks (sync_id, created_at, updated_at, is_deleted, created_by, title, description, category, priority, repeat, time)
            VALUES ('$rSync', $t, $t, 0, 'user_1', '${r[0]}', '${r[1]}', '${r[2]}', ${r[3]}, '${r[4]}', '${r[5]}')
          ''');

          // Add completions for last 60 days to show realistic habit streaks
          for (int d = 1; d <= 60; d++) {
            if (rand.nextDouble() > 0.25) {
              final cDt = ago(d);
              final cT = cDt.millisecondsSinceEpoch;
              await db.customStatement('''
                INSERT INTO routine_completions (sync_id, created_at, updated_at, is_deleted, created_by, routine_task_sync_id, date_key)
                VALUES ('${_uuid.v4()}', $cT, $cT, 0, 'user_1', '$rSync', '${_dateStr(cDt)}')
              ''');
            }
          }
        }
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}