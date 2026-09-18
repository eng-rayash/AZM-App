import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
  SetMetadata,
  UnauthorizedException,
  createParamDecorator,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';

import { TenantPrismaService } from '../prisma/tenant-prisma.service';
import { TenantContext, UserRole, hasRole } from './tenant-context';

/** المسارات المعلَّمة بهذا لا تحتاج مصادقة — التسجيل والدخول. */
export const PUBLIC_KEY = 'azm:public';
export const Public = () => SetMetadata(PUBLIC_KEY, true);

/** أقلّ دور مطلوب للمسار. */
export const ROLE_KEY = 'azm:minRole';
export const RequireRole = (role: UserRole) => SetMetadata(ROLE_KEY, role);

/**
 * AZM — حارس المستأجر
 *
 * يحوّل رمزًا موثَّقًا إلى [TenantContext]، ويرفض ما دون ذلك.
 *
 * **الشركة تُقرأ من العضوية في القاعدة، لا من الرمز.** الرمز يحمل
 * `userId` و`companyId` المطلوبة، لكن الدور والصلاحية يُجلبان طازجين
 * من `memberships` في كل طلب. السبب: رمز صالح لساعة يظلّ يحمل دورًا
 * سُحب قبل نصف ساعة. قراءة الدور من الرمز تعني أن سحب الصلاحية لا
 * يسري إلا بعد انتهاء الرمز.
 *
 * هذا استعلام إضافي لكل طلب، وثمنه مقبول: البديل نافذة يبقى فيها
 * موظف مفصول قادرًا على الكتابة.
 */
@Injectable()
export class TenantGuard implements CanActivate {
  constructor(
    private readonly reflector: Reflector,
    private readonly prisma: TenantPrismaService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const isPublic = this.reflector.getAllAndOverride<boolean>(PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) return true;

    const req = context.switchToHttp().getRequest();

    // `req.user` يضعه JwtStrategy بعد التحقّق من التوقيع
    const payload = req.user as
      | { sub?: string; companyId?: string }
      | undefined;

    if (!payload?.sub) {
      throw new UnauthorizedException('رمز غير صالح');
    }
    if (!payload.companyId) {
      throw new UnauthorizedException('الرمز لا يحدّد شركة');
    }

    // الدور من القاعدة لا من الرمز — انظر توثيق الصنف
    const membership = await this.prisma.membership.findFirst({
      where: {
        userId: payload.sub,
        organizationId: payload.companyId,
        isActive: true,
        deletedAt: null,
      },
      select: { id: true, role: true, organizationId: true, userId: true },
    });

    if (!membership) {
      // لا نكشف ما إذا كانت الشركة موجودة: الرسالة نفسها لعدم العضوية
      // ولعدم وجود الشركة. الفارق بينهما يسرّب وجود شركات.
      throw new ForbiddenException('لا عضوية فعّالة في هذه الشركة');
    }

    const minRole = this.reflector.getAllAndOverride<UserRole>(ROLE_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    if (minRole !== undefined && !hasRole(membership.role, minRole)) {
      throw new ForbiddenException('صلاحيتك لا تكفي لهذا الإجراء');
    }

    const ctx: TenantContext = {
      userId: membership.userId,
      companyId: membership.organizationId,
      role: membership.role,
      membershipId: membership.id,
    };
    req.tenant = ctx;

    return true;
  }
}

/**
 * يحقن [TenantContext] في معاملات المتحكّم.
 *
 * ```ts
 * findAll(@Tenant() ctx: TenantContext) { … }
 * ```
 */
export const Tenant = createParamDecorator(
  (_: unknown, context: ExecutionContext): TenantContext => {
    const req = context.switchToHttp().getRequest();
    const ctx = req.tenant as TenantContext | undefined;
    if (!ctx) {
      // يقع فقط إن نُسي الحارس على المسار — خطأ برمجي لا خطأ مستخدم
      throw new Error(
        'TenantContext غير مُهيَّأ: تأكّد من تفعيل TenantGuard على المسار',
      );
    }
    return ctx;
  },
);
