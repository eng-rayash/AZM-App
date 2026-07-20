"""
مُدير — Demo SQLite Database Generator
======================================
يُنشئ قاعدة بيانات تجريبية واقعية لتطبيق "مُدير"
تبدو كأنها مستخدمة منذ 4 أشهر
لا تحتوي على أي بيانات حقيقية
"""

import sqlite3
import uuid
import time
import datetime
import json
import hashlib
import random
import os

# ── المسار الهدف ──────────────────────────────────────────────────────────
OUTPUT_PATH = r"f:\Mudiri\Mudiri\assets\mudiri_demo.sqlite"

# ── وقت "الآن" للبيانات ─────────────────────────────────────────────────────
NOW = datetime.datetime(2026, 6, 27, 20, 30, 0)
FOUR_MONTHS_AGO = NOW - datetime.timedelta(days=120)

def ms(dt: datetime.datetime) -> int:
    """تحويل datetime إلى Unix milliseconds"""
    return int(dt.timestamp() * 1000)

def ago(days=0, hours=0, minutes=0) -> datetime.datetime:
    return NOW - datetime.timedelta(days=days, hours=hours, minutes=minutes)

def future(days=0, hours=0) -> datetime.datetime:
    return NOW + datetime.timedelta(days=days, hours=hours)

def uid() -> str:
    return str(uuid.uuid4())

def date_str(dt: datetime.datetime) -> str:
    return dt.strftime("%Y-%m-%d")

def time_str(dt: datetime.datetime) -> str:
    return dt.strftime("%H:%M")

def pin_hash(pin: str) -> str:
    """تشفير PIN مثل ما يفعله التطبيق"""
    return hashlib.sha256(pin.encode()).hexdigest()

# ═══════════════════════════════════════════════════════════════════════════
# إنشاء قاعدة البيانات
# ═══════════════════════════════════════════════════════════════════════════

def create_database():
    os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
    
    if os.path.exists(OUTPUT_PATH):
        os.remove(OUTPUT_PATH)
    
    conn = sqlite3.connect(OUTPUT_PATH)
    cur = conn.cursor()
    
    # تفعيل Foreign Keys
    cur.execute("PRAGMA foreign_keys = ON")
    cur.execute("PRAGMA journal_mode = WAL")
    cur.execute("PRAGMA user_version = 5")  # schemaVersion = 5
    
    # ────────────────────────────────────────────────────────────────────
    # إنشاء الجداول
    # ────────────────────────────────────────────────────────────────────
    
    cur.executescript("""
    -- USERS
    CREATE TABLE IF NOT EXISTS users (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        sync_id     TEXT    NOT NULL,
        created_at  INTEGER NOT NULL,
        updated_at  INTEGER NOT NULL,
        is_deleted  INTEGER NOT NULL DEFAULT 0,
        created_by  TEXT,
        display_name        TEXT NOT NULL,
        pin_hash            TEXT,
        auth_method         INTEGER NOT NULL DEFAULT 0,
        is_biometric_enabled INTEGER NOT NULL DEFAULT 0,
        role                INTEGER NOT NULL DEFAULT 0,
        avatar_path         TEXT
    );

    -- MEETINGS
    CREATE TABLE IF NOT EXISTS meetings (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        sync_id     TEXT    NOT NULL,
        created_at  INTEGER NOT NULL,
        updated_at  INTEGER NOT NULL,
        is_deleted  INTEGER NOT NULL DEFAULT 0,
        created_by  TEXT,
        title               TEXT NOT NULL,
        meeting_type        INTEGER NOT NULL DEFAULT 0,
        date                TEXT NOT NULL,
        time                TEXT NOT NULL,
        end_time            TEXT,
        location            TEXT,
        objective           TEXT,
        agenda              TEXT,
        decisions           TEXT,
        outcomes            TEXT,
        attendees           TEXT,
        attachments         TEXT,
        status              INTEGER NOT NULL DEFAULT 0,
        priority            INTEGER NOT NULL DEFAULT 2,
        notes               TEXT,
        minutes             TEXT,
        recurrence_rule     TEXT,
        custom_meeting_type TEXT
    );

    -- TASKS
    CREATE TABLE IF NOT EXISTS tasks (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        sync_id     TEXT    NOT NULL,
        created_at  INTEGER NOT NULL,
        updated_at  INTEGER NOT NULL,
        is_deleted  INTEGER NOT NULL DEFAULT 0,
        created_by  TEXT,
        title               TEXT NOT NULL,
        description         TEXT,
        due_date            TEXT,
        assigned_to         TEXT,
        priority            INTEGER NOT NULL DEFAULT 2,
        status              INTEGER NOT NULL DEFAULT 0,
        linked_meeting_id   INTEGER
    );

    -- FOLLOW_UPS
    CREATE TABLE IF NOT EXISTS follow_ups (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        sync_id     TEXT    NOT NULL,
        created_at  INTEGER NOT NULL,
        updated_at  INTEGER NOT NULL,
        is_deleted  INTEGER NOT NULL DEFAULT 0,
        created_by  TEXT,
        title               TEXT NOT NULL,
        notes               TEXT,
        target_date         TEXT,
        entity_type         INTEGER NOT NULL DEFAULT 0,
        entity_id           INTEGER,
        priority            INTEGER NOT NULL DEFAULT 2,
        status              INTEGER NOT NULL DEFAULT 0,
        assigned_to         TEXT
    );

    -- DIRECTIVES
    CREATE TABLE IF NOT EXISTS directives (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        sync_id     TEXT    NOT NULL,
        created_at  INTEGER NOT NULL,
        updated_at  INTEGER NOT NULL,
        is_deleted  INTEGER NOT NULL DEFAULT 0,
        created_by  TEXT,
        title               TEXT NOT NULL,
        details             TEXT,
        source              TEXT,
        assigned_to         TEXT,
        deadline            TEXT,
        priority            INTEGER NOT NULL DEFAULT 1,
        status              INTEGER NOT NULL DEFAULT 0
    );

    -- CONTACTS
    CREATE TABLE IF NOT EXISTS contacts (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        sync_id     TEXT    NOT NULL,
        created_at  INTEGER NOT NULL,
        updated_at  INTEGER NOT NULL,
        is_deleted  INTEGER NOT NULL DEFAULT 0,
        created_by  TEXT,
        name                TEXT NOT NULL,
        position            TEXT,
        company             TEXT,
        phone_number        TEXT,
        email               TEXT,
        is_vip              INTEGER NOT NULL DEFAULT 0,
        notes               TEXT
    );

    -- APPOINTMENTS
    CREATE TABLE IF NOT EXISTS appointments (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        sync_id     TEXT    NOT NULL,
        created_at  INTEGER NOT NULL,
        updated_at  INTEGER NOT NULL,
        is_deleted  INTEGER NOT NULL DEFAULT 0,
        created_by  TEXT,
        title               TEXT NOT NULL,
        contact_id          INTEGER,
        date                TEXT NOT NULL,
        time                TEXT NOT NULL,
        duration_minutes    INTEGER NOT NULL DEFAULT 30,
        location            TEXT,
        status              INTEGER NOT NULL DEFAULT 0
    );

    -- ARCHIVE
    CREATE TABLE IF NOT EXISTS archive (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        sync_id     TEXT    NOT NULL,
        created_at  INTEGER NOT NULL,
        updated_at  INTEGER NOT NULL,
        is_deleted  INTEGER NOT NULL DEFAULT 0,
        created_by  TEXT,
        title               TEXT NOT NULL,
        reference_number    TEXT,
        hijri_date          TEXT,
        document_date       TEXT,
        directed_entity     TEXT,
        category            TEXT,
        local_file_path     TEXT,
        tags                TEXT,
        notes               TEXT,
        is_confidential     INTEGER NOT NULL DEFAULT 0
    );

    -- SECURITY_LOGS
    CREATE TABLE IF NOT EXISTS security_logs (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        sync_id     TEXT    NOT NULL,
        created_at  INTEGER NOT NULL,
        updated_at  INTEGER NOT NULL,
        is_deleted  INTEGER NOT NULL DEFAULT 0,
        created_by  TEXT,
        action              INTEGER NOT NULL,
        details             TEXT,
        device_info         TEXT,
        ip_address          TEXT
    );

    -- APP_SETTINGS
    CREATE TABLE IF NOT EXISTS app_settings (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        sync_id     TEXT    NOT NULL,
        created_at  INTEGER NOT NULL,
        updated_at  INTEGER NOT NULL,
        is_deleted  INTEGER NOT NULL DEFAULT 0,
        created_by  TEXT,
        key                 TEXT NOT NULL UNIQUE,
        value               TEXT NOT NULL,
        category            TEXT
    );

    -- CALLS
    CREATE TABLE IF NOT EXISTS calls (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        sync_id     TEXT    NOT NULL,
        created_at  INTEGER NOT NULL,
        updated_at  INTEGER NOT NULL,
        is_deleted  INTEGER NOT NULL DEFAULT 0,
        created_by  TEXT,
        caller_name         TEXT NOT NULL,
        phone_number        TEXT,
        call_type           INTEGER NOT NULL DEFAULT 0,
        date                TEXT NOT NULL,
        time                TEXT NOT NULL,
        summary             TEXT,
        is_important        INTEGER NOT NULL DEFAULT 0
    );

    -- VISITORS
    CREATE TABLE IF NOT EXISTS visitors (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        sync_id     TEXT    NOT NULL,
        created_at  INTEGER NOT NULL,
        updated_at  INTEGER NOT NULL,
        is_deleted  INTEGER NOT NULL DEFAULT 0,
        created_by  TEXT,
        visitor_name        TEXT NOT NULL,
        company             TEXT,
        purpose             TEXT,
        appointment_id      TEXT,
        entry_time          TEXT,
        exit_time           TEXT,
        status              INTEGER NOT NULL DEFAULT 0
    );

    -- NOTES
    CREATE TABLE IF NOT EXISTS notes (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        sync_id     TEXT    NOT NULL,
        created_at  INTEGER NOT NULL,
        updated_at  INTEGER NOT NULL,
        is_deleted  INTEGER NOT NULL DEFAULT 0,
        created_by  TEXT,
        title               TEXT,
        content             TEXT NOT NULL,
        color_code          TEXT,
        tags                TEXT
    );

    -- MOVEMENTS
    CREATE TABLE IF NOT EXISTS movements (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        sync_id     TEXT    NOT NULL,
        created_at  INTEGER NOT NULL,
        updated_at  INTEGER NOT NULL,
        is_deleted  INTEGER NOT NULL DEFAULT 0,
        created_by  TEXT,
        destination         TEXT NOT NULL,
        purpose             TEXT,
        date                TEXT NOT NULL,
        time                TEXT NOT NULL,
        type                INTEGER NOT NULL DEFAULT 0,
        notes               TEXT
    );

    -- ROUTINE_TASKS
    CREATE TABLE IF NOT EXISTS routine_tasks (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        sync_id     TEXT    NOT NULL,
        created_at  INTEGER NOT NULL,
        updated_at  INTEGER NOT NULL,
        is_deleted  INTEGER NOT NULL DEFAULT 0,
        created_by  TEXT,
        title               TEXT NOT NULL,
        description         TEXT,
        category            TEXT NOT NULL DEFAULT 'personal',
        priority            INTEGER NOT NULL DEFAULT 2,
        repeat              TEXT NOT NULL DEFAULT 'daily',
        time                TEXT,
        days_of_week        TEXT NOT NULL DEFAULT '[]',
        is_active           INTEGER NOT NULL DEFAULT 1
    );

    -- ROUTINE_COMPLETIONS
    CREATE TABLE IF NOT EXISTS routine_completions (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        sync_id     TEXT    NOT NULL,
        created_at  INTEGER NOT NULL,
        updated_at  INTEGER NOT NULL,
        is_deleted  INTEGER NOT NULL DEFAULT 0,
        created_by  TEXT,
        routine_task_sync_id TEXT NOT NULL,
        date_key            TEXT NOT NULL
    );
    """)

    # ════════════════════════════════════════════════════════════════════
    # 1. المستخدم
    # ════════════════════════════════════════════════════════════════════
    created = ms(ago(days=120))
    cur.execute("""INSERT INTO users VALUES 
        (1, ?, ?, ?, 0, NULL, 'م. خالد العتيبي', ?, 1, 1, 0, NULL)""",
        (uid(), created, created, pin_hash("1234")))

    # ════════════════════════════════════════════════════════════════════
    # 2. الإعدادات
    # ════════════════════════════════════════════════════════════════════
    settings = [
        ("theme_mode", "dark", "appearance"),
        ("language", "ar", "general"),
        ("app_version", "1.5.0", "system"),
        ("first_run_done", "true", "system"),
        ("notification_enabled", "true", "notifications"),
        ("auto_lock_minutes", "5", "security"),
        ("dashboard_period", "day", "dashboard"),
        ("font_size", "medium", "appearance"),
        ("calendar_type", "both", "calendar"),
        ("export_format", "pdf", "export"),
    ]
    for k, v, cat in settings:
        t = ms(ago(days=random.randint(90, 120)))
        cur.execute("INSERT INTO app_settings VALUES (NULL,?,?,?,0,NULL,?,?,?)",
                    (uid(), t, t, k, v, cat))

    # ════════════════════════════════════════════════════════════════════
    # 3. جهات الاتصال (25 جهة)
    # ════════════════════════════════════════════════════════════════════
    contacts_data = [
        # (الاسم، المنصب، الشركة، الهاتف، الإيميل، VIP، ملاحظة)
        ("م. سعد المطيري",        "مدير عام",            "شركة الخليج للطاقة",          "0501234567", "saad@gulf-energy.sa",        1, "شريك استراتيجي مهم"),
        ("د. نورة الغامدي",        "مديرة الموارد البشرية","مجموعة رواد للاستثمار",        "0551234568", "noura@rawad.com",            1, "اجتماع ربع سنوي"),
        ("م. فيصل القحطاني",      "مستشار مالي",          "بنك الرياض",                   "0561234569", "faisal@rib.com",             1, "مراجعة سنوية في يوليو"),
        ("أ. عبدالله الشمري",      "مدير المشاريع",        "مجموعة التميم للمقاولات",      "0571234570", "abdallah@tamim.sa",          0, None),
        ("د. هند الزهراني",        "استشارية إدارية",      "مستقلة",                       "0581234571", "hind.z@consulting.sa",       0, "خبرة في التحول الرقمي"),
        ("م. أحمد الدوسري",       "نائب الرئيس",          "شركة بترو العربية",            "0591234572", "ahmed.d@petroarabia.com",    1, "اجتماع شهري"),
        ("أ. محمد السعيد",         "مدير التسويق",         "شركة البيان للإعلام",          "0501234573", "m.alsaeed@bayan.sa",         0, None),
        ("د. علي الحربي",          "رئيس مجلس الإدارة",   "مجموعة الحربي القابضة",        "0551234574", "ali.harbi@harbigroup.com",   1, "VIP — التواصل مسبقاً"),
        ("أ. ريم العسيري",         "مديرة التطوير",        "شركة الرؤية التقنية",          "0561234575", "reem.a@vision-tech.sa",      0, None),
        ("م. يوسف المالكي",        "مهندس البنية التحتية", "وزارة الاتصالات",              "0571234576", "y.malki@mcit.gov.sa",        0, "تنسيق مشروع الربط"),
        ("أ. سارة العجلان",        "مديرة العلاقات العامة","شركة الفجر للتطوير",          "0581234577", "sara.a@alfajr.sa",           0, None),
        ("د. طارق الرشيدي",        "مدير التقنية",         "شركة سايبر العربية",           "0591234578", "tariq.r@cyber-arab.sa",      0, "خبير أمن معلومات"),
        ("م. لطيفة الصباح",        "مديرة الفروع",         "بنك الإمارات دبي الوطني",      "0501234579", "lateefa@enbd.ae",            1, "علاقة بنكية استراتيجية"),
        ("أ. صالح الغزالي",        "مستشار قانوني",        "مكتب الغزالي للمحاماة",        "0551234580", "saleh@alghazali-law.sa",     0, None),
        ("م. بدر الرفاعي",         "مدير المبيعات",        "شركة البدر للتوزيع",           "0561234581", "badr@albadrdist.sa",         0, None),
        ("د. ميسون الحمدان",       "باحثة اقتصادية",       "مركز جدوى للأبحاث",           "0571234582", "meison@jadwa.com",           0, None),
        ("أ. إبراهيم الخضيري",     "مدير المحفظة",         "صندوق الاستثمارات العامة",     "0581234583", "i.khodairi@pif.gov.sa",      1, "شراكة رؤية 2030"),
        ("م. نادية السلطاني",      "مهندسة مشاريع",        "أرامكو السعودية",              "0591234584", "n.sultani@aramco.com",       1, None),
        ("أ. حمد الرويلي",         "مدير المشتريات",        "شركة المنارة الصناعية",        "0501234585", "hamad.r@almanara.sa",        0, None),
        ("د. عمر عسيري",           "استشاري طبي",          "مستشفى المملكة",               "0551234586", "omar.a@kingdomhospital.com", 0, "الفحوصات السنوية"),
        ("م. لولوة الكواري",        "مديرة شراكات خليجية", "مجموعة القطرية",               "0561234587", "lulwa.k@qatarigroup.com",    1, "اجتماع خليجي شهري"),
        ("أ. غازي التميمي",        "مدير الجودة",           "هيئة الجودة والاعتماد",        "0571234588", "ghazi.t@ncbe.gov.sa",        0, None),
        ("م. حصة العتيبي",         "مديرة الابتكار",       "شركة موج للتقنية",              "0581234589", "hessa.a@mawj.sa",            0, "مشروع الذكاء الاصطناعي"),
        ("د. وليد الجفري",         "أستاذ جامعي",           "جامعة الملك عبدالعزيز",        "0591234590", "w.jafri@kau.edu.sa",         0, None),
        ("أ. منال الحميدان",       "مديرة المجتمع",         "جمعية رواد الأعمال",           "0501234591", "manal.h@rewad.org",          0, None),
    ]
    contact_ids = []
    for i, (name, pos, comp, phone, email, vip, note) in enumerate(contacts_data, 1):
        t = ms(ago(days=random.randint(20, 115)))
        cur.execute("""INSERT INTO contacts VALUES 
            (NULL,?,?,?,0,NULL,?,?,?,?,?,?,?)""",
            (uid(), t, t, name, pos, comp, phone, email, vip, note))
        contact_ids.append(cur.lastrowid)

    # ════════════════════════════════════════════════════════════════════
    # 4. الاجتماعات (30 اجتماع — ماضية ومستقبلية)
    # ════════════════════════════════════════════════════════════════════
    # meetingType: 0=عام, 1=إداري, 2=طارئ, 3=مجلس إدارة, 4=تقني
    # status: 0=مجدوَل, 1=جارٍ, 2=منتهٍ, 3=مؤجَّل, 4=مُلغى
    # priority: 0=حرجة, 1=عالية, 2=متوسطة, 3=منخفضة

    meetings_data = [
        # ماضية — منتهية (status=2)
        {
            "title": "اجتماع مجلس الإدارة الربع سنوي",
            "type": 3, "days_ago": 105, "hour": 9, "end_hour": 12,
            "location": "قاعة الاجتماعات الرئيسية - الطابق 12",
            "objective": "مراجعة أداء الربع الأول وتحديد توجهات الربع الثاني",
            "agenda": json.dumps(["مراجعة تقرير الأداء المالي", "مناقشة المشاريع الاستراتيجية", "خطة التوسع الجغرافي", "تقييم الأداء التشغيلي"], ensure_ascii=False),
            "decisions": json.dumps(["الموافقة على ميزانية التوسع", "تكليف الإدارة المالية بإعداد تقرير تفصيلي", "تأجيل مشروع الفرع الجديد للربع الثالث"], ensure_ascii=False),
            "attendees": json.dumps([{"name":"م. سعد المطيري","role":"رئيس مجلس الإدارة"},{"name":"د. علي الحربي","role":"عضو"},{"name":"م. فيصل القحطاني","role":"المستشار المالي"}], ensure_ascii=False),
            "status": 2, "priority": 0,
            "minutes": "انعقد الاجتماع في تمام الساعة التاسعة صباحاً برئاسة م. سعد المطيري. تمت مراجعة تقرير الأداء وأجمع الأعضاء على أن الربع الأول حقق نمواً بنسبة 12% مقارنة بالعام السابق.",
        },
        {
            "title": "مراجعة التقرير المالي الشهري",
            "type": 1, "days_ago": 97, "hour": 10, "end_hour": 11,
            "location": "مكتب المدير المالي",
            "objective": "مراجعة إيرادات ومصروفات شهر مارس",
            "agenda": json.dumps(["تقرير الإيرادات", "تقرير المصروفات", "توقعات الربع الثاني"], ensure_ascii=False),
            "decisions": json.dumps(["خفض المصروفات التشغيلية 5%", "تسريع تحصيل الذمم المدينة"], ensure_ascii=False),
            "attendees": json.dumps([{"name":"م. فيصل القحطاني","role":"مدير مالي"},{"name":"أ. صالح الغزالي","role":"مستشار"}], ensure_ascii=False),
            "status": 2, "priority": 1,
            "minutes": None,
        },
        {
            "title": "ورشة التحول الرقمي",
            "type": 0, "days_ago": 90, "hour": 8, "end_hour": 14,
            "location": "فندق الريتز كارلتون — قاعة الياسمين",
            "objective": "وضع خارطة طريق التحول الرقمي للمنظمة",
            "agenda": json.dumps(["تقييم الوضع الراهن", "تحليل الفجوات", "تحديد الأولويات", "خطة التنفيذ"], ensure_ascii=False),
            "decisions": json.dumps(["إطلاق 3 مبادرات رقمية رئيسية", "تخصيص 15% من الميزانية للتقنية", "تعيين مدير تحول رقمي"], ensure_ascii=False),
            "attendees": json.dumps([{"name":"د. هند الزهراني","role":"مستشارة"},{"name":"م. حصة العتيبي","role":"مديرة الابتكار"},{"name":"د. طارق الرشيدي","role":"مدير التقنية"}], ensure_ascii=False),
            "status": 2, "priority": 1,
            "minutes": "ورشة عمل مكثفة لمدة 6 ساعات استعرضت فيها د. هند الزهراني أفضل الممارسات العالمية في التحول الرقمي.",
        },
        {
            "title": "اجتماع إطاري مع شركة بترو العربية",
            "type": 0, "days_ago": 82, "hour": 11, "end_hour": 12,
            "location": "مقر الشركة - الرياض",
            "objective": "مناقشة فرص الشراكة الاستراتيجية",
            "agenda": json.dumps(["عرض الفرص المشتركة", "تقييم الجدوى", "الإطار الزمني للتنفيذ"], ensure_ascii=False),
            "decisions": json.dumps(["الاتفاق مبدئياً على الشراكة", "تكليف الفرق القانونية بإعداد المسودة الأولية"], ensure_ascii=False),
            "attendees": json.dumps([{"name":"م. أحمد الدوسري","role":"نائب الرئيس"},{"name":"أ. صالح الغزالي","role":"مستشار قانوني"}], ensure_ascii=False),
            "status": 2, "priority": 1,
            "minutes": None,
        },
        {
            "title": "اجتماع الأداء الوظيفي — الإدارة التشغيلية",
            "type": 1, "days_ago": 75, "hour": 9, "end_hour": 10,
            "location": "قاعة 5 — الطابق السابع",
            "objective": "مراجعة مؤشرات الأداء الوظيفي للفريق",
            "agenda": json.dumps(["تقييم الأداء الفردي", "مناقشة التحديات", "خطط التطوير"], ensure_ascii=False),
            "decisions": json.dumps(["ترقية 3 موظفين", "إلزام الفريق بالتدريب التقني"], ensure_ascii=False),
            "attendees": json.dumps([{"name":"د. نورة الغامدي","role":"مديرة الموارد البشرية"}], ensure_ascii=False),
            "status": 2, "priority": 2,
            "minutes": None,
        },
        {
            "title": "اجتماع طارئ — أزمة سلسلة الإمداد",
            "type": 2, "days_ago": 65, "hour": 16, "end_hour": 18,
            "location": "غرفة العمليات",
            "objective": "التعامل مع انقطاع في سلسلة الإمداد وإيجاد حلول عاجلة",
            "agenda": json.dumps(["تقييم حجم الأزمة", "الحلول البديلة", "التواصل مع الموردين"], ensure_ascii=False),
            "decisions": json.dumps(["التعاقد مع مورد بديل مؤقت", "تعويض العملاء المتضررين", "مراجعة سياسة الموردين"], ensure_ascii=False),
            "attendees": json.dumps([{"name":"أ. عبدالله الشمري","role":"مدير المشاريع"},{"name":"أ. حمد الرويلي","role":"مدير المشتريات"}], ensure_ascii=False),
            "status": 2, "priority": 0,
            "minutes": "اجتماع طارئ استدعته أزمة انقطاع مفاجئ في الإمدادات. تم التعامل مع الموقف خلال 72 ساعة.",
        },
        {
            "title": "اجتماع الشراكة مع صندوق الاستثمارات العامة",
            "type": 0, "days_ago": 58, "hour": 10, "end_hour": 12,
            "location": "مقر صندوق الاستثمارات العامة",
            "objective": "عرض مشروع رؤية 2030 والحصول على دعم الصندوق",
            "agenda": json.dumps(["عرض المشروع", "مناقشة الجدوى المالية", "متطلبات الشراكة"], ensure_ascii=False),
            "decisions": json.dumps(["إرسال دراسة الجدوى خلال أسبوعين", "جلسة متابعة في أغسطس"], ensure_ascii=False),
            "attendees": json.dumps([{"name":"أ. إبراهيم الخضيري","role":"مدير المحفظة"},{"name":"م. فيصل القحطاني","role":"المستشار المالي"}], ensure_ascii=False),
            "status": 2, "priority": 0,
            "minutes": None,
        },
        {
            "title": "اجتماع مراجعة مشروع الربط التقني",
            "type": 4, "days_ago": 50, "hour": 14, "end_hour": 15,
            "location": "اجتماع مرئي عبر Teams",
            "objective": "متابعة تقدم مشروع الربط مع وزارة الاتصالات",
            "agenda": json.dumps(["تقرير التقدم", "العقبات التقنية", "الخطوات التالية"], ensure_ascii=False),
            "decisions": json.dumps(["تسريع تسليم مرحلة الاختبار", "اجتماع أسبوعي للمتابعة"], ensure_ascii=False),
            "attendees": json.dumps([{"name":"م. يوسف المالكي","role":"وزارة الاتصالات"},{"name":"د. طارق الرشيدي","role":"مدير التقنية"}], ensure_ascii=False),
            "status": 2, "priority": 1,
            "minutes": None,
        },
        {
            "title": "مراجعة الاتفاقية مع شركة الخليج للطاقة",
            "type": 0, "days_ago": 43, "hour": 11, "end_hour": 12,
            "location": "قاعة الاجتماعات B",
            "objective": "مراجعة بنود عقد التوريد",
            "agenda": json.dumps(["مراجعة البنود", "التعديلات المقترحة", "آلية الإقرار"], ensure_ascii=False),
            "decisions": json.dumps(["قبول التعديلات الجوهرية", "تحديد جلسة توقيع"], ensure_ascii=False),
            "attendees": json.dumps([{"name":"م. سعد المطيري","role":"المدير العام"},{"name":"أ. صالح الغزالي","role":"المستشار القانوني"}], ensure_ascii=False),
            "status": 2, "priority": 1,
            "minutes": None,
        },
        {
            "title": "اجتماع الخطة التشغيلية — مايو",
            "type": 1, "days_ago": 35, "hour": 9, "end_hour": 11,
            "location": "قاعة الاجتماعات الرئيسية",
            "objective": "وضع الخطة التشغيلية لشهر مايو",
            "agenda": json.dumps(["مراجعة أهداف أبريل", "أهداف مايو", "توزيع المهام", "المؤشرات المستهدفة"], ensure_ascii=False),
            "decisions": json.dumps(["زيادة هدف الإنتاجية 8%", "إطلاق حملة توعوية داخلية", "مراجعة اليوم 15 من كل شهر"], ensure_ascii=False),
            "attendees": json.dumps([{"name":"أ. عبدالله الشمري","role":"مدير المشاريع"},{"name":"أ. محمد السعيد","role":"مدير التسويق"},{"name":"د. نورة الغامدي","role":"موارد بشرية"}], ensure_ascii=False),
            "status": 2, "priority": 1,
            "minutes": "اجتماع منتج انتهى بقرارات عملية واضحة لرفع مستوى الأداء التشغيلي في مايو.",
        },
        {
            "title": "لقاء تعريفي مع الشركاء الخليجيين",
            "type": 0, "days_ago": 28, "hour": 14, "end_hour": 16,
            "location": "فندق ماريوت — قاعة D",
            "objective": "بناء علاقات شراكة مع المجموعة القطرية",
            "agenda": json.dumps(["التعريف بالمنظمتين", "فرص التعاون", "الإطار الزمني"], ensure_ascii=False),
            "decisions": json.dumps(["تبادل وثائق الشراكة", "زيارة ميدانية متبادلة في أغسطس"], ensure_ascii=False),
            "attendees": json.dumps([{"name":"م. لولوة الكواري","role":"مديرة شراكات"},{"name":"د. علي الحربي","role":"مجلس الإدارة"}], ensure_ascii=False),
            "status": 2, "priority": 2,
            "minutes": None,
        },
        {
            "title": "اجتماع مراجعة نظام مُدير",
            "type": 4, "days_ago": 20, "hour": 10, "end_hour": 11,
            "location": "مكتب المدير التنفيذي",
            "objective": "مراجعة أداء التطبيق وتقديم التحديثات الجديدة",
            "agenda": json.dumps(["استعراض المزايا الجديدة", "الملاحظات والتعديلات المطلوبة", "خطة التطوير القادمة"], ensure_ascii=False),
            "decisions": json.dumps(["الموافقة على إضافة وحدة التقارير التفصيلية", "طلب تحسين نظام الإشعارات"], ensure_ascii=False),
            "attendees": json.dumps([{"name":"م. حصة العتيبي","role":"مديرة الابتكار"},{"name":"د. طارق الرشيدي","role":"مدير التقنية"}], ensure_ascii=False),
            "status": 2, "priority": 2,
            "minutes": None,
        },
        {
            "title": "اجتماع متابعة دراسة الجدوى — PIF",
            "type": 1, "days_ago": 14, "hour": 11, "end_hour": 12,
            "location": "اجتماع مرئي",
            "objective": "متابعة تقديم دراسة الجدوى لصندوق الاستثمارات",
            "agenda": json.dumps(["تقرير تقدم الدراسة", "النقاط الخلافية", "الخطوات التالية"], ensure_ascii=False),
            "decisions": json.dumps(["تسليم الدراسة خلال 10 أيام", "تعديل هيكل العرض المالي"], ensure_ascii=False),
            "attendees": json.dumps([{"name":"م. فيصل القحطاني","role":"مستشار مالي"},{"name":"أ. صالح الغزالي","role":"مستشار قانوني"}], ensure_ascii=False),
            "status": 2, "priority": 1,
            "minutes": None,
        },
        {
            "title": "اجتماع اللجنة المالية الطارئ",
            "type": 2, "days_ago": 8, "hour": 15, "end_hour": 16,
            "location": "غرفة اللجان",
            "objective": "مناقشة تعديل الميزانية التشغيلية للنصف الثاني",
            "agenda": json.dumps(["عرض الوضع المالي الراهن", "مقترحات إعادة التوزيع", "الموافقة على التعديلات"], ensure_ascii=False),
            "decisions": json.dumps(["إعادة توزيع 10% من ميزانية التشغيل", "تجميد التوظيف لشهرين"], ensure_ascii=False),
            "attendees": json.dumps([{"name":"م. فيصل القحطاني","role":"مدير مالي"},{"name":"د. علي الحربي","role":"رئيس مجلس"}], ensure_ascii=False),
            "status": 2, "priority": 0,
            "minutes": None,
        },
        {
            "title": "اجتماع تقييم الموردين",
            "type": 1, "days_ago": 3, "hour": 10, "end_hour": 11,
            "location": "قاعة الاجتماعات A",
            "objective": "تقييم الموردين الجدد واختيار البديل الأنسب",
            "agenda": json.dumps(["عرض قوائم الموردين", "معايير التقييم", "اختيار أفضل 3 موردين"], ensure_ascii=False),
            "decisions": json.dumps(["اختيار 3 موردين مرشحين", "طلب عروض أسعار خلال أسبوع"], ensure_ascii=False),
            "attendees": json.dumps([{"name":"أ. حمد الرويلي","role":"مدير المشتريات"},{"name":"م. بدر الرفاعي","role":"مدير المبيعات"}], ensure_ascii=False),
            "status": 2, "priority": 2,
            "minutes": None,
        },
        # قادمة (status=0)
        {
            "title": "اجتماع مجلس الإدارة الربع سنوي — Q2",
            "type": 3, "days_ago": -7, "hour": 9, "end_hour": 12,
            "location": "قاعة الاجتماعات الرئيسية - الطابق 12",
            "objective": "مراجعة نتائج الربع الثاني واعتماد خطة النصف الثاني",
            "agenda": json.dumps(["تقرير الأداء المالي Q2", "مراجعة المبادرات الاستراتيجية", "خطة النصف الثاني", "قرارات الاستثمار"], ensure_ascii=False),
            "decisions": None,
            "attendees": json.dumps([{"name":"م. سعد المطيري","role":"رئيس مجلس"},{"name":"د. علي الحربي","role":"عضو"},{"name":"م. فيصل القحطاني","role":"مستشار مالي"},{"name":"أ. إبراهيم الخضيري","role":"ممثل PIF"}], ensure_ascii=False),
            "status": 0, "priority": 0,
            "minutes": None,
        },
        {
            "title": "مناقشة عقد الشراكة الاستراتيجية — بترو العربية",
            "type": 0, "days_ago": -10, "hour": 11, "end_hour": 13,
            "location": "مقر شركة بترو العربية",
            "objective": "مراجعة المسودة النهائية لعقد الشراكة",
            "agenda": json.dumps(["قراءة بنود العقد", "التعديلات النهائية", "تحديد موعد التوقيع"], ensure_ascii=False),
            "decisions": None,
            "attendees": json.dumps([{"name":"م. أحمد الدوسري","role":"نائب الرئيس"},{"name":"أ. صالح الغزالي","role":"مستشار قانوني"}], ensure_ascii=False),
            "status": 0, "priority": 1,
            "minutes": None,
        },
        {
            "title": "ورشة تقييم مؤشرات الأداء — H1 Review",
            "type": 1, "days_ago": -15, "hour": 8, "end_hour": 13,
            "location": "قاعة التدريب - الطابق 4",
            "objective": "مراجعة شاملة لمؤشرات الأداء للنصف الأول",
            "agenda": json.dumps(["نتائج الأقسام الرئيسية", "تحليل الفجوات", "خطة التصحيح", "اعتماد الأهداف H2"], ensure_ascii=False),
            "decisions": None,
            "attendees": json.dumps([{"name":"د. نورة الغامدي","role":"موارد بشرية"},{"name":"أ. عبدالله الشمري","role":"مشاريع"},{"name":"أ. محمد السعيد","role":"تسويق"}], ensure_ascii=False),
            "status": 0, "priority": 1,
            "minutes": None,
        },
        {
            "title": "اجتماع مع المجموعة القطرية — زيارة ميدانية",
            "type": 0, "days_ago": -32, "hour": 10, "end_hour": 15,
            "location": "الدوحة — مقر المجموعة القطرية",
            "objective": "زيارة ميدانية وتعزيز الشراكة الخليجية",
            "agenda": json.dumps(["جولة بالمرافق", "عروض تقديمية مشتركة", "توقيع مذكرة التفاهم"], ensure_ascii=False),
            "decisions": None,
            "attendees": json.dumps([{"name":"م. لولوة الكواري","role":"مضيفة"},{"name":"د. علي الحربي","role":"رئيس الوفد"}], ensure_ascii=False),
            "status": 0, "priority": 2,
            "minutes": None,
        },
    ]

    meeting_ids = {}
    for i, m in enumerate(meetings_data, 1):
        days = m["days_ago"]
        dt = ago(days=days) if days >= 0 else future(days=-days)
        t_created = ms(dt - datetime.timedelta(days=random.randint(3, 10)))
        t_updated = ms(dt - datetime.timedelta(hours=2)) if m["status"] == 2 else t_created
        
        cur.execute("""INSERT INTO meetings VALUES
            (NULL,?,?,?,0,'user_1',?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,NULL)""",
            (uid(), t_created, t_updated,
             m["title"], m["type"],
             date_str(dt), time_str(dt.replace(hour=m["hour"])),
             f"{m['end_hour']:02d}:00",
             m["location"], m["objective"],
             m["agenda"], m["decisions"], None,
             m["attendees"], None,
             m["status"], m["priority"],
             m.get("notes"),
             m.get("minutes")))
        meeting_ids[i] = cur.lastrowid

    # ════════════════════════════════════════════════════════════════════
    # 5. المهام (35 مهمة)
    # ════════════════════════════════════════════════════════════════════
    # priority: 0=حرجة, 1=عالية, 2=متوسطة, 3=منخفضة
    # status: 0=جديدة, 1=قيد التنفيذ, 3=منجزة, 4=متأخرة

    tasks_data = [
        # منجزة
        ("إعداد تقرير الأداء Q1",         "تجميع وتحليل مؤشرات الأداء للربع الأول",           ago(days=100), "م. فيصل القحطاني", 0, 3, 1),
        ("مراجعة عقد شركة الخليج",         "قراءة ومراجعة بنود العقد مع الفريق القانوني",      ago(days=95), "أ. صالح الغزالي",   1, 3, None),
        ("إعداد خطة التحول الرقمي",        "توثيق الخطة بناء على نتائج الورشة",                ago(days=85), "م. حصة العتيبي",    1, 3, None),
        ("مراجعة سياسة الموردين",           "تحديث سياسة اختيار وتقييم الموردين",               ago(days=80), "أ. حمد الرويلي",    2, 3, None),
        ("إعداد دراسة الجدوى — PIF",       "تجميع البيانات المالية وإعداد العرض التقديمي",     ago(days=75), "م. فيصل القحطاني", 0, 3, 7),
        ("تدريب الفريق على نظام مُدير",    "تنظيم جلسات تدريبية للفريق على التطبيق الجديد",   ago(days=70), "أ. ريم العسيري",    2, 3, None),
        ("إرسال تقارير الشهر لمجلس الإدارة","تجميع وإرسال تقارير أبريل",                       ago(days=65), "م. فيصل القحطاني", 1, 3, None),
        ("مراجعة أداء الموظفين — Q1",      "إجراء مراجعات الأداء مع مديري الأقسام",            ago(days=60), "د. نورة الغامدي",   1, 3, 5),
        ("التفاوض مع المورد البديل",        "التفاوض وإبرام عقد مع المورد الجديد",               ago(days=58), "أ. حمد الرويلي",    0, 3, None),
        ("إعداد تقرير أزمة سلسلة الإمداد", "توثيق الأزمة والدروس المستفادة",                   ago(days=55), "أ. عبدالله الشمري", 1, 3, 6),
        ("تحديث بوابة العملاء",             "مراجعة وتحديث واجهة بوابة الخدمات",                ago(days=50), "د. طارق الرشيدي",  2, 3, None),
        ("إعداد خطة التسويق — Q2",         "وضع خطة التسويق الرقمي للربع الثاني",              ago(days=45), "أ. محمد السعيد",    1, 3, None),
        ("مراجعة الميزانية التشغيلية",      "مراجعة الميزانية مع تقليص 5% في المصروفات",       ago(days=40), "م. فيصل القحطاني", 1, 3, None),
        ("إطلاق المبادرة الرقمية الأولى",   "إطلاق برنامج إدارة التوثيق الرقمي",               ago(days=35), "م. حصة العتيبي",    0, 3, None),
        ("تقديم دراسة الجدوى — PIF",       "تقديم الدراسة النهائية لصندوق الاستثمارات",        ago(days=12), "م. فيصل القحطاني", 0, 3, 13),
        # قيد التنفيذ
        ("تطوير مبادرة الذكاء الاصطناعي",  "بناء نموذج أولي لأتمتة العمليات باستخدام AI",     future(days=20), "م. حصة العتيبي",   0, 1, None),
        ("مراجعة عروض الموردين المرشحين",   "تقييم العروض الثلاثة المقدمة من الموردين",         future(days=5), "أ. حمد الرويلي",   1, 1, None),
        ("إعداد تقرير H1 للمجلس",          "إعداد عرض تقديمي شامل لنتائج النصف الأول",         future(days=8), "م. فيصل القحطاني", 0, 1, None),
        ("تحديث خطة إدارة المخاطر",         "مراجعة سنوية لخطة إدارة مخاطر المنظمة",           future(days=25), "أ. صالح الغزالي",  1, 1, None),
        ("تحضير أجندة اجتماع مجلس الإدارة","إعداد جدول الأعمال والوثائق الداعمة لاجتماع Q2",  future(days=3), "د. نورة الغامدي",  0, 1, 16),
        ("التفاوض على شروط عقد بترو العربية","مراجعة البنود الخلافية مع الفريق القانوني",       future(days=9), "أ. صالح الغزالي",  1, 1, 17),
        # جديدة
        ("متابعة مذكرة التفاهم الخليجية",   "إعداد وثيقة المذكرة مع المجموعة القطرية",         future(days=35), "أ. صالح الغزالي",  1, 0, 19),
        ("بحث أسواق التوسع الجديدة",        "إجراء دراسة بحثية لأسواق المنطقة الشمالية",       future(days=40), "د. ميسون الحمدان", 2, 0, None),
        ("تقييم برامج التدريب Q3",          "اختيار البرامج التدريبية للنصف الثاني",            future(days=45), "د. نورة الغامدي",  2, 0, None),
        ("مراجعة اشتراطات هيئة الجودة",    "الاطلاع على المتطلبات الجديدة والتأكد من الامتثال",future(days=30), "أ. غازي التميمي",  1, 0, None),
        ("تحديث استراتيجية التواصل الاجتماعي","وضع خطة محتوى لقنوات التواصل",                  future(days=20), "أ. محمد السعيد",   2, 0, None),
        ("إعداد دليل الموظف الجديد",         "تحديث الدليل ليشمل السياسات الجديدة",             future(days=50), "د. نورة الغامدي",  3, 0, None),
        # متأخرة
        ("إرسال ملاحظات عقد شركة البدر",   "مراجعة العقد وإرسال الملاحظات",                    ago(days=5), "أ. صالح الغزالي",   1, 4, None),
        ("إعداد تقرير الزيارات الميدانية",  "توثيق نتائج زيارات الموردين الأخيرة",              ago(days=3), "أ. عبدالله الشمري", 2, 4, None),
        ("متابعة استرداد الذمم المدينة",     "التواصل مع العملاء المتأخرين في السداد",           ago(days=2), "م. فيصل القحطاني", 0, 4, None),
    ]
    task_ids = {}
    for i, (title, desc, due, assigned, prio, status, meet_id) in enumerate(tasks_data, 1):
        t_created = ms(due - datetime.timedelta(days=random.randint(3, 12)))
        t_updated = ms(due - datetime.timedelta(hours=random.randint(1, 48))) if status in [3,4] else t_created
        cur.execute("""INSERT INTO tasks VALUES
            (NULL,?,?,?,0,'user_1',?,?,?,?,?,?,?)""",
            (uid(), t_created, t_updated,
             title, desc, date_str(due), assigned, prio, status,
             meeting_ids.get(meet_id) if meet_id else None))
        task_ids[i] = cur.lastrowid

    # ════════════════════════════════════════════════════════════════════
    # 6. المتابعات (20 متابعة)
    # ════════════════════════════════════════════════════════════════════
    followups_data = [
        ("متابعة قرار تعديل الميزانية التشغيلية", "التأكد من تنفيذ قرار خفض المصروفات 5%",     ago(days=38), 0, 0, "م. فيصل القحطاني", 3),
        ("متابعة تطبيق نتائج ورشة التحول الرقمي", "مراجعة خطة التنفيذ وقياس التقدم",           ago(days=30), 0, 1, "م. حصة العتيبي",    1),
        ("متابعة التفاوض مع المورد البديل",         "التحقق من توقيع العقد وبدء التسليم",         ago(days=25), 1, 0, "أ. حمد الرويلي",    3),
        ("متابعة برنامج تدريب الفريق",              "التحقق من إتمام جميع الموظفين للتدريب",       ago(days=20), 1, 0, "د. نورة الغامدي",   3),
        ("متابعة مذكرة التفاهم مع بترو العربية",   "التأكد من التقدم في صياغة العقد",             ago(days=15), 0, 0, "أ. صالح الغزالي",   1),
        ("متابعة تسليم مشروع الربط التقني",         "التحقق من استكمال مرحلة الاختبار",            ago(days=12), 0, 0, "د. طارق الرشيدي",  1),
        ("متابعة تقديم دراسة الجدوى لـ PIF",       "التأكد من استلام الصندوق للدراسة وملاحظاتهم", future(days=5), 1, 0, "م. فيصل القحطاني", 1),
        ("متابعة ترقية الموظفين المعتمدة",          "إتمام إجراءات الترقية والمستحقات",            future(days=8), 1, 0, "د. نورة الغامدي",   1),
        ("متابعة عروض الموردين المرشحين",           "الحصول على تأكيدات الأسعار النهائية",         future(days=10), 1, 0, "أ. حمد الرويلي",    1),
        ("متابعة قرار تجميد التوظيف",               "مراجعة الاستثناءات المطلوبة ورفعها للإدارة",  future(days=15), 0, 0, "د. نورة الغامدي",   2),
        ("متابعة تطبيق سياسة الموردين الجديدة",    "التحقق من التزام الأقسام بالسياسة",           future(days=20), 2, 0, "أ. حمد الرويلي",    2),
        ("متابعة إعداد تقرير H1",                  "مراجعة مسودة التقرير قبل تقديمه للمجلس",      future(days=7), 1, 0, "م. فيصل القحطاني", 0),
        ("متابعة تطبيق المبادرة الرقمية الأولى",    "قياس مؤشرات التبني والرضا",                   future(days=25), 2, 0, "م. حصة العتيبي",   0),
        ("متابعة عقد شركة البدر للتوزيع",           "إنهاء ملاحظات العقد والرد",                    future(days=3), 2, 0, "أ. صالح الغزالي",   0),
        ("متابعة استرداد الذمم المدينة",             "متابعة تحصيل الدفعات المتأخرة",               future(days=5), 2, 0, "م. فيصل القحطاني", 0),
        ("متابعة مؤشرات جودة الخدمة",               "قياس رضا العملاء ومؤشرات الأداء",             future(days=30), 2, 0, "أ. غازي التميمي",   0),
        ("متابعة أجندة اجتماع مجلس الإدارة",       "التأكد من توزيع الوثائق على الأعضاء",          future(days=5), 0, 0, "د. نورة الغامدي",   0),
        ("متابعة زيارة الدوحة",                     "ترتيب برنامج الزيارة والفندق",                  future(days=28), 0, 0, "أ. ريم العسيري",    0),
        ("متابعة نتائج مراجعة أداء الموظفين",       "تطبيق خطط التحسين المتفق عليها",              future(days=45), 1, 0, "د. نورة الغامدي",   0),
        ("متابعة اشتراطات هيئة الجودة",             "رفع خطة الامتثال للإدارة العليا",              future(days=35), 2, 0, "أ. غازي التميمي",   0),
    ]
    for title, notes, target, entity_type, entity_id, assigned, status in followups_data:
        t_created = ms(target - datetime.timedelta(days=random.randint(2, 8)))
        cur.execute("""INSERT INTO follow_ups VALUES
            (NULL,?,?,?,0,'user_1',?,?,?,?,?,?,?,?)""",
            (uid(), t_created, t_created,
             title, notes, date_str(target), entity_type, entity_id,
             1, status, assigned))

    # ════════════════════════════════════════════════════════════════════
    # 7. التوجيهات (15 توجيه)
    # ════════════════════════════════════════════════════════════════════
    directives_data = [
        ("رفع كفاءة عمليات سلسلة الإمداد",    "مراجعة شاملة لكافة عمليات الاستيراد والتخزين وإيجاد حلول تقليل التكلفة بنسبة 10%",         "المدير التنفيذي", "أ. حمد الرويلي",    ago(days=60), 0, 3),
        ("تبني نظام إدارة الوثائق الرقمي",     "الانتقال الكامل لنظام التوثيق الرقمي خلال 3 أشهر، مع تدريب جميع الموظفين",                "المدير التنفيذي", "م. حصة العتيبي",    ago(days=30), 1, 3),
        ("تحسين معدلات رضا العملاء",           "تطبيق برنامج قياس رضا العملاء وتحقيق نسبة 85% أو أكثر",                                    "مجلس الإدارة",   "أ. محمد السعيد",    future(days=45), 1, 1),
        ("مراجعة الهيكل التنظيمي",             "إعادة دراسة الهيكل التنظيمي لتحسين كفاءة التواصل وتقليل طبقات الإدارة",                   "مجلس الإدارة",   "د. نورة الغامدي",   future(days=60), 0, 0),
        ("تطوير برامج كادر الشباب",            "وضع وتنفيذ برنامج تطوير الكفاءات الشابة والقيادات الواعدة داخل المنظمة",                   "المدير التنفيذي", "د. نورة الغامدي",   future(days=90), 1, 1),
        ("تقليص المصروفات التشغيلية",          "تحديد بنود المصروفات القابلة للتخفيض وتطبيق قرار التوفير 5%",                               "اللجنة المالية", "م. فيصل القحطاني", ago(days=38), 1, 3),
        ("تعزيز الأمن السيبراني",              "تقييم نقاط الضعف في البنية التحتية وتطبيق معايير الأمن الموصى بها",                         "المدير التنفيذي", "د. طارق الرشيدي",  future(days=30), 0, 1),
        ("توطين 30% من الوظائف التقنية",       "وضع خطة توطين الوظائف التقنية بنسبة 30% خلال العام",                                       "مجلس الإدارة",   "د. نورة الغامدي",   future(days=180), 1, 1),
        ("تطوير الموقع الإلكتروني الرسمي",     "إعادة تصميم وتطوير الموقع وفق أحدث المعايير التقنية والتصميمية",                            "المدير التنفيذي", "أ. محمد السعيد",    future(days=45), 2, 1),
        ("تنفيذ برنامج المسؤولية الاجتماعية",  "إطلاق مبادرات اجتماعية تعكس التزام المنظمة بالمجتمع",                                       "مجلس الإدارة",   "م. لولوة الكواري",  future(days=120), 2, 0),
        ("إعداد تقرير الاستدامة السنوي",       "جمع البيانات وإعداد تقرير الاستدامة والممارسات البيئية",                                    "المدير التنفيذي", "أ. ريم العسيري",    future(days=90), 2, 0),
        ("ترقية أنظمة ERP",                    "تقييم خيارات ترقية أنظمة تخطيط الموارد المؤسسية واختيار المورد المناسب",                   "اللجنة التقنية", "د. طارق الرشيدي",  future(days=60), 1, 0),
        ("تسريع برنامج التحول الرقمي",         "مراجعة الجدول الزمني وتقليصه 20% مع الحفاظ على جودة التنفيذ",                               "مجلس الإدارة",   "م. حصة العتيبي",    future(days=30), 0, 1),
        ("تحديث لوائح الحوكمة الداخلية",       "مراجعة وتحديث لوائح الحوكمة لتتوافق مع التشريعات الجديدة",                                 "اللجنة القانونية", "أ. صالح الغزالي",  future(days=45), 1, 0),
        ("رفع تقرير الأداء الشهري في الموعد", "الالتزام بتقديم التقرير في اليوم الخامس من كل شهر دون تأخير",                               "المدير التنفيذي", "م. فيصل القحطاني", future(days=5), 1, 1),
    ]
    for title, details, src, assigned, deadline, prio, status in directives_data:
        t_created = ms(deadline - datetime.timedelta(days=random.randint(5, 15)))
        t_updated = ms(deadline - datetime.timedelta(days=random.randint(1, 4))) if status == 3 else t_created
        cur.execute("""INSERT INTO directives VALUES
            (NULL,?,?,?,0,'user_1',?,?,?,?,?,?,?)""",
            (uid(), t_created, t_updated,
             title, details, src, assigned, date_str(deadline), prio, status))

    # ════════════════════════════════════════════════════════════════════
    # 8. الأرشيف (25 وثيقة)
    # ════════════════════════════════════════════════════════════════════
    archive_data = [
        # (العنوان، الرقم، هجري، ميلادي، الجهة الموجهة، الفئة، الوسوم، ملاحظات، سري)
        ("عقد الشراكة الاستراتيجية — شركة الخليج للطاقة",   "صادر/2026/001", "1447/09/15", "2026-03-15", "شركة الخليج للطاقة",      "عقود وشراكات",   "عقد,شراكة,طاقة",       "تمت الموافقة عليه من المجلس",     0),
        ("محضر اجتماع مجلس الإدارة — Q1 2026",            "صادر/2026/002", "1447/09/20", "2026-03-20", "مجلس الإدارة",             "محاضر الاجتماعات","مجلس,اجتماع,Q1",       None,                               0),
        ("تقرير الأداء المالي — مارس 2026",               "داخلي/2026/015", "1447/09/25", "2026-03-25", "الإدارة العليا",          "تقارير مالية",    "مالي,أداء,مارس",        None,                               1),
        ("دراسة الجدوى الاقتصادية — مشروع التوسع",        "صادر/2026/003", "1447/10/01", "2026-04-01", "صندوق الاستثمارات العامة", "دراسات وأبحاث",   "جدوى,استثمار,PIF",     "تقديم رسمي للصندوق",              1),
        ("عروض أسعار الموردين — دورة 2026",               "وارد/2026/021",  "1447/10/10", "2026-04-10", "إدارة المشتريات",          "مشتريات",         "موردون,عروض",           None,                               0),
        ("مذكرة داخلية — تفعيل نظام التوثيق الرقمي",      "داخلي/2026/018", "1447/10/15", "2026-04-15", "جميع الأقسام",             "مذكرات إدارية",   "توجيه,رقمنة",           None,                               0),
        ("عقد تأهيل المورد البديل — حالة طارئة",          "صادر/2026/004", "1447/10/20", "2026-04-20", "مورد الإمدادات الجديد",    "عقود وشراكات",   "مورد,طارئ,عقد",        "بعد أزمة سلسلة الإمداد",          0),
        ("تقرير ورشة التحول الرقمي",                      "داخلي/2026/022", "1447/10/28", "2026-04-28", "الإدارة التنفيذية",        "تقارير وخطط",     "تحول,رقمي,ورشة",       None,                               0),
        ("خطاب شكر — شركة بترو العربية",                  "وارد/2026/030",  "1447/11/02", "2026-05-02", "المدير التنفيذي",          "مراسلات",         "شكر,علاقات",            None,                               0),
        ("تقرير مراجعة الأداء الوظيفي — H1",              "داخلي/2026/025", "1447/11/08", "2026-05-08", "الإدارة العليا",           "موارد بشرية",     "أداء,موظفون",           "سري — للإدارة فقط",               1),
        ("مذكرة تفاهم — مبدئية مع بترو العربية",          "صادر/2026/005", "1447/11/12", "2026-05-12", "شركة بترو العربية",        "عقود وشراكات",   "مذكرة,شراكة,بترو",     None,                               0),
        ("قرارات اجتماع اللجنة المالية — مايو",           "داخلي/2026/028", "1447/11/18", "2026-05-18", "الأقسام المعنية",          "محاضر الاجتماعات","لجنة,مالية,قرارات",    None,                               1),
        ("تقرير مشروع الربط التقني — وزارة الاتصالات",   "وارد/2026/038",  "1447/11/22", "2026-05-22", "وزارة الاتصالات",          "تقارير تقنية",    "تقنية,ربط,وزارة",      "تقدم المرحلة الثانية",             0),
        ("خطة التسويق الرقمي — Q2 2026",                  "داخلي/2026/031", "1447/11/28", "2026-05-28", "إدارة التسويق",            "خطط تسويقية",     "تسويق,رقمي,Q2",        None,                               0),
        ("محضر اجتماع تقييم الموردين",                    "داخلي/2026/035", "1447/12/02", "2026-06-02", "إدارة المشتريات",          "محاضر الاجتماعات","موردون,تقييم",          None,                               0),
        ("تقرير الأداء التشغيلي — مايو 2026",             "داخلي/2026/038", "1447/12/07", "2026-06-07", "الإدارة التنفيذية",        "تقارير تشغيلية",  "أداء,مايو,تشغيل",      None,                               0),
        ("خطاب رسمي — هيئة الجودة",                       "وارد/2026/045",  "1447/12/10", "2026-06-10", "المدير التنفيذي",          "مراسلات حكومية",  "جودة,هيئة,امتثال",     "يتطلب رد خلال 30 يوماً",          0),
        ("دليل السياسات والإجراءات — نسخة 2026",         "داخلي/2026/040", "1447/12/12", "2026-06-12", "جميع الموظفين",            "سياسات وإجراءات", "دليل,سياسات,إجراءات", "يسري اعتباراً من يوليو",           0),
        ("عروض الأسعار — استبدال معدات IT",               "وارد/2026/048",  "1447/12/15", "2026-06-15", "إدارة التقنية",            "تقنية معلومات",   "IT,معدات,عروض",        None,                               0),
        ("تقرير زيارة الشركاء الخليجيين",                 "داخلي/2026/042", "1447/12/18", "2026-06-18", "الإدارة العليا",           "علاقات دولية",    "خليج,شراكة,زيارة",     None,                               0),
        ("إشعار تجديد العقد — شركة الخليج",               "وارد/2026/050",  "1447/12/20", "2026-06-20", "إدارة العقود",             "عقود وشراكات",   "تجديد,عقد,طاقة",       "موعد التجديد: أغسطس",             0),
        ("خطة المخاطر التشغيلية — H2 2026",               "داخلي/2026/044", "1447/12/22", "2026-06-22", "لجنة إدارة المخاطر",       "خطط وسياسات",    "مخاطر,H2,خطة",         None,                               1),
        ("مقترح مشروع الذكاء الاصطناعي",                  "داخلي/2026/046", "1447/12/24", "2026-06-24", "مجلس الإدارة",             "مشاريع تقنية",    "AI,ذكاء,مقترح",        "بانتظار الموافقة",                0),
        ("تقرير رضا العملاء — Q1 2026",                   "داخلي/2026/048", "1447/12/25", "2026-06-25", "الإدارة التنفيذية",        "تقارير",          "رضا,عملاء,Q1",         None,                               0),
        ("محضر اجتماع الخطة التشغيلية — يونيو",          "داخلي/2026/049", "1447/12/26", "2026-06-26", "رؤساء الأقسام",            "محاضر الاجتماعات","خطة,تشغيل,يونيو",     None,                               0),
    ]
    for title, ref, hijri, greg, entity, cat, tags, notes, conf in archive_data:
        t_created = ms(datetime.datetime.strptime(greg, "%Y-%m-%d") - datetime.timedelta(hours=random.randint(1, 5)))
        cur.execute("""INSERT INTO archive VALUES
            (NULL,?,?,?,0,'user_1',?,?,?,?,?,?,NULL,?,?,?)""",
            (uid(), t_created, t_created,
             title, ref, hijri, greg, entity, cat, tags, notes, conf))

    # ════════════════════════════════════════════════════════════════════
    # 9. المواعيد (15 موعد)
    # ════════════════════════════════════════════════════════════════════
    appointments_data = [
        ("لقاء مع م. سعد المطيري لمتابعة الشراكة",    1, future(days=3),  "10:00", 60,  "مكتب المدير العام",    0),
        ("زيارة مقر شركة بترو العربية",                6, future(days=10), "11:00", 120, "مقر بترو العربية",     0),
        ("اجتماع ثنائي مع د. هند الزهراني",           5, future(days=2),  "14:00", 45,  "مكتب المستشارة",       0),
        ("مقابلة مرشح منصب مدير التحول الرقمي",       None, future(days=5), "09:00", 60, "غرفة المقابلات",       0),
        ("جلسة مراجعة مالية مع م. فيصل",              3, future(days=8),  "10:30", 90,  "مكتب المدير المالي",   0),
        ("زيارة هيئة الجودة",                         None, future(days=12), "09:00", 60, "مقر الهيئة",          0),
        ("متابعة مع د. طارق حول أمن المعلومات",       12, future(days=6), "15:00", 45,  "قاعة التقنية",         0),
        ("غداء عمل مع أ. إبراهيم الخضيري",            17, future(days=4), "13:00", 60,  "مطعم الديوان - الرياض",0),
        ("اجتماع تقني مع فريق مشروع AI",              None, future(days=7), "14:00", 90, "قاعة الابتكار",        0),
        ("مراجعة دراسة الجدوى مع م. فيصل",            3, future(days=1),  "11:00", 60,  "مكتب المدير المالي",   0),
        ("لقاء مع أ. صالح الغزالي — عقد البدر",      14, future(days=2), "16:00", 30,  "مكتب القانونية",       0),
        ("تفقد مشروع التوسع الميداني",                 None, future(days=18), "08:00", 180, "موقع المشروع",       0),
        ("جلسة مع د. نورة — مراجعة الهيكل التنظيمي", 2, future(days=14), "10:00", 90,  "قاعة الاجتماعات",      0),
        ("اجتماع مرئي — المجموعة القطرية",             21, future(days=9), "15:00", 60,  "Teams Online",         0),
        ("اجتماع تمهيدي لمجلس الإدارة Q2",            None, future(days=6), "09:00", 60, "غرفة مجلس الإدارة",   0),
    ]
    for title, contact_id, dt, time_s, dur, loc, status in appointments_data:
        t_created = ms(dt - datetime.timedelta(days=random.randint(2, 7)))
        contact_db_id = contact_ids[contact_id - 1] if contact_id else None
        cur.execute("""INSERT INTO appointments VALUES
            (NULL,?,?,?,0,'user_1',?,?,?,?,?,?,?)""",
            (uid(), t_created, t_created,
             title, contact_db_id, date_str(dt), time_s, dur, loc, status))

    # ════════════════════════════════════════════════════════════════════
    # 10. سجل المكالمات (25 مكالمة)
    # ════════════════════════════════════════════════════════════════════
    # callType: 0=وارد, 1=صادر, 2=فائت
    calls_data = [
        ("م. سعد المطيري",      "0501234567", 0, ago(days=2,  hours=2), "مناقشة أجندة اجتماع مجلس الإدارة", 1),
        ("م. فيصل القحطاني",   "0561234569", 1, ago(days=2,  hours=5), "متابعة تقرير H1",                  1),
        ("أ. صالح الغزالي",    "0551234580", 0, ago(days=3,  hours=1), "استفسار حول عقد البدر",             0),
        ("رقم غير محفوظ",      "0509876543", 2, ago(days=3,  hours=4), None,                               0),
        ("م. أحمد الدوسري",    "0591234572", 1, ago(days=4,  hours=3), "تأكيد موعد زيارة مقر بترو",        1),
        ("د. علي الحربي",       "0551234574", 0, ago(days=4,  hours=7), "طلب توضيح حول تقرير المخاطر",      1),
        ("د. طارق الرشيدي",    "0591234578", 1, ago(days=5,  hours=2), "متابعة مشروع أمن المعلومات",       0),
        ("أ. إبراهيم الخضيري", "0581234583", 0, ago(days=5,  hours=6), "تأكيد موعد غداء العمل",            1),
        ("م. لولوة الكواري",   "0561234587", 0, ago(days=6,  hours=1), "ترتيب اجتماع المجموعة القطرية",    0),
        ("أ. حمد الرويلي",     "0501234585", 1, ago(days=6,  hours=4), "استفسار عن عروض الموردين",         0),
        ("م. يوسف المالكي",    "0571234576", 0, ago(days=7,  hours=2), "تحديث حول مشروع الاتصالات",       0),
        ("د. نورة الغامدي",    "0551234568", 1, ago(days=7,  hours=5), "متابعة ترقية الموظفين",            0),
        ("م. حصة العتيبي",     "0581234589", 0, ago(days=8,  hours=1), "مناقشة نتائج ورشة التحول",        1),
        ("أ. غازي التميمي",    "0571234588", 2, ago(days=8,  hours=3), None,                               0),
        ("أ. محمد السعيد",     "0501234573", 1, ago(days=9,  hours=2), "مناقشة خطة التسويق Q3",           0),
        ("م. نادية السلطاني",  "0591234584", 0, ago(days=9,  hours=4), "استفسار تقني عن المشروع",          0),
        ("رقم غير معروف",      "0555000001", 2, ago(days=10, hours=1), None,                               0),
        ("د. هند الزهراني",    "0581234571", 1, ago(days=10, hours=3), "مناقشة نتائج التحول الرقمي",       1),
        ("م. بدر الرفاعي",     "0561234581", 0, ago(days=11, hours=2), "طلب تمديد العقد",                  0),
        ("أ. ريم العسيري",     "0561234575", 1, ago(days=12, hours=1), "تنسيق زيارة الدوحة",              0),
        ("م. سعد المطيري",     "0501234567", 0, ago(days=13, hours=2), "مشاورة قبل الاجتماع الطارئ",      1),
        ("أ. عبدالله الشمري",  "0571234570", 1, ago(days=14, hours=4), "متابعة تقرير أزمة الإمداد",       0),
        ("د. وليد الجفري",     "0591234590", 0, ago(days=15, hours=2), "استشارة بحثية",                   0),
        ("م. فيصل القحطاني",   "0561234569", 1, ago(days=16, hours=3), "تدقيق ميزانية Q2",               1),
        ("م. لطيفة الصباح",    "0501234579", 0, ago(days=17, hours=1), "متابعة القرض البنكي",             1),
    ]
    for caller, phone, ctype, dt, summary, important in calls_data:
        t = ms(dt)
        cur.execute("""INSERT INTO calls VALUES
            (NULL,?,?,?,0,'user_1',?,?,?,?,?,?,?)""",
            (uid(), t, t, caller, phone, ctype, date_str(dt), time_str(dt), summary, important))

    # ════════════════════════════════════════════════════════════════════
    # 11. سجل الزوار (15 زائر)
    # ════════════════════════════════════════════════════════════════════
    # status: 0=انتظار, 1=داخل, 2=انصرف
    visitors_data = [
        ("أ. خالد المطيري",     "شركة الفجر",             "استلام وثائق",             "09:00", "09:25", 2, ago(days=1)),
        ("م. سالم الشمري",      "وزارة التجارة",           "اجتماع تنسيقي",            "10:00", "11:30", 2, ago(days=1)),
        ("فريق التدقيق المالي", "شركة ديلويت",             "جلسة تدقيق ربع سنوي",     "08:30", "13:00", 2, ago(days=2)),
        ("أ. نورة العتيبي",     "هيئة الاتصالات",          "تقديم شكوى رسمية",         "11:00", "11:45", 2, ago(days=2)),
        ("م. طارق الشهري",     "شركة المنارة",             "متابعة عرض السعر",         "14:00", "14:40", 2, ago(days=3)),
        ("مندوب شركة SAP",      "SAP Middle East",        "عرض منتجات ERP",           "10:00", "12:00", 2, ago(days=4)),
        ("أ. فهد العمر",        "مجموعة الفنار القابضة",   "مناقشة فرص الاستثمار",     "09:30", "10:15", 2, ago(days=5)),
        ("د. سمر الحميدي",      "مستشفى الملك فيصل",      "تنسيق برامج الرعاية",      "13:00", "13:30", 2, ago(days=5)),
        ("م. عبدالرحمن اليامي", "هيئة الجودة",             "تفتيش دوري",               "09:00", "12:00", 2, ago(days=6)),
        ("أ. ليلى القحطاني",    "جامعة الأميرة نورة",     "بحث تعاوني",               "11:00", "11:50", 2, ago(days=7)),
        ("م. صالح الشريف",      "بنك الرياض",              "متابعة تسهيلات ائتمانية",  "14:30", "15:00", 2, ago(days=8)),
        ("ممثل وزارة الطاقة",   "وزارة الطاقة",            "لقاء تنسيقي",              "10:00", "11:00", 2, ago(days=9)),
        ("أ. نايف العنزي",      "مورد الخدمات اللوجستية",  "تجديد عقد الخدمات",       "09:00", None,    1, ago(days=0, hours=1)),
        ("م. ريم الجهني",       "شركة الابتكار التقني",    "عرض تقني لنظام جديد",     "11:00", None,    0, ago(days=0, hours=0)),
        ("فريق التدريب",        "أكاديمية سدير",           "ورشة مهارات إدارية",       "08:00", None,    1, ago(days=0, hours=2)),
    ]
    for name, comp, purpose, entry, exit_t, status, dt in visitors_data:
        t = ms(dt)
        cur.execute("""INSERT INTO visitors VALUES
            (NULL,?,?,?,0,'user_1',?,?,?,NULL,?,?,?)""",
            (uid(), t, t, name, comp, purpose, entry, exit_t, status))

    # ════════════════════════════════════════════════════════════════════
    # 12. الملاحظات (12 ملاحظة)
    # ════════════════════════════════════════════════════════════════════
    notes_data = [
        ("أولويات الربع الثالث",      "1. إطلاق المبادرة الرقمية\n2. مراجعة هيكل التوظيف\n3. تطوير برنامج الكادر الشاب",  "#1E3A5F", "أولويات,Q3",         ago(days=3)),
        ("نقاط مهمة — اجتماع PIF",    "- تقديم الدراسة قبل 5 يوليو\n- ضرورة وجود هيكل مالي مفصل\n- المشروع يحتاج 18 شهراً", "#2E7D32", "PIF,دراسة,ملاحظات",  ago(days=14)),
        ("أفكار استراتيجية",           "التوسع في السوق الخليجية خلال 2027\nالاستثمار في الذكاء الاصطناعي كمحور رئيسي",     "#4A148C", "استراتيجية,أفكار",   ago(days=7)),
        ("متابعة عاجلة",               "الاتصال بأ. صالح الغزالي اليوم بشأن عقد البدر — عاجل",                              "#B71C1C", "عاجل,متابعة",        ago(days=1)),
        ("قائمة القراءة",              "- كتاب: Good to Great\n- تقرير McKinsey عن التحول الرقمي\n- دراسة WEF للقيادة",      "#1565C0", "قراءة,تطوير",        ago(days=10)),
        ("مواعيد مهمة يوليو",          "5 يوليو: تقديم دراسة PIF\n8 يوليو: اجتماع مجلس الإدارة Q2\n15 يوليو: ورشة H1",    "#E65100", "يوليو,مواعيد",       ago(days=2)),
        ("تذكير: اشتراطات الجودة",     "الرد على خطاب هيئة الجودة قبل 10 يوليو — لا تنسَ",                                   "#4E342E", "جودة,تذكير,مهلة",    ago(days=0, hours=3)),
        ("أفكار لتطوير فريق العمل",    "برنامج مرشد (Mentor/Mentee)\nورش تطوير ذاتي شهرية\nرحلة بناء الفريق في يوليو",      "#006064", "فريق,تطوير,أفكار",   ago(days=5)),
        ("ملاحظات من ورشة التحول",    "د. هند: 70% من مشاريع التحول تفشل بسبب عامل البشر\nالحل: الإشراك المبكر والتدريب",  "#1A237E", "تحول,ورشة,تقنية",    ago(days=90)),
        ("خطة السفر — الدوحة",         "الرحلة: QR 108\nالفندق: ماريوت ويست باي\nالاجتماع: 10 صباحاً في مقر المجموعة",     "#37474F", "دوحة,سفر,خطة",       ago(days=1)),
        ("نقاط ضعف تحتاج معالجة",     "- بطء في تحصيل الذمم\n- ضعف التنسيق بين الأقسام\n- تأخر في تقارير الأداء",          "#880E4F", "تحسين,نقاط ضعف",     ago(days=4)),
        ("اقتباسات تحفيزية",           '"النجاح ليس مصادفة، إنه عمل جاد وتعلم مستمر وحب لما تفعل" — Colin Powell',           "#2E7D32", "تحفيز,اقتباس",       ago(days=20)),
    ]
    for title, content, color, tags, dt in notes_data:
        t = ms(dt)
        cur.execute("""INSERT INTO notes VALUES
            (NULL,?,?,?,0,'user_1',?,?,?,?)""",
            (uid(), t, t, title, content, color, tags))

    # ════════════════════════════════════════════════════════════════════
    # 13. التنقلات (20 حركة)
    # ════════════════════════════════════════════════════════════════════
    # type: 0=خروج, 1=عودة, 2=مهمة خارجية
    movements_data = [
        ("وزارة التجارة والاستثمار",   "اجتماع لجنة التنسيق الحكومي",      ago(days=14), "09:00", 0),
        ("وزارة التجارة والاستثمار",   "العودة من الاجتماع",                 ago(days=14), "11:30", 1),
        ("مقر شركة أرامكو — ظهران",   "زيارة ميدانية لمناقشة الشراكة",     ago(days=12), "07:00", 2),
        ("المطار الدولي — رحلة عمل",  "سفر إلى الدوحة لاجتماع الشركاء",    ago(days=10), "06:30", 0),
        ("مطار الملك خالد",            "عودة من رحلة الدوحة",               ago(days=8),  "18:00", 1),
        ("هيئة الاتصالات وتقنية المعلومات","متابعة مشروع الربط التقني",    ago(days=7),  "10:00", 0),
        ("هيئة الاتصالات",             "العودة إلى المكتب",                  ago(days=7),  "12:30", 1),
        ("مستشفى الملك فيصل التخصصي", "فحص دوري سنوي",                     ago(days=6),  "08:00", 0),
        ("مستشفى الملك فيصل",          "العودة",                             ago(days=6),  "10:00", 1),
        ("ديوان رئاسة مجلس الوزراء",   "تسليم وثائق رسمية",                  ago(days=5),  "09:30", 0),
        ("ديوان الرئاسة",               "العودة",                            ago(days=5),  "10:15", 1),
        ("موقع مشروع التوسع",           "تفقد ميداني للمشروع",               ago(days=3),  "08:00", 2),
        ("بنك الرياض — الفرع الرئيسي", "متابعة التسهيلات الائتمانية",       ago(days=2),  "11:00", 0),
        ("بنك الرياض",                  "العودة إلى المكتب",                 ago(days=2),  "12:00", 1),
        ("غرفة تجارة الرياض",          "حضور فعالية ريادية",                 ago(days=1),  "17:00", 0),
        ("غرفة تجارة الرياض",           "العودة",                            ago(days=1),  "20:00", 1),
        ("صندوق الاستثمارات العامة",   "اجتماع متابعة دراسة الجدوى",        ago(days=0, hours=3), "10:00", 0),
        ("صندوق الاستثمارات العامة",   "العودة إلى المكتب",                  ago(days=0, hours=1), "12:30", 1),
        ("مطار الملك خالد",            "سفر إلى الدوحة — زيارة ميدانية",    future(days=32), "06:30", 0),
        ("مطار الملك خالد",            "عودة من الدوحة",                     future(days=33), "20:00", 1),
    ]
    for dest, purpose, dt, time_s, mtype in movements_data:
        t = ms(dt)
        cur.execute("""INSERT INTO movements VALUES
            (NULL,?,?,?,0,'user_1',?,?,?,?,?,NULL)""",
            (uid(), t, t, dest, purpose, date_str(dt), time_s, mtype))

    # ════════════════════════════════════════════════════════════════════
    # 14. المهام الروتينية (15 روتين)
    # ════════════════════════════════════════════════════════════════════
    routine_tasks_data = [
        # (العنوان، الوصف، الفئة، الأولوية، التكرار، الوقت، أيام_الأسبوع)
        ("مراجعة البريد الإلكتروني الصباحي", "مراجعة ورد على رسائل البريد الإلكتروني المهمة", "work",     0, "daily",    "07:30", "[]"),
        ("قراءة التقارير اليومية",            "مراجعة تقارير الأداء والمبيعات اليومية",          "work",     1, "weekdays", "08:00", "[]"),
        ("اجتماع الفريق الصباحي",             "Stand-up meeting مع مديري الأقسام الرئيسيين",     "work",     1, "weekdays", "08:30", "[]"),
        ("مراجعة جدول الأعمال اليومي",        "تنظيم المواعيد والمهام المجدولة لليوم",            "work",     2, "daily",    "07:00", "[]"),
        ("رياضة الصباح",                      "30 دقيقة مشي أو تمارين كارديو",                   "health",   1, "daily",    "06:00", "[]"),
        ("قراءة تحفيزية",                     "قراءة 10 صفحات يومياً من كتاب متخصص",             "learning", 2, "daily",    "22:00", "[]"),
        ("مراجعة الميزانية الأسبوعية",        "تتبع المصروفات والإيرادات الأسبوعية",              "finance",  1, "weekly",   "14:00", "[0]"),
        ("ورد وأذكار",                         "قراءة الورد اليومي وأذكار الصباح",                "spiritual",1, "daily",    "05:30", "[]"),
        ("متابعة المهام المتأخرة",             "مراجعة قائمة المهام المتأخرة وتحديث حالتها",      "work",     0, "weekdays", "09:30", "[]"),
        ("مراجعة لوحة مؤشرات الأداء",        "تحديث ومراجعة KPIs الرئيسية",                     "work",     1, "weekly",   "10:00", "[0]"),
        ("التخطيط الأسبوعي",                  "جلسة تخطيط وأولوية لأهداف الأسبوع القادم",        "work",     1, "weekly",   "16:00", "[4]"),
        ("صلة الرحم والتواصل الاجتماعي",     "التواصل مع العائلة والأصدقاء المقربين",            "personal", 2, "weekly",   "20:00", "[5]"),
        ("تقييم اليوم قبل النوم",             "مراجعة إنجازات اليوم وتحديد نقاط التحسين",        "personal", 2, "daily",    "22:30", "[]"),
        ("متابعة مواعيد الصحة",               "تناول الأدوية الدورية ومتابعة الصحة العامة",       "health",   0, "daily",    "21:00", "[]"),
        ("مراجعة مستجدات السوق",              "متابعة أخبار السوق المالية والاقتصادية",            "finance",  2, "weekdays", "07:45", "[]"),
    ]
    routine_sync_ids = []
    for title, desc, cat, prio, repeat, time_s, days in routine_tasks_data:
        t_created = ms(ago(days=random.randint(60, 115)))
        sync = uid()
        routine_sync_ids.append(sync)
        cur.execute("""INSERT INTO routine_tasks VALUES
            (NULL,?,?,?,0,'user_1',?,?,?,?,?,?,?,?)""",
            (sync, t_created, t_created, title, desc, cat, prio, repeat, time_s, days, 1))

    # ════════════════════════════════════════════════════════════════════
    # 15. إنجازات الروتين — آخر 90 يوم بشكل واقعي
    # ════════════════════════════════════════════════════════════════════
    for day_offset in range(90, 0, -1):
        current_date = ago(days=day_offset)
        weekday = current_date.weekday()  # 0=Mon, 4=Fri, 5=Sat, 6=Sun
        
        for idx, (sync_id, task_row) in enumerate(zip(routine_sync_ids, routine_tasks_data)):
            task_title, _, _, _, repeat, _, days_json = task_row
            
            # تحديد هل هذا اليوم ينبغي أن تُنجز فيه المهمة
            should_do = False
            if repeat == "daily":
                should_do = True
            elif repeat == "weekdays":
                should_do = weekday < 5  # الإثنين - الجمعة
            elif repeat == "weekend":
                should_do = weekday >= 5
            elif repeat == "weekly":
                days_list = json.loads(days_json)
                should_do = weekday in days_list
            
            if not should_do:
                continue
            
            # نسبة الإنجاز تعتمد على الأولوية والنوع
            # روتين العمل: نسبة عالية
            # روتين شخصي: متوسط
            completion_chance = {
                "work": 0.88,
                "health": 0.75,
                "learning": 0.70,
                "spiritual": 0.82,
                "finance": 0.78,
                "personal": 0.72,
            }.get(task_row[2], 0.75)
            
            # تقليل الانتظام قليلاً في الأسابيع الأولى ثم التحسن
            if day_offset > 70:
                completion_chance *= 0.85
            elif day_offset > 50:
                completion_chance *= 0.90
            
            if random.random() < completion_chance:
                date_key = date_str(current_date)
                t = ms(current_date)
                try:
                    cur.execute("""INSERT INTO routine_completions VALUES
                        (NULL,?,?,?,0,'user_1',?,?)""",
                        (uid(), t, t, sync_id, date_key))
                except Exception:
                    pass  # تجاهل التكرار

    # ════════════════════════════════════════════════════════════════════
    # 16. سجل الأمان (25 سجل)
    # ════════════════════════════════════════════════════════════════════
    # action: 0=login, 1=failedLogin, 7=exportData
    device_info = "Samsung Galaxy S24 Ultra — Android 15"
    security_logs = []
    
    # تسجيل دخول يومي على مدى 4 أشهر
    for day in range(115, 0, -5):
        login_time = ago(days=day, hours=random.randint(6, 9))
        security_logs.append((0, "تسجيل دخول ناجح", device_info, None, login_time))
    
    # بعض محاولات دخول فاشلة
    for day in [110, 95, 73, 45, 22, 8]:
        fail_time = ago(days=day, hours=random.randint(6, 9))
        security_logs.append((1, "PIN خاطئ — المحاولة 1", device_info, None, fail_time))
    
    # تصدير بيانات
    for day in [90, 60, 30, 15, 7, 2]:
        export_time = ago(days=day, hours=random.randint(10, 15))
        security_logs.append((7, "تصدير تقرير PDF", device_info, None, export_time))
    
    # تسجيلات حديثة
    for d, h in [(2,7), (1,8), (0,7), (0,5)]:
        security_logs.append((0, "تسجيل دخول ناجح", device_info, None, ago(days=d, hours=h)))
    
    for action, details, dev, ip, dt in security_logs[:30]:
        t = ms(dt)
        cur.execute("""INSERT INTO security_logs VALUES
            (NULL,?,?,?,0,NULL,?,?,?,?)""",
            (uid(), t, t, action, details, dev, ip))

    # ════════════════════════════════════════════════════════════════════
    # حفظ وإغلاق
    # ════════════════════════════════════════════════════════════════════
    conn.commit()
    
    # إحصائيات
    tables = ["users","meetings","tasks","follow_ups","directives","contacts",
              "appointments","archive","security_logs","app_settings","calls",
              "visitors","notes","movements","routine_tasks","routine_completions"]
    
    print("\n" + "═"*55)
    print("  ✅  مُدير Demo Database — تم الإنشاء بنجاح")
    print("═"*55)
    print(f"  📁  الملف: {OUTPUT_PATH}")
    print(f"  📦  الحجم: {os.path.getsize(OUTPUT_PATH) / 1024:.1f} KB")
    print("─"*55)
    print("  📊  إحصائيات البيانات:")
    for tbl in tables:
        count = cur.execute(f"SELECT COUNT(*) FROM {tbl}").fetchone()[0]
        print(f"     {tbl:<30} {count:>4} سجل")
    print("═"*55)
    
    conn.close()
    return OUTPUT_PATH

if __name__ == "__main__":
    create_database()
