import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { randomUUID } from 'node:crypto';
import request from 'supertest';
import type { App } from 'supertest/types';

import { AppModule } from '../src/app.module';
import { DomainErrorFilter } from '../src/common/errors/domain-error.filter';
import { TenantPrismaService } from '../src/common/prisma/tenant-prisma.service';
import { UserRole } from '../src/common/tenant/tenant-context';

/**
 * AZM — بوابة الخروج من المرحلة ٣
 *
 * هذه ليست اختبارات وحدات. اختبارات `tenant-isolation.spec.ts` تفحص
 * المنطق بلا قاعدة، وهي تُطمئن ولا تُثبت: العزل يُكسر في الطبقة التي
 * لا تُحاكى — استعلام يصل إلى PostgreSQL بلا مرشّح، أو حقل يمرّ من
 * جسم الطلب إلى Prisma.
 *
 * فهنا **خادم حقيقي وقاعدة حقيقية وطلبات HTTP حقيقية**، وشركتان
 * منفصلتان تحاول كل منهما أن ترى الأخرى.
 *
 * ⚠ يتطلّب قاعدة تعمل: `npm run db:up` ثم `npx prisma migrate deploy`.
 *
 * الترتيب مقصود: الاختبارات تبني على بعضها (تسجيل ← إنشاء ← محاولة
 * اختراق)، لذا `maxWorkers: 1` في `jest-e2e.json`.
 */
describe('عزل المستأجرين — من طرف إلى طرف', () => {
  let app: INestApplication;
  let prisma: TenantPrismaService;
  let http: App;

  /** شركتان لا صلة بينهما، لكلّ منها مالك. */
  const alpha = {
    email: `alpha-${randomUUID()}@azm.test`,
    password: 'alpha-pass-1234',
    displayName: 'مالك ألفا',
    companyName: 'شركة ألفا للتقنية',
    token: '',
    companyId: '',
    userId: '',
  };

  const beta = {
    email: `beta-${randomUUID()}@azm.test`,
    password: 'beta-pass-1234',
    displayName: 'مالك بيتا',
    companyName: 'مؤسسة بيتا',
    token: '',
    companyId: '',
    userId: '',
  };

  /** اجتماع يخصّ ألفا — هدف كل محاولات بيتا أدناه. */
  let alphaMeetingId = '';

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleRef.createNestApplication();
    // نسخة طبق الأصل من `main.ts`: اختبار يشغّل إعدادًا مختلفًا عن
    // الإنتاج يختبر خادمًا لا وجود له.
    app.setGlobalPrefix('api/v1');
    app.useGlobalFilters(new DomainErrorFilter());
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
      }),
    );
    await app.init();

    prisma = app.get(TenantPrismaService);
    http = app.getHttpServer() as App;
  });

  afterAll(async () => {
    // حذف الشركتين يسحب معهما الاجتماعات والعضويات بـ`onDelete: Cascade`،
    // والمستخدمون عالميون فيُحذفون صراحةً.
    for (const id of [alpha.companyId, beta.companyId].filter(Boolean)) {
      await prisma.organization.delete({ where: { id } }).catch(() => undefined);
    }
    for (const email of [alpha.email, beta.email]) {
      await prisma.user.delete({ where: { email } }).catch(() => undefined);
    }
    await app.close();
  });

  // ─────────────────────────────────────────────
  // التهيئة: شركتان مستقلّتان
  // ─────────────────────────────────────────────

  describe('التسجيل', () => {
    it('ينشئ حسابًا وشركةً ويعيد رمزًا', async () => {
      const res = await request(http)
        .post('/api/v1/auth/register')
        .send({
          email: alpha.email,
          password: alpha.password,
          displayName: alpha.displayName,
          companyName: alpha.companyName,
        })
        .expect(201);

      expect(res.body.accessToken).toEqual(expect.any(String));
      expect(res.body.user.email).toBe(alpha.email);
      // لا تجزئة كلمة مرور في الردّ
      expect(res.body.user).not.toHaveProperty('passwordHash');

      alpha.token = res.body.accessToken;
      alpha.companyId = res.body.company.id;
      alpha.userId = res.body.user.id;
    });

    it('ينشئ الشركة الثانية بمعزل عن الأولى', async () => {
      const res = await request(http)
        .post('/api/v1/auth/register')
        .send({
          email: beta.email,
          password: beta.password,
          displayName: beta.displayName,
          companyName: beta.companyName,
        })
        .expect(201);

      beta.token = res.body.accessToken;
      beta.companyId = res.body.company.id;
      beta.userId = res.body.user.id;

      expect(beta.companyId).not.toBe(alpha.companyId);
    });

    it('المُسجِّل يصير مالكًا — والدور من القاعدة لا من الطلب', async () => {
      const res = await request(http)
        .get('/api/v1/auth/me')
        .set('Authorization', `Bearer ${alpha.token}`)
        .expect(200);

      expect(res.body.role).toBe(UserRole.Owner);
      expect(res.body.companyId).toBe(alpha.companyId);
    });

    it('يرفض بريدًا مكرّرًا', async () => {
      await request(http)
        .post('/api/v1/auth/register')
        .send({
          email: alpha.email,
          password: 'other-pass-1234',
          displayName: 'منتحل',
          companyName: 'شركة أخرى',
        })
        .expect(409);
    });

    it('يرفض كلمة مرور قصيرة', async () => {
      await request(http)
        .post('/api/v1/auth/register')
        .send({
          email: `short-${randomUUID()}@azm.test`,
          password: 'قصيرة',
          displayName: 'أحد',
          companyName: 'شركة',
        })
        .expect(400);
    });
  });

  // ─────────────────────────────────────────────
  // الحارس العامّ
  // ─────────────────────────────────────────────

  describe('المنع هو الافتراض', () => {
    it('طلب بلا رمز يُرفض', async () => {
      await request(http).get('/api/v1/meetings').expect(401);
    });

    it('رمز مشوَّه يُرفض', async () => {
      await request(http)
        .get('/api/v1/meetings')
        .set('Authorization', 'Bearer not.a.real.token')
        .expect(401);
    });

    it('رمز موقَّع بسرّ آخر يُرفض', async () => {
      // رمز صحيح البنية موقَّع بسرّ مختلف — يفشل على التوقيع لا البنية
      const forged =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.' +
        Buffer.from(
          JSON.stringify({ sub: alpha.userId, companyId: alpha.companyId }),
        ).toString('base64url') +
        '.ZmFrZXNpZ25hdHVyZQ';

      await request(http)
        .get('/api/v1/meetings')
        .set('Authorization', `Bearer ${forged}`)
        .expect(401);
    });
  });

  // ─────────────────────────────────────────────
  // الإنشاء والقراءة داخل الشركة
  // ─────────────────────────────────────────────

  describe('ألفا تعمل داخل شركتها', () => {
    it('تنشئ اجتماعًا وتُحقن الشركة تلقائيًا', async () => {
      const res = await request(http)
        .post('/api/v1/meetings')
        .set('Authorization', `Bearer ${alpha.token}`)
        .send({
          title: 'اجتماع ألفا السرّي',
          date: '2026-10-01',
          time: '10:00',
          objective: 'خطة الربع الرابع',
        })
        .expect(201);

      alphaMeetingId = res.body.id;

      // الحقن وقع رغم أن الطلب لم يذكر الشركة
      expect(res.body.companyId).toBe(alpha.companyId);
      expect(res.body.createdBy).toBe(alpha.userId);
      expect(res.body.version).toBe(1);
      expect(res.body.syncId).toEqual(expect.any(String));
    });

    it('تراه في قائمتها', async () => {
      const res = await request(http)
        .get('/api/v1/meetings')
        .set('Authorization', `Bearer ${alpha.token}`)
        .expect(200);

      expect(res.body.map((m: { id: string }) => m.id)).toContain(
        alphaMeetingId,
      );
    });

    it('ترفض حقلًا غير معلَن — بما فيه `companyId`', async () => {
      // هذه هي المحاولة الأوضح: تمرير الشركة في الجسم. لولا
      // `forbidNonWhitelisted` لمرّت صامتة ووصلت إلى Prisma.
      await request(http)
        .post('/api/v1/meetings')
        .set('Authorization', `Bearer ${alpha.token}`)
        .send({
          title: 'محاولة انتحال شركة',
          date: '2026-10-02',
          time: '09:00',
          companyId: beta.companyId,
        })
        .expect(400);
    });

    it('ترفض تاريخًا بصيغة خاطئة', async () => {
      await request(http)
        .post('/api/v1/meetings')
        .set('Authorization', `Bearer ${alpha.token}`)
        .send({ title: 'بلا تاريخ صالح', date: '01/10/2026', time: '10:00' })
        .expect(400);
    });
  });

  // ─────────────────────────────────────────────
  // ❖ جوهر البوابة: بيتا تحاول رؤية ألفا
  // ─────────────────────────────────────────────

  describe('بيتا لا ترى ألفا ولا تلمسها', () => {
    it('قائمتها فارغة من اجتماعات ألفا', async () => {
      const res = await request(http)
        .get('/api/v1/meetings')
        .set('Authorization', `Bearer ${beta.token}`)
        .expect(200);

      expect(res.body.map((m: { id: string }) => m.id)).not.toContain(
        alphaMeetingId,
      );
      expect(
        res.body.every(
          (m: { companyId: string }) => m.companyId === beta.companyId,
        ),
      ).toBe(true);
    });

    it('الوصول بالمعرّف يعيد ٤٠٤ لا ٤٠٣ — ولا يكشف وجوده', async () => {
      const res = await request(http)
        .get(`/api/v1/meetings/${alphaMeetingId}`)
        .set('Authorization', `Bearer ${beta.token}`)
        .expect(404);

      // الرسالة نفسها التي يعطيها معرّف غير موجود أصلًا
      const ghost = await request(http)
        .get(`/api/v1/meetings/${randomUUID()}`)
        .set('Authorization', `Bearer ${beta.token}`)
        .expect(404);

      expect(res.body.message).toBe(ghost.body.message);
    });

    it('التعديل يُمنع', async () => {
      await request(http)
        .patch(`/api/v1/meetings/${alphaMeetingId}`)
        .set('Authorization', `Bearer ${beta.token}`)
        .send({ title: 'اختُرق' })
        .expect(404);
    });

    it('الحذف يُمنع', async () => {
      await request(http)
        .delete(`/api/v1/meetings/${alphaMeetingId}`)
        .set('Authorization', `Bearer ${beta.token}`)
        .expect(404);
    });

    it('ولا أثر لأي محاولة على الصفّ نفسه', async () => {
      // الفحص الحاسم: نقرأ الصفّ من القاعدة مباشرة لا عبر الخادم
      const row = await prisma.meeting.findUnique({
        where: { id: alphaMeetingId },
      });

      expect(row).not.toBeNull();
      expect(row!.title).toBe('اجتماع ألفا السرّي');
      expect(row!.deletedAt).toBeNull();
      expect(row!.companyId).toBe(alpha.companyId);
    });
  });

  // ─────────────────────────────────────────────
  // القفل التفاؤلي
  // ─────────────────────────────────────────────

  describe('القفل التفاؤلي', () => {
    it('التعديل بالنسخة الصحيحة يمرّ ويرفع الرقم', async () => {
      const res = await request(http)
        .patch(`/api/v1/meetings/${alphaMeetingId}`)
        .set('Authorization', `Bearer ${alpha.token}`)
        .set('If-Match', '1')
        .send({ objective: 'خطة محدَّثة' })
        .expect(200);

      expect(res.body.version).toBe(2);
      expect(res.body.objective).toBe('خطة محدَّثة');
    });

    it('التعديل بنسخة قديمة يُرفض بـ٤٠٩ لا يمحو', async () => {
      const res = await request(http)
        .patch(`/api/v1/meetings/${alphaMeetingId}`)
        .set('Authorization', `Bearer ${alpha.token}`)
        .set('If-Match', '1')
        .send({ objective: 'كتابة فوق عمل غيري' })
        .expect(409);

      expect(res.body.currentVersion).toBe(2);
      expect(res.body.expectedVersion).toBe(1);

      // والأهم: القيمة لم تتغيّر
      const row = await prisma.meeting.findUnique({
        where: { id: alphaMeetingId },
      });
      expect(row!.objective).toBe('خطة محدَّثة');
    });

    it('بلا `If-Match` يمرّ — التوافق مع عميل لا يرسلها', async () => {
      await request(http)
        .patch(`/api/v1/meetings/${alphaMeetingId}`)
        .set('Authorization', `Bearer ${alpha.token}`)
        .send({ location: 'قاعة ٣' })
        .expect(200);
    });
  });

  // ─────────────────────────────────────────────
  // الأدوار — على الخادم لا في الواجهة
  // ─────────────────────────────────────────────

  describe('الأدوار تُفرَض على الخادم', () => {
    let employeeToken = '';

    beforeAll(async () => {
      // موظف في شركة ألفا نفسها — العضوية تُكتب مباشرة لأن دعوة
      // الأعضاء ليست في نطاق هذه المرحلة.
      const user = await prisma.user.create({
        data: {
          syncId: randomUUID(),
          email: `employee-${randomUUID()}@azm.test`,
          // تجزئة كلمة مرور لا تُستخدم: الرمز يُصدَر مباشرة أدناه
          passwordHash: '$2b$12$' + 'x'.repeat(53),
          displayName: 'موظف ألفا',
        },
      });
      await prisma.membership.create({
        data: {
          syncId: randomUUID(),
          userId: user.id,
          organizationId: alpha.companyId,
          role: UserRole.Employee,
          joinedAt: new Date(),
        },
      });

      const { JwtService } = await import('@nestjs/jwt');
      const jwt = app.get(JwtService);
      employeeToken = await jwt.signAsync({
        sub: user.id,
        companyId: alpha.companyId,
      });
    });

    it('الموظف يقرأ ويكتب', async () => {
      await request(http)
        .get('/api/v1/meetings')
        .set('Authorization', `Bearer ${employeeToken}`)
        .expect(200);

      await request(http)
        .post('/api/v1/meetings')
        .set('Authorization', `Bearer ${employeeToken}`)
        .send({ title: 'اجتماع موظف', date: '2026-10-05', time: '11:00' })
        .expect(201);
    });

    it('الموظف لا يحذف — ٤٠٣ لأن السجلّ في شركته', async () => {
      // الفارق عن ٤٠٤ أعلاه مقصود: هناك السجلّ خارج شركته فلا نكشف
      // وجوده، وهنا داخلها فالمنع صلاحية لا إخفاء.
      await request(http)
        .delete(`/api/v1/meetings/${alphaMeetingId}`)
        .set('Authorization', `Bearer ${employeeToken}`)
        .expect(403);
    });

    it('المالك يحذف', async () => {
      await request(http)
        .delete(`/api/v1/meetings/${alphaMeetingId}`)
        .set('Authorization', `Bearer ${alpha.token}`)
        .expect(200);
    });

    it('الدور المسحوب يسري فورًا — لا ينتظر انتهاء الرمز', async () => {
      const membership = await prisma.membership.findFirst({
        where: { userId: alpha.userId, organizationId: alpha.companyId },
      });
      await prisma.membership.update({
        where: { id: membership!.id },
        data: { isActive: false },
      });

      // الرمز نفسه الذي نجح قبل سطرين
      await request(http)
        .get('/api/v1/meetings')
        .set('Authorization', `Bearer ${alpha.token}`)
        .expect(403);

      await prisma.membership.update({
        where: { id: membership!.id },
        data: { isActive: true },
      });
    });
  });

  // ─────────────────────────────────────────────
  // الحذف الناعم
  // ─────────────────────────────────────────────

  describe('الحذف حدث لا غياب', () => {
    it('الصفّ يبقى في القاعدة بعلامة حذف', async () => {
      const row = await prisma.meeting.findUnique({
        where: { id: alphaMeetingId },
      });

      expect(row).not.toBeNull();
      expect(row!.deletedAt).not.toBeNull();
    });

    it('ويختفي عن القراءة', async () => {
      await request(http)
        .get(`/api/v1/meetings/${alphaMeetingId}`)
        .set('Authorization', `Bearer ${alpha.token}`)
        .expect(404);

      const list = await request(http)
        .get('/api/v1/meetings')
        .set('Authorization', `Bearer ${alpha.token}`)
        .expect(200);

      expect(list.body.map((m: { id: string }) => m.id)).not.toContain(
        alphaMeetingId,
      );
    });
  });

  // ─────────────────────────────────────────────
  // المزامنة التفاضلية
  // ─────────────────────────────────────────────

  describe('المزامنة التفاضلية', () => {
    it('`since` يعيد ما تغيّر بعده فقط', async () => {
      const cutoff = new Date();

      // نضمن فارقًا زمنيًا يتجاوز دقّة الطابع
      await new Promise((r) => setTimeout(r, 50));

      const fresh = await request(http)
        .post('/api/v1/meetings')
        .set('Authorization', `Bearer ${alpha.token}`)
        .send({ title: 'بعد القطع', date: '2026-10-09', time: '08:00' })
        .expect(201);

      const res = await request(http)
        .get('/api/v1/meetings')
        .query({ since: cutoff.toISOString() })
        .set('Authorization', `Bearer ${alpha.token}`)
        .expect(200);

      const ids = res.body.map((m: { id: string }) => m.id);
      expect(ids).toContain(fresh.body.id);
      expect(ids).not.toContain(alphaMeetingId);
    });

    it('`since` غير صالح يعيد كل شيء لا لا شيء', async () => {
      const res = await request(http)
        .get('/api/v1/meetings')
        .query({ since: 'ليس تاريخًا' })
        .set('Authorization', `Bearer ${alpha.token}`)
        .expect(200);

      expect(res.body.length).toBeGreaterThan(0);
    });
  });
});
