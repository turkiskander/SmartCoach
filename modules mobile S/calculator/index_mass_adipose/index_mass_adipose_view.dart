import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IndexMassAdiposeView extends StatefulWidget {
  const IndexMassAdiposeView({super.key});

  @override
  State<IndexMassAdiposeView> createState() => _IndexMassAdiposeViewState();
}

class _TXT {
  static const String screenTitle = "Index de masse adipeuse";

  static const String infoTitle = "Analyse corporelle";
  static const String infoSubtitle =
      "Calcule ton IMA à partir de la taille et du tour de hanches.";

  static const String quickLabel = "IMA • Taille / Hanches";
  static const String quickCalc = "Calculateur";
  static const String quickTables = "Références";

  static const String introTitle = "À propos de l’IMA";
  static const String introBody =
      "L’index de masse adipeuse (IMA) est un indicateur permettant d’estimer la masse grasse corporelle sans utiliser le poids.\n\n"
      "Il repose principalement sur la taille et le tour de hanches. C’est un repère utile pour une première lecture, mais il doit toujours être interprété selon le sexe, l’âge et le contexte sportif.";

  static const String calcTitle = "Calculateur IMA";
  static const String calcDesc =
      "Saisis tes mesures puis lance le calcul sans modifier la formule.";
  static const String height = "Taille";
  static const String hip = "Hanches";
  static const String calculate = "Calculer";

  static const String resultsTitle = "Résultats";
  static const String imaShort = "IMA";
  static const String noResult = "—";
  static const String resultExplain =
      "L’IMA fournit une estimation de la masse grasse corporelle. Un résultat isolé ne suffit pas pour poser un diagnostic : il doit être comparé à des repères adaptés à l’âge et au sexe.";

  static const String interpretationTitle = "Interprétation";
  static const String interpretationBody =
      "Un IMA plus élevé peut correspondre à une masse grasse plus importante.\n\n"
      "Chez les sportifs, les valeurs peuvent varier selon la discipline, le niveau d’entraînement et la composition corporelle.\n\n"
      "Utilise ce résultat comme un indicateur de suivi, pas comme une conclusion médicale.";

  static const String formulaTitle = "Formule utilisée";
  static const String formulaBody =
      "IMA = (H / (T × √T)) − 18\n\n"
      "H = tour de hanches en centimètres\n"
      "T = taille en mètres\n\n"
      "La logique de calcul ci-dessous reste strictement identique à ton fichier d’origine.";

  static const String legendTitle = "Légende";
  static const String legendBody =
      "Les tableaux suivants donnent des repères généraux. Ils servent d’aide à la lecture mais ne remplacent pas une évaluation professionnelle.";

  static const String tablesTitle = "Tables de référence";
  static const String womenTitle = "Femmes";
  static const String menTitle = "Hommes";

  static const String colAge = "Âge";
  static const String colRange = "Références";
  static const String colStatus = "Catégories";

  static const String age1 = "20–39 ans";
  static const String age2 = "40–59 ans";
  static const String age3 = "60–79 ans";

  static const String low = "Trop bas";
  static const String normal = "Normal";
  static const String high = "Élevé";
  static const String veryHigh = "Très élevé";

  static const String womenRange1 = "< 21%\n21–33%\n33–39%\n> 39%";
  static const String womenRange2 = "< 23%\n23–34%\n34–40%\n> 40%";
  static const String womenRange3 = "< 24%\n24–36%\n36–42%\n> 42%";

  static const String menRange1 = "< 8%\n8–20%\n20–25%\n> 25%";
  static const String menRange2 = "< 11%\n11–22%\n22–27%\n> 27%";
  static const String menRange3 = "< 13%\n13–25%\n25–30%\n> 30%";
}

class _IndexMassAdiposeViewState extends State<IndexMassAdiposeView>
    with TickerProviderStateMixin {
  static const String _bg = "assets/images/BgS.jfif";

  final TextEditingController heightCtl = TextEditingController(text: "0");
  final TextEditingController hipCtl = TextEditingController(text: "0");

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _calcKey = GlobalKey();
  final GlobalKey _resultsKey = GlobalKey();
  final GlobalKey _tablesKey = GlobalKey();

  late final AnimationController _enterCtrl;

  double _ima = 0;
  bool _hasResult = false;

  double _safeDouble(String s) =>
      double.tryParse(s.trim().replaceAll(',', '.')) ?? 0.0;

  void _compute() {
    final tCm = _safeDouble(heightCtl.text);
    final hCm = _safeDouble(hipCtl.text);
    if (tCm <= 0 || hCm <= 0) {
      setState(() {
        _ima = 0;
        _hasResult = false;
      });
      return;
    }
    final tM = tCm / 100.0;
    final ima = (hCm / (tM * sqrt(tM))) - 18;

    setState(() {
      _ima = ima;
      _hasResult = true;
    });
  }

  Future<void> _scrollTo(GlobalKey key) async {
    final ctx = key.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

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
    _scrollController.dispose();
    heightCtl.dispose();
    hipCtl.dispose();
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
      backgroundColor: Colors.transparent,
      body: Stack(
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
                          Colors.black.withOpacity(0.30),
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
                          onCalc: () => _scrollTo(_calcKey),
                        ),
                        const SizedBox(height: 12),
                        _QuickActions(
                          onCalc: () => _scrollTo(_calcKey),
                          onTables: () => _scrollTo(_tablesKey),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: _Glass(
                            radius: 20,
                            padding: EdgeInsets.zero,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 900),
                                    child: Column(
                                      children: [
                                        _StaggerReveal(
                                          controller: _enterCtrl,
                                          index: 0,
                                          child: const _InfoBanner(
                                            title: _TXT.infoTitle,
                                            subtitle: _TXT.infoSubtitle,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        _StaggerReveal(
                                          controller: _enterCtrl,
                                          index: 1,
                                          child: const _SectionTextCard(
                                            icon: Icons.info_outline_rounded,
                                            title: _TXT.introTitle,
                                            body: _TXT.introBody,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        _StaggerReveal(
                                          controller: _enterCtrl,
                                          index: 2,
                                          child: KeyedSubtree(
                                            key: _calcKey,
                                            child: _CalcCard(
                                              heightCtl: heightCtl,
                                              hipCtl: hipCtl,
                                              onCompute: () {
                                                HapticFeedback.selectionClick();
                                                _compute();
                                                _scrollTo(_resultsKey);
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        _StaggerReveal(
                                          controller: _enterCtrl,
                                          index: 3,
                                          child: KeyedSubtree(
                                            key: _resultsKey,
                                            child: _ResultsCard(
                                              ima: _ima,
                                              hasResult: _hasResult,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        _StaggerReveal(
                                          controller: _enterCtrl,
                                          index: 4,
                                          child: const _SectionTextCard(
                                            icon: Icons.insights_rounded,
                                            title: _TXT.interpretationTitle,
                                            body: _TXT.interpretationBody,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        _StaggerReveal(
                                          controller: _enterCtrl,
                                          index: 5,
                                          child: const _SectionTextCard(
                                            icon: Icons.functions_rounded,
                                            title: _TXT.formulaTitle,
                                            body: _TXT.formulaBody,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        _StaggerReveal(
                                          controller: _enterCtrl,
                                          index: 6,
                                          child: const _LegendCard(),
                                        ),
                                        const SizedBox(height: 10),
                                        _StaggerReveal(
                                          controller: _enterCtrl,
                                          index: 7,
                                          child: KeyedSubtree(
                                            key: _tablesKey,
                                            child: Column(
                                              children: const [
                                                _TableCard(
                                                  title: _TXT.womenTitle,
                                                  rows: [
                                                    [_TXT.age1, _TXT.womenRange1],
                                                    [_TXT.age2, _TXT.womenRange2],
                                                    [_TXT.age3, _TXT.womenRange3],
                                                  ],
                                                ),
                                                SizedBox(height: 10),
                                                _TableCard(
                                                  title: _TXT.menTitle,
                                                  rows: [
                                                    [_TXT.age1, _TXT.menRange1],
                                                    [_TXT.age2, _TXT.menRange2],
                                                    [_TXT.age3, _TXT.menRange3],
                                                  ],
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
  final VoidCallback onTables;

  const _QuickActions({
    required this.onCalc,
    required this.onTables,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _QuickChip(
          icon: Icons.monitor_weight_outlined,
          label: _TXT.quickLabel,
          color: cs.primary,
        ),
        _QuickButtonChip(
          icon: Icons.calculate_rounded,
          label: _TXT.quickCalc,
          onTap: onCalc,
        ),
        _QuickButtonChip(
          icon: Icons.table_chart_rounded,
          label: _TXT.quickTables,
          onTap: onTables,
        ),
      ],
    );
  }
}

class _QuickChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _QuickChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return _Glass(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color.withOpacity(0.92)),
          const SizedBox(width: 8),
          Text(
            label,
            style: t.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white.withOpacity(0.86),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickButtonChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickButtonChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

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
              border: Border.all(
                color: Colors.white.withOpacity(0.14),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.analytics_rounded,
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

class _SectionTextCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _SectionTextCard({
    required this.icon,
    required this.title,
    required this.body,
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
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white.withOpacity(0.10),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.14),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: cs.primary.withOpacity(0.92),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: t.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.96),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: t.textTheme.bodyMedium?.copyWith(
              height: 1.35,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.82),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalcCard extends StatelessWidget {
  final TextEditingController heightCtl;
  final TextEditingController hipCtl;
  final VoidCallback onCompute;

  const _CalcCard({
    required this.heightCtl,
    required this.hipCtl,
    required this.onCompute,
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
          Row(
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
                child: Icon(
                  Icons.tune_rounded,
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
                      _TXT.calcTitle,
                      style: t.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white.withOpacity(0.96),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _TXT.calcDesc,
                      style: t.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.72),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _NumberField(
                  label: _TXT.height,
                  suffix: "cm",
                  controller: heightCtl,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NumberField(
                  label: _TXT.hip,
                  suffix: "cm",
                  controller: hipCtl,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onCompute,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white.withOpacity(0.12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.16),
                    width: 1,
                  ),
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
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 18,
                      color: cs.primary.withOpacity(0.92),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _TXT.calculate,
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
    );
  }
}

class _ResultsCard extends StatelessWidget {
  final double ima;
  final bool hasResult;

  const _ResultsCard({
    required this.ima,
    required this.hasResult,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return _Glass(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _TXT.resultsTitle,
            style: t.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.96),
            ),
          ),
          const SizedBox(height: 10),
          _ResultRow(
            label: _TXT.imaShort,
            value: hasResult ? "${ima.toStringAsFixed(2)} %" : _TXT.noResult,
          ),
          const SizedBox(height: 8),
          Text(
            _TXT.resultExplain,
            style: t.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.72),
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendCard extends StatefulWidget {
  const _LegendCard();

  @override
  State<_LegendCard> createState() => _LegendCardState();
}

class _LegendCardState extends State<_LegendCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = true;
  late final AnimationController _ctl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  )..forward();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _ctl,
      builder: (_, __) {
        final fade = CurvedAnimation(parent: _ctl, curve: Curves.easeOutCubic);
        final slide = Tween<Offset>(
          begin: const Offset(0, -0.04),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _ctl, curve: Curves.easeOutBack),
        );

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: slide,
            child: _Glass(
              radius: 18,
              padding: const EdgeInsets.all(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => setState(() => _expanded = !_expanded),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.white.withOpacity(0.10),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.14),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            color: cs.primary.withOpacity(0.92),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _TXT.legendTitle,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white.withOpacity(0.96),
                                ),
                          ),
                        ),
                        AnimatedRotation(
                          turns: _expanded ? 0.0 : -0.25,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          child: Icon(
                            Icons.expand_more_rounded,
                            color: Colors.white.withOpacity(0.82),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 360),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topCenter,
                      child: _expanded
                          ? Column(
                              children: const [
                                _LegendRow(),
                                SizedBox(height: 10),
                                Text(
                                  _TXT.legendBody,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600,
                                    height: 1.3,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow();

  @override
  Widget build(BuildContext context) {
    final items = [
      _LegendPill(color: Theme.of(context).colorScheme.primary, label: _TXT.low),
      _LegendPill(color: Colors.green.shade600, label: _TXT.normal),
      _LegendPill(color: Colors.orange.shade600, label: _TXT.high),
      _LegendPill(color: Colors.red.shade600, label: _TXT.veryHigh),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: items,
    );
  }
}

class _LegendPill extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendPill({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _TableCard extends StatelessWidget {
  final String title;
  final List<List<String>> rows;

  const _TableCard({
    required this.title,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return _Glass(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: t.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.96),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 640),
              child: _ImaTableBase(rows: rows),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImaTableBase extends StatelessWidget {
  final List<List<String>> rows;

  const _ImaTableBase({
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final zebra1 = Colors.blue.withOpacity(isDark ? 0.16 : 0.10);
    final zebra2 = Colors.indigo.withOpacity(isDark ? 0.14 : 0.08);
    final textColor = Colors.white.withOpacity(0.92);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Table(
        border: TableBorder.all(color: Colors.white.withOpacity(0.12)),
        columnWidths: const {
          0: FlexColumnWidth(1.0),
          1: FlexColumnWidth(1.2),
          2: FlexColumnWidth(1.2),
        },
        children: [
          TableRow(
            children: [
              _th(context, _TXT.colAge),
              _th(context, _TXT.colRange),
              _th(context, _TXT.colStatus),
            ],
          ),
          ...List.generate(rows.length, (i) {
            final bg = i.isEven ? zebra1 : zebra2;
            return TableRow(
              children: [
                _td(rows[i][0], bg, textColor),
                _td(rows[i][1], bg, textColor),
                _tdPills(
                  context,
                  const [_TXT.low, _TXT.normal, _TXT.high, _TXT.veryHigh],
                  bg,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _th(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primary.withOpacity(0.92),
            cs.secondary.withOpacity(0.92),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _td(String text, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      color: bg,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          height: 1.35,
        ),
      ),
    );
  }

  Widget _tdPills(BuildContext context, List<String> statuses, Color bg) {
    final colors = [
      Theme.of(context).colorScheme.primary,
      Colors.green.shade600,
      Colors.orange.shade600,
      Colors.red.shade600,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      color: bg,
      child: Column(
        children: List.generate(statuses.length, (i) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 3),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              color: colors[i],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statuses[i],
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _StaggerReveal extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final Widget child;

  const _StaggerReveal({
    required this.controller,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final start = (0.06 * index).clamp(0.0, 0.85).toDouble();
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(start, 1.0, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(animation),
        child: child,
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
    final t = Theme.of(context);
    final isDark = t.brightness == Brightness.dark;
    final bg =
        isDark ? Colors.white.withOpacity(0.07) : Colors.white.withOpacity(0.10);
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
          border: Border.all(
            color: Colors.white.withOpacity(0.14),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: accent ?? Colors.white.withOpacity(0.92),
          size: 20,
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({
    required this.size,
    required this.color,
  });

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
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
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
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.14),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.14),
              ),
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
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 1,
        ),
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