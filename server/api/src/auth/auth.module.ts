import { Module } from "@nestjs/common";
import { AuthController } from "./auth.controller";
import { AuthService } from "./auth.service";
import { UserModule } from "src/users/user.module";
import { HttpModule } from "@nestjs/axios";
import { JwtModule } from "@nestjs/jwt";
import { TypeOrmModule } from "@nestjs/typeorm";
import { User } from "src/users/entities/user.entity";
import { ConfigModule, ConfigService } from "@nestjs/config";
import { JwtStrategy } from "./jwt.strategy";

@Module({
    imports: [
        TypeOrmModule.forFeature([User]),
        HttpModule,
        ConfigModule,
        JwtModule.registerAsync({
            imports: [ConfigModule],
            inject: [ConfigService],
            useFactory: async (configService: ConfigService) => ({
              secret: configService.get<string>('JWT_SECRET'),
              signOptions: { expiresIn: configService.get<string>("ACCESS_TOKEN_EXPIRES_IN") }, //기본 설정 만료기간
            })
        })
    ],
    controllers: [
        AuthController
    ],
    providers: [
        AuthService,
        JwtStrategy
    ],
})

export class AuthModule {}