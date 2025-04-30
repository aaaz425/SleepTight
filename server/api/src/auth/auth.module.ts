import { Module } from "@nestjs/common";
import { AuthController } from "./auth.controller";
import { AuthService } from "./auth.service";
import { UserModule } from "src/users/user.module";
import { HttpModule } from "@nestjs/axios";
import { JwtModule } from "@nestjs/jwt";

@Module({
    imports: [
        UserModule,
        HttpModule,
        JwtModule,
    ],
    controllers: [
        AuthController
    ],
    providers: [
        AuthService
    ],
})

export class AuthModule {}