import {
  Controller,
  Post,
  UseGuards,
  Body,
  Request,
  Logger,
} from '@nestjs/common';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';
import { ActivityDataService } from './activity-data.service';
import { UploadActivityDataRequestDto } from './dto/upload-activity-data.request.dto';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';

@ApiTags('Activity Data')
@Controller('activity-data')
export class ActivityDataController {
  private readonly logger = new Logger(ActivityDataController.name);

  constructor(private readonly activityDataService: ActivityDataService) {}

  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Post()
  @ApiOperation({ summary: '활동 데이터' })
  async uploadActivityData(
    @Request() req,
    @Body() body: UploadActivityDataRequestDto,
  ): Promise<{}> {
    const userId = req.user.userId;
    this.logger.log(
      `활동 데이터 업로드 요청 - userId: ${userId}, records: ${body.records.length}`,
    );

    try {
      await this.activityDataService.saveActivityData(userId, body);
      this.logger.log(`활동 데이터 업로드 성공 - userId: ${userId}`);
      return {};
    } catch (error) {
      this.logger.error(
        `활동 데이터 업로드 실패 - userId: ${userId}`,
        error.stack,
      );
      throw error;
    }
  }
}
