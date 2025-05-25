import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class CustomAudioWave extends StatefulWidget {
  final Size size;
  final Stream<Uint8List>? pcmDataStream;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BoxDecoration? decoration;
  final Color? backgroundColor;

  const CustomAudioWave({
    super.key,
    required this.size,
    this.pcmDataStream,
    this.padding,
    this.margin,
    this.decoration,
    this.backgroundColor,
  });

  @override
  State<CustomAudioWave> createState() => _CustomAudioWaveState();
}

class _CustomAudioWaveState extends State<CustomAudioWave> {
  String _displayedPcmData = "PCM 데이터 수신 대기 중...";
  StreamSubscription<Uint8List>? _pcmStreamSubscription;

  // --- 쓰로틀링을 위한 변수들 ---
  Timer? _throttleTimer; // 쓰로틀링 타이머
  Uint8List? _latestPcmDataChunk; // 가장 최근에 수신된 PCM 데이터 청크
  bool _isNewDataAvailable = false; // 마지막 UI 업데이트 이후 새 데이터가 있는지 여부
  final Duration _throttleInterval = const Duration(seconds: 1); // 쓰로틀 간격: 1초
  // --- 쓰로틀링 변수 끝 ---

  @override
  void initState() {
    super.initState();
    if (widget.pcmDataStream != null) {
      debugPrint('CustomAudioWave initState: pcmDataStream 구독 시도.');
      _pcmStreamSubscription = widget.pcmDataStream!.listen(
        (Uint8List pcmData) {
          // debugPrint('AudioWaveforms 리스너: 데이터 수신됨 (쓰로틀 전). 크기: ${pcmData.length}');

          _latestPcmDataChunk = pcmData;
          _isNewDataAvailable = true;

          if (_throttleTimer == null || !_throttleTimer!.isActive) {
            _throttleTimer = Timer(_throttleInterval, _performUpdateUI);
          }
        },
        onError: (error) {
          debugPrint('AudioWaveforms 리스너: 스트림 오류 - $error');
          if (mounted) {
            setState(() {
              // 수정된 부분
              _displayedPcmData = "PCM 스트림 오류: $error";
            });
          }
        },
        onDone: () {
          debugPrint('AudioWaveforms 리스너: 스트림 완료.');
          if (mounted) {
            if (_isNewDataAvailable) {
              _performUpdateUI();
            }
            setState(() {
              // 수정된 부분
              if (!_displayedPcmData.startsWith("PCM Chunk")) {
                _displayedPcmData = "PCM 스트림이 종료되었습니다.";
              } else {
                _displayedPcmData += "\n(PCM 스트림 종료됨)";
              }
            });
          }
        },
      );
    } else {
      debugPrint('AudioWaveforms initState: pcmDataStream이 null입니다.');
      _displayedPcmData = "PCM 데이터 스트림이 제공되지 않았습니다.";
    }
  }

  void _performUpdateUI() {
    if (mounted && _isNewDataAvailable && _latestPcmDataChunk != null) {
      debugPrint('AudioWaveforms: UI 업데이트 수행 (쓰로틀됨).');
      setState(() {
        // 수정된 부분
        final pcmData = _latestPcmDataChunk!;
        int displayLength = pcmData.length > 30 ? 30 : pcmData.length;
        List<String> byteStrings = [];
        for (int i = 0; i < displayLength; i++) {
          byteStrings.add(
            pcmData[i].toRadixString(16).padLeft(2, '0').toUpperCase(),
          );
        }
        _displayedPcmData =
            "PCM Chunk (길이: ${pcmData.length} bytes):\n[ ${byteStrings.join(', ')}${pcmData.length > displayLength ? ', ...' : ''} ]";

        _isNewDataAvailable = false;
      });
    }
  }

  @override
  void dispose() {
    _pcmStreamSubscription?.cancel();
    _throttleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size.width,
      height: widget.size.height,
      padding: widget.padding ?? const EdgeInsets.all(16.0),
      margin: widget.margin,
      decoration: widget.decoration,
      color: widget.backgroundColor ?? Colors.grey[850],
      child: SingleChildScrollView(
        child: Text(
          _displayedPcmData,
          style: const TextStyle(
            fontSize: 11,
            fontFamily: 'monospace',
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
