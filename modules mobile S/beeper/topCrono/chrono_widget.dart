// lib/features/beeper/topCrono/chrono_widget.dart
// ✅ Keep logic unchanged — UI aligned with premium screens
// ✅ NO gradients, uses Theme.primary accent + glass surfaces

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';

class ChronoWidget extends StatefulWidget {
  final String title;
  const ChronoWidget({super.key, required this.title});

  @override
  State<ChronoWidget> createState() => _ChronoWidgetState();
}

class _ChronoWidgetState extends State<ChronoWidget> {
  Duration _elapsed = Duration.zero;
  bool _running = false;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker((_) {
      if (!_running) return;
      if (!mounted) return;
      setState(() => _elapsed += const Duration(milliseconds: 16));
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _start() {
    HapticFeedback.lightImpact();
    setState(() => _running = true);
  }

  void _stop() {
    HapticFeedback.selectionClick();
    setState(() => _running = false);
  }

  void _reset() {
    HapticFeedback.mediumImpact();
    setState(() {
      _running = false;
      _elapsed = Duration.zero;
    });
  }

  String _fmt(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final cs = (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    return "$mm:$ss:$cs";
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return _Glass(
      radius: 20,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "⏱️ ${widget.title}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.96),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _StateChip(
                text: _running ? "RUN" : "STOP",
                running: _running,
                accent: cs.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white.withOpacity(0.08),
              border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
            ),
            child: Center(
              child: Text(
                _fmt(_elapsed),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                  color: Colors.white.withOpacity(0.96),
                ),
              ),
            ),
          ),

          const Spacer(),

          Row(
            children: [
              Expanded(
                child: _PrimaryButton(
                  icon: Icons.play_arrow_rounded,
                  label: "Start",
                  enabled: !_running,
                  onTap: _running ? null : _start,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DangerButton(
                  icon: Icons.stop_rounded,
                  label: "Stop",
                  enabled: _running,
                  onTap: _running ? _stop : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _GhostButton(
            icon: Icons.refresh_rounded,
            label: "Reset",
            onTap: _reset,
          ),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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

class _DangerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  const _DangerButton({
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
            Icon(icon,
                size: 20,
                color: enabled ? const Color(0xFFE11D48) : const Color(0xFFE11D48).withOpacity(0.6)),
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
