import { Body, Controller, Get, HttpCode, Post } from '@nestjs/common';

import { Public, Tenant } from '../../common/tenant/tenant.guard';
import { TenantContext } from '../../common/tenant/tenant-context';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';

/**
 * AZM — مسارات المصادقة
 *
 * مساران عامّان فقط، ومعلَّمان بـ`@Public()` صراحةً. الحارس العامّ
 * يمنع كل ما عداهما افتراضيًا.
 */
@Controller('auth')
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Public()
  @Post('register')
  register(@Body() dto: RegisterDto) {
    return this.auth.registerWithCompany(dto);
  }

  /**
   * ٢٠٠ لا ٢٠١: الدخول لا يُنشئ موردًا.
   */
  @Public()
  @Post('login')
  @HttpCode(200)
  login(@Body() dto: LoginDto) {
    return this.auth.login(dto);
  }

  /**
   * من أنا في هذه الشركة.
   *
   * يعيد الدور كما قرأه الحارس من القاعدة لا كما في الرمز. العميل
   * يستخدمه لرسم الواجهة — **لا لحراستها**: إخفاء زرّ ليس منعًا،
   * والمنع يقع هنا في الخادم على كل مسار.
   */
  @Get('me')
  me(@Tenant() ctx: TenantContext) {
    return {
      userId: ctx.userId,
      companyId: ctx.companyId,
      role: ctx.role,
      membershipId: ctx.membershipId,
    };
  }
}
