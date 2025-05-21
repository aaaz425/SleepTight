import { Module } from '@nestjs/common';
import { FcmService } from './fcm.service';
import { UserModule } from 'src/users/user.module';

@Module({
  imports:[UserModule],
  providers: [FcmService],
  exports: [FcmService],
})
export class FcmModule {}