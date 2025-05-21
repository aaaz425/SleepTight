import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import * as admin from 'firebase-admin';
import { ConfigService } from '@nestjs/config';
import { UserService } from 'src/users/user.service';

@Injectable()
export class FcmService implements OnModuleInit {
    private readonly logger: Logger = new Logger(FcmService.name);
    constructor(
        private readonly configService: ConfigService,
        private readonly userService: UserService,
    ) {}

    onModuleInit() {
        if (!admin.apps.length) {
            const firebaseConfig = {
                type: this.configService.get('FIREBASE_TYPE'),
                projectId: this.configService.get('FIREBASE_PROJECT_ID'),
                privateKeyId: this.configService.get('FIREBASE_PRIVATE_KEY_ID'),
                privateKey: this.configService.get('FIREBASE_PRIVATE_KEY')?.replace(/\\n/g, '\n'),
                clientEmail: this.configService.get('FIREBASE_CLIENT_EMAIL'),
                clientId: this.configService.get('FIREBASE_CLIENT_ID'),
                authUri: this.configService.get('FIREBASE_AUTH_URI'),
                tokenUri: this.configService.get('FIREBASE_TOKEN_URI'),
                authProviderX509CertUrl: this.configService.get('FIREBASE_AUTH_PROVIDER_X509_CERT_URL'),
                clientC509CertUrl: this.configService.get('FIREBASE_CLIENT_X509_CERT_URL'),
            };

            admin.initializeApp({
                credential: admin.credential.cert(firebaseConfig as admin.ServiceAccount),
            });
        }
    }

    async sendNotification(userId: number, title: string, body: string) {
        const user = await this.userService.findById(userId);
        const token = user.fcm_token||'';

        const message = {
            notification: {
                title,
                body,
            },
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

