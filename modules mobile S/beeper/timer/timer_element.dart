// lib/features/timer/timer_element.dart
// ✅ UI unchanged — logic unchanged (kept as-is)

import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import 'timer_widget.dart';

class TimerElement extends StatefulWidget {
  final GlobalKey<TimerWidgetState>? timerKey;
  final VoidCallback? onSessionFinished;

  const TimerElement({
    super.key,
    this.timerKey,
    this.onSessionFinished,
  });

  @override
  State<TimerElement> createState() => _TimerElementState();
}

class _TimerElementState extends State<TimerElement>
    with AutomaticKeepAliveClientMixin<TimerElement> {
  // Work (CD), Rest (CD), Remaining session (CD), Elapsed (CU)
  final StopWatchTimer _work = StopWatchTimer(mode: StopWatchMode.countDown);
  final StopWatchTimer _rest = StopWatchTimer(mode: StopWatchMode.countDown);
  final StopWatchTimer _remain = StopWatchTimer(mode: StopWatchMode.countDown);
  final StopWatchTimer _elapsed = StopWatchTimer(mode: StopWatchMode.countUp);

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _work.dispose();
    _rest.dispose();
    _remain.dispose();
    _elapsed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return TimerWidget(
      key: widget.timerKey,
      stopWatchTimer: _work,
      stopWatchTimer1: _rest,
      stopWatchTimer2: _remain,
      stopWatchTimer3: _elapsed,
      onSessionFinished: widget.onSessionFinished,
    );
  }
}
