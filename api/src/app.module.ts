import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { APP_GUARD } from '@nestjs/core';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';

import { TenantPrismaService } from './common/prisma/tenant-prisma.service';
import { TenantGuard } from './common/tenant/tenant.guard';
import { AuthService } from './modules/auth/auth.service';
import { JwtStrategy } from './modules/auth/jwt.strategy';
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
 */
@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PassportModule,
    JwtModule.registerAsync({
      global: true,
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        secret: config.get<string>('JWT_SECRET'),
        signOptions: {
          expiresIn: config.get<string>('JWT_EXPIRES_IN') ?? '7d',
        },
      }),
    }),
  ],
  providers: [
    TenantPrismaService,
    JwtStrategy,
    AuthService,
    MeetingsService,
    { provide: APP_GUARD, useClass: TenantGuard },
  ],
})
export class AppModule {}
