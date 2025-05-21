import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import * as admin from 'firebase-admin';
import { UserService } from 'src/users/user.service';
import * as path from 'path';
import * as fs from 'fs';

@Injectable()
export class FcmService implements OnModuleInit {
    private readonly logger: Logger = new Logger(FcmService.name);
    constructor(private readonly userService: UserService) {}

    onModuleInit() {
        if (!admin.apps.length) {
            const jsonPath = path.join(__dirname, '..', '..', '..','src', 'common', 'fcm', 'sleep-tight-d9f9d-firebase-adminsdk-fbsvc-3fe0729751.json');
            const serviceAccount = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));
            admin.initializeApp({
                credential: admin.credential.cert(serviceAccount),
            });
        }
    }

    async sendNotification(userId: number, title: string, body: string) {
        const user = await this.userService.findById(userId);
        const token = user.fcm_token || '';

        const message = {
            notification: { title, body },
            data:{}, //TODO: 추후 알림 Type 추가시 여기에
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