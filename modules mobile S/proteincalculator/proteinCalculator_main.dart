// lib/features/proteincalculator/protein_calculator_main.dart
//
// ✅ Shell AppBar (PremiumAppBar) will show the title from routeTitles
// ✅ This page no longer has its own AppBar (to avoid double AppBar)
// ✅ Keep same intro animations + same _glassRoute navigation
// ✅ NO intl / NO localization
//
// REQUIRED ASSET:
// - assets/images/BgHome.jfif  (declared in pubspec.yaml)
//
// IMPORTANT:
// - Put ProteinCalculatorView here:
//   lib/features/proteincalculator/protein_calculator_view.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'protein_calculator_view.dart';

class ProteinCalculatorMain extends StatefulWidget {
  const ProteinCalculatorMain({super.key});

  @override
  State<ProteinCalculatorMain> createState() => _ProteinCalculatorMainState();
}

class _ProteinCalculatorMainState extends State<ProteinCalculatorMain>
    with SingleTickerProviderStateMixin {
  static const String _bgHome = "assets/images/BgHome.jfif";

  late final AnimationController _enterCtrl;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    )..forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final isDark = t.brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      isDark
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.transparent,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.transparent,
            ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,

      // ✅ IMPORTANT: No AppBar here. The shell PremiumAppBar will be used.
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

          // Orbs ambience
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

          // ✅ CONTENT
          SafeArea(
            child: Padding(
              // ✅ EXACTLY under the shell AppBar (PremiumAppBar)
              padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 2, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Back arrow like your Beeper capture (no circle)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: Colors.white,
                      iconSize: 26,
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 40, minHeight: 40),
                      splashRadius: 22,
                      tooltip: MaterialLocalizations.of(context)
                          .backButtonTooltip,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: AnimatedBuilder(
                      animation: _enterCtrl,
                      builder: (context, _) {
                        final anim = CurvedAnimation(
                          parent: _enterCtrl,
                          curve: Curves.easeOutCubic,
                        );

                        return FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.04),
                              end: Offset.zero,
                            ).animate(anim),
                            child: _Glass(
                              radius: 20,
                              padding: EdgeInsets.zero,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: CustomScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  slivers: [
                                    SliverToBoxAdapter(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            14, 14, 14, 10),
                                        child: _InfoBanner(
                                          title: "Daily Protein Intake",
                                          subtitle:
                                              "Enter your info, then calculate your recommended grams/day.",
                                        ),
                                      ),
                                    ),
                                    SliverToBoxAdapter(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            14, 0, 14, 14),
                                        child: _Glass(
                                          radius: 18,
                                          padding: const EdgeInsets.all(16),
                                          child: const _IntroTexts(
                                            line1:
                                                "Calculate your daily protein intake",
                                            line2:
                                                "Based on weight, goal and activity level",
                                            line3: "Simple inputs, instant result",
                                            line4:
                                                "Tip: higher activity usually needs more protein.\n\nUse it daily to stay consistent.",
                                          ),
                                        ),
                                      ),
                                    ),
                                    SliverToBoxAdapter(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            14, 0, 14, 18),
                                        child: Center(
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: 420),
                                            child: _ShinyCTAButton(
                                              label: "Next",
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  _glassRoute(
                                                    const ProteinCalculatorView(),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SliverToBoxAdapter(
                                      child: SizedBox(height: 10),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Same glassy transition
  PageRouteBuilder _glassRoute(Widget page) => PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 460),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (ctx, anim, __, child) {
          final curved = CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          final blur = Tween(begin: 0.0, end: 10.0).animate(curved);
          final scale = Tween(begin: 0.985, end: 1.0).animate(curved);

          return AnimatedBuilder(
            animation: blur,
            builder: (_, __) => BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur.value, sigmaY: blur.value),
              child: FadeTransition(
                opacity: curved,
                child: ScaleTransition(scale: scale, child: child),
              ),
            ),
          );
        },
      );
}

/* =============================== UI PARTS =============================== */

class _InfoBanner extends StatelessWidget {
  final String title;
  final String subtitle;

  const _InfoBanner({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return _Glass(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white.withOpacity(0.10),
              border:
                  Border.all(color: Colors.white.withOpacity(0.14), width: 1),
            ),
            child: Icon(
              Icons.fitness_center_rounded,
              color: cs.primary.withOpacity(0.92),
              size: 22,
            ),
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
                    color: Colors.white.withOpacity(0.96),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: t.textTheme.bodySmall?.copyWith(
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.72),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroTexts extends StatefulWidget {
  final String line1, line2, line3, line4;

  const _IntroTexts({
    required this.line1,
    required this.line2,
    required this.line3,
    required this.line4,
  });

  @override
  State<_IntroTexts> createState() => _IntroTextsState();
}

class _IntroTextsState extends State<_IntroTexts>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  late final Animation<double> _fade1, _fade2, _fade3, _fade4;
  late final Animation<Offset> _slide1, _slide2, _slide3, _slide4;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fade1 = CurvedAnimation(
        parent: _ctl,
        curve: const Interval(0.00, 0.45, curve: Curves.easeOut));
    _fade2 = CurvedAnimation(
        parent: _ctl,
        curve: const Interval(0.10, 0.60, curve: Curves.easeOut));
    _fade3 = CurvedAnimation(
        parent: _ctl,
        curve: const Interval(0.20, 0.70, curve: Curves.easeOut));
    _fade4 = CurvedAnimation(
        parent: _ctl,
        curve: const Interval(0.30, 0.85, curve: Curves.easeOut));

    _slide1 = Tween(begin: const Offset(0, 0.10), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _ctl,
          curve: const Interval(0.00, 0.45, curve: Curves.easeOutCubic)),
    );
    _slide2 = Tween(begin: const Offset(0, 0.12), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _ctl,
          curve: const Interval(0.10, 0.60, curve: Curves.easeOutCubic)),
    );
    _slide3 = Tween(begin: const Offset(0, 0.14), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _ctl,
          curve: const Interval(0.20, 0.70, curve: Curves.easeOutCubic)),
    );
    _slide4 = Tween(begin: const Offset(0, 0.16), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _ctl,
          curve: const Interval(0.30, 0.85, curve: Curves.easeOutCubic)),
    );
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FadeTransition(
          opacity: _fade1,
          child: SlideTransition(
            position: _slide1,
            child: Text(
              widget.line1,
              textAlign: TextAlign.center,
              style: t.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(0.96),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        FadeTransition(
          opacity: _fade2,
          child: SlideTransition(
            position: _slide2,
            child: Text(
              widget.line2,
              textAlign: TextAlign.center,
              style: t.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.86),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        FadeTransition(
          opacity: _fade3,
          child: SlideTransition(
            position: _slide3,
            child: Text(
              widget.line3,
              textAlign: TextAlign.center,
              style: t.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.78),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        FadeTransition(
          opacity: _fade4,
          child: SlideTransition(
            position: _slide4,
            child: Text(
              widget.line4,
              textAlign: TextAlign.center,
              style: t.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.74),
                height: 1.35,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShinyCTAButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _ShinyCTAButton({
    required this.label,
    required this.onTap,
  });

  @override
  State<_ShinyCTAButton> createState() => _ShinyCTAButtonState();
}

class _ShinyCTAButtonState extends State<_ShinyCTAButton>
    with TickerProviderStateMixin {
  late final AnimationController _pressCtl;
  late final AnimationController _shineCtl;

  @override
  void initState() {
    super.initState();
    _pressCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _shineCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _pressCtl.dispose();
    _shineCtl.dispose();
    super.dispose();
  }

  Future<void> _tap() async {
    await _pressCtl.forward();
    await _pressCtl.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isDark = t.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: Listenable.merge([_pressCtl, _shineCtl]),
      builder: (_, __) {
        final press = Curves.easeOut.transform(_pressCtl.value);
        final scale = 1.0 - press * 0.03;
        final shineX = Tween(begin: -1.0, end: 2.0).transform(_shineCtl.value);

        return Transform.scale(
          scale: scale,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _tap,
              child: Ink(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? Colors.black : Colors.blueGrey)
                          .withOpacity(isDark ? 0.35 : 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.22,
                          child: Transform.translate(
                            offset: Offset(
                              shineX * MediaQuery.of(context).size.width,
                              0,
                            ),
                            child: Transform.rotate(
                              angle: -0.35,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: 90,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.white70, Colors.white10],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.label,
                              style: t.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.arrow_forward_rounded,
                                color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
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

    final bg = isDark
        ? Colors.white.withOpacity(0.07)
        : Colors.white.withOpacity(0.10);
    final border = isDark
        ? Colors.white.withOpacity(0.10)
        : Colors.white.withOpacity(0.14);

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
