// lib/features/beeper/topCrono/actual_game_widget.dart
// ✅ Keep logic unchanged — UI aligned with premium screens
// ✅ NO gradients, uses Theme.primary accent + glass surfaces
// ✅ No TabBar here; just widget UI

import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ActualGameTimeWidget extends StatefulWidget {
  const ActualGameTimeWidget({super.key});

  @override
  State<ActualGameTimeWidget> createState() => _ActualGameTimeWidgetState();
}

class _ActualGameTimeWidgetState extends State<ActualGameTimeWidget> {
  Timer? _ticker;

  Duration _elapsed = Duration.zero;
  bool _running = false;
  int _period = 1;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_running) return;
      if (!mounted) return;
      setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    setState(() => _running = !_running);
  }

  void _reset() {
    HapticFeedback.mediumImpact();
    setState(() {
      _running = false;
      _elapsed = Duration.zero;
      _period = 1;
    });
  }

  void _nextPeriod() {
    HapticFeedback.selectionClick();
    setState(() => _period = (_period == 1) ? 2 : 1);
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    if (h > 0) return '$h:$m:$s';
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool hasBoundedHeight =
            constraints.hasBoundedHeight && constraints.maxHeight.isFinite;
        const double fallbackMaxHeight = 320.0;
        final double effectiveMaxHeight =
            hasBoundedHeight ? constraints.maxHeight : fallbackMaxHeight;

        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: effectiveMaxHeight),
          child: _Glass(
            radius: 20,
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _PillTag(
                      icon: Icons.flag_rounded,
                      text: _period == 1 ? '1ère période' : '2ème période',
                      accent: cs.primary,
                    ),
                    const Spacer(),
                    _StateChip(
                      text: _running ? 'En cours' : 'Pause',
                      running: _running,
                      accent: cs.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white.withOpacity(0.08),
                    border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
                  ),
                  child: Center(
                    child: Text(
                      _fmt(_elapsed),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white.withOpacity(0.96),
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _StatChip(
                              icon: Icons.flag_rounded,
                              label: 'Période',
                              value: _period.toString(),
                              accent: cs.primary,
                            ),
                            _StatChip(
                              icon: Icons.timelapse_rounded,
                              label: 'Minutes',
                              value: _elapsed.inMinutes.toString(),
                              accent: cs.primary,
                            ),
                            _StatChip(
                              icon: Icons.timer_rounded,
                              label: 'Secondes',
                              value: (_elapsed.inSeconds % 60).toString(),
                              accent: cs.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: _PrimaryButton(
                                icon: _running ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                label: _running ? 'Pause' : 'Start',
                                onTap: _toggle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _DangerButton(
                                icon: Icons.restart_alt_rounded,
                                label: 'Reset',
                                onTap: _reset,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _GhostButton(
                          icon: Icons.swap_horiz_rounded,
                          label: 'Changer période',
                          onTap: _nextPeriod,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/* ---------------- UI kit ---------------- */

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

    final bg = isDark ? Colors.white.withOpacity(0.07) : Colors.white.withOpacity(0.10);
    final border = isDark ? Colors.white.withOpacity(0.10) : Colors.white.withOpacity(0.14);

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

class _PillTag extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color accent;

  const _PillTag({
    required this.icon,
    required this.text,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withOpacity(0.10),
        border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: accent.withOpacity(0.92)),
          const SizedBox(width: 8),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.94),
            ),
          ),
        ],
      ),
    );
  }
}

class _StateChip extends StatelessWidget {
  final String text;
  final bool running;
  final Color accent;

  const _StateChip({
    required this.text,
    required this.running,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: running ? accent.withOpacity(0.18) : Colors.white.withOpacity(0.10),
        border: Border.all(
          color: running ? accent.withOpacity(0.35) : Colors.white.withOpacity(0.14),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: t.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w900,
          color: running ? Colors.white.withOpacity(0.94) : Colors.white.withOpacity(0.78),
        ),
      ),
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
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

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
          color: Colors.white.withOpacity(0.12),
          border: Border.all(color: Colors.white.withOpacity(0.16), width: 1),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              color: Colors.black.withOpacity(0.25),
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: cs.primary.withOpacity(0.92), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: t.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(0.94),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DangerButton({
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
          color: const Color(0xFFE11D48).withOpacity(0.22),
          border: Border.all(color: const Color(0xFFE11D48).withOpacity(0.35), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFE11D48), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: t.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(0.94),
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
