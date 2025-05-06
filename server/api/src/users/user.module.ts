import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { User } from "./entities/user.entity";
import { UserController } from "./user.controller";
import { UserService } from "./user.service";
import { ConfigModule, ConfigService } from "@nestjs/config";
import { JwtModule } from "@nestjs/jwt";


@Module({
    imports: [
        TypeOrmModule.forFeature([User]),
        ConfigModule,
        JwtModule.registerAsync({
            imports: [ConfigModule],
            inject: [ConfigService],
            useFactory: async (configService: ConfigService) => ({
              secret: configService.get<string>('JWT_SECRET'),
              signOptions: { expiresIn: '1h' },
            })
        })
    ],
    controllers: [
        UserController
    ],
    providers: [
        UserService
    ],
    exports: [
        UserService
    ],
})

export class UserModule {}