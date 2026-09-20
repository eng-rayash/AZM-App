import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { APP_GUARD } from '@nestjs/core';
import { JwtModule, JwtModuleOptions } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';

import { TenantPrismaService } from './common/prisma/tenant-prisma.service';
import { JwtAuthGuard } from './common/tenant/jwt-auth.guard';
import { TenantGuard } from './common/tenant/tenant.guard';
import { AuthController } from './modules/auth/auth.controller';
import { AuthService } from './modules/auth/auth.service';
import { JwtStrategy } from './modules/auth/jwt.strategy';
import { MeetingsController } from './modules/meetings/meetings.controller';
import { MeetingsService } from './modules/meetings/meetings.service';

/**
 * AZM — الوحدة الجذر
 *
 * قرار معماري واحد يستحقّ الانتباه: [TenantGuard] مُسجَّل حارسًا
 * **عامًّا** لا على مسارات مختارة.
 *
 * السبب: الحماية الافتراضية يجب أن تكون المنع لا السماح. لو سُجِّل
 * على المسارات فرادى، لكان كل مسار جديد مفتوحًا حتى يتذكّر كاتبه
 * إضافة الحارس — والنسيان هنا ثغرة صامتة. الآن العكس: المسار مغلق
 * حتى يُعلَّم بـ`@Public()` صراحةً، والسهو يُنتج مسارًا لا يعمل لا
 * مسارًا مكشوفًا.
 *
 * [JwtAuthGuard] مُسجَّل قبله للسبب نفسه، والترتيب ملزِم: Nest ينفّذ
 * حرّاس `APP_GUARD` بترتيب تسجيلهم، و[TenantGuard] يقرأ `req.user`
 * الذي يملؤه الأول.
 */
@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PassportModule,
    JwtModule.registerAsync({
      global: true,
      inject: [ConfigService],
      useFactory: (config: ConfigService): JwtModuleOptions => ({
        // `!` مبرَّر: JwtStrategy يفشل عند الإقلاع إن غاب السرّ،
        // فلا يصل التطبيق إلى هنا بقيمة فارغة.
        secret: config.get<string>('JWT_SECRET')!,
        signOptions: {
          // `expiresIn` في jsonwebtoken يقبل عددًا أو صيغة مدّة
          // (`7d`)، ونوعه الضيّق لا يُستنتج من `string`.
          expiresIn: (config.get<string>('JWT_EXPIRES_IN') ??
            '7d') as `${number}d`,
        },
      }),
    }),
  ],
  controllers: [AuthController, MeetingsController],
  providers: [
    TenantPrismaService,
    JwtStrategy,
    AuthService,
    MeetingsService,
    { provide: APP_GUARD, useClass: JwtAuthGuard },
    { provide: APP_GUARD, useClass: TenantGuard },
  ],
})
export class AppModule {}
