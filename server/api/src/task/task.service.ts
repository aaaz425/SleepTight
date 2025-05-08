import { Injectable, Logger } from "@nestjs/common";
import { Cron, CronExpression } from "@nestjs/schedule";
import { InjectRepository } from "@nestjs/typeorm";
import { User } from "src/users/entities/user.entity";
import { UserStatus } from "src/users/user-status.enum";
import { LessThan, Repository } from "typeorm";


@Injectable()
export class TaskService {
    private readonly logger = new Logger(TaskService.name);

    constructor(
        @InjectRepository(User)
        private readonly userRepository :Repository<User>
    ){}

    // @Cron("*/10 * * * * *") // 테스트용 10초마다 
    @Cron(CronExpression.EVERY_DAY_AT_3AM)// 매일 새벽 3시
    async handleUserPseudonymization() {
        this.logger.log('🚀 사용자 가명화 작업 실행 중...');

        //현재 날짜에서 90일전 날짜
        const ninetyDaysAgo = new Date(); 
        ninetyDaysAgo.setDate(ninetyDaysAgo.getDate() - 90);

        const users = await this.userRepository.find({
            where: {
              status: UserStatus.PENDING_WITHDRAW,
              withdrawal_at: LessThan(ninetyDaysAgo),
            },
        });
          
        //만약 대상이 없으면 return
        if (users.length === 0) {
            this.logger.log('✅ 가명화 대상 없음');
            return;
        }

        for (const user of users) {
            await this.pseudonymizeUser(user);
        }
        this.logger.log(`🔒 ${users.length}명의 유저를 가명처리 완료`);
    }

    private async pseudonymizeUser(user: User) {
        await this.userRepository.update(user.id, {
            first_name: "",
            last_name: "",
            email: `deleted_user_${user.id}@example.com`,
            refresh_token: '',
            status: UserStatus.WITHDRAWN,
        });
    }
}