import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:sleep_tight/features/sleep_mode/presentation/widgets/pcm_wave_painter.dart';

// 이 위젯은 외부에서 pcmDataStream 등을 받아오는 StatefulWidget이라고 가정합니다.
// 예시를 위해 간단한 형태로 정의합니다.
class CustomAudioWave extends StatefulWidget {
  final Stream<Uint8List>? pcmDataStream;
  final Size size;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxDecoration? decoration;
  // 추가적인 스타일링 파라미터 (색상 등)를 여기에 추가할 수 있습니다.
  final Color currentWaveColor;
  final Color previousWaveColor;

  const CustomAudioWave({
    super.key,
    required this.pcmDataStream,
    this.size = const Size(double.infinity, 100.0), // 기본 크기
    this.padding,
    this.margin,
    this.decoration,
    this.currentWaveColor = Colors.cyan,
    this.previousWaveColor = Colors.blueAccent,
  });

  @override
  CustomAudioWaveState createState() => CustomAudioWaveState();
}

class CustomAudioWaveState extends State<CustomAudioWave>
    with SingleTickerProviderStateMixin {
  StreamSubscription<Uint8List>? _pcmStreamSubscription;
  Timer? _throttleTimer;
  Uint8List? _latestPcmDataChunk;
  bool _isNewDataAvailable = false;
  final Duration _throttleInterval = const Duration(
    milliseconds: 2000,
  ); // UI 업데이트 간격 (애니메이션과 별개로 데이터 수신 간격)

  // 애니메이션을 위한 상태 변수
  late AnimationController _animationController;
  late Animation<double> _animation;
  final Duration _animationDuration = const Duration(
    milliseconds: 2000,
  ); // 애니메이션 지속 시간

  Uint8List? _currentPcmAnimatingFrom;
  Uint8List? _previousPcmAnimatingFrom;
  Uint8List? _currentPcmTarget;
  Uint8List? _previousPcmTarget;

  // (선택) 디버깅용 텍스트
  String _displayedPcmData = "PCM 데이터 수신 대기 중...";

  @override
  void initState() {
    super.initState();

    // AnimationController와 Animation은 먼저 초기화합니다.
    // 이 시점에서 'this' (vsync)는 유효해야 합니다.
    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // 스트림 구독 및 관련 로직은 첫 프레임이 그려진 후에 실행합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 이 시점에서는 위젯이 마운트되었고, _animationController가 초기화된 상태입니다.
      if (mounted) {
        // 콜백 시점에도 mounted 상태인지 확인하는 것이 좋습니다.
        if (widget.pcmDataStream != null) {
          debugPrint(
            'CustomAudioWave initState (post-frame): pcmDataStream 구독 시도.',
          );
          _pcmStreamSubscription = widget.pcmDataStream!.listen(
            (Uint8List pcmData) {
              _latestPcmDataChunk = pcmData;
              _isNewDataAvailable = true;

              if (_throttleTimer == null || !_throttleTimer!.isActive) {
                // _animationController가 null이 아님을 이제 확신할 수 있습니다.
                _throttleTimer = Timer(_throttleInterval, _performUpdateUI);
              }
            },
            onError: (error) {
              debugPrint('CustomAudioWave 리스너: 스트림 오류 - $error');
              if (mounted) {
                setState(() {
                  _displayedPcmData = "PCM 스트림 오류: $error";
                });
              }
            },
            onDone: () {
              debugPrint('CustomAudioWave 리스너: 스트림 완료.');
              if (mounted) {
                if (_isNewDataAvailable) {
                  _performUpdateUI(); // 마지막 데이터 처리
                }
                // 스트림 종료 시 처리 (필요에 따라)
                // setState(() {
                //   _displayedPcmData += "\n(PCM 스트림 종료됨)";
                // });
              }
            },
          );
        } else {
          debugPrint(
            'CustomAudioWave initState (post-frame): pcmDataStream이 null입니다.',
          );
          // setState는 build 메소드를 다시 호출하므로, 여기서 UI 업데이트가 필요하면 사용합니다.
          setState(() {
            _displayedPcmData = "PCM 데이터 스트림이 제공되지 않았습니다.";
          });
        }
      }
    });
  }

  void _performUpdateUI() {
    if (mounted && _isNewDataAvailable && _latestPcmDataChunk != null) {
      // debugPrint('CustomAudioWave: UI 업데이트 및 애니메이션 시작');
      setState(() {
        _currentPcmAnimatingFrom = _currentPcmTarget;
        _previousPcmAnimatingFrom = _previousPcmTarget;

        _previousPcmTarget = _currentPcmTarget;
        _currentPcmTarget = _latestPcmDataChunk;

        if (_currentPcmAnimatingFrom == null && _currentPcmTarget != null) {
          _currentPcmAnimatingFrom = _currentPcmTarget;
        }
        if (_previousPcmAnimatingFrom == null && _previousPcmTarget != null) {
          _previousPcmAnimatingFrom = _previousPcmTarget;
        }

        // (선택) 디버깅용 텍스트 업데이트
        if (_currentPcmTarget != null) {
          final pcmData = _currentPcmTarget!;
          int displayLength = pcmData.length > 10 ? 10 : pcmData.length;
          List<String> byteStrings = [];
          for (int i = 0; i < displayLength; i++) {
            byteStrings.add(
              pcmData[i].toRadixString(16).padLeft(2, '0').toUpperCase(),
            );
          }
          _displayedPcmData =
              "PCM (len: ${pcmData.length}): [${byteStrings.join(', ')}${pcmData.length > displayLength ? ', ...' : ''} ]";
        }

        _isNewDataAvailable = false;
        _animationController.forward(from: 0.0);
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pcmStreamSubscription?.cancel();
    _throttleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size.width,
      height: widget.size.height,
      padding: widget.padding ?? EdgeInsets.zero,
      margin: widget.margin,
      decoration: widget.decoration,

      child: AnimatedBuilder(
        // AnimatedBuilder로 CustomPaint를 감싸서 애니메이션 값 변경 시 다시 그리도록 함
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            size: widget.size,
            painter: PcmWavePainter(
              // 애니메이션 시작/종료 PCM 데이터와 현재 애니메이션 값을 전달
              currentPcmStart: _currentPcmAnimatingFrom,
              currentPcmTarget: _currentPcmTarget,
              previousPcmStart: _previousPcmAnimatingFrom,
              previousPcmTarget: _previousPcmTarget,
              animationValue: _animation.value, // 0.0 ~ 1.0 사이의 값
              // 위젯으로부터 색상 및 스타일 파라미터 전달
              waveColor1: widget.currentWaveColor,
              waveColor2: widget.previousWaveColor,
            ),
          );
        },
      ),
    );
  }
}
