// lib/features/timer/timer_widget.dart
// ✅ UI refactor only — logic unchanged, NO localization
// ✅ Design match "dernier écran": glass sombre + accent Theme.primary + chips sobres
// ✅ AUCUN changement sur start/stop/reset/rounds/stop_watch_timer/beep

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class _TXT {
  static const String validationPrefix = "⚠️";
  static const String validationRoundsAndWork =
      "Veuillez saisir un nombre de rounds et une durée de travail valides.";

  static const String timerWork = "Travail";
  static const String workPeriod = "Période de travail";
  static const String restPeriod = "Repos";

  static const String intervals = "Intervalles";
  static const String remainingTime = "Temps restant";
  static const String time = "Temps";

  static const String start = "Démarrer";
  static const String stop = "Stop";
  static const String reset = "Réinitialiser";

  static const String timerSettings = "Paramètres du timer";
  static const String minutes = "Minutes";
  static const String seconds = "Secondes";
  static const String rounds = "Rounds";
  static const String timerHint =
      "Astuce : mets Repos à 0 si tu veux des intervalles Travail uniquement.";

  static const String restSubtitle = "Période de repos";
}

class TimerWidget extends StatefulWidget {
  final StopWatchTimer stopWatchTimer; // Work (CD)
  final StopWatchTimer stopWatchTimer1; // Rest (CD)
  final StopWatchTimer stopWatchTimer2; // Remaining (CD)
  final StopWatchTimer stopWatchTimer3; // Elapsed (CU)
  final VoidCallback? onSessionFinished;

  const TimerWidget({
    super.key,
    required this.stopWatchTimer,
    required this.stopWatchTimer1,
    required this.stopWatchTimer2,
    required this.stopWatchTimer3,
    this.onSessionFinished,
  });

  @override
  TimerWidgetState createState() => TimerWidgetState();
}

class TimerWidgetState extends State<TimerWidget>
    with AutomaticKeepAliveClientMixin<TimerWidget> {
  final secondsController = TextEditingController();
  final minutesController = TextEditingController();
  final secondsController1 = TextEditingController();
  final minutesController1 = TextEditingController();
  final roundsController = TextEditingController(text: "1");

  bool _isWorkPhase = true;
  int _roundCompleted = 0;
  bool _isRunning = false;

  late final AudioPlayer _audioPlayer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  int _safeInt(String? s) {
    final v = int.tryParse((s ?? "").trim()) ?? 0;
    if (v < 0) return 0;
    if (v > 9999) return 9999;
    return v;
  }

  int _toSeconds({required String? m, required String? s}) =>
      _safeInt(m) * 60 + _safeInt(s);

  @override
  void dispose() {
    secondsController.dispose();
    minutesController.dispose();
    secondsController1.dispose();
    minutesController1.dispose();
    roundsController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _beep() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/beep.mp3'));
    } catch (_) {}
  }

  void startFromParent() => _start();
  void stopFromParent() => _stopAll();
  void resetFromParent() => _resetAll();

  Future<void> _start() async {
    if (_isRunning) return;

    final rounds = _safeInt(roundsController.text);
    final workSec =
        _toSeconds(m: minutesController.text, s: secondsController.text);
    final restSec =
        _toSeconds(m: minutesController1.text, s: secondsController1.text);

    if (rounds <= 0 || workSec <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("${_TXT.validationPrefix} ${_TXT.validationRoundsAndWork}"),
        ),
      );
      return;
    }

    final total = (workSec + (restSec > 0 ? restSec : 0)) * rounds;

    setState(() {
      _isRunning = true;
      _roundCompleted = 0;
      _isWorkPhase = true;
    });

    widget.stopWatchTimer2.setPresetTime(
      add: false,
      mSec: StopWatchTimer.getMilliSecFromSecond(total),
    );
    widget.stopWatchTimer2.onStartTimer();

    widget.stopWatchTimer3.onResetTimer();
    widget.stopWatchTimer3.onStartTimer();

    for (int i = 0; i < rounds; i++) {
      if (!mounted) return;

      await _beep();
      if (!mounted) return;

      setState(() => _isWorkPhase = true);
      widget.stopWatchTimer.setPresetTime(
        add: false,
        mSec: StopWatchTimer.getMilliSecFromSecond(workSec),
      );
      widget.stopWatchTimer.onStartTimer();
      await widget.stopWatchTimer.fetchEnded.first;
      if (!mounted) return;

      if (restSec > 0) {
        await _beep();
        if (!mounted) return;

        setState(() => _isWorkPhase = false);
        widget.stopWatchTimer1.setPresetTime(
          add: false,
          mSec: StopWatchTimer.getMilliSecFromSecond(restSec),
        );
        widget.stopWatchTimer1.onStartTimer();
        await widget.stopWatchTimer1.fetchEnded.first;
        if (!mounted) return;
      }

      widget.stopWatchTimer.onResetTimer();
      widget.stopWatchTimer1.onResetTimer();

      if (!mounted) return;
      setState(() => _roundCompleted = i + 1);
    }

    await _beep();

    widget.stopWatchTimer.onStopTimer();
    widget.stopWatchTimer1.onStopTimer();
    widget.stopWatchTimer2.onStopTimer();
    widget.stopWatchTimer3.onStopTimer();

    if (!mounted) return;
    setState(() {
      _isRunning = false;
      _isWorkPhase = true;
    });

    widget.onSessionFinished?.call();
  }

  void _stopAll() {
    widget.stopWatchTimer.onStopTimer();
    widget.stopWatchTimer1.onStopTimer();
    widget.stopWatchTimer2.onStopTimer();
    widget.stopWatchTimer3.onStopTimer();

    if (mounted) setState(() => _isRunning = false);
  }

  void _resetAll() {
    _stopAll();
    widget.stopWatchTimer.onResetTimer();
    widget.stopWatchTimer1.onResetTimer();
    widget.stopWatchTimer2.onResetTimer();
    widget.stopWatchTimer3.onResetTimer();
    if (mounted) {
      setState(() {
        _roundCompleted = 0;
        _isWorkPhase = true;
      });
    }
  }

  String _mmss(int rawMs) =>
      StopWatchTimer.getDisplayTime(rawMs, hours: false, milliSecond: false);

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final t = Theme.of(context);
    final cs = t.colorScheme;

    final workPanel = _phasePanel(
      title: "🏋️ ${_TXT.timerWork}",
      subtitle: _TXT.workPeriod,
      stream: widget.stopWatchTimer.rawTime,
      initial: widget.stopWatchTimer.rawTime.value,
      icon: Icons.fitness_center_rounded,
      accent: cs.primary,
    );

    final restPanel = _phasePanel(
      title: "🪑 ${_TXT.restPeriod}",
      subtitle: _TXT.restSubtitle,
      stream: widget.stopWatchTimer1.rawTime,
      initial: widget.stopWatchTimer1.rawTime.value,
      icon: Icons.self_improvement_rounded,
      accent: cs.primary,
    );

    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Glass(
            radius: 20,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  transitionBuilder: (child, animation) {
                    final offsetAnimation = Tween<Offset>(
                      begin: const Offset(0.15, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                    );
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(position: offsetAnimation, child: child),
                    );
                  },
                  child: _isWorkPhase
                      ? KeyedSubtree(key: const ValueKey('work'), child: workPanel)
                      : KeyedSubtree(key: const ValueKey('rest'), child: restPanel),
                ),
                const SizedBox(height: 12),

                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _StatChip(
                      icon: Icons.repeat_rounded,
                      label: _TXT.intervals,
                      value: "$_roundCompleted/${roundsController.text}",
                      accent: cs.primary,
                    ),
                    StreamBuilder<int>(
                      stream: widget.stopWatchTimer2.rawTime,
                      initialData: widget.stopWatchTimer2.rawTime.value,
                      builder: (_, s) => _StatChip(
                        icon: Icons.hourglass_bottom_rounded,
                        label: _TXT.remainingTime,
                        value: _mmss(s.data ?? 0),
                        accent: cs.primary,
                      ),
                    ),
                    StreamBuilder<int>(
                      stream: widget.stopWatchTimer3.rawTime,
                      initialData: widget.stopWatchTimer3.rawTime.value,
                      builder: (_, s) => _StatChip(
                        icon: Icons.timer_rounded,
                        label: _TXT.time,
                        value: _mmss(s.data ?? 0),
                        accent: cs.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _PrimaryButton(
                        icon: Icons.play_arrow_rounded,
                        label: _TXT.start,
                        enabled: !_isRunning,
                        onTap: _isRunning ? null : _start,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SecondaryButton(
                        icon: Icons.stop_rounded,
                        label: _TXT.stop,
                        enabled: _isRunning,
                        onTap: _isRunning ? _stopAll : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                _GhostButton(
                  icon: Icons.refresh_rounded,
                  label: _TXT.reset,
                  onTap: _resetAll,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          if (!_isRunning)
            _Glass(
              radius: 20,
              padding: const EdgeInsets.all(14),
              child: LayoutBuilder(
                builder: (_, c) {
                  final twoCols = c.maxWidth >= 640;

                  Widget row2(Widget a, Widget b) => twoCols
                      ? Row(
                          children: [
                            Expanded(child: a),
                            const SizedBox(width: 12),
                            Expanded(child: b),
                          ],
                        )
                      : Column(
                          children: [
                            a,
                            const SizedBox(height: 10),
                            b,
                          ],
                        );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _TXT.timerSettings,
                        style: t.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withOpacity(0.96),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Text(
                        "🏋️ ${_TXT.workPeriod}",
                        style: t.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withOpacity(0.78),
                        ),
                      ),
                      const SizedBox(height: 8),
                      row2(
                        _GlassNumberField(label: _TXT.minutes, ctl: minutesController),
                        _GlassNumberField(label: _TXT.seconds, ctl: secondsController),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        "🪑 ${_TXT.restPeriod}",
                        style: t.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withOpacity(0.78),
                        ),
                      ),
                      const SizedBox(height: 8),
                      row2(
                        _GlassNumberField(label: _TXT.minutes, ctl: minutesController1),
                        _GlassNumberField(label: _TXT.seconds, ctl: secondsController1),
                      ),

                      const SizedBox(height: 14),

                      _GlassNumberField(
                        label: "🔁 ${_TXT.rounds}",
                        ctl: roundsController,
                        hint: "1",
                      ),

                      const SizedBox(height: 10),

                      Text(
                        _TXT.timerHint,
                        style: t.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.66),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _phasePanel({
    required String title,
    required String subtitle,
    required Stream<int> stream,
    required int initial,
    required IconData icon,
    required Color accent,
  }) {
    return _Glass(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              _LeadingBadge(icon: icon, accent: accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: Colors.white.withOpacity(0.96),
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withOpacity(0.70),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          StreamBuilder<int>(
            stream: stream,
            initialData: initial,
            builder: (_, snap) {
              final raw = snap.data ?? 0;
              final display = _mmss(raw);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.white.withOpacity(0.08),
                  border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
                ),
                child: Center(
                  child: Text(
                    display,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: Colors.white.withOpacity(0.96),
                        ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// ---------------- UI kit (same as "dernier écran") ----------------

class _Glass extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsets padding;

  const _Glass({
    required this.child,
    this.radius = 18,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isDark = t.brightness == Brightness.dark;

    final bg =
        isDark ? Colors.white.withOpacity(0.07) : Colors.white.withOpacity(0.10);
    final border =
        isDark ? Colors.white.withOpacity(0.10) : Colors.white.withOpacity(0.14);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: bg,
            border: Border.all(color: border, width: 1),
            boxShadow: [
              BoxShadow(
                blurRadius: 22,
                color: Colors.black.withOpacity(0.25),
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _LeadingBadge extends StatelessWidget {
  final IconData icon;
  final Color accent;

  const _LeadingBadge({
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.10),
        border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            color: Colors.black.withOpacity(0.22),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: accent.withOpacity(0.92), size: 22),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withOpacity(0.10),
        border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.10),
              border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
            ),
            child: Icon(icon, size: 14, color: accent.withOpacity(0.92)),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: t.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.70),
                ),
              ),
              Text(
                value,
                style: t.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withOpacity(0.96),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: enabled
          ? () {
              HapticFeedback.lightImpact();
              onTap?.call();
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(enabled ? 0.12 : 0.08),
          border: Border.all(
            color: Colors.white.withOpacity(enabled ? 0.16 : 0.12),
            width: 1,
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    blurRadius: 18,
                    color: Colors.black.withOpacity(0.25),
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: cs.primary.withOpacity(enabled ? 0.92 : 0.55), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: t.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(enabled ? 0.94 : 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: enabled
          ? () {
              HapticFeedback.lightImpact();
              onTap?.call();
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFFE11D48).withOpacity(enabled ? 0.22 : 0.12),
          border: Border.all(
            color: const Color(0xFFE11D48).withOpacity(enabled ? 0.35 : 0.20),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.stop_rounded, color: Color(0xFFE11D48), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: t.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(enabled ? 0.94 : 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _GhostButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.10),
          border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.78), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: t.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(0.78),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassNumberField extends StatelessWidget {
  final String label;
  final TextEditingController ctl;
  final String hint;

  const _GlassNumberField({
    required this.label,
    required this.ctl,
    this.hint = "0",
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: t.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.white.withOpacity(0.70),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctl,
          keyboardType: TextInputType.number,
          style: t.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: Colors.white.withOpacity(0.96),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.10),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: cs.primary.withOpacity(0.85), width: 1.2),
            ),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
          ),
        ),
      ],
    );
  }
}
