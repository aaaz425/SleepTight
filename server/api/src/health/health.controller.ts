import { Controller, Get, Logger } from '@nestjs/common';

@Controller('health')
export class HealthController {
  private readonly logger = new Logger(HealthController.name);

  @Get()
  healthCheck() {
    this.logger.log('헬스 체크 요청 받음');
    return { status: 'ok!' };
  }
}
