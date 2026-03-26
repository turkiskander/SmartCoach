// lib/feature/ppCalculator/pp_calculator_main.dart
//
// ✅ Search bar removed
// ✅ AppBar added like Beeper (transparent + back + title)
// ✅ Carousel + navigation unchanged

import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_1/features/ppcalculator/average_resting_heart_rate/average_resting_heart_rate.dart';
import 'package:flutter_1/features/ppcalculator/blood_presure/blood_presure.dart';
import 'package:flutter_1/features/ppcalculator/full_body_analysis/full_body_analysis_view.dart';
import 'package:flutter_1/features/ppcalculator/human_water_requirement/human_water_requirement.dart';
import 'package:flutter_1/features/ppcalculator/target_heart_rate/target_heart_rate.dart';
import 'package:flutter_1/features/ppcalculator/traning_calculation/training_calculation_view.dart';
import 'package:flutter_1/features/ppcalculator/vVo2Max/vVo2Max.dart';
import 'package:flutter_1/features/ppcalculator/vma/vma.dart';
import 'package:flutter_1/features/ppcalculator/vo2max_calcul/vo2max_calcul.dart';
import 'package:flutter_1/features/ppcalculator/water_loss/water_loss.dart';
import 'package:flutter_1/features/ppcalculator/yoyo-test1/yoyo_test1.dart';
import 'package:flutter_1/features/ppcalculator/yoyo_endurance1_2/yoyo_endurance1_2.dart';
import 'package:flutter_1/features/ppcalculator/yoyo_test2/yoyo_test2.dart';

class _TXT {
  static const String title = "PP Calculator";

  static const String trainingCalculation = "Training Calculation";
  static const String vma = "VMA";
  static const String vo2max = "VO₂max";
  static const String vvo2max = "vVO₂max";

  static const String yoyo1 = "Yo-Yo 1";
  static const String yoyo2 = "Yo-Yo 2";
  static const String yoyoEndurance = "Yo-Yo Endurance 1/2";

  static const String fullBody = "Full Body Analysis";
  static const String targetHR = "Target Heart Rate";
  static const String restingHR = "Average Resting Heart Rate";
  static const String bloodPressure = "Blood Pressure";
  static const String waterRequirement = "Human Water Requirement";
  static const String waterLoss = "Water Loss";
}

class PpCalculatorMAin extends StatefulWidget {
  const PpCalculatorMAin({super.key});

  @override
  State<PpCalculatorMAin> createState() => _PpCalculatorMAinState();
}

class _PpCalculatorMAinState extends State<PpCalculatorMAin>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bgCtl;

  late final List<_CalcItem> _allItems;

  static const String _bg = "assets/images/BgS.jfif";

  // ✅ Carousel
  late final PageController _pageCtl;
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();

    _bgCtl =
        AnimationController(vsync: this, duration: const Duration(seconds: 12))
          ..repeat();

    _pageCtl = PageController(viewportFraction: 0.90);
    _pageCtl.addListener(() {
      final p = _pageCtl.page ?? _pageCtl.initialPage.toDouble();
      final idx = p.round();
      if (idx != _activeIndex && mounted) setState(() => _activeIndex = idx);
    });

    _allItems = [
      _CalcItem(
        _TXT.trainingCalculation,
        'assets/images/traning_calculation.png',
        () => const TrainingCalculationView(),
      ),
      _CalcItem(_TXT.vma, 'assets/images/VMA.png', () => const Vma()),
      _CalcItem(
        _TXT.vo2max,
        'assets/images/vo2max_calcul.png',
        () => const vo2maxCalcul(),
      ),
      _CalcItem(
        _TXT.vvo2max,
        'assets/images/vVo2Max.png',
        () => const VVo2Max(),
      ),
      _CalcItem(
        _TXT.yoyo1,
        'assets/images/yoyo_test1.png',
        () => const YoyoTest1(),
      ),
      _CalcItem(
        _TXT.yoyo2,
        'assets/images/yoyo_test2.png',
        () => const YoyoTest2(),
      ),
      _CalcItem(
        _TXT.yoyoEndurance,
        'assets/images/yoyo_endurance.png',
        () => const YoyoEndurance12(),
      ),
      _CalcItem(
        _TXT.fullBody,
        'assets/images/full_body_analysis.png',
        () => const FullBodyAnalysisView(),
      ),
      _CalcItem(
        _TXT.targetHR,
        'assets/images/target_heart_rate.png',
        () => const TargetHeartRate(),
      ),
      _CalcItem(
        _TXT.restingHR,
        'assets/images/average_resting_heart_rate.png',
        () => const AverageRestingHeartRate(),
      ),
      _CalcItem(
        _TXT.bloodPressure,
        'assets/images/blood_presure.png',
        () => const BloodPresure(),
      ),
      _CalcItem(
        _TXT.waterRequirement,
        'assets/images/human_water_requirement.png',
        () => const HumanWaterRequirement(),
      ),
      _CalcItem(
        _TXT.waterLoss,
        'assets/images/water_loss.png',
        () => const WaterLoss(),
      ),
    ];
  }

  @override
  void dispose() {
    _bgCtl.dispose();
    _pageCtl.dispose();
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

    final items = _allItems;
    if (_activeIndex >= items.length) _activeIndex = 0;

    final titleGrad = _themeHeadlineGradient(cs);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,

      // ✅ AppBar like Beeper
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
        title: _GradientText(
          text: _TXT.title,
          gradient: titleGrad,
          style: t.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),

      body: AnimatedBuilder(
        animation: _bgCtl,
        builder: (_, __) {
          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  _bg,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (_, __, ___) =>
                      Container(color: const Color(0xFF0B0F14)),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark
                          ? [
                              Colors.black.withOpacity(0.55),
                              Colors.black.withOpacity(0.32),
                              Colors.black.withOpacity(0.62),
                            ]
                          : [
                              Colors.black.withOpacity(0.30),
                              Colors.black.withOpacity(0.14),
                              Colors.black.withOpacity(0.34),
                            ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -160,
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

              // ✅ Body content (no search / no custom header)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  child: Column(
                    children: [
                      const SizedBox(height: 4),

                      Expanded(
                        child: _StackedCarouselWithNav<_CalcItem>(
                          controller: _pageCtl,
                          items: items,
                          activeIndex: _activeIndex,
                          isDark: isDark,
                          titleOf: (it) => it.title,
                          imageOf: (it) => it.imageAsset,
                          onOpen: (it) => Navigator.of(context)
                              .push(_glassRoute(it.builder())),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  PageRouteBuilder _glassRoute(Widget page) => PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (ctx, anim, __, child) {
          final curved = CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          final blur = Tween(begin: 0.0, end: 10.0).animate(curved);
          return AnimatedBuilder(
            animation: blur,
            builder: (_, __) => BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur.value, sigmaY: blur.value),
              child: FadeTransition(
                opacity: curved,
                child: ScaleTransition(
                  scale: Tween(begin: 0.98, end: 1.0).animate(curved),
                  child: child,
                ),
              ),
            ),
          );
        },
      );

  static List<Color> _themeHeadlineGradient(ColorScheme cs) {
    final a = cs.primary.withOpacity(0.95);
    final b = (cs.secondary == cs.primary ? cs.tertiary : cs.secondary)
        .withOpacity(0.95);
    return [a, b];
  }
}

/* ========================================================================== */
/* Models */
/* ========================================================================== */

class _CalcItem {
  final String title;
  final String imageAsset;
  final Widget Function() builder;
  _CalcItem(this.title, this.imageAsset, this.builder);
}

/* ========================================================================== */
/* Carousel (unchanged) */
/* ========================================================================== */

class _StackedCarouselWithNav<T> extends StatelessWidget {
  final PageController controller;
  final List<T> items;
  final int activeIndex;

  final bool isDark;
  final String Function(T) titleOf;
  final String Function(T) imageOf;
  final void Function(T) onOpen;

  const _StackedCarouselWithNav({
    required this.controller,
    required this.items,
    required this.activeIndex,
    required this.isDark,
    required this.titleOf,
    required this.imageOf,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final p = controller.hasClients
                  ? (controller.page ?? controller.initialPage.toDouble())
                  : 0.0;

              return PageView.builder(
                controller: controller,
                physics: const BouncingScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];

                  final raw = index - p;
                  final d = raw.abs();
                  final c = d.clamp(0.0, 1.0);

                  final scale = 1.0 - 0.08 * c;
                  final y = 16.0 * c;
                  final x = 26.0 * raw;
                  final rotZ = (-0.06 * raw).clamp(-0.10, 0.10);
                  final opacity = 1.0 - 0.20 * c;

                  final blur = 0.0 + 6.0 * c;
                  final glow = (1.0 - c).clamp(0.0, 1.0);

                  return Center(
                    child: Opacity(
                      opacity: opacity,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0016)
                          ..translate(x, y)
                          ..rotateZ(rotZ)
                          ..scale(scale, scale),
                        child: _ModernImageCard(
                          isDark: isDark,
                          title: titleOf(item),
                          imageAsset: imageOf(item),
                          blurSigma: blur,
                          glowColor: cs.primary.withOpacity(0.18 * glow),
                          onTap: () => onOpen(item),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        _Glass(
          radius: 18,
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Row(
            children: [
              _MiniNavBtn(
                icon: Icons.chevron_left_rounded,
                onTap: () {
                  final target = (activeIndex - 1).clamp(0, items.length - 1);
                  controller.animateToPage(
                    target,
                    duration: const Duration(milliseconds: 340),
                    curve: Curves.easeOutCubic,
                  );
                },
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, i) {
                      final item = items[i];
                      final selected = i == activeIndex;

                      return _ThumbTile(
                        selected: selected,
                        imageAsset: imageOf(item),
                        title: titleOf(item),
                        onTap: () {
                          controller.animateToPage(
                            i,
                            duration: const Duration(milliseconds: 360),
                            curve: Curves.easeOutCubic,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _MiniNavBtn(
                icon: Icons.chevron_right_rounded,
                onTap: () {
                  final target = (activeIndex + 1).clamp(0, items.length - 1);
                  controller.animateToPage(
                    target,
                    duration: const Duration(milliseconds: 340),
                    curve: Curves.easeOutCubic,
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _ProgressLine(
          value: items.length <= 1 ? 1.0 : (activeIndex / (items.length - 1)),
          active: cs.primary.withOpacity(0.95),
          base: Colors.white.withOpacity(0.18),
        ),
      ],
    );
  }
}

class _ModernImageCard extends StatelessWidget {
  final bool isDark;
  final String title;
  final String imageAsset;

  final double blurSigma;
  final Color glowColor;

  final VoidCallback onTap;

  const _ModernImageCard({
    required this.isDark,
    required this.title,
    required this.imageAsset,
    required this.blurSigma,
    required this.glowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: LayoutBuilder(
          builder: (context, c) {
            final maxH = c.maxHeight.isFinite ? c.maxHeight : 520.0;

            final gap = 10.0;
            final titleH = (maxH * 0.18).clamp(52.0, 74.0);
            final imageH = (maxH - titleH - gap).clamp(240.0, maxH);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: glowColor,
                        blurRadius: 40,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.28),
                        blurRadius: 22,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: SizedBox(
                      height: imageH,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              imageAsset,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                              isAntiAlias: true,
                              gaplessPlayback: true,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFF0B0F14),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.white.withOpacity(0.35),
                                ),
                              ),
                            ),
                          ),
                          if (blurSigma > 0.1)
                            Positioned.fill(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: blurSigma,
                                  sigmaY: blurSigma,
                                ),
                                child: const SizedBox.shrink(),
                              ),
                            ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.10),
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.34),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: gap),
                Container(
                  height: titleH,
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white.withOpacity(isDark ? 0.10 : 0.12),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.22),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    title,
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
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ThumbTile extends StatelessWidget {
  final bool selected;
  final String imageAsset;
  final String title;
  final VoidCallback onTap;

  const _ThumbTile({
    required this.selected,
    required this.imageAsset,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: selected ? 160 : 64,
        height: 56,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(selected ? 0.12 : 0.08),
          border: Border.all(
            color: Colors.white.withOpacity(selected ? 0.22 : 0.10),
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.28 : 0.20),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth.isFinite ? c.maxWidth : (selected ? 160.0 : 64.0);
            final h = c.maxHeight.isFinite ? c.maxHeight : 56.0;
            final thumb = math.max(18.0, math.min(44.0, math.min(w, h)));

            return ClipRect(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: thumb,
                      height: thumb,
                      child: Image.asset(
                        imageAsset,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.medium,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF0B0F14),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: math.min(18, thumb),
                            color: Colors.white.withOpacity(0.35),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (selected) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.90),
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MiniNavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MiniNavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: Colors.white.withOpacity(0.10),
          border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
        ),
        child: Icon(icon, color: Colors.white.withOpacity(0.92), size: 22),
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  final double value;
  final Color active;
  final Color base;

  const _ProgressLine({
    required this.value,
    required this.active,
    required this.base,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(decoration: BoxDecoration(color: base)),
            ),
            FractionallySizedBox(
              widthFactor: value.clamp(0.0, 1.0),
              child: DecoratedBox(decoration: BoxDecoration(color: active)),
            ),
          ],
        ),
      ),
    );
  }
}

/* ========================================================================== */
/* Glass + Orbs */
/* ========================================================================== */

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