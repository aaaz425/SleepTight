import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { setupSwagger } from './common/config/swagger';
import { setupGlobalPrefix } from './common/config/prefix';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  setupSwagger(app);
  setupGlobalPrefix(app);

  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
