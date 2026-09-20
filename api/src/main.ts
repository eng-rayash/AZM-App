import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';

import { AppModule } from './app.module';
import { DomainErrorFilter } from './common/errors/domain-error.filter';

/**
 * AZM — إقلاع الخادم
 *
 * `whitelist` و`forbidNonWhitelisted` ليسا تجميلًا: بدونهما يستطيع
 * العميل إرسال `companyId` في جسم الطلب فيصل إلى Prisma ويتجاوز
 * الحقن. مع التصفية، أي حقل غير معلَن في الـDTO يُرفض الطلب بسببه
 * صراحةً — والحقول الحسّاسة غير معلَنة في أي DTO أصلًا.
 */
async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.setGlobalPrefix('api/v1');
  app.useGlobalFilters(new DomainErrorFilter());
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: { enableImplicitConversion: false },
    }),
  );

  const port = Number(process.env.PORT ?? 3000);
  await app.listen(port);
}

void bootstrap();
