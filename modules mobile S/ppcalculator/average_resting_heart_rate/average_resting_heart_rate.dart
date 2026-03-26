// lib/feature/ppCalculator/heart/average_resting_heart_rate.dart
//
// ✅ DESIGN refait pour matcher BeepIntermittentTrainingView (glass + header moderne + orbs + scroll premium)
// ✅ Navigation moderne (chips qui scroll vers Sections: Intro / Saisie / Résultats)
// ✅ Logique de calcul + sync 10s↔1min INCHANGÉE (mêmes controllers, mêmes méthodes)
// ✅ Aucun package externe (Flutter only)
//
// ⚠️ Asset requis:
// - assets/images/BgHome.jfif

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AverageRestingHeartRate extends StatefulWidget {
  const AverageRestingHeartRate({super.key});

  @override
  State<AverageRestingHeartRate> createState() => _AverageRestingHeartRateState();
}

class _AverageRestingHeartRateState extends State<AverageRestingHeartRate>
    with TickerProviderStateMixin {
  // BG animé
  late final AnimationController _bgCtl;

  // ✅ Entrance animation (design)
  late final AnimationController _enterCtrl;

  // ✅ Background image
  static const String _bgHome = 'assets/images/BgHome.jfif';

  // ✅ Scroll + navigation
  final ScrollController _scrollCtrl = ScrollController();
  final GlobalKey _kIntro = GlobalKey();
  final GlobalKey _kInputs = GlobalKey();
  final GlobalKey _kResults = GlobalKey();

  // Controllers (5 jours × 2 champs)
  final TextEditingController day1 = TextEditingController();
  final TextEditingController day1Min = TextEditingController();
  final TextEditingController day2 = TextEditingController();
  final TextEditingController day2Min = TextEditingController();
  final TextEditingController day3 = TextEditingController();
  final TextEditingController day3Min = TextEditingController();
  final TextEditingController day4 = TextEditingController();
  final TextEditingController day4Min = TextEditingController();
  final TextEditingController day5 = TextEditingController();
  final TextEditingController day5Min = TextEditingController();

  // Résultats
  String average10sec = "0";
  String average1min = "0";
  String interpretation = "0";

  // Pour éviter les boucles infinies lors de la sync 10s ↔ 1min
  bool _isSyncing = false;

  bool get _canSubmit =>
      day1.text.trim().isNotEmpty &&
      day1Min.text.trim().isNotEmpty &&
      day2.text.trim().isNotEmpty &&
      day2Min.text.trim().isNotEmpty &&
      day3.text.trim().isNotEmpty &&
      day3Min.text.trim().isNotEmpty &&
      day4.text.trim().isNotEmpty &&
      day4Min.text.trim().isNotEmpty &&
      day5.text.trim().isNotEmpty &&
      day5Min.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();

    _bgCtl = AnimationController(vsync: this, duration: const Duration(seconds: 12))
      ..repeat();

    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
    )..forward();

    // Sync automatique (10s ↔ 1min)
    _linkPair(day1, day1Min);
    _linkPair(day2, day2Min);
    _linkPair(day3, day3Min);
    _linkPair(day4, day4Min);
    _linkPair(day5, day5Min);
  }

  @override
  void dispose() {
    _bgCtl.dispose();
    _enterCtrl.dispose();
    _scrollCtrl.dispose();

    day1.dispose();
    day1Min.dispose();
    day2.dispose();
    day2Min.dispose();
    day3.dispose();
    day3Min.dispose();
    day4.dispose();
    day4Min.dispose();
    day5.dispose();
    day5Min.dispose();
    super.dispose();
  }

  // ========= LOGIQUE INCHANGÉE =========

  /// Lie un champ "10 sec" à un champ "1 min" (×6 / ÷6)
  void _linkPair(TextEditingController c10s, TextEditingController c1m) {
    // 10 sec -> 1 min (×6)
    c10s.addListener(() {
      if (_isSyncing) return;
      _isSyncing = true;
      final txt = c10s.text.trim();
      final v = double.tryParse(txt);
      if (v == null) {
        c1m.text = '';
      } else {
        final res = v * 6.0;
        c1m.text = _formatNumber(res);
      }
      _isSyncing = false;
      setState(() {});
    });

    // 1 min -> 10 sec (÷6)
    c1m.addListener(() {
      if (_isSyncing) return;
      _isSyncing = true;
      final txt = c1m.text.trim();
      final v = double.tryParse(txt);
      if (v == null) {
        c10s.text = '';
      } else {
        final res = v / 6.0;
        c10s.text = _formatNumber(res);
      }
      _isSyncing = false;
      setState(() {});
    });
  }

  String _formatNumber(double v) {
    if (v % 1 == 0) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }

  bool _isNumAndNonZero(String s) {
    final v = double.tryParse(s);
    return v != null && v != 0;
  }

  void _showDayError(int dayIndex) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text('Please provide valid numeric values in Day $dayIndex inputs.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _clearAll() {
    day1.clear();
    day1Min.clear();
    day2.clear();
    day2Min.clear();
    day3.clear();
    day3Min.clear();
    day4.clear();
    day4Min.clear();
    day5.clear();
    day5Min.clear();

    setState(() {
      average10sec = "0";
      average1min = "0";
      interpretation = "0";
    });
  }

  /// ----- LOGIQUE LOCALE (sans API) -----
  /// (inchangée)
  void _calculateRHR() {
    HapticFeedback.selectionClick();

    final d1 = day1.text.trim();
    final d1m = day1Min.text.trim();
    final d2 = day2.text.trim();
    final d2m = day2Min.text.trim();
    final d3 = day3.text.trim();
    final d3m = day3Min.text.trim();
    final d4 = day4.text.trim();
    final d4m = day4Min.text.trim();
    final d5 = day5.text.trim();
    final d5m = day5Min.text.trim();

    if (!_isNumAndNonZero(d1) || !_isNumAndNonZero(d1m)) {
      _showDayError(1);
      return;
    }
    if (!_isNumAndNonZero(d2) || !_isNumAndNonZero(d2m)) {
      _showDayError(2);
      return;
    }
    if (!_isNumAndNonZero(d3) || !_isNumAndNonZero(d3m)) {
      _showDayError(3);
      return;
    }
    if (!_isNumAndNonZero(d4) || !_isNumAndNonZero(d4m)) {
      _showDayError(4);
      return;
    }
    if (!_isNumAndNonZero(d5) || !_isNumAndNonZero(d5m)) {
      _showDayError(5);
      return;
    }

    const c = 5.0;

    final sum10 = double.parse(d1) +
        double.parse(d2) +
        double.parse(d3) +
        double.parse(d4) +
        double.parse(d5);

    final avg10 = sum10 / c;
    final rAvg10 = avg10.toStringAsFixed(2);

    final sum1m = double.parse(d1m) +
        double.parse(d2m) +
        double.parse(d3m) +
        double.parse(d4m) +
        double.parse(d5m);

    final avg1 = sum1m / c;
    final rAvg1 = avg1.toStringAsFixed(2);

    String inter;
    if (avg1 <= 40) {
      inter = "Excellent (40- bpm)";
    } else if (avg1 > 40 && avg1 < 60) {
      inter = "Good (41 - 59 bpm)";
    } else if (avg1 >= 60 && avg1 <= 80) {
      inter = "Normal (60-80 bpm)";
    } else {
      inter = "Above Normal (81+ bpm)";
    }

    setState(() {
      average10sec = rAvg10;
      average1min = rAvg1;
      interpretation = inter;
    });

    HapticFeedback.lightImpact();
  }

  // ========= DESIGN / NAV =========

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    HapticFeedback.selectionClick();
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      alignment: 0.06,
    );
  }

  void _openTips() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TipsSheet(
        title: "Conseils",
        bullets: const [
          "Mesure au réveil, avant café/activité.",
          "Reste allongé(e) et respire calmement 1–2 minutes.",
          "Renseigne 5 jours consécutifs pour réduire les variations.",
          "Si tu saisis en 10s, la conversion 1 min se fait automatiquement (×6).",
        ],
      ),
    );
  }

  void _openResultsSheet() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ResultsSheet(
        avg10: average10sec,
        avg1: average1min,
        interpretation: interpretation,
      ),
    );
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

    const screenTitle = "Average Resting Heart Rate";
    const heroDesc = "Enter your resting heart rate for 5 days.";
    const headerSubtitle = "5 days • 10s ↔ 1 min auto sync";

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // BG
          Positioned.fill(
            child: Image.asset(
              _bgHome,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0B0F14)),
            ),
          ),

          // Overlay premium
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [
                          Colors.black.withOpacity(0.56),
                          Colors.black.withOpacity(0.32),
                          Colors.black.withOpacity(0.64),
                        ]
                      : [
                          Colors.black.withOpacity(0.34),
                          Colors.black.withOpacity(0.18),
                          Colors.black.withOpacity(0.40),
                        ],
                ),
              ),
            ),
          ),

          // Orbs discrets
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

          // Lignes subtiles
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _bgCtl,
                builder: (_, __) => CustomPaint(
                  painter: _SubtleLines(progress: _bgCtl.value),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: AnimatedBuilder(
                animation: _enterCtrl,
                builder: (_, __) {
                  final v = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut).value;

                  return Opacity(
                    opacity: v,
                    child: Column(
                      children: [
                        _HeaderModern(
                          title: screenTitle,
                          onBack: () => Navigator.of(context).maybePop(),
                          onPrimary: _openResultsSheet,
                          primaryIcon: Icons.analytics_rounded,
                        ),
                        const SizedBox(height: 12),

                        _QuickActions(
                          onIntro: () => _scrollTo(_kIntro),
                          onInputs: () => _scrollTo(_kInputs),
                          onResults: () => _scrollTo(_kResults),
                          onTips: _openTips,
                          onClear: _clearAll,
                        ),
                        const SizedBox(height: 12),

                        Expanded(
                          child: _Glass(
                            radius: 20,
                            padding: EdgeInsets.zero,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: CustomScrollView(
                                controller: _scrollCtrl,
                                physics: const BouncingScrollPhysics(),
                                slivers: [
                                  // Intro
                                  SliverToBoxAdapter(
                                    key: _kIntro,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                                      child: _InfoBanner(
                                        title: "Average Resting Heart Rate",
                                        subtitle: headerSubtitle,
                                        icon: Icons.favorite_rounded,
                                      ),
                                    ),
                                  ),

                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                      child: _Glass(
                                        radius: 18,
                                        padding: const EdgeInsets.all(14),
                                        child: Column(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(18),
                                              child: SizedBox(
                                                height: 190,
                                                width: double.infinity,
                                                child: Stack(
                                                  children: [
                                                    Positioned.fill(
                                                      child: Image.network(
                                                        "https://application.sportspedagogue.com/_nuxt/img/average.220defe.jpg",
                                                        fit: BoxFit.cover,
                                                        filterQuality: FilterQuality.high,
                                                        loadingBuilder: (context, child, progress) {
                                                          if (progress == null) return child;
                                                          return const Center(
                                                            child: SizedBox(
                                                              height: 22,
                                                              width: 22,
                                                              child: CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        errorBuilder: (_, __, ___) => const Center(
                                                          child: Icon(
                                                            Icons.broken_image_rounded,
                                                            color: Colors.white70,
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
                                                              Colors.black.withOpacity(0.18),
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
                                                          border: Border.all(color: Colors.white.withOpacity(0.14)),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              heroDesc,
                                              textAlign: TextAlign.center,
                                              style: t.textTheme.bodyMedium?.copyWith(
                                                color: Colors.white.withOpacity(0.78),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Inputs
                                  SliverToBoxAdapter(
                                    key: _kInputs,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _SectionTitle(
                                        icon: Icons.tune_rounded,
                                        title: "Paramètres",
                                        subtitle: "Renseigne les 5 jours (10 sec ou 1 min).",
                                      ),
                                    ),
                                  ),

                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                      child: _Glass(
                                        radius: 18,
                                        padding: const EdgeInsets.all(14),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            _TableHeader(gradA: cs.primary, gradB: (cs.tertiary == cs.primary ? cs.secondary : cs.tertiary)),
                                            const SizedBox(height: 12),

                                            _DayRow(label: "Day 1", c10s: day1, c1m: day1Min),
                                            _DayRow(label: "Day 2", c10s: day2, c1m: day2Min, alt: true),
                                            _DayRow(label: "Day 3", c10s: day3, c1m: day3Min),
                                            _DayRow(label: "Day 4", c10s: day4, c1m: day4Min, alt: true),
                                            _DayRow(label: "Day 5", c10s: day5, c1m: day5Min),

                                            const SizedBox(height: 14),

                                            Row(
                                              children: [
                                                Expanded(
                                                  child: _PrimaryButton(
                                                    enabled: _canSubmit,
                                                    onTap: _canSubmit
                                                        ? () {
                                                            _calculateRHR();
                                                            _scrollTo(_kResults);
                                                          }
                                                        : null,
                                                    icon: Icons.auto_awesome_rounded,
                                                    label: "Calculate",
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                _IconChip(
                                                  icon: Icons.backspace_rounded,
                                                  label: "Clear",
                                                  onTap: _clearAll,
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 10),

                                            _GlassHint(
                                              text: "Fill 5 days • Tap Calculate",
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Results
                                  SliverToBoxAdapter(
                                    key: _kResults,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _SectionTitle(
                                        icon: Icons.analytics_rounded,
                                        title: "YOUR RESULTS",
                                        subtitle: "Moyennes + interprétation.",
                                      ),
                                    ),
                                  ),

                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                                      child: _Glass(
                                        radius: 18,
                                        padding: const EdgeInsets.all(14),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            _ResultLine(
                                              title: "Average 10 sec RHR",
                                              value: average10sec,
                                              unit: "b/10s",
                                              alt: true,
                                            ),
                                            _ResultLine(
                                              title: "Average 1 min RHR",
                                              value: average1min,
                                              unit: "bpm",
                                            ),
                                            _ResultLine(
                                              title: "Interpretation",
                                              value: interpretation,
                                              unit: "",
                                              alt: true,
                                            ),
                                            const SizedBox(height: 10),
                                            _IconChip(
                                              icon: Icons.open_in_new_rounded,
                                              label: "Open in sheet",
                                              onTap: _openResultsSheet,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SliverToBoxAdapter(child: SizedBox(height: 6)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ========================================================================== */
/* UI - Header / Nav / Sections */
/* ========================================================================== */

class _HeaderModern extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onPrimary;
  final IconData primaryIcon;

  const _HeaderModern({
    required this.title,
    required this.onBack,
    required this.onPrimary,
    required this.primaryIcon,
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
              title,
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
          _PillIconButton(
            icon: primaryIcon,
            onTap: onPrimary,
            accent: cs.primary.withOpacity(0.92),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onIntro;
  final VoidCallback onInputs;
  final VoidCallback onResults;
  final VoidCallback onTips;
  final VoidCallback onClear;

  const _QuickActions({
    required this.onIntro,
    required this.onInputs,
    required this.onResults,
    required this.onTips,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    Widget chip(IconData icon, String label, VoidCallback onTap) {
      return InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: _Glass(
          radius: 18,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: cs.primary.withOpacity(0.92)),
              const SizedBox(width: 8),
              Text(
                label,
                style: t.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withOpacity(0.90),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          chip(Icons.info_outline_rounded, "Intro", onIntro),
          const SizedBox(width: 10),
          chip(Icons.tune_rounded, "Saisie", onInputs),
          const SizedBox(width: 10),
          chip(Icons.analytics_rounded, "Résultats", onResults),
          const SizedBox(width: 10),
          chip(Icons.lightbulb_outline_rounded, "Conseils", onTips),
          const SizedBox(width: 10),
          chip(Icons.delete_outline_rounded, "Clear", onClear),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

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
            child: Icon(icon, color: cs.primary.withOpacity(0.92), size: 22),
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

class _InfoBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _InfoBanner({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

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
            child: Icon(icon, color: cs.primary.withOpacity(0.92), size: 22),
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

class _TableHeader extends StatelessWidget {
  final Color gradA;
  final Color gradB;

  const _TableHeader({required this.gradA, required this.gradB});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [gradA, gradB],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "RHR",
              style: t.textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "10 sec",
              textAlign: TextAlign.center,
              style: t.textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "1 min",
              textAlign: TextAlign.center,
              style: t.textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ========================================================================== */
/* Inputs */
/* ========================================================================== */

class _DayRow extends StatelessWidget {
  final String label;
  final TextEditingController c10s;
  final TextEditingController c1m;
  final bool alt;

  const _DayRow({
    required this.label,
    required this.c10s,
    required this.c1m,
    this.alt = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = alt ? Colors.white.withOpacity(isDark ? 0.06 : 0.05) : Colors.transparent;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.90),
                  ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _NumField(controller: c10s, hint: 'e.g. 12'),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _NumField(controller: c1m, hint: 'e.g. 72'),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _NumField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        ],
        style: t.textTheme.bodyMedium?.copyWith(
          color: Colors.white.withOpacity(0.92),
          fontWeight: FontWeight.w900,
        ),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: hint,
          hintStyle: t.textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.45),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/* ========================================================================== */
/* Results */
/* ========================================================================== */

class _ResultLine extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final bool alt;

  const _ResultLine({
    required this.title,
    required this.value,
    required this.unit,
    this.alt = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = alt ? Colors.white.withOpacity(isDark ? 0.06 : 0.05) : Colors.transparent;
    final t = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: t.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white.withOpacity(0.88),
              ),
            ),
          ),
          Row(
            children: [
              const Text('🫀'),
              const SizedBox(width: 6),
              Text(
                value,
                style: t.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withOpacity(0.95),
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(
                  unit,
                  style: t.textTheme.labelLarge?.copyWith(
                    color: Colors.white.withOpacity(0.70),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/* ========================================================================== */
/* BottomSheets */
/* ========================================================================== */

class _TipsSheet extends StatelessWidget {
  final String title;
  final List<String> bullets;

  const _TipsSheet({required this.title, required this.bullets});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: _Glass(
        radius: 22,
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Container(
            color: Colors.black.withOpacity(0.16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: Colors.white.withOpacity(0.25),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: t.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: Colors.white.withOpacity(0.96),
                              ),
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: Colors.white.withOpacity(0.10),
                                border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
                              ),
                              child: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.92)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0x22FFFFFF)),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                    child: Column(
                      children: [
                        for (final b in bullets) ...[
                          _Bullet(text: b),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultsSheet extends StatelessWidget {
  final String avg10;
  final String avg1;
  final String interpretation;

  const _ResultsSheet({
    required this.avg10,
    required this.avg1,
    required this.interpretation,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: _Glass(
        radius: 22,
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Container(
            color: Colors.black.withOpacity(0.16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: Colors.white.withOpacity(0.25),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Résultats",
                              style: t.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: Colors.white.withOpacity(0.96),
                              ),
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: Colors.white.withOpacity(0.10),
                                border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
                              ),
                              child: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.92)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0x22FFFFFF)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                  child: Column(
                    children: [
                      _SheetLine(title: "Average 10 sec RHR", value: avg10, unit: "b/10s"),
                      const SizedBox(height: 10),
                      _SheetLine(title: "Average 1 min RHR", value: avg1, unit: "bpm"),
                      const SizedBox(height: 10),
                      _SheetLine(title: "Interpretation", value: interpretation, unit: ""),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.72),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: t.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.82),
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}

class _SheetLine extends StatelessWidget {
  final String title;
  final String value;
  final String unit;

  const _SheetLine({
    required this.title,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: t.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white.withOpacity(0.82),
              ),
            ),
          ),
          Text(
            value,
            style: t.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.96),
            ),
          ),
          if (unit.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              unit,
              style: t.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.70),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/* ========================================================================== */
/* UI Kit (Beep-like) */
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

class _PillIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? accent;

  const _PillIconButton({
    required this.icon,
    required this.onTap,
    this.accent,
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
        child: Icon(icon, color: (accent ?? Colors.white.withOpacity(0.92)), size: 20),
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

class _PrimaryButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onTap;
  final IconData icon;
  final String label;

  const _PrimaryButton({
    required this.enabled,
    required this.onTap,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: enabled ? () {
        HapticFeedback.lightImpact();
        onTap?.call();
      } : null,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withOpacity(enabled ? 0.12 : 0.08),
          border: Border.all(color: Colors.white.withOpacity(0.16), width: 1),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              color: Colors.black.withOpacity(0.25),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: cs.primary.withOpacity(enabled ? 0.92 : 0.55)),
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

class _IconChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _IconChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withOpacity(0.08),
          border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white.withOpacity(0.88)),
            const SizedBox(width: 8),
            Text(
              label,
              style: t.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(0.90),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassHint extends StatelessWidget {
  final String text;
  const _GlassHint({required this.text});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
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
          Icon(Icons.touch_app_rounded, size: 20, color: Colors.white.withOpacity(0.78)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: t.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.78),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ========================================================================== */
/* Painter */
/* ========================================================================== */

class _SubtleLines extends CustomPainter {
  final double progress; // 0..1
  _SubtleLines({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    final line = Paint()
      ..color = Colors.white.withOpacity(0.022)
      ..strokeWidth = 1;

    const gap = 7.0;
    final shift = (progress * 80) % gap;

    for (double y = -shift; y < h; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(w, y), line);
    }

    final vignette = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.22),
        ],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, vignette);
  }

  @override
  bool shouldRepaint(covariant _SubtleLines old) => old.progress != progress;
}