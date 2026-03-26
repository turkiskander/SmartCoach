// lib/features/timer/timer_view.dart
// ✅ UI redesign ONLY — LOGIC unchanged (same timers, same beep, same auto-next behavior)
// ✅ NO TabBar / NO TabBarView
// ✅ Modern layout: single premium page + accordion sections + auto-scroll to next
// ✅ Background = ONLY assets/images/BgHome.jfif (no extra layers under it)

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

import 'timer_element.dart';
import 'timer_widget.dart';

class _TXT {
  static const String titleAppBar = "One session timer";

  static const List<String> tabs = [
    "🔥 Getting started",
    "💪 General warm-up",
    "🏃 Running",
    "🧘 Mobility",
    "⚙️ Custom A",
    "⚙️ Custom B",
  ];

  static const String sessionControlsTitle = "Session controls";
  static const String start = "Start";
  static const String stop = "Stop";
  static const String clear = "Clear";

  static const String sessionFinishedAllTabs = "Session finished (all tabs).";
}

class TimerView extends StatefulWidget {
  const TimerView({super.key});

  @override
  State<TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  late final List<String> _tabs;
  late final List<GlobalKey<TimerWidgetState>> _timerKeys;

  // For auto-scroll + ensureVisible
  late final ScrollController _scrollController;
  late final List<GlobalKey> _sectionKeys;

  // Accordion state
  late final List<bool> _open;

  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();

    _tabs = List<String>.from(_TXT.tabs);
    _timerKeys = List.generate(_tabs.length, (_) => GlobalKey<TimerWidgetState>());

    _scrollController = ScrollController();
    _sectionKeys = List.generate(_tabs.length, (_) => GlobalKey());
    _open = List<bool>.generate(_tabs.length, (i) => i == 0); // open first

    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _beep() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/beep.mp3'));
    } catch (_) {}
  }

  Future<void> _scrollToSection(int index) async {
    final ctx = _sectionKeys[index].currentContext;
    if (ctx == null) return;

    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  void _toggleSection(int index) {
    HapticFeedback.selectionClick();
    setState(() => _open[index] = !_open[index]);
  }

  void _openOnly(int index) {
    setState(() {
      for (int i = 0; i < _open.length; i++) {
        _open[i] = i == index;
      }
    });
  }

  void _onSessionFinished(int index) async {
    if (!mounted) return;

    if (index + 1 < _tabs.length) {
      final nextIndex = index + 1;

      await _beep();

      // Open next section (modern step behavior)
      _openOnly(nextIndex);

      // Scroll + start next
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _scrollToSection(nextIndex);
        _timerKeys[nextIndex].currentState?.startFromParent();
      });
    } else {
      await _beep();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(_TXT.sessionFinishedAllTabs)),
      );
    }
  }

  Future<void> _handlePlay() async {
    await _beep();

    // reset all timers
    for (final key in _timerKeys) {
      key.currentState?.resetFromParent();
    }

    // Open first + scroll + start
    _openOnly(0);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _scrollToSection(0);
      _timerKeys[0].currentState?.startFromParent();
    });
  }

  Future<void> _handleStop() async {
    await _beep();
    for (final key in _timerKeys) {
      key.currentState?.stopFromParent();
    }
  }

  Future<void> _handleClear() async {
    await _beep();
    for (final key in _timerKeys) {
      key.currentState?.resetFromParent();
    }
    _openOnly(0);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSection(0));
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isDark = t.brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      isDark
          ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ✅ ONLY background (no layers under it)
          Positioned.fill(
            child: Image.asset(
              'assets/images/BgS.jfif',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Column(
                children: [
                  _PremiumHeader(
                    title: _TXT.titleAppBar,
                    onBack: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(height: 12),

                  // ✅ Main content (accordion sections)
                  Expanded(
                    child: ListView.separated(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 10),
                      itemCount: _tabs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        return KeyedSubtree(
                          key: _sectionKeys[index],
                          child: _ExpandableGlassSection(
                            step: index + 1,
                            total: _tabs.length,
                            title: _tabs[index],
                            isOpen: _open[index],
                            onToggle: () => _toggleSection(index),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                              child: TimerElement(
                                timerKey: _timerKeys[index],
                                onSessionFinished: () => _onSessionFinished(index),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ✅ Bottom controls (always visible)
                  _ControlsBar(
                    onPlay: _handlePlay,
                    onStop: _handleStop,
                    onClear: _handleClear,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================= Modern UI kit ============================= */

class _PremiumHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _PremiumHeader({
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return _Glass(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          _PillIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () {
              HapticFeedback.selectionClick();
              onBack();
            },
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "⏲️ $title",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
                color: Colors.white.withOpacity(0.96),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.10),
              border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
              boxShadow: [
                BoxShadow(
                  blurRadius: 18,
                  color: Colors.black.withOpacity(0.22),
                ),
              ],
            ),
            child: Icon(
              Icons.timer_rounded,
              color: cs.primary.withOpacity(0.90),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandableGlassSection extends StatelessWidget {
  final int step;
  final int total;
  final String title;
  final bool isOpen;
  final VoidCallback onToggle;
  final Widget child;

  const _ExpandableGlassSection({
    required this.step,
    required this.total,
    required this.title,
    required this.isOpen,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return _Glass(
      radius: 20,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            InkWell(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Row(
                  children: [
                    _StepBadge(step: step, total: total),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: t.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                          color: Colors.white.withOpacity(0.96),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: (isOpen ? cs.primary.withOpacity(0.18) : Colors.white.withOpacity(0.10)),
                        border: Border.all(
                          color: isOpen ? cs.primary.withOpacity(0.35) : Colors.white.withOpacity(0.14),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        isOpen ? "OPEN" : "CLOSED",
                        style: t.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withOpacity(0.88),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 220),
                      turns: isOpen ? 0.5 : 0.0,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white.withOpacity(0.85),
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(height: 0),
              secondChild: child,
              crossFadeState: isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 260),
              sizeCurve: Curves.easeOutCubic,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  final int step;
  final int total;

  const _StepBadge({required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$step",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.primary.withOpacity(0.92),
                  height: 1.0,
                ),
          ),
          Text(
            "/$total",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withOpacity(0.70),
                  height: 1.0,
                ),
          ),
        ],
      ),
    );
  }
}

class _ControlsBar extends StatelessWidget {
  final VoidCallback onPlay;
  final VoidCallback onStop;
  final VoidCallback onClear;

  const _ControlsBar({
    required this.onPlay,
    required this.onStop,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return _Glass(
      radius: 20,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _TXT.sessionControlsTitle,
            textAlign: TextAlign.center,
            style: t.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.78),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ActionPill(
                  icon: Icons.play_arrow_rounded,
                  label: _TXT.start,
                  onTap: onPlay,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionPill(
                  icon: Icons.stop_rounded,
                  label: _TXT.stop,
                  danger: true,
                  onTap: onStop,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionPill(
                  icon: Icons.refresh_rounded,
                  label: _TXT.clear,
                  subtle: true,
                  onTap: onClear,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  final bool subtle;

  const _ActionPill({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
    this.subtle = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

    final Color bg = danger
        ? const Color(0xFFE11D48).withOpacity(0.22)
        : (subtle ? Colors.white.withOpacity(0.10) : Colors.white.withOpacity(0.12));

    final Color border = danger
        ? const Color(0xFFE11D48).withOpacity(0.35)
        : Colors.white.withOpacity(0.16);

    final Color iconColor = danger ? const Color(0xFFE11D48) : cs.primary.withOpacity(0.90);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: bg,
          border: Border.all(color: border, width: 1),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              color: Colors.black.withOpacity(0.20),
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: iconColor),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? Colors.white.withOpacity(0.07) : Colors.white.withOpacity(0.10);
    final border = isDark ? Colors.white.withOpacity(0.10) : Colors.white.withOpacity(0.14);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        // Glass only inside cards (background remains untouched)
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

class _PillIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _PillIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: Colors.white.withOpacity(0.10),
          border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
        ),
        child: Icon(icon, color: Colors.white.withOpacity(0.92), size: 20),
      ),
    );
  }
}
