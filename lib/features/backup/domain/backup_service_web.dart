// Web stub — no drift/native or dart:io imports here.
//
// النسخ الاحتياطي على الويب غير مدعوم بعد. الإصدار السابق كان يعيد `true`
// من هذه الدوال فيظهر للمستخدم أن النسخ تمّ ولم يحدث شيء إطلاقًا — وهو
// أسوأ من غياب الميزة. تُعيد الآن نتيجة فشل صريحة تشرح السبب.
import 'restore_result.dart';

Future<bool> exportNative(dynamic logger, dynamic db) async => false;

Future<RestoreResult> restoreNative(dynamic logger, dynamic db) async =>
    const RestoreResult.failure(
      'النسخ الاحتياطي غير متاح في نسخة الويب. استخدم تطبيق الجوال.',
    );

Future<String> getDbSizeNative() async => 'غير متوفر على الويب';
