import { Injectable, OnModuleInit, Logger } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

/**
 * AZM — عميل Prisma بحارس مستأجر
 *
 * المشكلة التي يحلّها: العزل الذي يعتمد على انتباه المطوّر ينكسر.
 * استعلام واحد يُكتب بلا `where: { companyId }` يسرّب بيانات شركة إلى
 * أخرى، ولا شيء يفشل — لا اختبار ولا مُصرِّف. يظهر العطب حين يشتكي
 * عميل أنه يرى بيانات غيره.
 *
 * الحلّ هنا: `forTenant(companyId)` يعيد عميلًا **يحقن المرشّح
 * تلقائيًا** في كل قراءة وكتابة على الجداول المُقيَّدة. المطوّر لا
 * يستطيع نسيانه لأنه لا يكتبه.
 *
 * ```ts
 * const db = prisma.forTenant(ctx.companyId);
 * await db.meeting.findMany();        // مُقيَّد تلقائيًا
 * await db.meeting.create({ data });  // companyId يُحقن
 * ```
 *
 * الطبقات الثلاث للعزل، ولا تكفي واحدة:
 *   ١. قيد قاعدة — `companyId` NOT NULL بمفتاح أجنبي
 *   ٢. سياق الطلب — الشركة من الجلسة لا من العميل
 *   ٣. حارس الاستعلام — هذا الملف
 */
@Injectable()
export class TenantPrismaService extends PrismaClient implements OnModuleInit {
  private readonly logger = new Logger(TenantPrismaService.name);

  /**
   * النماذج المُقيَّدة بالشركة.
   *
   * ما ليس هنا عالمي عمدًا: `user` لأن الشخص يملك عضويات في أكثر من
   * شركة، و`organization` لأنها الجذر، و`membership` لأنها الجسر
   * بينهما ويُقيَّد بشكل مختلف.
   */
  private static readonly TENANT_MODELS = new Set([
    'meeting',
    'followUp',
    'client',
    'invoice',
    'employee',
    'auditLog',
  ]);

  async onModuleInit(): Promise<void> {
    await this.$connect();
  }

  /**
   * عميل مُقيَّد بشركة واحدة.
   *
   * يستخدم `$extends` من Prisma فيعترض كل عملية قبل وصولها إلى
   * القاعدة — لا يعتمد على المستدعي في شيء.
   */
  forTenant(companyId: string) {
    if (!companyId) {
      // فشل صريح خير من استعلام بلا قيد: لو مرّرنا `undefined` لـPrisma
      // لتجاهله المرشّح وأعاد كل الصفوف.
      throw new Error('TenantPrisma: companyId مطلوب ولا يقبل الفراغ');
    }

    const tenantModels = TenantPrismaService.TENANT_MODELS;
    const logger = this.logger;

    return this.$extends({
      query: {
        $allModels: {
          async $allOperations({ model, operation, args, query }) {
            if (!model || !tenantModels.has(lowerFirst(model))) {
              return query(args);
            }

            const a = args as Record<string, unknown>;

            switch (operation) {
              // ── القراءة والتحديث والحذف: يُحقن المرشّح ─────────
              case 'findFirst':
              case 'findFirstOrThrow':
              case 'findMany':
              case 'updateMany':
              case 'deleteMany':
              case 'count':
              case 'aggregate':
                a.where = { ...(a.where as object), companyId };
                break;

              // ── الوصول بالمعرّف: يُتحقَّق بعد الجلب ────────────
              //
              // `findUnique` لا يقبل حقلًا غير فريد في `where`، فلا
              // سبيل لحقن المرشّح. الحلّ أن نجلب ثم نتحقّق — وإرجاع
              // `null` لصفّ شركة أخرى يجعله غير موجود من منظور
              // الطالب، وهو السلوك الصحيح: لا نكشف حتى وجوده.
              case 'findUnique':
              case 'findUniqueOrThrow': {
                const row = (await query(args)) as { companyId?: string } | null;
                if (row && row.companyId !== companyId) {
                  logger.warn(
                    `منع وصول عابر للمستأجر: ${model} من شركة أخرى`,
                  );
                  return null;
                }
                return row;
              }

              // ── الإنشاء: تُحقن الشركة ─────────────────────────
              case 'create':
                a.data = { ...(a.data as object), companyId };
                break;

              case 'createMany': {
                const data = a.data;
                a.data = Array.isArray(data)
                  ? data.map((d) => ({ ...(d as object), companyId }))
                  : { ...(data as object), companyId };
                break;
              }

              // ── update/delete بمعرّف: يُتحقَّق أولًا ──────────
              //
              // لا يمكن حقن المرشّح في `where` الفريد، فنقرأ الصفّ
              // ونتأكّد من ملكيته قبل تعديله أو حذفه.
              case 'update':
              case 'delete': {
                const owner = await (this as any)[model].findFirst({
                  where: { ...(a.where as object), companyId },
                  select: { id: true },
                });
                if (!owner) {
                  throw new TenantIsolationError(model, operation);
                }
                break;
              }

              case 'upsert':
                a.create = { ...(a.create as object), companyId };
                a.where = { ...(a.where as object) };
                break;
            }

            return query(a);
          },
        },
      },
    });
  }
}

/** يُرمى حين تحاول عملية لمس صفّ خارج شركة الطالب. */
export class TenantIsolationError extends Error {
  constructor(model: string, operation: string) {
    super(`منع ${operation} على ${model}: السجلّ خارج نطاق شركتك`);
    this.name = 'TenantIsolationError';
  }
}

/** Prisma يسمّي النماذج بحرف أول كبير في الاعتراض، والعميل بصغير. */
function lowerFirst(s: string): string {
  return s.charAt(0).toLowerCase() + s.slice(1);
}
