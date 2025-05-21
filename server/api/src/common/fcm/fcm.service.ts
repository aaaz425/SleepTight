import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import * as admin from 'firebase-admin';
import { UserService } from 'src/users/user.service';
import * as path from 'path';
import * as fs from 'fs';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class FcmService implements OnModuleInit {
  private readonly logger: Logger = new Logger(FcmService.name);

  constructor(
    private readonly userService: UserService,
    private readonly configService: ConfigService,
  ) {}

  onModuleInit() {
    if (!admin.apps.length) {
      // 1) env 변수 런타임 체크 ▶ 변경
      const jsonPath = this.configService.get<string>('GOOGLE_APPLICATION_CREDENTIALS');
      if (!jsonPath) {
        throw new Error(
          'Environment variable GOOGLE_APPLICATION_CREDENTIALS is not defined',
        );
      }

      // 2) 상대경로인 경우 절대경로로 변환 ▶ 변경
      const absPath = path.isAbsolute(jsonPath)
        ? jsonPath
        : path.join(process.cwd(), jsonPath);

      // 3) non-null assertion (!) 으로 TS에 undefined 아님을 보장 ▶ 변경
      const raw = fs.readFileSync(absPath!, 'utf8');
      const serviceAccount = JSON.parse(raw);

      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
    }
  }

  async sendNotification(userId: number, title: string, body: string) {
    const user = await this.userService.findById(userId);
    const token = user.fcm_token || '';

    const message = {
      notification: {
        title,
        body,
      },
      data: {}, // TODO: 추후 알림 Type 추가 시 여기에
      token,
    };

    try {
      const res = await admin.messaging().send(message);
      this.logger.log('📨 FCM 전송 성공:', res);
    } catch (err) {
      this.logger.error('❌ FCM 전송 실패:', err);
    }
  }
}
