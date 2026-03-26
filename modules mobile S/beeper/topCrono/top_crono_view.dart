// lib/features/beeper/topCrono/top_crono_view.dart
// ✅ KEEP logic (same widgets, same chronos list) — UI redesign ONLY
// ✅ NO TabBar / NO TabBarView
// ✅ Modern layout: single premium scroll page + expandable sections + responsive grid
// ✅ Background uses Home image ONLY (NO layers under/over it)

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_1/features/beeper/topCrono/actual_game_widget.dart';
import 'package:flutter_1/features/beeper/topCrono/chrono_widget.dart';

class TopCronoView extends StatefulWidget {
  const TopCronoView({super.key});

  @override
  State<TopCronoView> createState() => _TopCronoViewState();
}

class _TopCronoViewState extends State<TopCronoView> {
  static const String _screenTitle = "Top Chrono";

  static const List<String> _chronoTitles = [
    "Chrono 1",
    "Chrono 2",
    "Chrono 3",
    "Chrono 4",
    "Chrono 5",
    "Chrono 6",
  ];

  bool _openGame = true;
  bool _openChronos = true;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isDark = t.brightness == Brightness.dark;
    final cs = t.colorScheme;

    SystemChrome.setSystemUIOverlayStyle(
      isDark
          ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ✅ ONLY background image (no layers under/over it)
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
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _PremiumHeader(
                      title: _screenTitle,
                      onBack: () => Navigator.of(context).maybePop(),
                      rightIcon: Icons.speed_rounded,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),

                  // ✅ Section 1: Temps de jeu
                  SliverToBoxAdapter(
                    child: _ExpandableGlassSection(
                      icon: Icons.sports_esports_rounded,
                      title: "Temps de jeu",
                      subtitle: "Suivi en temps réel",
                      accent: cs.primary,
                      isOpen: _openGame,
                      onToggle: () {
                        HapticFeedback.selectionClick();
                        setState(() => _openGame = !_openGame);
                      },
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(12, 12, 12, 14),
                        child: ActualGameTimeWidget(),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 14)),

                  // ✅ Section 2: Chronos
                  SliverToBoxAdapter(
                    child: _ExpandableGlassSection(
                      icon: Icons.grid_view_rounded,
                      title: "Chronos",
                      subtitle: "Plusieurs chronos indépendants",
                      accent: cs.primary,
                      isOpen: _openChronos,
                      onToggle: () {
                        HapticFeedback.selectionClick();
                        setState(() => _openChronos = !_openChronos);
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final w = constraints.maxWidth;
                            final col = w >= 1000 ? 3 : (w >= 640 ? 2 : 1);

                            return GridView.count(
                              crossAxisCount: col,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 1.12,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                for (final title in _chronoTitles) ChronoWidget(title: title),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 18)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================= Premium UI kit ============================= */

class _PremiumHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final IconData rightIcon;

  const _PremiumHeader({
    required this.title,
    required this.onBack,
    required this.rightIcon,
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
              "⏱️ $title",
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
              rightIcon,
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
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;

  final bool isOpen;
  final VoidCallback onToggle;
  final Widget child;

  const _ExpandableGlassSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.isOpen,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

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
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white.withOpacity(0.10),
                        border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
                      ),
                      child: Icon(icon, color: accent.withOpacity(0.92), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.2,
                              color: Colors.white.withOpacity(0.96),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withOpacity(0.70),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
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
        // ✅ Glass effect is inside the cards only (does NOT cover the whole background)
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
