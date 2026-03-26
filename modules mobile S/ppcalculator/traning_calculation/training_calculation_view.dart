// lib/feature/ppCalculator/traning_calculation/training_calculation_view.dart
//
// ✅ LOGIQUE inchangée (recherche + liste outils + _openTool() identique)
// ✅ NO localization import
// ✅ DESIGN aligné sur pp_calculator_main.dart (AppBar + gradient title + carousel nav + progress)
// ✅ Sections affichées l'une après l'autre (scroll vertical)
// ✅ FIX: RenderFlex overflow (thumbnail) corrigé + rendu responsive (tous écrans)
// ✅ NEW: background image pour chaque carousel
// ✅ NEW: emoji central supprimé pour toutes les cartes
// ✅ FIX: popup vide corrigé (les tools complets s’affichent correctement dans le bottom sheet)

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ✅ tools (même dossier)
import 'aerobic_speed.dart';
import 'cat.dart';
import 'cooper.dart';
import 'distance_based.dart';
import 'half_cooper.dart';
import 'hrmax.dart';
import 'karnoven.dart';
import 'kilometer_based.dart';
import 'ruffier.dart';
import 'speed_based.dart';
import 'strength.dart';
import 'time_based.dart';
import 'weight_height.dart';
import 'ymca.dart';

/// ✅ Texts (no localization)
class _TXT {
  static const String trainingCalculation = "Training Calculation";

  // sections
  static const String titleTests = "Tests cardio & zones";
  static const String titleSeances = "Séances";
  static const String titleForme = "Forme & indices";

  static const String noResultsFr = "Aucun résultat";
  static const String noResultsEn = "No results";

  static const String swipeHint = "Scroll pour explorer";
}

class TrainingCalculationView extends StatefulWidget {
  const TrainingCalculationView({super.key});

  @override
  State<TrainingCalculationView> createState() => _TrainingCalculationViewState();
}

class _TrainingCalculationViewState extends State<TrainingCalculationView>
    with SingleTickerProviderStateMixin {
  static const String _bg = "assets/images/BgS.jfif";

  late final AnimationController _bgCtl;

  final TextEditingController _searchCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bgCtl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _bgCtl.dispose();
    _searchCtl.dispose();
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

    final tools = _buildTools(context);
    final sections = [
      _SectionBundle(
        title: _TXT.titleTests,
        key: 'tests',
        items: tools.where((e) => e.group == _ToolGroup.tests).toList(),
      ),
      _SectionBundle(
        title: _TXT.titleSeances,
        key: 'seances',
        items: tools.where((e) => e.group == _ToolGroup.seances).toList(),
      ),
      _SectionBundle(
        title: _TXT.titleForme,
        key: 'forme',
        items: tools.where((e) => e.group == _ToolGroup.forme).toList(),
      ),
    ];

    final q = _searchCtl.text.trim().toLowerCase();
    final filtered = sections
        .map(
          (s) => s.copyWith(
            items: q.isEmpty
                ? s.items
                : s.items.where((it) => it.title.toLowerCase().contains(q)).toList(),
          ),
        )
        .toList();

    final titleGrad = _themeHeadlineGradient(cs);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
        title: _GradientText(
          text: _TXT.trainingCalculation,
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
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  child: _Glass(
                    radius: 20,
                    padding: EdgeInsets.zero,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _Glass(
                              radius: 18,
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    _TXT.swipeHint,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: t.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white.withOpacity(0.92),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _SearchField(
                                    controller: _searchCtl,
                                    hint:
                                        '${MaterialLocalizations.of(context).searchFieldLabel}…',
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            for (int i = 0; i < filtered.length; i++) ...[
                              _SectionBanner(title: filtered[i].title),
                              const SizedBox(height: 12),
                              _StackedToolCarousel(
                                items: filtered[i].items,
                                onOpen: _openTool,
                              ),
                              const SizedBox(height: 18),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ✅ FIX popup vide
  void _openTool(_ToolItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black87.withOpacity(0.35),
      builder: (ctx) {
        final t = Theme.of(ctx);
        final cs = t.colorScheme;
        final isDark = t.brightness == Brightness.dark;

        return DraggableScrollableSheet(
          initialChildSize: 0.96,
          minChildSize: 0.75,
          maxChildSize: 0.99,
          expand: false,
          builder: (_, __) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(isDark ? 0.55 : 0.38),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withOpacity(0.10),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        height: 4,
                        width: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Theme(
                          data: t.copyWith(
                            textTheme: t.textTheme.apply(
                              bodyColor: Colors.white.withOpacity(0.92),
                              displayColor: Colors.white.withOpacity(0.92),
                            ),
                            colorScheme: t.colorScheme.copyWith(
                              primary: cs.primary,
                              surface: Colors.transparent,
                            ),
                          ),
                          child: item.builder(ctx),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<_ToolItem> _buildTools(BuildContext context) {
    return [
      // Tests cardio & zones
      _ToolItem(
        'Half Cooper',
        '🏃‍♂️',
        _ToolGroup.tests,
        (c) => const HalfCooper(),
        heroBg: 'assets/images/Half_cooper.jfif',
        hideHeroEmoji: true,
      ),
      _ToolItem(
        'HRmax',
        '❤️',
        _ToolGroup.tests,
        (c) => const Hrmax(),
        heroBg: 'assets/images/Hrmax.jfif',
        hideHeroEmoji: true,
      ),
      _ToolItem(
        'Karvonen',
        '🫀',
        _ToolGroup.tests,
        (c) => const Karnoven(),
        heroBg: 'assets/images/karnoven.jfif',
        hideHeroEmoji: true,
      ),
      _ToolItem(
        'Aerobic Speed',
        '⚡️',
        _ToolGroup.tests,
        (c) => const AerobicSpeed(),
        heroBg: 'assets/images/aerobic_speed.jfif',
        hideHeroEmoji: true,
      ),
      _ToolItem(
        'Cooper',
        '🏁',
        _ToolGroup.tests,
        (c) => const Cooper(),
        heroBg: 'assets/images/Cooper.jfif',
        hideHeroEmoji: true,
      ),
      _ToolItem(
        'CAT',
        '📏',
        _ToolGroup.tests,
        (c) => const Cat(),
        heroBg: 'assets/images/Cat.jfif',
        hideHeroEmoji: true,
      ),

      // Séances
      _ToolItem(
        'Time Based',
        '⏱️',
        _ToolGroup.seances,
        (c) => const TimeBased(),
        heroBg: 'assets/images/time_based.jfif',
        hideHeroEmoji: true,
      ),
      _ToolItem(
        'Distance Based',
        '📐',
        _ToolGroup.seances,
        (c) => const DistanceBased(),
        heroBg: 'assets/images/Distance.jfif',
        hideHeroEmoji: true,
      ),
      _ToolItem(
        'Speed Based',
        '🚀',
        _ToolGroup.seances,
        (c) => const SpeedBased(),
        heroBg: 'assets/images/speed_based.jfif',
        hideHeroEmoji: true,
      ),
      _ToolItem(
        'Kilometer Based',
        '📏',
        _ToolGroup.seances,
        (c) => const KilometerBased(),
        heroBg: 'assets/images/kilometer_based.jfif',
        hideHeroEmoji: true,
      ),

      // Forme & indices
      _ToolItem(
        'Strength',
        '🏋️',
        _ToolGroup.forme,
        (c) => const Strength(),
        heroBg: 'assets/images/Strength.jfif',
        hideHeroEmoji: true,
      ),
      _ToolItem(
        'Ruffier',
        '🧪',
        _ToolGroup.forme,
        (c) => const Ruffer(),
        heroBg: 'assets/images/ruffier.jfif',
        hideHeroEmoji: true,
      ),
      _ToolItem(
        'Weight / Height',
        '⚖️',
        _ToolGroup.forme,
        (c) => const WeightHeight(),
        heroBg: 'assets/images/weight_height.jfif',
        hideHeroEmoji: true,
      ),
      _ToolItem(
        'YMCA',
        '📊',
        _ToolGroup.forme,
        (c) => const Ymca(),
        heroBg: 'assets/images/ymca.jfif',
        hideHeroEmoji: true,
      ),
    ];
  }

  static List<Color> _themeHeadlineGradient(ColorScheme cs) {
    final a = cs.primary.withOpacity(0.95);
    final b =
        (cs.secondary == cs.primary ? cs.tertiary : cs.secondary).withOpacity(0.95);
    return [a, b];
  }
}

/* ========================================================================== */
/* Models */
/* ========================================================================== */

enum _ToolGroup { tests, seances, forme }

class _ToolItem {
  final String title;
  final String emoji;
  final _ToolGroup group;
  final WidgetBuilder builder;
  final String? heroBg;
  final bool hideHeroEmoji;

  _ToolItem(
    this.title,
    this.emoji,
    this.group,
    this.builder, {
    this.heroBg,
    this.hideHeroEmoji = false,
  });
}

class _SectionBundle {
  final String title;
  final String key;
  final List<_ToolItem> items;

  _SectionBundle({
    required this.title,
    required this.key,
    required this.items,
  });

  _SectionBundle copyWith({String? title, String? key, List<_ToolItem>? items}) =>
      _SectionBundle(
        title: title ?? this.title,
        key: key ?? this.key,
        items: items ?? this.items,
      );
}

/* ========================================================================== */
/* UI (sections) */
/* ========================================================================== */

class _SectionBanner extends StatelessWidget {
  final String title;
  const _SectionBanner({required this.title});

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
              border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
            ),
            child: Icon(
              Icons.view_carousel_rounded,
              color: cs.primary.withOpacity(0.92),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: t.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(0.96),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ========================================================================== */
/* ✅ Carousel (style PP Calculator) pour Tools */
/* ========================================================================== */

class _StackedToolCarousel extends StatefulWidget {
  final List<_ToolItem> items;
  final void Function(_ToolItem) onOpen;

  const _StackedToolCarousel({required this.items, required this.onOpen});

  @override
  State<_StackedToolCarousel> createState() => _StackedToolCarouselState();
}

class _StackedToolCarouselState extends State<_StackedToolCarousel> {
  late final PageController _pageCtl;
  int _activeIndex = 0;
  bool _precacheDone = false;

  @override
  void initState() {
    super.initState();
    _pageCtl = PageController(viewportFraction: 0.90);
    _pageCtl.addListener(() {
      final p = _pageCtl.page ?? _pageCtl.initialPage.toDouble();
      final idx = p.round();
      if (idx != _activeIndex && mounted) {
        setState(() => _activeIndex = idx);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precacheDone) return;
    _precacheDone = true;

    final unique = <String>{};
    for (final it in widget.items) {
      final bg = it.heroBg;
      if (bg != null && bg.isNotEmpty) unique.add(bg);
    }
    for (final bg in unique) {
      precacheImage(AssetImage(bg), context);
    }
  }

  @override
  void dispose() {
    _pageCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final isDark = t.brightness == Brightness.dark;

    if (widget.items.isEmpty) {
      final lang = Localizations.localeOf(context).languageCode.toLowerCase();
      final emptyText = (lang == 'fr' || lang.startsWith('fr'))
          ? _TXT.noResultsFr
          : _TXT.noResultsEn;

      return _Glass(
        radius: 18,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            emptyText,
            style: t.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white.withOpacity(0.86),
            ),
          ),
        ),
      );
    }

    if (_activeIndex >= widget.items.length) _activeIndex = 0;

    final sz = MediaQuery.sizeOf(context);
    final carouselHeight = (sz.height * 0.42).clamp(300.0, 380.0);

    return Column(
      children: [
        SizedBox(
          height: carouselHeight,
          child: AnimatedBuilder(
            animation: _pageCtl,
            builder: (context, _) {
              final p = _pageCtl.hasClients
                  ? (_pageCtl.page ?? _pageCtl.initialPage.toDouble())
                  : 0.0;

              return PageView.builder(
                controller: _pageCtl,
                physics: const BouncingScrollPhysics(),
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];

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
                        child: _ModernToolCard(
                          isDark: isDark,
                          title: item.title,
                          emoji: item.emoji,
                          blurSigma: blur,
                          glowColor: cs.primary.withOpacity(0.18 * glow),
                          backgroundAsset: item.heroBg,
                          hideHeroEmoji: item.hideHeroEmoji,
                          onTap: () => widget.onOpen(item),
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
                  final target = (_activeIndex - 1).clamp(0, widget.items.length - 1);
                  _pageCtl.animateToPage(
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
                    itemCount: widget.items.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, i) {
                      final item = widget.items[i];
                      final selected = i == _activeIndex;

                      return _ThumbTileTool(
                        selected: selected,
                        emoji: item.emoji,
                        title: item.title,
                        onTap: () {
                          _pageCtl.animateToPage(
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
                  final target = (_activeIndex + 1).clamp(0, widget.items.length - 1);
                  _pageCtl.animateToPage(
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
          value: widget.items.length <= 1 ? 1.0 : (_activeIndex / (widget.items.length - 1)),
          active: cs.primary.withOpacity(0.95),
          base: Colors.white.withOpacity(0.18),
        ),
      ],
    );
  }
}

class _ModernToolCard extends StatelessWidget {
  final bool isDark;
  final String title;
  final String emoji;
  final double blurSigma;
  final Color glowColor;
  final String? backgroundAsset;
  final bool hideHeroEmoji;
  final VoidCallback onTap;

  const _ModernToolCard({
    required this.isDark,
    required this.title,
    required this.emoji,
    required this.blurSigma,
    required this.glowColor,
    required this.onTap,
    this.backgroundAsset,
    this.hideHeroEmoji = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return LayoutBuilder(
      builder: (context, c) {
        final maxH = (c.maxHeight.isFinite && c.maxHeight > 0) ? c.maxHeight : 330.0;

        final padV = maxH < 320 ? 6.0 : 10.0;
        final gap = maxH < 320 ? 8.0 : 10.0;

        double footerH = (maxH * 0.22).clamp(50.0, 64.0);
        footerH = math.min(footerH, math.max(44.0, maxH - gap - 8.0));

        final bubble = (maxH * 0.38).clamp(84.0, 110.0);

        return GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: padV),
            child: SizedBox(
              height: maxH,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(color: glowColor, blurRadius: 40, spreadRadius: 2),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.28),
                            blurRadius: 22,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Stack(
                          children: [
                            if (backgroundAsset != null && backgroundAsset!.isNotEmpty)
                              Positioned.fill(
                                child: Image.asset(
                                  backgroundAsset!,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                  errorBuilder: (_, __, ___) =>
                                      Container(color: const Color(0xFF0B0F14)),
                                ),
                              ),
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      cs.primary.withOpacity(0.20),
                                      Colors.white.withOpacity(0.02),
                                      Colors.black.withOpacity(0.20),
                                    ],
                                  ),
                                ),
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
                                  border: Border.all(color: Colors.white.withOpacity(0.16)),
                                ),
                              ),
                            ),
                            if (!hideHeroEmoji)
                              Center(
                                child: Container(
                                  width: bubble,
                                  height: bubble,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.08),
                                    border: Border.all(color: Colors.white.withOpacity(0.16)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: cs.primary.withOpacity(0.18),
                                        blurRadius: 24,
                                        offset: const Offset(0, 12),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(emoji, style: const TextStyle(fontSize: 56)),
                                  ),
                                ),
                              ),
                            Positioned(
                              right: 14,
                              top: 14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  color: Colors.white.withOpacity(0.10),
                                  border: Border.all(color: Colors.white.withOpacity(0.14)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.open_in_new_rounded,
                                      size: 14,
                                      color: cs.primary.withOpacity(0.90),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Open",
                                      style: t.textTheme.labelMedium?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white.withOpacity(0.86),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: gap),
                  SizedBox(
                    height: footerH,
                    width: double.infinity,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// ✅ FIX OVERFLOW + RESPONSIVE widths
class _ThumbTileTool extends StatelessWidget {
  final bool selected;
  final String emoji;
  final String title;
  final VoidCallback onTap;

  const _ThumbTileTool({
    required this.selected,
    required this.emoji,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sw = MediaQuery.sizeOf(context).width;

    final selectedW = (sw * 0.46).clamp(140.0, 170.0);
    final unselectedW = (sw * 0.18).clamp(56.0, 68.0);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: selected ? selectedW : unselectedW,
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
            final w =
                c.maxWidth.isFinite ? c.maxWidth : (selected ? selectedW : unselectedW);
            final h = c.maxHeight.isFinite ? c.maxHeight : 56.0;

            final thumb = math.max(18.0, math.min(44.0, math.min(w, h)));
            final minForRow = thumb + 10 + 40;
            final canShowText = selected && w >= minForRow;

            if (!canShowText) {
              return Center(
                child: SizedBox(
                  width: thumb,
                  height: thumb,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withOpacity(0.10),
                      border: Border.all(color: Colors.white.withOpacity(0.14)),
                    ),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(emoji, style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                  ),
                ),
              );
            }

            return ClipRect(
              child: Row(
                children: [
                  Container(
                    width: thumb,
                    height: thumb,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withOpacity(0.10),
                      border: Border.all(color: Colors.white.withOpacity(0.14)),
                    ),
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(emoji, style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.90),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
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
/* Search + Glass primitives */
/* ========================================================================== */

class _SearchField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  const _SearchField({
    required this.controller,
    required this.hint,
    this.onChanged,
  });

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final FocusNode _fn = FocusNode();

  @override
  void dispose() {
    _fn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final focused = _fn.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.10),
        border: Border.all(
          color: focused
              ? cs.primary.withOpacity(0.55)
              : Colors.white.withOpacity(0.14),
          width: 1,
        ),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: cs.primary.withOpacity(0.20),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 20, color: Colors.white.withOpacity(0.75)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              focusNode: _fn,
              controller: widget.controller,
              style: t.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white.withOpacity(0.92),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.hint,
                hintStyle: t.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.55),
                ),
              ),
              onChanged: widget.onChanged,
            ),
          ),
          if (widget.controller.text.isNotEmpty)
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                widget.controller.clear();
                widget.onChanged?.call('');
                setState(() {});
              },
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Colors.white.withOpacity(0.75),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/* ========================================================================== */
/* Glass + Orbs + Gradient title */
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

    final bg = isDark ? Colors.white.withOpacity(0.07) : Colors.white.withOpacity(0.10);
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
          BoxShadow(color: color, blurRadius: 150, spreadRadius: 10),
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