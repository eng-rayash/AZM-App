@TestOn('vm')
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:azm/core/constants/enums.dart';

/// يثبّت الأرقام المخزَّنة في قاعدة البيانات.
///
/// هذه ليست اختبارات سلوك بل **عقود تخزين**: كل قيمة هنا مكتوبة في
/// صفوف قائمة على أجهزة المستخدمين. تغيير رقم واحد يعيد تفسير بيانات
/// محفوظة — «ملغي» يصير «متعثر» بلا أن يفشل شيء.
///
/// سبب وجودها: كانت تعليقات الجداول تسرد أرقامًا تخالف التعدادات في
/// ثلاثة مواضع. استُبدلت التعليقات بإشارات إلى التعدادات، وهذه
/// الاختبارات تحرس التعدادات نفسها.
void main() {
  group('UnifiedStatus — عقد التخزين', () {
    test('الأرقام ثابتة', () {
      expect(UnifiedStatus.newItem.value, 0);
      expect(UnifiedStatus.inProgress.value, 1);
      expect(UnifiedStatus.awaitingResponse.value, 2);
      expect(UnifiedStatus.completed.value, 3);
      expect(UnifiedStatus.overdue.value, 4);
      expect(UnifiedStatus.stalled.value, 5);
      expect(UnifiedStatus.cancelled.value, 6);
    });

    test('٥ متعثر لا ملغي — الخطأ الذي كان في تعليق الجدول', () {
      expect(UnifiedStatus.fromValue(5), UnifiedStatus.stalled);
      expect(UnifiedStatus.fromValue(6), UnifiedStatus.cancelled);
    });
  });

  group('لا تعداد يرمي عند قيمة غير معروفة', () {
    // صفّ من نسخة أقدم، أو عمود تالف، أو قيمة أُضيفت ثم أُزيلت — كلها
    // تصل إلى fromValue. الرمي هنا يُسقط الشاشة كلها لا الصفّ وحده.
    test('ستة تعدادات كانت ترمي وصارت تُرجع قيمة افتراضية', () {
      expect(() => MeetingStatus.fromValue(99), returnsNormally);
      expect(() => MeetingType.fromValue(99), returnsNormally);
      expect(() => UnifiedStatus.fromValue(99), returnsNormally);
      expect(() => Priority.fromValue(99), returnsNormally);
      expect(() => SecurityAction.fromValue(99), returnsNormally);
      expect(() => AuthMethod.fromValue(99), returnsNormally);
    });

    test('والبقية كانت محصّنة أصلًا', () {
      expect(() => FollowupType.fromValue(99), returnsNormally);
      expect(() => FollowUpEntityType.fromValue(99), returnsNormally);
      expect(() => EntityLinkType.fromValue(99), returnsNormally);
      expect(() => InvoiceStatus.fromValue(99), returnsNormally);
      expect(() => ProjectStatus.fromValue(99), returnsNormally);
      expect(() => UserRole.fromValue(99), returnsNormally);
    });
  });

  group('FollowupType — عقد التخزين', () {
    test('سبع قيَم لا ثماني', () {
      expect(FollowupType.values, hasLength(7));
      expect(FollowupType.followup.value, 0);
      expect(FollowupType.task.value, 1);
      expect(FollowupType.clientFollowup.value, 2);
      expect(FollowupType.other.value, 6);
    });
  });

  group('EntityLinkType — عقد التخزين', () {
    test('سبع عشرة قيمة متتابعة من صفر', () {
      expect(EntityLinkType.values, hasLength(17));
      for (var i = 0; i < EntityLinkType.values.length; i++) {
        expect(EntityLinkType.values[i].value, i,
            reason: 'الترقيم متتابع بلا فجوات');
      }
    });

    test('المراسي المستخدَمة في شاشات التفاصيل', () {
      expect(EntityLinkType.meeting.value, 1);
      expect(EntityLinkType.client.value, 3);
      expect(EntityLinkType.project.value, 4);
      expect(EntityLinkType.employee.value, 5);
      expect(EntityLinkType.invoice.value, 6);
      expect(EntityLinkType.other.value, 16);
    });
  });

  group('التمييز بين خريطتَي الكيانات', () {
    test('FollowUpEntityType و EntityLinkType لا يتطابقان', () {
      // العمودان `entityType` و`linkedEntityType` يحملان معنيين
      // مختلفين. لو تُرجم أحدهما إلى الآخر ضمنيًا لصار الاجتماع مهمة.
      expect(FollowUpEntityType.meeting.value, 0);
      expect(EntityLinkType.meeting.value, 1);
      expect(
        FollowUpEntityType.meeting.value == EntityLinkType.meeting.value,
        isFalse,
        reason: 'خريطتان مختلفتان عمدًا — لا تُخلطا',
      );
    });

    test('FollowUpEntityType ثابت لأن فيه بيانات قديمة', () {
      expect(FollowUpEntityType.meeting.value, 0);
      expect(FollowUpEntityType.task.value, 1);
      expect(FollowUpEntityType.directive.value, 2);
      expect(FollowUpEntityType.other.value, 7);
    });
  });

  group('Priority — عقد التخزين', () {
    test('الأصغر أعلى إلحاحًا', () {
      expect(Priority.critical.value, 0);
      expect(Priority.high.value, 1);
      expect(Priority.medium.value, 2);
      expect(Priority.low.value, 3);
    });
  });

  group('UserRole — هرم الصلاحيات', () {
    test('الأصغر أعلى صلاحية', () {
      expect(UserRole.owner.value, 0);
      expect(UserRole.guest.value, 9);
      expect(UserRole.owner.level < UserRole.employee.level, isTrue);
    });

    test('قواعد الوصول تتبع الترتيب', () {
      expect(UserRole.admin.canManageUsers, isTrue);
      expect(UserRole.executive.canManageUsers, isFalse);
      expect(UserRole.hrManager.hasHrAccess, isTrue);
      expect(UserRole.hrManager.hasFinanceAccess, isFalse);
      expect(UserRole.financeManager.hasFinanceAccess, isTrue);
    });
  });
}
