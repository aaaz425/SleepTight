import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui'; // lerpDouble을 위해 필요
import 'package:flutter/material.dart';

class PcmWavePainter extends CustomPainter {
  final Uint8List? currentPcmStart;
  final Uint8List? currentPcmTarget;
  final Uint8List? previousPcmStart;
  final Uint8List? previousPcmTarget;
  final double animationValue;

  final Color waveColor1;
  final Color waveColor2;
  final double strokeWidth;

  PcmWavePainter({
    required this.currentPcmStart,
    required this.currentPcmTarget,
    required this.previousPcmStart,
    required this.previousPcmTarget,
    required this.animationValue,
    this.waveColor1 = Colors.transparent,
    this.waveColor2 = Colors.transparent,
    this.strokeWidth = 0.2,
  });

  List<double> _calculateSegmentAverages(Uint8List? pcmData, int numSegments) {
    List<double> segmentAverages = List.filled(numSegments, 0.5);
    if (pcmData == null || pcmData.isEmpty) {
      return segmentAverages;
    }

    int pcmLength = pcmData.length;
    if (pcmLength > 0) {
      double samplesPerSegmentReal = pcmLength / numSegments.toDouble();
      for (int i = 0; i < numSegments; i++) {
        double currentSegmentSum = 0;
        int startSampleIndex = (i * samplesPerSegmentReal).floor();
        int endSampleIndex = ((i + 1) * samplesPerSegmentReal).floor() - 1;
        startSampleIndex = math.max(0, startSampleIndex);
        endSampleIndex = math.min(pcmLength - 1, endSampleIndex);
        int countInSegment = 0;
        if (startSampleIndex < pcmLength &&
            endSampleIndex >= startSampleIndex) {
          for (int j = startSampleIndex; j <= endSampleIndex; j++) {
            currentSegmentSum += pcmData[j];
            countInSegment++;
          }
        }
        if (countInSegment > 0) {
          segmentAverages[i] = (currentSegmentSum / countInSegment) / 255.0;
        }
      }
    }
    return segmentAverages;
  }

  List<double> _getInterpolatedAverages(
    Uint8List? pcmStartData,
    Uint8List? pcmTargetData,
    int numSegments,
    double animValue,
  ) {
    List<double> averagesStart = _calculateSegmentAverages(
      pcmStartData,
      numSegments,
    );
    List<double> averagesTarget = _calculateSegmentAverages(
      pcmTargetData,
      numSegments,
    );

    List<double> interpolatedAverages = [];
    for (int i = 0; i < numSegments; i++) {
      interpolatedAverages.add(
        lerpDouble(averagesStart[i], averagesTarget[i], animValue) ?? 0.5,
      );
    }
    return interpolatedAverages;
  }

  Path _buildPathFromAverages(
    List<double> interpolatedAverages,
    Size size,
    double yOffsetFactor,
    bool reverse,
  ) {
    Path path = Path();
    final int numSegments = interpolatedAverages.length;

    if (numSegments == 0) {
      double middleY = size.height * yOffsetFactor;
      path.moveTo(0, middleY);
      path.lineTo(size.width, middleY);
      return path;
    }

    List<Offset> points = [];
    double stepX =
        (numSegments > 1) ? size.width / (numSegments - 1) : size.width;
    double amplitude = size.height * 0.20;
    double baseY = size.height * yOffsetFactor;

    for (int i = 0; i < numSegments; i++) {
      double x = i * stepX;
      double yValue = baseY + (interpolatedAverages[i] * 2.0 - 1.0) * amplitude;
      points.add(Offset(x, yValue));
    }

    if (points.isEmpty) {
      double middleY = size.height * yOffsetFactor;
      path.moveTo(0, middleY);
      path.lineTo(size.width, middleY);
      return path;
    }
    if (points.length == 1) {
      path.moveTo(points.first.dx, points.first.dy);
      path.lineTo(points.first.dx, points.first.dy);
      return path;
    }

    if (reverse) {
      points = points.reversed.toList();
    }

    path.moveTo(points.first.dx, points.first.dy);
    double tension = 0.25;
    for (int i = 0; i < points.length - 1; i++) {
      Offset p0, p1, p2, p3;
      p1 = points[i];
      p2 = points[i + 1];
      p0 = (i == 0) ? p1 : points[i - 1];
      p3 = (i + 2 < points.length) ? points[i + 2] : p2;

      double cp1x = p1.dx + (p2.dx - p0.dx) * tension;
      double cp1y = p1.dy + (p2.dy - p0.dy) * tension;
      double cp2x = p2.dx - (p3.dx - p1.dx) * tension;
      double cp2y = p2.dy - (p3.dy - p1.dy) * tension;

      if (i == 0) {
        cp1x = p1.dx + (p2.dx - p1.dx) * (tension * 1.5);
        cp1y = p1.dy + (p2.dy - p1.dy) * (tension * 1.5);
      }
      if (i == points.length - 2) {
        cp2x = p2.dx - (p2.dx - p1.dx) * (tension * 1.5);
        cp2y = p2.dy - (p2.dy - p1.dy) * (tension * 1.5);
      }

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint currentWavePaint =
        Paint()
          ..color = waveColor1
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;
    final Paint previousWavePaint =
        Paint()
          ..color = waveColor2
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;

    // --- 그라데이션 설정 시작 ---
    // 1. 그라데이션 색상 정의 (Hex 코드로부터 Color 객체 생성)
    final Color gradientColor1 = Color(0xFF002484); // #002484
    final Color gradientColor2 = Color(0xFF7B9FFF); // #7B9FFF

    // 2. 그라데이션 적용 범위 정의 (여기서는 전체 캔버스 높이)
    final Rect gradientRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // 3. LinearGradient 객체 생성
    final LinearGradient fillGradient = LinearGradient(
      colors: [gradientColor1, gradientColor2],
      begin: Alignment.topCenter, // 그라데이션 시작점 (위쪽 중앙)
      end: Alignment.bottomCenter, // 그라데이션 끝점 (아래쪽 중앙)
      // stops: [0.0, 1.0], // 필요에 따라 색상 중단점 설정 가능
    );

    // 4. 그라데이션을 사용하는 Paint 객체 생성
    final Paint fillAreaPaint =
        Paint()
          // .color = Colors.white // 셰이더 사용 시 기본 색상 설정은 선택 사항 (셰이더가 덮어씀)
          ..shader = fillGradient.createShader(gradientRect) // Paint에 셰이더 적용
          ..style = PaintingStyle.fill;
    // --- 그라데이션 설정 끝 ---

    // 참고: 위와 같이 fillAreaPaint에 shader를 직접 설정하면,
    // PcmWavePainter 생성자로 전달된 this.fillColor는 이 채우기 영역에는 사용되지 않습니다.

    final int numSegmentsForAveraging = 20;

    List<double> currentInterpolatedAverages = _getInterpolatedAverages(
      currentPcmStart,
      currentPcmTarget,
      numSegmentsForAveraging,
      animationValue,
    );
    Path currentWavePath = _buildPathFromAverages(
      currentInterpolatedAverages,
      size,
      0.5,
      false,
    );

    List<double> previousInterpolatedAverages = _getInterpolatedAverages(
      previousPcmStart,
      previousPcmTarget,
      numSegmentsForAveraging,
      animationValue,
    );
    Path previousWavePath = _buildPathFromAverages(
      previousInterpolatedAverages,
      size,
      0.5,
      false,
    );
    Path previousWavePathReversed = _buildPathFromAverages(
      previousInterpolatedAverages,
      size,
      0.5,
      true,
    );

    bool canDrawCurrent = currentPcmTarget != null || currentPcmStart != null;
    bool canDrawPrevious =
        previousPcmTarget != null || previousPcmStart != null;

    if (canDrawCurrent && canDrawPrevious) {
      Path fillPath = Path();
      fillPath.addPath(currentWavePath, Offset.zero);
      fillPath.addPath(previousWavePathReversed, Offset.zero);
      fillPath.close();
      // 이제 fillAreaPaint는 그라데이션 셰이더를 가집니다.
      canvas.drawPath(fillPath, fillAreaPaint);
    }

    if (canDrawCurrent) {
      canvas.drawPath(currentWavePath, currentWavePaint);
    }
    if (canDrawPrevious) {
      canvas.drawPath(previousWavePath, previousWavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant PcmWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.currentPcmStart != currentPcmStart ||
        oldDelegate.currentPcmTarget != currentPcmTarget ||
        oldDelegate.previousPcmStart != previousPcmStart ||
        oldDelegate.previousPcmTarget != previousPcmTarget ||
        oldDelegate.waveColor1 != waveColor1 ||
        oldDelegate.waveColor2 != waveColor2 ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
