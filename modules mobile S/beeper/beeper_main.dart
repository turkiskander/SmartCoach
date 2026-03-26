// lib/features/beeper/beeper_main_view.dart
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:flutter_1/features/beeper/beep_intermittent_training/beep_intermittent_training_view.dart';
import 'package:flutter_1/features/beeper/beep_test/beep_test__view.dart';
import 'package:flutter_1/features/beeper/timer/timer_view.dart';
import 'package:flutter_1/features/beeper/topCrono/top_crono_view.dart';

/// ✅ BeeperMain (compatible avec toute l’app)
/// ✅ Background identique Home: assets/images/BgHome.jfif + overlay premium
/// ✅ Cards: watch1.png NET (pas de blur) + subtitle affiché SOUS l’image
/// ✅ Carrousel avancé: PageView + depth/scale/tilt + parallax + worm indicator
///
/// Assets requis:
/// - assets/images/BgHome.jfif
/// - assets/images/top_chrono.png
/// - assets/images/beep_intermittent_training.png
/// - assets/images/beep_test.png
/// - assets/images/timer.png

class BeeperMainView extends StatefulWidget {
  const BeeperMainView({super.key});

  @override
  State<BeeperMainView> createState() => _BeeperMainViewState();
}

class _BeeperMainViewState extends State<BeeperMainView> {
  static const String _bgHome = 'assets/images/BgHome.jfif';

  late final PageController _pageCtl;
  double _page = 0;

  // ✅ Seulement subtitles (pas d’emojis / pas de titres)
  static const List<_BeeperCardModel> _cards = [
    _BeeperCardModel(
      subtitle: "Temps de jeu + multi-chronos",
      routeType: _BeeperRoute.topChrono,
      imageAsset: 'assets/images/top_chrono.png',
    ),
    _BeeperCardModel(
      subtitle: "Entraînement intermittent",
      routeType: _BeeperRoute.intermittent,
      imageAsset: 'assets/images/beep_intermittent_training.png',
    ),
    _BeeperCardModel(
      subtitle: "Test + niveaux + progression",
      routeType: _BeeperRoute.beepTest,
      imageAsset: 'assets/images/beep_test.png',
    ),
    _BeeperCardModel(
      subtitle: "Minuteur simple et rapide",
      routeType: _BeeperRoute.timer,
      imageAsset: 'assets/images/timer.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageCtl = PageController(viewportFraction: 0.78);
    _pageCtl.addListener(() {
      setState(() => _page = _pageCtl.page ?? _pageCtl.initialPage.toDouble());
    });
  }

  @override
  void dispose() {
    _pageCtl.dispose();
    super.dispose();
  }

  Widget _routeFor(_BeeperRoute type) {
    switch (type) {
      case _BeeperRoute.topChrono:
        return const TopCronoView();
      case _BeeperRoute.intermittent:
        return const BeepIntermittentTrainingView();
      case _BeeperRoute.beepTest:
        return const BeepTestView();
      case _BeeperRoute.timer:
        return const TimerView();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final isDark = t.brightness == Brightness.dark;

    final titleGrad = _themeHeadlineGradient(cs);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
        title: _GradientText(
          text: "Beeper",
          gradient: titleGrad,
          style: t.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
      body: Stack(
        children: [
          // ✅ Background Home
          Positioned.fill(
            child: Image.asset(
              _bgHome,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              isAntiAlias: true,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFF0B0F14)),
            ),
          ),

          // ✅ Overlay premium
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(isDark ? 0.55 : 0.45),
                    Colors.black.withOpacity(isDark ? 0.30 : 0.22),
                    Colors.black.withOpacity(isDark ? 0.62 : 0.52),
                  ],
                ),
              ),
            ),
          ),

          // Orbs (theme-like)
          Positioned(
            top: -150,
            left: -160,
            child: _GlowOrb(
              size: 360,
              color: cs.primary.withOpacity(isDark ? 0.10 : 0.08),
            ),
          ),
          Positioned(
            bottom: -170,
            right: -170,
            child: _GlowOrb(
              size: 390,
              color: (cs.tertiary == cs.primary ? cs.secondary : cs.tertiary)
                  .withOpacity(isDark ? 0.12 : 0.10),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: _TopHeader(
                    title: "Modules Beeper",
                    subtitle: "Carousel • Watch cards",
                    iconGradient: _themeBrandGradient(cs),
                  ),
                ),

                // ✅ Carousel
                Expanded(
                  child: PageView.builder(
                    controller: _pageCtl,
                    itemCount: _cards.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final model = _cards[index];

                      final distance = (_page - index).abs();
                      final clamped = distance.clamp(0.0, 1.0);

                      final scale = 1.0 - 0.10 * clamped;
                      final tilt = (index - _page) * 0.10;
                      final opacity = 1.0 - 0.22 * clamped;

                      return Center(
                        child: Opacity(
                          opacity: opacity,
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.0014)
                              ..rotateY(tilt)
                              ..scale(scale, scale),
                            child: _WatchCard(
                              isDark: isDark,
                              subtitle: model.subtitle,
                              parallax: (index - _page) * 24,
                              watchAsset: model.imageAsset,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => _routeFor(model.routeType),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Indicator + hint
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                  child: Column(
                    children: [
                      _WormIndicator(
                        count: _cards.length,
                        page: _page,
                        active: cs.primary.withOpacity(0.95),
                        base: Colors.white.withOpacity(0.22),
                      ),
                      const SizedBox(height: 10),
                      _GlassHint(
                        text: "Glissez • Touchez une carte pour ouvrir",
                        fg: Colors.white.withOpacity(0.78),
                        border: Colors.white.withOpacity(0.10),
                        fill: Colors.white.withOpacity(0.08),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== Theme helpers =====================

  static List<Color> _themeBrandGradient(ColorScheme cs) {
    final a = cs.primary;
    final b = (cs.tertiary == cs.primary ? cs.secondary : cs.tertiary);
    return [a, b];
  }

  static List<Color> _themeHeadlineGradient(ColorScheme cs) {
    final a = cs.primary.withOpacity(0.95);
    final b = (cs.secondary == cs.primary ? cs.tertiary : cs.secondary)
        .withOpacity(0.95);
    return [a, b];
  }
}

/* ========================================================================== */
/*                                    Models                                  */
/* ========================================================================== */

enum _BeeperRoute { topChrono, intermittent, beepTest, timer }

class _BeeperCardModel {
  final String subtitle;
  final _BeeperRoute routeType;
  final String imageAsset;

  const _BeeperCardModel({
    required this.subtitle,
    required this.routeType,
    required this.imageAsset,
  });
}

/* ========================================================================== */
/*                                    UI                                      */
/* ========================================================================== */

class _TopHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Color> iconGradient;

  const _TopHeader({
    required this.title,
    required this.subtitle,
    required this.iconGradient,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(colors: iconGradient),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.30),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.watch_rounded, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: t.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: t.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.72),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ✅ FIX OVERFLOW: watch height + subtitle height adaptent aux contraintes.
/// ✅ Subtitle affiché SOUS l’image.
class _WatchCard extends StatelessWidget {
  final bool isDark;
  final String subtitle;
  final double parallax;
  final String watchAsset;
  final VoidCallback onTap;

  const _WatchCard({
    required this.isDark,
    required this.subtitle,
    required this.parallax,
    required this.watchAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        // ✅ réduit marge verticale -> évite overflow
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: LayoutBuilder(
          builder: (context, c) {
            final maxH = c.maxHeight.isFinite ? c.maxHeight : 520.0;

            final gap = 10.0;
            final subtitleH = (maxH * 0.18).clamp(52.0, 74.0);
            final watchH = (maxH - subtitleH - gap).clamp(240.0, maxH);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // -------- Watch image (NET) --------
                ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: SizedBox(
                    height: watchH,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Transform.translate(
                            offset: Offset(parallax, 0),
                            child: Image.asset(
                              watchAsset,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                              isAntiAlias: true,
                              gaplessPlayback: true,
                            ),
                          ),
                        ),

                        // overlay léger pour lisibilité (sans flouter l’image)
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.14),
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.26),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // border glass
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white.withOpacity(0.14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: gap),

                // -------- Subtitle sous l’image --------
                SizedBox(
                  height: subtitleH,
                  width: double.infinity,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.white.withOpacity(isDark ? 0.10 : 0.12),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.26),
                          blurRadius: 16,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: t.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.90),
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _WormIndicator extends StatelessWidget {
  final int count;
  final double page;
  final Color active;
  final Color base;

  const _WormIndicator({
    required this.count,
    required this.page,
    required this.active,
    required this.base,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (i) {
          final d = (page - i).abs().clamp(0.0, 1.0);
          final w = 10 + (1 - d) * 18;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            height: 8,
            width: w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: Color.lerp(active, base, d),
            ),
          );
        }),
      ),
    );
  }
}

class _GlassHint extends StatelessWidget {
  final String text;
  final Color fg;
  final Color border;
  final Color fill;

  const _GlassHint({
    required this.text,
    required this.fg,
    required this.border,
    required this.fill,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: fill,
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.30),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.touch_app_rounded, size: 20, color: fg),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: t.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 150,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }
}

class _GradientText extends StatelessWidget {
  final String text;
  final List<Color> gradient;
  final TextStyle? style;

  const _GradientText({
    required this.text,
    required this.gradient,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final s = style ?? Theme.of(context).textTheme.titleLarge;
    return ShaderMask(
      shaderCallback: (r) => LinearGradient(
        colors: gradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(r),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: (s ?? const TextStyle()).copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}