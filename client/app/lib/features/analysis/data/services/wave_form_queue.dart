class WaveformQueue {
  bool _isRunning = false;
  final List<Future<void> Function()> _queue = [];

  void add(Future<void> Function() task) {
    _queue.add(task);
    _run();
  }

  void _run() async {
    if (_isRunning || _queue.isEmpty) return;
    _isRunning = true;

    while (_queue.isNotEmpty) {
      final task = _queue.removeAt(0);
      try {
        await task();
        // 🔐 MediaCodec 안정화 시간 약간 확보
        await Future.delayed(Duration(milliseconds: 300));
      } catch (e) {
        print('❌ 큐 작업 중 오류: $e');
      }
    }

    _isRunning = false;
  }
}
