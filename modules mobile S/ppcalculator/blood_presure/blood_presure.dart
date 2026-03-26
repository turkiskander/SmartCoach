// lib/feature/ppCalculator/heart/blood_presure.dart
//
// ✅ LOGIQUE _calculateFromAgeGroup() INCHANGÉE (switch-case identique)
// ✅ DESIGN ALIGNÉ SUR TargetHeartRate (BgS + overlay + orbs + glass + header moderne)
// ✅ SANS localization / SANS packages externes
// ✅ Navigation moderne (chips) + scrollTo sections + même “vibe” couleurs/background
//
// Assets requis:
// - assets/images/BgS.jfif

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BloodPresure extends StatefulWidget {
  const BloodPresure({super.key});

  @override
  State<BloodPresure> createState() => _BloodPresureState();
}

class _BloodPresureState extends State<BloodPresure>
    with SingleTickerProviderStateMixin {
  static const String _bg = "assets/images/BgS.jfif";

  late final AnimationController _enterCtrl;

  // Scroll + sections
  final ScrollController _scrollCtrl = ScrollController();
  final GlobalKey _kIntro = GlobalKey();
  final GlobalKey _kForm = GlobalKey();
  final GlobalKey _kResults = GlobalKey();

  // Controller + selection
  final TextEditingController ageController = TextEditingController();
  String? _selectedAge;

  // Results
  String systolicMin = "0";
  String systolicAvg = "0";
  String systolicMax = "0";
  String diastolicMin = "0";
  String diastolicAvg = "0";
  String diastolicMax = "0";

  bool get _canSubmit => ageController.text.trim().isNotEmpty;

  static const List<String> _ageGroups = [
    "15-19",
    "20-24",
    "25-29",
    "30-34",
    "35-39",
    "40-44",
    "45-49",
    "50-54",
    "55-59",
    "60-64",
  ];

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    )..forward();

    ageController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _scrollCtrl.dispose();
    ageController.dispose();
    super.dispose();
  }

  // =================== LOGIQUE INCHANGÉE ===================

  void _calculateFromAgeGroup() {
    final ageLabel = ageController.text.trim();

    if (ageLabel.isEmpty) {
      _showSelectAgeAlert();
      return;
    }

    HapticFeedback.selectionClick();

    String sMin = "0", sAvg = "0", sMax = "0";
    String dMin = "0", dAvg = "0", dMax = "0";

    switch (ageLabel) {
      case '15-19':
        sMin = "105";
        sAvg = "117";
        sMax = "120";
        dMin = "73";
        dAvg = "77";
        dMax = "81";
        break;

      case '20-24':
        sMin = "108";
        sAvg = "120";
        sMax = "132";
        dMin = "75";
        dAvg = "79";
        dMax = "83";
        break;

      case '25-29':
        sMin = "109";
        sAvg = "121";
        sMax = "133";
        dMin = "76";
        dAvg = "80";
        dMax = "84";
        break;

      case '30-34':
        sMin = "110";
        sAvg = "122";
        sMax = "134";
        dMin = "77";
        dAvg = "81";
        dMax = "85";
        break;

      case '35-39':
        sMin = "111";
        sAvg = "133";
        sMax = "135";
        dMin = "78";
        dAvg = "82";
        dMax = "86";
        break;

      case '40-44':
        sMin = "112";
        sAvg = "125";
        sMax = "137";
        dMin = "79";
        dAvg = "83";
        dMax = "87";
        break;

      case '45-49':
        sMin = "115";
        sAvg = "127";
        sMax = "139";
        dMin = "80";
        dAvg = "84";
        dMax = "88";
        break;

      case '50-54':
        sMin = "116";
        sAvg = "129";
        sMax = "142";
        dMin = "81";
        dAvg = "85";
        dMax = "89";
        break;

      case '55-59':
        sMin = "118";
        sAvg = "131";
        sMax = "144";
        dMin = "82";
        dAvg = "86";
        dMax = "90";
        break;

      case '60-64':
        sMin = "121";
        sAvg = "134";
        sMax = "147";
        dMin = "83";
        dAvg = "87";
        dMax = "91";
        break;

      default:
        _showSelectAgeAlert();
        return;
    }

    setState(() {
      systolicMin = sMin;
      systolicAvg = sAvg;
      systolicMax = sMax;
      diastolicMin = dMin;
      diastolicAvg = dAvg;
      diastolicMax = dMax;
    });

    HapticFeedback.lightImpact();
  }

  void _showSelectAgeAlert() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Oops'),
        content: const Text('Please Select Age Group.'),
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
    setState(() {
      _selectedAge = null;
      ageController.text = "";
      systolicMin = "0";
      systolicAvg = "0";
      systolicMax = "0";
      diastolicMin = "0";
      diastolicAvg = "0";
      diastolicMax = "0";
    });
    HapticFeedback.selectionClick();
  }

  // =================== NAV ===================

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    HapticFeedback.selectionClick();
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  void _openTips() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _TipsSheet(
        title: "Conseils",
        bullets: [
          "Les valeurs affichées sont des repères moyens (min/avg/max) par tranche d’âge.",
          "Si ta tension est souvent élevée, consulte un professionnel de santé.",
          "Mesure au repos, assis(e), après 5 minutes de calme.",
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
      builder: (_) => _BPResultsSheet(
        age: ageController.text.trim(),
        sMin: systolicMin,
        sAvg: systolicAvg,
        sMax: systolicMax,
        dMin: diastolicMin,
        dAvg: diastolicAvg,
        dMax: diastolicMax,
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

    // Fix dropdown sur blur
    final solidDropdownBg = isDark ? const Color(0xFF0B1220) : Colors.white;
    final dropdownTheme = Theme.of(context).copyWith(
      canvasColor: solidDropdownBg,
      cardColor: solidDropdownBg,
      dialogBackgroundColor: solidDropdownBg,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ✅ Background (IDENTIQUE vibe TargetHeartRate)
          Positioned.fill(
            child: Image.asset(
              _bg,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFF0B0F14)),
            ),
          ),

          // ✅ Overlay premium (IDENTIQUE)
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

          // Orbs discrets (IDENTIQUE)
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
              child: AnimatedBuilder(
                animation: _enterCtrl,
                builder: (context, _) {
                  final fade = CurvedAnimation(
                    parent: _enterCtrl,
                    curve: Curves.easeOut,
                  ).value;

                  return Opacity(
                    opacity: fade,
                    child: Column(
                      children: [
                        // ✅ Header moderne IDENTIQUE
                        _HeaderModern(
                          title: "Blood Pressure",
                          onBack: () => Navigator.of(context).maybePop(),
                          onAction: _openTips,
                          actionIcon: Icons.lightbulb_outline_rounded,
                        ),
                        const SizedBox(height: 12),

                        Expanded(
                          child: _Glass(
                            radius: 20,
                            padding: EdgeInsets.zero,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Theme(
                                data: dropdownTheme,
                                child: CustomScrollView(
                                  controller: _scrollCtrl,
                                  physics: const BouncingScrollPhysics(),
                                  slivers: [
                                    // Banner “Ready” like Target
                                    SliverToBoxAdapter(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            12, 12, 12, 8),
                                        child: _InfoBanner(
                                          title: "Ready",
                                          subtitle:
                                              "Select your age group then calculate.",
                                          icon: Icons.monitor_heart_rounded,
                                        ),
                                      ),
                                    ),

                                    // ✅ Navigation chips dans le même style
                                    SliverToBoxAdapter(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            12, 0, 12, 10),
                                        child: _NavChips(
                                          onIntro: () => _scrollTo(_kIntro),
                                          onForm: () => _scrollTo(_kForm),
                                          onResults: () => _scrollTo(_kResults),
                                          onClear: _clearAll,
                                          onSheet: _openResultsSheet,
                                        ),
                                      ),
                                    ),

                                    // Hero / Intro (image + textes, style identique)
                                    SliverToBoxAdapter(
                                      key: _kIntro,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            12, 0, 12, 10),
                                        child: _Glass(
                                          radius: 18,
                                          padding: const EdgeInsets.all(14),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 44,
                                                    height: 44,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              14),
                                                      color: Colors.white
                                                          .withOpacity(0.10),
                                                      border: Border.all(
                                                        color: Colors.white
                                                            .withOpacity(0.14),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Icon(
                                                      Icons.favorite_rounded,
                                                      color: cs.primary
                                                          .withOpacity(0.92),
                                                      size: 22,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      "Blood Pressure Reference",
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: t.textTheme
                                                          .titleMedium
                                                          ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color: Colors.white
                                                            .withOpacity(0.96),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                child: SizedBox(
                                                  height: 180,
                                                  child: Stack(
                                                    children: [
                                                      Positioned.fill(
                                                        child: Image.network(
                                                          "https://application.sportspedagogue.com/_nuxt/img/blood.8d61f66.jpg",
                                                          fit: BoxFit.cover,
                                                          filterQuality:
                                                              FilterQuality.high,
                                                          loadingBuilder: (c,
                                                              child, progress) {
                                                            if (progress ==
                                                                null) {
                                                              return child;
                                                            }
                                                            return const Center(
                                                              child: SizedBox(
                                                                height: 22,
                                                                width: 22,
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          errorBuilder: (_, __,
                                                                  ___) =>
                                                              const Center(
                                                            child: Icon(
                                                              Icons
                                                                  .broken_image_rounded,
                                                              color: Colors
                                                                  .white70,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned.fill(
                                                        child: DecoratedBox(
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              begin: Alignment
                                                                  .topCenter,
                                                              end: Alignment
                                                                  .bottomCenter,
                                                              colors: [
                                                                Colors.black
                                                                    .withOpacity(
                                                                        0.16),
                                                                Colors
                                                                    .transparent,
                                                                Colors.black
                                                                    .withOpacity(
                                                                        0.30),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned.fill(
                                                        child: DecoratedBox(
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.14),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                "Select your age group to view typical blood pressure values.",
                                                textAlign: TextAlign.center,
                                                style: t.textTheme.bodyMedium
                                                    ?.copyWith(
                                                  height: 1.25,
                                                  color: Colors.white
                                                      .withOpacity(0.82),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                "Results show Min / Average / Max (mmHg).",
                                                textAlign: TextAlign.center,
                                                style: t.textTheme.bodySmall
                                                    ?.copyWith(
                                                  height: 1.25,
                                                  color: Colors.white
                                                      .withOpacity(0.70),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Form (Age) identique style
                                    SliverToBoxAdapter(
                                      key: _kForm,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            12, 0, 12, 10),
                                        child: _Glass(
                                          radius: 18,
                                          padding: const EdgeInsets.all(14),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 44,
                                                    height: 44,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              14),
                                                      color: Colors.white
                                                          .withOpacity(0.10),
                                                      border: Border.all(
                                                        color: Colors.white
                                                            .withOpacity(0.14),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Icon(
                                                      Icons.tune_rounded,
                                                      color: cs.primary
                                                          .withOpacity(0.92),
                                                      size: 22,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      "Parameters",
                                                      style: t.textTheme
                                                          .titleMedium
                                                          ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color: Colors.white
                                                            .withOpacity(0.96),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: _AgeDropdown(
                                                      title: "Age Group",
                                                      value: _selectedAge,
                                                      items: _ageGroups,
                                                      onChanged: (v) {
                                                        setState(() {
                                                          _selectedAge = v;
                                                          ageController.text =
                                                              v ?? '';
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  const _UnitPill(text: "mmHg"),
                                                ],
                                              ),
                                              const SizedBox(height: 14),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  onTap: _canSubmit
                                                      ? () {
                                                          _calculateFromAgeGroup();
                                                          _scrollTo(_kResults);
                                                        }
                                                      : null,
                                                  child: Opacity(
                                                    opacity:
                                                        _canSubmit ? 1.0 : 0.55,
                                                    child: const _ActionButton(
                                                      icon: Icons
                                                          .auto_awesome_rounded,
                                                      label: "Calculate",
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Results (table style identique Target)
                                    SliverToBoxAdapter(
                                      key: _kResults,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            12, 0, 12, 14),
                                        child: _Glass(
                                          radius: 18,
                                          padding: const EdgeInsets.all(14),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 44,
                                                    height: 44,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              14),
                                                      color: Colors.white
                                                          .withOpacity(0.10),
                                                      border: Border.all(
                                                        color: Colors.white
                                                            .withOpacity(0.14),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Icon(
                                                      Icons.analytics_rounded,
                                                      color: cs.primary
                                                          .withOpacity(0.92),
                                                      size: 22,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      "YOUR RESULTS",
                                                      style: t.textTheme
                                                          .titleMedium
                                                          ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color: Colors.white
                                                            .withOpacity(0.96),
                                                      ),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    onTap: _openResultsSheet,
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 8),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        color: Colors.white
                                                            .withOpacity(0.10),
                                                        border: Border.all(
                                                          color: Colors.white
                                                              .withOpacity(
                                                                  0.14),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        "Sheet",
                                                        style: t
                                                            .textTheme
                                                            .labelLarge
                                                            ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          color: Colors.white
                                                              .withOpacity(
                                                                  0.92),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),

                                              const _HeaderRowGlass(
                                                left: "Type",
                                                right: "Min / Avg / Max",
                                              ),
                                              const SizedBox(height: 8),

                                              _ResultTripletRowGlass(
                                                alt: true,
                                                title: "Systolic",
                                                min: systolicMin,
                                                avg: systolicAvg,
                                                max: systolicMax,
                                              ),
                                              _ResultTripletRowGlass(
                                                title: "Diastolic",
                                                min: diastolicMin,
                                                avg: diastolicAvg,
                                                max: diastolicMax,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SliverToBoxAdapter(
                                        child: SizedBox(height: 6)),
                                  ],
                                ),
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
/*                                    UI Kit                                  */
/* ========================================================================== */

class _HeaderModern extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onAction;
  final IconData actionIcon;

  const _HeaderModern({
    required this.title,
    required this.onBack,
    required this.onAction,
    required this.actionIcon,
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
            icon: actionIcon,
            onTap: onAction,
            accent: cs.primary.withOpacity(0.90),
          ),
        ],
      ),
    );
  }
}

class _NavChips extends StatelessWidget {
  final VoidCallback onIntro;
  final VoidCallback onForm;
  final VoidCallback onResults;
  final VoidCallback onClear;
  final VoidCallback onSheet;

  const _NavChips({
    required this.onIntro,
    required this.onForm,
    required this.onResults,
    required this.onClear,
    required this.onSheet,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    Widget chip(IconData icon, String label, VoidCallback onTap) {
      return InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white.withOpacity(0.10),
            border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: cs.primary.withOpacity(0.92)),
              const SizedBox(width: 8),
              Text(
                label,
                style: t.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withOpacity(0.92),
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
          chip(Icons.tune_rounded, "Age", onForm),
          const SizedBox(width: 10),
          chip(Icons.analytics_rounded, "Results", onResults),
          const SizedBox(width: 10),
          chip(Icons.open_in_new_rounded, "Sheet", onSheet),
          const SizedBox(width: 10),
          chip(Icons.delete_outline_rounded, "Clear", onClear),
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
              border: Border.all(
                color: Colors.white.withOpacity(0.14),
                width: 1,
              ),
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionButton({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.12),
        border: Border.all(color: Colors.white.withOpacity(0.16), width: 1),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            color: Colors.black.withOpacity(0.25),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: cs.primary.withOpacity(0.92)),
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
    );
  }
}

class _HeaderRowGlass extends StatelessWidget {
  final String left;
  final String right;

  const _HeaderRowGlass({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.12),
        border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              left,
              style: t.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(0.90),
              ),
            ),
          ),
          Text(
            right,
            style: t.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.90),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultTripletRowGlass extends StatelessWidget {
  final String title;
  final String min;
  final String avg;
  final String max;
  final bool alt;

  const _ResultTripletRowGlass({
    required this.title,
    required this.min,
    required this.avg,
    required this.max,
    this.alt = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    Widget pill(String k, String v, {bool strong = false}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withOpacity(strong ? 0.14 : 0.10),
          border: Border.all(color: Colors.white.withOpacity(0.14)),
        ),
        child: Text(
          "$k: $v",
          style: t.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: Colors.white.withOpacity(strong ? 0.96 : 0.86),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: alt
            ? Colors.white.withOpacity(0.11)
            : Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: t.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(0.88),
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              pill("Min", min),
              pill("Avg", avg, strong: true),
              pill("Max", max),
            ],
          ),
        ],
      ),
    );
  }
}

class _UnitPill extends StatelessWidget {
  final String text;
  const _UnitPill({required this.text});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
        color: Colors.white.withOpacity(0.10),
      ),
      child: Text(
        text,
        style: t.textTheme.labelLarge?.copyWith(
          color: Colors.white.withOpacity(0.85),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _AgeDropdown extends StatelessWidget {
  final String title;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _AgeDropdown({
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      icon: Icon(
        Icons.expand_more_rounded,
        color: isDark ? Colors.white70 : Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: title,
        labelStyle: TextStyle(
          color: isDark ? Colors.white70 : Colors.black87,
          fontWeight: FontWeight.w800,
        ),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.22)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      dropdownColor: isDark ? const Color(0xFF0B1220) : Colors.white,
      items: items
          .map(
            (e) => DropdownMenuItem<String>(
              value: e,
              child: Text(
                e,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
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
        child: Icon(
          icon,
          color: (accent ?? Colors.white.withOpacity(0.92)),
          size: 20,
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

/* ============================= BottomSheets ============================= */

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
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.14),
                                  width: 1,
                                ),
                              ),
                              child: Icon(Icons.close_rounded,
                                  color: Colors.white.withOpacity(0.92)),
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

class _BPResultsSheet extends StatelessWidget {
  final String age;
  final String sMin, sAvg, sMax;
  final String dMin, dAvg, dMax;

  const _BPResultsSheet({
    required this.age,
    required this.sMin,
    required this.sAvg,
    required this.sMax,
    required this.dMin,
    required this.dAvg,
    required this.dMax,
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
                              "Results",
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
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.14),
                                  width: 1,
                                ),
                              ),
                              child: Icon(Icons.close_rounded,
                                  color: Colors.white.withOpacity(0.92)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (age.isNotEmpty)
                        Text(
                          "Age group: $age",
                          style: t.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.72),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0x22FFFFFF)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                  child: Column(
                    children: [
                      _SheetTriplet(
                        title: "Systolic (mmHg)",
                        min: sMin,
                        avg: sAvg,
                        max: sMax,
                      ),
                      const SizedBox(height: 10),
                      _SheetTriplet(
                        title: "Diastolic (mmHg)",
                        min: dMin,
                        avg: dAvg,
                        max: dMax,
                      ),
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

class _SheetTriplet extends StatelessWidget {
  final String title;
  final String min, avg, max;

  const _SheetTriplet({
    required this.title,
    required this.min,
    required this.avg,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    Widget pill(String k, String v) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white.withOpacity(0.08),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Column(
            children: [
              Text(
                k,
                style: t.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withOpacity(0.78),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                v,
                style: t.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withOpacity(0.96),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: t.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.92),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              pill("Min", min),
              const SizedBox(width: 10),
              pill("Avg", avg),
              const SizedBox(width: 10),
              pill("Max", max),
            ],
          ),
        ],
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