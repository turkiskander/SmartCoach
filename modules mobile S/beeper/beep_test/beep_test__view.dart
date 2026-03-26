// lib/features/beeper/beep_test/beep_test_view.dart
//
// ✅ UI refaite (identique au design moderne de BeepIntermittentTrainingView)
// ✅ NO TabBar / NO TabBarView
// ✅ Background + overlay premium (style HomePage)
// ✅ Glass cards sombres + accordéons + animations
// ✅ Calculateurs: LOGIQUE INCHANGÉE (Shuttle + YoYo) — seulement UI déplacée (BottomSheet)
// ✅ Audio: même AudioWidget (logique inchangée)

import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../beep_test/audio_widget.dart';

/// ✅ Texts (no localization / no intl)
class _TXT {
  static const String beepTest = "Beep Test";

  static const String tabLucLeger = "Luc Léger";
  static const String tab3015 = "30-15 IFT";
  static const String tabVma = "VMA";
  static const String tabYoyoIr = "YoYo IR";
  static const String tabYoyoEndu = "YoYo Endu";

  static const String parag1 =
      "Test progressif 20m (Luc Léger). Lance l’audio puis suis les bips.";
  static const String parag2 =
      "Test 30-15 IFT. Lance l’audio puis respecte les phases effort/récup.";
  static const String parag3 =
      "Test VMA progressif. Lance l’audio puis suis les paliers.";
  static const String parag4 = "YoYo Intermittent Recovery (niveau 1 et 2).";
  static const String parag5 = "YoYo Endurance (niveau 1 et 2).";

  static const String level1 = "Niveau 1";
  static const String level2 = "Niveau 2";

  static const String calculatorsTitle = "Calculateurs";
  static const String calculatorsDesc =
      "Calcule rapidement des estimations (distance, VMA approx, etc.).";

  // Shuttle / Luc Léger card
  static const String shuttleCardTitle = "Shuttle 20m (Luc Léger / VMA)";
  static const String palierLabel = "Palier";
  static const String navetteLabel = "Navette";
  static const String calculate = "Calculer";
  static const String enterPositiveIntegers =
      "Veuillez saisir des entiers positifs.";
  static const String palierSpeedLabel = "Vitesse du palier";
  static const String totalShuttlesLabel = "Navettes totales";
  static const String distanceLabel = "Distance";
  static const String approxVmaLabel = "VMA approx";
  static const String maxShuttlesPerLevelLabel = "Navettes max / palier";
  static const String shuttleTip =
      "Astuce : estimation simple basée sur un palier à 8,5 km/h puis +0,5 km/h.";

  static const String kmPerHour = "km/h";
  static const String meterShort = "m";

  // YoYo card
  static const String yoyoCardTitle = "YoYo (IR / Endurance)";
  static const String runsCompletedLabel = "Allers-retours complétés";
  static const String enterValidRuns = "Veuillez saisir un nombre valide (> 0).";
  static const String runLengthLabel = "Distance par aller-retour";
  static const String runsLabel = "Allers-retours";
  static const String yoyoTip =
      "Chaque aller-retour = 2 × 20 m = 40 m. Distance = N × 40 m.";

  // Chips
  static const String chipOpenCalculators = "Ouvrir calculateurs";
  static const String chipAudioProtocols = "Audio • Tests";
  static const String bannerTitle = "Tests prêts";
  static const String bannerSubtitle =
      "Ouvre une carte, lance l’audio et suis les bips.";
}

class BeepTestView extends StatefulWidget {
  const BeepTestView({super.key});

  @override
  State<BeepTestView> createState() => _BeepTestViewState();
}

class _BeepTestViewState extends State<BeepTestView>
    with TickerProviderStateMixin {
  static const String _baseUrl = "https://api.sportspedagogue.com/Beep_Test/";
  static const String _bg = "assets/images/BgS.jfif";

  late final AnimationController _enterCtrl;

  final List<_TestModel> _tests = [
    _TestModel(
      emoji: "🏃",
      title: _TXT.tabLucLeger,
      subtitle: "Shuttle 20m",
      desc: _TXT.parag1,
      content: [
        AudioWidget(source: "${_baseUrl}test_luc_leger.mp3"),
      ],
    ),
    _TestModel(
      emoji: "⏱️",
      title: _TXT.tab3015,
      subtitle: "Intermittent",
      desc: _TXT.parag2,
      content: [
        AudioWidget(source: "${_baseUrl}vma.mp3"),
      ],
    ),
    _TestModel(
      emoji: "🎯",
      title: _TXT.tabVma,
      subtitle: "Progressif",
      desc: _TXT.parag3,
      content: [
        AudioWidget(source: "${_baseUrl}testvma.mp3"),
      ],
    ),
    _TestModel(
      emoji: "🔁",
      title: _TXT.tabYoyoIr,
      subtitle: "Recovery",
      desc: _TXT.parag4,
      content: [
        const _SectionPill(text: _TXT.level1),
        AudioWidget(
          source: "${_baseUrl}Yo_yo_Intermittent_Recovery_Test_Level_1.mp3",
        ),
        const SizedBox(height: 12),
        const _SectionPill(text: _TXT.level2),
        AudioWidget(
          source: "${_baseUrl}Yo_Yo_Intermitent_Recovery_Test_Level_2.mp3",
        ),
      ],
    ),
    _TestModel(
      emoji: "🏁",
      title: _TXT.tabYoyoEndu,
      subtitle: "Endurance",
      desc: _TXT.parag5,
      content: [
        const _SectionPill(text: _TXT.level1),
        AudioWidget(source: "${_baseUrl}YOYO_20m_level_1.mp3"),
        const SizedBox(height: 12),
        const _SectionPill(text: _TXT.level2),
        AudioWidget(source: "${_baseUrl}YOYO_20m_level_2.mp3"),
      ],
    ),
  ];

  int _openIndex = 0;

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

  void _openCalculatorsSheet() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CalculatorsBottomSheet(),
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              _bg,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFF0B0F14)),
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

          // Orbs discrets
          Positioned(
            top: -140,
            left: -140,
            child: _GlowOrb(
              size: 340,
              color: cs.primary.withOpacity(isDark ? 0.10 : 0.08),
            ),
          ),
          Positioned(
            bottom: -170,
            right: -170,
            child: _GlowOrb(
              size: 380,
              color: cs.primary.withOpacity(isDark ? 0.12 : 0.10),
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
                        _HeaderModern(
                          title: _TXT.beepTest,
                          onBack: () => Navigator.of(context).maybePop(),
                          onCalculators: _openCalculatorsSheet,
                        ),
                        const SizedBox(height: 12),

                        _QuickActions(
                          onCalculators: _openCalculatorsSheet,
                        ),
                        const SizedBox(height: 12),

                        Expanded(
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
                                          12, 12, 12, 8),
                                      child: const _InfoBanner(
                                        title: _TXT.bannerTitle,
                                        subtitle: _TXT.bannerSubtitle,
                                      ),
                                    ),
                                  ),

                                  SliverList.separated(
                                    itemCount: _tests.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 10),
                                    itemBuilder: (context, index) {
                                      final m = _tests[index];

                                      final anim = CurvedAnimation(
                                        parent: _enterCtrl,
                                        curve: Interval(
                                          0.08 + (index * 0.08),
                                          1.0,
                                          curve: Curves.easeOutCubic,
                                        ),
                                      );

                                      return Padding(
                                        padding:
                                            const EdgeInsets.fromLTRB(12, 0, 12, 0),
                                        child: FadeTransition(
                                          opacity: anim,
                                          child: SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(0, 0.06),
                                              end: Offset.zero,
                                            ).animate(anim),
                                            child: _TestAccordionCard(
                                              model: m,
                                              isOpen: _openIndex == index,
                                              onToggle: () {
                                                HapticFeedback.selectionClick();
                                                setState(() {
                                                  _openIndex =
                                                      _openIndex == index
                                                          ? -1
                                                          : index;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                  const SliverToBoxAdapter(
                                    child: SizedBox(height: 14),
                                  ),

                                  // Entry card calculators (no tab)
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(12, 0, 12, 14),
                                      child: _CalcEntryCard(
                                        onTap: _openCalculatorsSheet,
                                      ),
                                    ),
                                  ),
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
/*                                    Models                                  */
/* ========================================================================== */

class _TestModel {
  final String emoji;
  final String title;
  final String subtitle;
  final String desc;
  final List<Widget> content;

  const _TestModel({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.desc,
    required this.content,
  });
}

/* ========================================================================== */
/*                                    UI                                      */
/* ========================================================================== */

class _HeaderModern extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onCalculators;

  const _HeaderModern({
    required this.title,
    required this.onBack,
    required this.onCalculators,
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
            icon: Icons.calculate_rounded,
            onTap: onCalculators,
            accent: cs.primary.withOpacity(0.90),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onCalculators;

  const _QuickActions({required this.onCalculators});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Row(
      children: [
        Expanded(
          child: _Glass(
            radius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.multitrack_audio_rounded,
                    size: 18, color: cs.primary.withOpacity(0.92)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _TXT.chipAudioProtocols,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withOpacity(0.84),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            HapticFeedback.lightImpact();
            onCalculators();
          },
          child: _Glass(
            radius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calculate_rounded,
                    size: 18, color: cs.primary.withOpacity(0.92)),
                const SizedBox(width: 8),
                Text(
                  _TXT.chipOpenCalculators,
                  style: t.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.90),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String title;
  final String subtitle;

  const _InfoBanner({
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
            child: Icon(Icons.timer_rounded,
                color: cs.primary.withOpacity(0.92), size: 22),
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

class _TestAccordionCard extends StatelessWidget {
  final _TestModel model;
  final bool isOpen;
  final VoidCallback onToggle;

  const _TestAccordionCard({
    required this.model,
    required this.isOpen,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return _Glass(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onToggle,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white.withOpacity(0.10),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.14), width: 1),
                  ),
                  child: Icon(Icons.play_circle_fill_rounded,
                      color: cs.primary.withOpacity(0.92), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${model.emoji} ${model.title}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withOpacity(0.96),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        model.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withOpacity(0.72),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedRotation(
                  turns: isOpen ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: Icon(Icons.expand_more_rounded,
                      color: Colors.white.withOpacity(0.88)),
                ),
              ],
            ),
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            child: isOpen
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          model.desc,
                          style: t.textTheme.bodyMedium?.copyWith(
                            height: 1.25,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.82),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...model.content,
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _CalcEntryCard extends StatelessWidget {
  final VoidCallback onTap;

  const _CalcEntryCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: _Glass(
        radius: 18,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.white.withOpacity(0.10),
                border:
                    Border.all(color: Colors.white.withOpacity(0.14), width: 1),
              ),
              child: Icon(Icons.calculate_rounded,
                  color: cs.primary.withOpacity(0.92), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _TXT.calculatorsTitle,
                    style: t.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withOpacity(0.96),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _TXT.calculatorsDesc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: t.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.72),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.arrow_forward_rounded,
                color: Colors.white.withOpacity(0.88)),
          ],
        ),
      ),
    );
  }
}

class _SectionPill extends StatelessWidget {
  final String text;
  const _SectionPill({required this.text});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withOpacity(0.10),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: t.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w900,
          color: Colors.white.withOpacity(0.82),
        ),
      ),
    );
  }
}

/* ========================================================================== */
/*                              BottomSheet Calculateurs                       */
/* ========================================================================== */

class _CalculatorsBottomSheet extends StatelessWidget {
  const _CalculatorsBottomSheet();

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
            color: Colors.black.withOpacity(0.15),
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
                              _TXT.calculatorsTitle,
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
                                    width: 1),
                              ),
                              child: Icon(Icons.close_rounded,
                                  color: Colors.white.withOpacity(0.92)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _TXT.calculatorsDesc,
                        style: t.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.78),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0x22FFFFFF)),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                    physics: const BouncingScrollPhysics(),
                    child: const Column(
                      children: [
                        _ShuttleCalculatorCard(),
                        SizedBox(height: 14),
                        _YoyoCalculatorCard(),
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

/* ========================================================================== */
/*                             UI Kit (identique)                              */
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

    final bg =
        isDark ? Colors.white.withOpacity(0.07) : Colors.white.withOpacity(0.10);
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

class _SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return _Glass(radius: 18, padding: padding, child: child);
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
        child: Icon(icon,
            color: (accent ?? Colors.white.withOpacity(0.92)), size: 20),
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

/* ========================================================================== */
/*                     CALCULATORS (LOGIC INCHANGÉE)                           */
/* ========================================================================== */

class _ShuttleCalculatorCard extends StatefulWidget {
  const _ShuttleCalculatorCard();

  @override
  State<_ShuttleCalculatorCard> createState() => _ShuttleCalculatorCardState();
}

class _ShuttleCalculatorCardState extends State<_ShuttleCalculatorCard> {
  final TextEditingController _palierCtrl = TextEditingController(text: '7');
  final TextEditingController _navetteCtrl = TextEditingController(text: '6');

  double? _vitessePalier;
  int? _navettesTotales;
  int? _distanceM;
  double? _vmaApprox;
  final int _navettesMaxPalier = 10;

  @override
  void dispose() {
    _palierCtrl.dispose();
    _navetteCtrl.dispose();
    super.dispose();
  }

  void _calculer() {
    final ctx = context;
    final palier = int.tryParse(_palierCtrl.text.trim());
    final navette = int.tryParse(_navetteCtrl.text.trim());

    if (palier == null || palier <= 0 || navette == null || navette <= 0) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text(_TXT.enterPositiveIntegers)),
      );
      return;
    }

    final double vitessePalier = 8.5 + 0.5 * (palier - 1);
    final int navettesTotales = (palier - 1) * _navettesMaxPalier + navette;
    final int distance = navettesTotales * 20;

    setState(() {
      _vitessePalier = vitessePalier;
      _navettesTotales = navettesTotales;
      _distanceM = distance;
      _vmaApprox = vitessePalier;
    });
  }

  String _fmtDouble1(double? v) => v == null ? '--' : v.toStringAsFixed(1);
  String _fmtInt(int? v) => v?.toString() ?? '--';

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _LeadingBadge(icon: Icons.directions_run_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _TXT.shuttleCardTitle,
                  style: t.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.96),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SmartNumberField(
                    label: _TXT.palierLabel, controller: _palierCtrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SmartNumberField(
                    label: _TXT.navetteLabel, controller: _navetteCtrl),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: _ActionButton(text: _TXT.calculate, onTap: _calculer),
          ),
          const SizedBox(height: 12),
          _ResultTile(
            label: _TXT.palierSpeedLabel,
            value: "${_fmtDouble1(_vitessePalier)} ${_TXT.kmPerHour}",
          ),
          _ResultTile(
              label: _TXT.totalShuttlesLabel, value: _fmtInt(_navettesTotales)),
          _ResultTile(
              label: _TXT.distanceLabel,
              value: "${_fmtInt(_distanceM)} ${_TXT.meterShort}"),
          _ResultTile(
              label: _TXT.approxVmaLabel,
              value: "${_fmtDouble1(_vmaApprox)} ${_TXT.kmPerHour}"),
          _ResultTile(
              label: _TXT.maxShuttlesPerLevelLabel,
              value: _navettesMaxPalier.toString()),
          const SizedBox(height: 8),
          Text(
            _TXT.shuttleTip,
            style: t.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.72),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _YoyoCalculatorCard extends StatefulWidget {
  const _YoyoCalculatorCard();

  @override
  State<_YoyoCalculatorCard> createState() => _YoyoCalculatorCardState();
}

class _YoyoCalculatorCardState extends State<_YoyoCalculatorCard> {
  final TextEditingController _runsCtrl = TextEditingController(text: '46');

  int? _distanceM;
  int? _runs;
  static const int _runLength = 40;

  @override
  void dispose() {
    _runsCtrl.dispose();
    super.dispose();
  }

  void _calculer() {
    final ctx = context;
    final runs = int.tryParse(_runsCtrl.text.trim());

    if (runs == null || runs <= 0) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text(_TXT.enterValidRuns)),
      );
      return;
    }

    final distance = runs * _runLength;

    setState(() {
      _runs = runs;
      _distanceM = distance;
    });
  }

  String _fmtInt(int? v) => v?.toString() ?? '--';

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _LeadingBadge(icon: Icons.loop_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _TXT.yoyoCardTitle,
                  style: t.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.96),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SmartNumberField(label: _TXT.runsCompletedLabel, controller: _runsCtrl),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: _ActionButton(text: _TXT.calculate, onTap: _calculer),
          ),
          const SizedBox(height: 12),
          _ResultTile(
              label: _TXT.distanceLabel,
              value: "${_fmtInt(_distanceM)} ${_TXT.meterShort}"),
          _ResultTile(
              label: _TXT.runLengthLabel,
              value: "$_runLength ${_TXT.meterShort}"),
          _ResultTile(label: _TXT.runsLabel, value: _fmtInt(_runs)),
          const SizedBox(height: 8),
          Text(
            _TXT.yoyoTip,
            style: t.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.72),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmartNumberField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _SmartNumberField({
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: t.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.white.withOpacity(0.78),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: t.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: Colors.white.withOpacity(0.96),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.10),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: cs.primary.withOpacity(0.85),
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _ActionButton({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded,
                color: cs.primary.withOpacity(0.92), size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: t.textTheme.labelLarge?.copyWith(
                color: Colors.white.withOpacity(0.94),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final String label;
  final String value;

  const _ResultTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.10),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: t.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white.withOpacity(0.78),
              ),
            ),
          ),
          Text(
            value,
            style: t.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.96),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadingBadge extends StatelessWidget {
  final IconData icon;
  const _LeadingBadge({required this.icon});

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
      child: Icon(icon, color: cs.primary.withOpacity(0.92), size: 22),
    );
  }
}
