/// نتيجة عملية استعادة نسخة احتياطية.
///
/// موجودة لأن `bool` لا تكفي هنا: «نجح» و«فشل» يخفيان الحالة الأهم —
/// أن الاستعادة تمّت ولم تنقل صفًّا واحدًا. مستخدم يستعيد نسخته بعد فقد
/// جهازه يستحق أن يعرف كم سجلًّا عاد فعلًا، لا كلمة «تمّت».
class RestoreResult {
  const RestoreResult({
    required this.status,
    this.insertedRows = 0,
    this.mergedTables = 0,
    this.skippedTables = const [],
    this.message,
  });

  final RestoreStatus status;

  /// عدد الصفوف المنقولة فعلًا من النسخة إلى القاعدة الحالية
  final int insertedRows;

  /// عدد الجداول التي عولجت بنجاح
  final int mergedTables;

  /// جداول موجودة في القاعدة وغائبة عن النسخة (نسخة أقدم من المخطط)
  final List<String> skippedTables;

  /// تفصيل يُعرض للمستخدم عند الفشل
  final String? message;

  bool get isSuccess => status == RestoreStatus.success;

  /// نجحت العملية تقنيًا ولم يُنقل شيء — النسخة لا تحمل جديدًا.
  bool get isEmpty => isSuccess && insertedRows == 0;

  /// ألغى المستخدم اختيار الملف — ليست فشلًا ولا تُعرض كخطأ.
  bool get isCancelled => status == RestoreStatus.cancelled;

  const RestoreResult.cancelled()
      : status = RestoreStatus.cancelled,
        insertedRows = 0,
        mergedTables = 0,
        skippedTables = const [],
        message = null;

  const RestoreResult.failure(String reason)
      : status = RestoreStatus.failure,
        insertedRows = 0,
        mergedTables = 0,
        skippedTables = const [],
        message = reason;

  /// نصّ عربي جاهز للعرض، يقول ما حدث فعلًا.
  String get displayMessage {
    switch (status) {
      case RestoreStatus.cancelled:
        return 'أُلغيت الاستعادة.';
      case RestoreStatus.failure:
        return message ?? 'تعذّرت الاستعادة.';
      case RestoreStatus.success:
        if (insertedRows == 0) {
          return 'قُرئت النسخة ولم يُضَف شيء — كل سجلاتها موجودة لديك أصلًا.';
        }
        final tail = skippedTables.isEmpty
            ? ''
            : ' (${skippedTables.length} جدولًا لم يوجد في النسخة)';
        return 'استُعيد $insertedRows سجلًّا في $mergedTables جدولًا.$tail'
            ' أعد تشغيل التطبيق.';
    }
  }
}

enum RestoreStatus { success, failure, cancelled }
