<div align="center">

# 🏛️ مُدير — نظام إدارة المكتب التنفيذي

**تطبيق Flutter متكامل لإدارة الاجتماعات والمهام والمتابعات والوثائق**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Drift](https://img.shields.io/badge/Database-Drift-orange)](https://drift.simonbinder.eu)
[![Riverpod](https://img.shields.io/badge/State-Riverpod-purple)](https://riverpod.dev)
[![License](https://img.shields.io/badge/License-Private-red)](.)

</div>

---

## 📋 نظرة عامة

**مُدير** هو تطبيق Flutter متخصص لمساعدة المدير التنفيذي على إدارة عمله اليومي بكفاءة عالية، يشمل:

| الوحدة | الوصف |
|--------|--------|
| 🏠 لوحة التحكم | نظرة شاملة على الأعمال اليومية والمهام الدورية |
| 📅 الاجتماعات | جدولة وتوثيق الاجتماعات والمقابلات |
| ✅ المهام | إدارة مهام العمل مع الأولويات والمواعيد |
| 🔄 الروتين | مهام روتينية يومية/أسبوعية مع تتبع الإنجاز |
| 👥 المتابعات | متابعة القرارات والتكليفات |
| 🗄️ الأرشيف | حفظ وتصنيف الوثائق والمراسلات |
| 📊 التقارير | تقارير أداء وإحصائيات |
| 🔒 الأمان | PIN + بصمة إصبع |

---

## 🏗️ هيكل المشروع

```
lib/
├── core/                          # النواة المشتركة
│   ├── constants/
│   │   ├── app_constants.dart     # ثوابت التطبيق (dbVersion, إلخ)
│   │   └── enums.dart             # التعدادات المشتركة (Priority, Status...)
│   ├── database/
│   │   ├── app_database.dart      # نقطة دخول Drift الرئيسية
│   │   ├── app_database.g.dart    # كود مولد تلقائياً (build_runner)
│   │   ├── tables/                # تعريفات جداول قاعدة البيانات
│   │   │   ├── base_table.dart    # BaseTableMixin (id, syncId, createdAt...)
│   │   │   ├── tasks_table.dart
│   │   │   ├── meetings_table.dart
│   │   │   ├── follow_ups_table.dart
│   │   │   ├── routine_tasks_table.dart  ✨ جديد — مهام الروتين
│   │   │   └── ...
│   │   ├── dao/                   # Data Access Objects
│   │   │   ├── tasks_dao.dart
│   │   │   ├── meetings_dao.dart
│   │   │   ├── routine_tasks_dao.dart    ✨ جديد
│   │   │   └── ...
│   │   └── providers/
│   │       └── database_providers.dart
│   ├── router/
│   │   ├── app_router.dart        # GoRouter — التوجيه الإعلاني
│   │   └── route_names.dart       # ثوابت مسارات الروابط
│   ├── theme/
│   │   ├── neu_colors.dart        # لوحة الألوان
│   │   ├── app_typography.dart    # أنماط النصوص
│   │   └── app_spacing.dart       # المسافات والهوامش
│   └── utils/                     # أدوات مساعدة
│
├── features/                      # وحدات الميزات (Feature-First)
│   ├── auth/                      # المصادقة والأمان
│   │   └── presentation/
│   │       ├── splash_screen.dart
│   │       ├── login_screen.dart
│   │       ├── pin_setup_screen.dart
│   │       └── lock_screen.dart
│   │
│   ├── dashboard/                 # لوحة التحكم
│   │   ├── presentation/
│   │   │   └── dashboard_screen.dart
│   │   └── providers/
│   │       └── periodic_tasks_provider.dart  # يدمج المهام + الروتين
│   │
│   ├── tasks/                     # مهام العمل
│   │   ├── domain/
│   │   │   ├── tasks_repository.dart
│   │   │   └── task_model.dart
│   │   ├── presentation/
│   │   │   ├── tasks_list_screen.dart
│   │   │   ├── create_task_screen.dart
│   │   │   ├── edit_task_screen.dart
│   │   │   └── task_detail_screen.dart
│   │   └── providers/
│   │       └── tasks_provider.dart
│   │
│   ├── routine_tasks/             # المهام الروتينية
│   │   ├── domain/
│   │   │   └── routine_task_model.dart
│   │   ├── presentation/
│   │   │   └── routine_tasks_screen.dart  # (اليوم / الأسبوع / الإدارة)
│   │   └── providers/
│   │       └── routine_tasks_provider.dart  # يقرأ من Drift DB
│   │
│   ├── meetings/                  # الاجتماعات
│   ├── followups/                 # المتابعات
│   ├── archive/                   # الأرشيف
│   ├── directives/                # التوجيهات
│   ├── contacts/                  # جهات الاتصال
│   ├── appointments/              # المواعيد
│   ├── calls/                     # المكالمات
│   ├── visitors/                  # الزوار
│   ├── notes/                     # الملاحظات
│   ├── movements/                 # التنقلات
│   ├── reports/                   # التقارير
│   ├── settings/                  # الإعدادات
│   └── timeline/                  # الجدول الزمني
│
└── shared/                        # مكونات مشتركة
    └── widgets/
        ├── neu_card.dart          # بطاقة Neumorphic
        ├── neu_button.dart        # زر Neumorphic
        ├── priority_chip.dart     # شارة الأولوية
        ├── search_filter_bar.dart # شريط البحث والتصفية
        ├── export_button.dart     # زر تصدير البيانات
        └── app_scaffold.dart      # هيكل التطبيق مع الشريط السفلي
```

---

## 🗄️ قاعدة البيانات

يستخدم التطبيق **Drift (Moor)** — ORM متكامل لـ SQLite.

### الجداول (schemaVersion = 5)

| الجدول | الغرض |
|--------|--------|
| `users` | بيانات المستخدم والمصادقة |
| `tasks` | مهام العمل |
| `meetings` | الاجتماعات |
| `follow_ups` | المتابعات |
| `directives` | التوجيهات |
| `contacts` | جهات الاتصال |
| `appointments` | المواعيد |
| `archive` | الأرشيف |
| `security_logs` | سجل الأحداث الأمنية |
| `app_settings` | إعدادات التطبيق |
| `calls` | سجل المكالمات |
| `visitors` | سجل الزوار |
| `notes` | الملاحظات |
| `movements` | التنقلات |
| `routine_tasks` | ✨ تعريف المهام الروتينية |
| `routine_completions` | ✨ تتبع إنجاز المهام الروتينية يومياً |

### نمط BaseTableMixin
كل جدول يرث من `BaseTableMixin` الذي يوفر:
```dart
// id (auto-increment PK), syncId (UUID), createdAt, updatedAt, isDeleted
```

---

## 🔄 نظام الحالة (State Management)

يعتمد التطبيق على **Flutter Riverpod**:

```
Provider Type          المستخدم في
─────────────────────────────────────────
StreamProvider         مراقبة الجداول في الوقت الفعلي
StateNotifierProvider  إدارة الحالة المعقدة (tasks, routine)
Provider               حساب الحالة المشتقة (periodicTasksProvider)
FutureProvider         العمليات غير المتزامنة
```

### أهم الـ Providers

| Provider | المسار | الوظيفة |
|----------|--------|----------|
| `tasksListProvider` | `tasks/providers/` | مهام العمل من DB |
| `routineTasksProvider` | `routine_tasks/providers/` | المهام الروتينية من DB |
| `periodicTasksProvider` | `dashboard/providers/` | **يدمج** المهام + الروتين للوحة التحكم |
| `selectedPeriodProvider` | `dashboard/providers/` | التبويب المحدد (يوم/أسبوع/شهر) |

---

## 🧭 نظام التوجيه (Navigation)

يستخدم التطبيق **GoRouter** مع:
- `ShellRoute` للشريط السفلي (لوحة التحكم، الاجتماعات، المهام، المتابعات، الأرشيف)
- `CustomTransitionPage` بانتقالات `SlideTransition + FadeTransition` للشاشات الفرعية
- حراسة المسارات (Auth redirect) للتحقق من تسجيل الدخول

---

## 🔒 الأمان

- **PIN**: مخزن كـ Hash، لا يُخزن نص عادي
- **بصمة الإصبع**: عبر `local_auth`
- **قفل تلقائي**: عند الخروج من التطبيق
- **سجل الأحداث**: `security_logs` يتتبع محاولات الدخول

---

## 🚀 تشغيل المشروع

### المتطلبات
- Flutter SDK >= 3.0.0
- Dart >= 3.0.0
- Android SDK / Xcode

### خطوات الإعداد

```bash
# 1. تنزيل الاعتماديات
flutter pub get

# 2. توليد كود Drift (مطلوب بعد أي تغيير في الجداول)
dart run build_runner build --delete-conflicting-outputs

# 3. تشغيل التطبيق
flutter run
```

> **ملاحظة:** يجب تشغيل `build_runner` بعد كل تعديل في ملفات `*_table.dart` أو `*_dao.dart`.

---

## 📦 الاعتماديات الرئيسية

```yaml
# State Management
flutter_riverpod: ^2.x

# Database
drift: ^2.x
drift_flutter: ^0.x

# Navigation
go_router: ^14.x

# UI
fl_chart: ^0.x           # رسوم بيانية
flutter_pdfview: ^1.x     # عرض PDF
intl: ^0.x                # تنسيق التواريخ (عربي)

# Security
local_auth: ^2.x           # بصمة الإصبع
crypto: ^3.x               # تشفير PIN

# Utilities
uuid: ^4.x                 # UUIDs
shared_preferences: ^2.x   # إعدادات بسيطة
path_provider: ^2.x        # مسارات الملفات
```

---

## 📱 الميزات الرئيسية

### لوحة التحكم
- نظام مهام دوري (يوم/أسبوع/شهر) يجمع **مهام العمل + الروتين**
- إحصائيات الإنجاز بمؤشر حلقي
- تقويم الاجتماعات القادمة
- اقتباس تحفيزي يومي

### المهام الروتينية
- تبويبات: اليوم / الأسبوع / الإدارة
- تصنيف حسب الفئة (عمل، صحة، تعلم، روحاني، مالي)
- تتبع الإنجاز اليومي مع نظام الـ Streak
- تكرار: يومي / أيام عمل / أسبوعي / عطلة

### نظام التصدير
- تصدير إلى PDF و Excel
- اختيار متعدد للعناصر قبل التصدير

---

## 🤝 المساهمة

هذا مشروع خاص. لأي استفسار يُرجى التواصل مع فريق التطوير.

---

<div align="center">
<sub>صُنع بـ ❤️ بـ Flutter • نسخة 1.5.0</sub>
</div>
