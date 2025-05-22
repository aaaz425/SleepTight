import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from 'src/app.module';
import { Repository } from 'typeorm';
import { getRepositoryToken } from '@nestjs/typeorm';
import { SleepEvent } from 'src/sleep-sound/entities/sleep-event.entity';
import * as fs from 'fs';
import * as path from 'path';
import { v4 as uuid } from 'uuid';

const JWT =
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZW1haWwiOiJ0ZXN0MUBrYWthby5jb20iLCJzdGF0dXMiOiJhY3RpdmUiLCJpYXQiOjE3MzkwNTkyMDAsImV4cCI6MTc3MDU5NTIwMH0._lDoAjX-Q0oDnL2tMY__n7sm4qx2od52PPHd0jjsmss';

describe('Sleep Sound E2E', () => {
  let app: INestApplication;
  let sleepEventRepo: Repository<SleepEvent>;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();

    sleepEventRepo = moduleFixture.get<Repository<SleepEvent>>(
      getRepositoryToken(SleepEvent),
    );
  });

  it('should execute full sleep flow with sound + events', async () => {
    // 1. 수면 시작
    const startRes = await request(app.getHttpServer())
      .post('/api/sleep-report/start-sleep')
      .set('Authorization', `Bearer ${JWT}`)
      .send({ sleep_start_time: '2025-05-17T22:00:00Z' });

    const reportId = startRes.body.data.reportId;
    console.log('startRes.body:', startRes.body);
    expect(reportId).toBeDefined();

    // 2. 수면 음성 업로드
    const segmentId = uuid();
    const uploadRes = await request(app.getHttpServer())
      .post('/api/sleep/sound')
      .set('Authorization', `Bearer ${JWT}`)
      .attach('file', path.resolve(__dirname, '__assets__/sample.opus'))
      .field('reportId', reportId)
      .field('segmentId', segmentId)
      .field('timestamp', '2025-05-17T22:30:00Z')
      .field('duration', 10);

    expect(uploadRes.body.success).toBe(true);

    // 3. 이벤트 수동 삽입
    const sleepEvent = sleepEventRepo.create({
      segmentId,
      startSec: 0,
      endSec: 5,
      inferenceTs: new Date(),
      anomaly: 'SNORE',
      confidence: 0.95,
    });
    await sleepEventRepo.save(sleepEvent);

    // 4. 수면 종료
    const endRes = await request(app.getHttpServer())
      .post('/api/sleep-report/end-sleep')
      .set('Authorization', `Bearer ${JWT}`)
      .send({
        reportId,
        sleepEndTime: '2025-05-18T06:00:00Z',
        stages: [
          {
            stageType: 'LIGHT',
            startTime: '2025-05-17T22:30:00Z',
            endTime: '2025-05-17T23:30:00Z',
          },
        ],
      });

    expect(endRes.body.data.isValidReport).toBe(true);

    // 5. 리포트 조회
    const reportRes = await request(app.getHttpServer())
      .get('/api/sleep-report/2025-05-17')
      .set('Authorization', `Bearer ${JWT}`);

    expect(reportRes.body.length).toBeGreaterThan(0);

    // 6. 분석 결과 조회
    const analysisRes = await request(app.getHttpServer())
      .get(`/api/sleep-report/events/${reportId}`)
      .set('Authorization', `Bearer ${JWT}`);

    expect(analysisRes.body.data.reportId).toBe(reportId);
    expect(analysisRes.body.data.sounds.length).toBeGreaterThan(0);
  });

  afterAll(async () => {
    await app.close();
  });
});
