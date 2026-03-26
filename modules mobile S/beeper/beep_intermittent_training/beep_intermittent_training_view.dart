// lib/features/beeper/beep_intermittent_training/beep_intermittent_training_view.dart
//
// ✅ Logic audio + calcul inchangée
// ✅ NO TabBar / NO TabBarView
// ✅ Nouveau design moderne: Scroll premium + cards accordéon + animations + Calcul en BottomSheet
// ✅ Background + overlay premium (style HomePage)
// ✅ Glass cards sombres, UI plus tendance

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../beep_test/audio_widget.dart';

/// ✅ Texts (no localization)
class _TXT {
  static const String screenTitle = "Beep Intermittent Training";

  static const String title1 = "Séance 1";
  static const String title2 = "Séance 2";
  static const String title3 = "Séance 3";
  static const String title4 = "Séance 4";
  static const String title5 = "Séance 5";
  static const String title6 = "Séance 6";

  static const String desc1 =
      "Lance la bande audio et suis les bips (effort / récupération) selon le protocole.";
  static const String desc2 =
      "Séance intermittente : respecte les phases de travail et de repos à chaque bip.";
  static const String desc3 =
      "Séance intermittente : adapte ton intensité à chaque signal sonore.";
  static const String desc4 =
      "Séance intermittente : conserve une exécution régulière tout au long du protocole.";
  static const String desc5 =
      "Séance intermittente : alterne travail/récupération, garde une intensité stable.";
  static const String desc6 =
      "Séance intermittente : maintiens la régularité et contrôle ta fatigue.";

  static const String calcTitle = "Calculateur 30-15";
  static const String calcDesc =
      "Calcule les cycles, segments et bips selon Work / Rest / Durée.";
  static const String calcWork = "Work";
  static const String calcRest = "Rest";
  static const String calcDuration = "Durée";
  static const String calcCompute = "Calculer";
  static const String calcResults = "Résultats";

  static const String secondsShort = "s";

  static const String resCycle = "Cycle";
  static const String resCycles = "Cycles";
  static const String resSegments = "Segments";
  static const String resBeeps = "Bips";
  static const String resResidual = "Reste";

  static const String calcHint =
      "Hypothèse conservée : 1 cycle = 2 segments (work + rest), 1 bip par segment.";

  static const String snackEnterPositive = "Entrez des valeurs positives.";
  static const String snackCyclePositive = "Le cycle doit être > 0.";

  static const String chipStart = "Démarrer";
  static const String chipOpenCalc = "Ouvrir calculateur";
  static const String chipTips = "Conseils";
}

class BeepIntermittentTrainingView extends StatefulWidget {
  const BeepIntermittentTrainingView({super.key});

  @override
  State<BeepIntermittentTrainingView> createState() =>
      _BeepIntermittentTrainingViewState();
}

class _BeepIntermittentTrainingViewState
    extends State<BeepIntermittentTrainingView> with TickerProviderStateMixin {
  static const String _bg = "assets/images/BgS.jfif";

  late final AnimationController _enterCtrl;

  final List<_SessionModel> _sessions = const [
    _SessionModel(
      label: "5-25 • 10 min",
      title: _TXT.title1,
      desc: _TXT.desc1,
      url:
          "https://api.sportspedagogue.com/beep_entrainement_intermitent/5_25_10miute.mp3",
    ),
    _SessionModel(
      label: "15-10 • 12 min",
      title: _TXT.title2,
      desc: _TXT.desc2,
      url:
          "https://api.sportspedagogue.com/beep_entrainement_intermitent/15_10_12miut.mp3",
    ),
    _SessionModel(
      label: "15-15 • 10 min",
      title: _TXT.title3,
      desc: _TXT.desc3,
      url:
          "https://api.sportspedagogue.com/beep_entrainement_intermitent/15_15_10min.mp3",
    ),
    _SessionModel(
      label: "20-20 • 10 min",
      title: _TXT.title4,
      desc: _TXT.desc4,
      url:
          "https://api.sportspedagogue.com/beep_entrainement_intermitent/20_20_10minute.mp3",
    ),
    _SessionModel(
      label: "30-15 • 15 min",
      title: _TXT.title5,
      desc: _TXT.desc5,
      url:
          "https://api.sportspedagogue.com/beep_entrainement_intermitent/30_15_15miut.mp3",
    ),
    _SessionModel(
      label: "20 min",
      title: _TXT.title6,
      desc: _TXT.desc6,
      url:
          "https://api.sportspedagogue.com/beep_entrainement_intermitent/20minuites.mp3",
    ),
  ];

  // Accordion open/close
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

  void _openCalcSheet() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CalcBottomSheet(),
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
          // ✅ Background
          Positioned.fill(
            child: Image.asset(
              _bg,
              fit: BoxFit.cover,
              alignment: Alignment.center,
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
                        _HeaderModern(
                          title: _TXT.screenTitle,
                          onBack: () => Navigator.of(context).maybePop(),
                          onCalc: _openCalcSheet,
                        ),
                        const SizedBox(height: 12),

                        // ✅ Quick actions row (modern chips)
                        _QuickActions(
                          onCalc: _openCalcSheet,
                        ),
                        const SizedBox(height: 12),

                        // ✅ Main content
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
                                      child: _InfoBanner(
                                        title: "Séances prêtes",
                                        subtitle:
                                            "Ouvre une carte, lance l’audio et suis les bips.",
                                      ),
                                    ),
                                  ),

                                  SliverList.separated(
                                    itemCount: _sessions.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 10),
                                    itemBuilder: (context, index) {
                                      final s = _sessions[index];

                                      final anim = CurvedAnimation(
                                        parent: _enterCtrl,
                                        curve: Interval(
                                          0.08 + (index * 0.08),
                                          1.0,
                                          curve: Curves.easeOutCubic,
                                        ),
                                      );

                                      return Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            12, index == 0 ? 0 : 0, 12, 0),
                                        child: FadeTransition(
                                          opacity: anim,
                                          child: SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(0, 0.06),
                                              end: Offset.zero,
                                            ).animate(anim),
                                            child: _SessionAccordionCard(
                                              model: s,
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

                                  // ✅ Dedicated card for calculator access (no Tab)
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(12, 0, 12, 14),
                                      child: _CalcEntryCard(
                                        onTap: _openCalcSheet,
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

class _SessionModel {
  final String label;
  final String title;
  final String desc;
  final String url;

  const _SessionModel({
    required this.label,
    required this.title,
    required this.desc,
    required this.url,
  });
}

/* ========================================================================== */
/*                                    UI                                      */
/* ========================================================================== */

class _HeaderModern extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onCalc;

  const _HeaderModern({
    required this.title,
    required this.onBack,
    required this.onCalc,
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
            onTap: onCalc,
            accent: cs.primary.withOpacity(0.90),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onCalc;

  const _QuickActions({required this.onCalc});

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
                Icon(Icons.graphic_eq_rounded,
                    size: 18, color: cs.primary.withOpacity(0.92)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Audio • Protocoles",
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
            onCalc();
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
                  _TXT.chipOpenCalc,
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

class _SessionAccordionCard extends StatelessWidget {
  final _SessionModel model;
  final bool isOpen;
  final VoidCallback onToggle;

  const _SessionAccordionCard({
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
                        model.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withOpacity(0.96),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        model.label,
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

          // Details (accordion)
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

                        // ✅ Audio logic unchanged (same AudioWidget)
                        AudioWidget(source: model.url),
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
                border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
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
                    _TXT.calcTitle,
                    style: t.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withOpacity(0.96),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _TXT.calcDesc,
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

/* ========================================================================== */
/*                              Calculator BottomSheet                        */
/* ========================================================================== */

class _CalcBottomSheet extends StatelessWidget {
  const _CalcBottomSheet();

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
                // Handle + header
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
                              _TXT.calcTitle,
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
                        _TXT.calcDesc,
                        style: t.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.78),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, color: Color(0x22FFFFFF)),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                    physics: const BouncingScrollPhysics(),
                    child: const _IntermittentCalcBody(),
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

/// ✅ Same compute logic as your previous tab
class _IntermittentCalcBody extends StatefulWidget {
  const _IntermittentCalcBody();

  @override
  State<_IntermittentCalcBody> createState() => _IntermittentCalcBodyState();
}

class _IntermittentCalcBodyState extends State<_IntermittentCalcBody> {
  final TextEditingController _workCtrl = TextEditingController(text: '15');
  final TextEditingController _restCtrl = TextEditingController(text: '15');
  final TextEditingController _durationCtrl = TextEditingController(text: '10');

  int? _cycleSeconds;
  int? _cycles;
  int? _segments;
  int? _beeps;
  int? _residual;

  @override
  void dispose() {
    _workCtrl.dispose();
    _restCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  void _compute() {
    final ctx = context;

    final work = int.tryParse(_workCtrl.text.trim());
    final rest = int.tryParse(_restCtrl.text.trim());
    final durationMin = int.tryParse(_durationCtrl.text.trim());

    if (work == null ||
        work <= 0 ||
        rest == null ||
        rest <= 0 ||
        durationMin == null ||
        durationMin <= 0) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text(_TXT.snackEnterPositive)),
      );
      return;
    }

    final totalSeconds = durationMin * 60;
    final cycle = work + rest;

    if (cycle <= 0) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text(_TXT.snackCyclePositive)),
      );
      return;
    }

    final cycles = totalSeconds ~/ cycle;
    final usedSeconds = cycles * cycle;
    final residual = totalSeconds - usedSeconds;

    final segments = cycles * 2;
    final beeps = segments;

    setState(() {
      _cycleSeconds = cycle;
      _cycles = cycles;
      _segments = segments;
      _beeps = beeps;
      _residual = residual;
    });

    HapticFeedback.selectionClick();
  }

  String _fmtInt(int? v) => v?.toString() ?? '--';

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Glass(
          radius: 18,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
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
                    child: Icon(Icons.tune_rounded,
                        color: cs.primary.withOpacity(0.92), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Paramètres",
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
                    child: _NumberField(
                      label: _TXT.calcWork,
                      suffix: _TXT.secondsShort,
                      controller: _workCtrl,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NumberField(
                      label: _TXT.calcRest,
                      suffix: _TXT.secondsShort,
                      controller: _restCtrl,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _NumberField(
                label: _TXT.calcDuration,
                suffix: "min",
                controller: _durationCtrl,
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _compute();
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white.withOpacity(0.12),
                      border:
                          Border.all(color: Colors.white.withOpacity(0.16), width: 1),
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
                        Icon(Icons.auto_awesome_rounded,
                            size: 18, color: cs.primary.withOpacity(0.92)),
                        const SizedBox(width: 8),
                        Text(
                          _TXT.calcCompute,
                          style: t.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: Colors.white.withOpacity(0.94),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Glass(
          radius: 18,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _TXT.calcResults,
                style: t.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withOpacity(0.96),
                ),
              ),
              const SizedBox(height: 10),
              _ResultRow(
                label: _TXT.resCycle,
                value: "${_fmtInt(_cycleSeconds)} ${_TXT.secondsShort}",
              ),
              _ResultRow(label: _TXT.resCycles, value: _fmtInt(_cycles)),
              _ResultRow(label: _TXT.resSegments, value: _fmtInt(_segments)),
              _ResultRow(label: _TXT.resBeeps, value: _fmtInt(_beeps)),
              _ResultRow(
                label: _TXT.resResidual,
                value: "${_fmtInt(_residual)} ${_TXT.secondsShort}",
              ),
              const SizedBox(height: 8),
              Text(
                _TXT.calcHint,
                style: t.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.72),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/* ========================================================================== */
/*                                 UI Kit                                     */
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

class _NumberField extends StatelessWidget {
  final String label;
  final String suffix;
  final TextEditingController controller;

  const _NumberField({
    required this.label,
    required this.suffix,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

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
            suffixText: suffix,
            suffixStyle: t.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.78),
            ),
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
                color: Theme.of(context).colorScheme.primary.withOpacity(0.85),
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow({
    required this.label,
    required this.value,
  });

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
