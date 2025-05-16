import { Controller, Post, UseGuards, Body, Request } from '@nestjs/common';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';
import { ActivityDataService } from './activity-data.service';
import { UploadActivityDataRequestDto } from './dto/upload-activity-data.request.dto';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';

@ApiTags('Activity Data')
@Controller('activity-data')
export class ActivityDataController {
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
    await this.activityDataService.saveActivityData(userId, body);
    return {};
  }
}
