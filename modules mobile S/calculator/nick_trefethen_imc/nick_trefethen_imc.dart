import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NickTrefethenImcView extends StatefulWidget {
  const NickTrefethenImcView({super.key});

  @override
  State<NickTrefethenImcView> createState() => _NickTrefethenImcViewState();
}

class _TXT {
  static const String screenTitle = "Nick Trefethen BMI";

  static const String infoTitle = "Indice corrigé";
  static const String infoSubtitle =
      "Calcule ton BMI avec la formule corrigée de Nick Trefethen.";

  static const String quickLabel = "BMI Nick • Taille / Poids";
  static const String quickCalc = "Calculateur";
  static const String quickInfo = "Informations";

  static const String introTitle = "À propos";
  static const String introBody =
      "La formule de Nick Trefethen propose une correction du BMI classique afin de mieux s’adapter à différentes tailles corporelles.\n\n"
      "Elle conserve la simplicité d’un indice anthropométrique tout en ajustant le calcul pour réduire certains biais du BMI traditionnel.";

  static const String calcTitle = "Calculateur BMI Nick";
  static const String calcDesc =
      "Saisis la taille et le poids, puis lance le calcul avec la formule d’origine.";
  static const String height = "Taille";
  static const String weight = "Poids";
  static const String calculate = "Calculer";

  static const String resultsTitle = "Résultats";
  static const String yourResult = "Votre résultat";
  static const String bmiNick = "BMIᴺᶦᶜᵏ";
  static const String noResult = "—";

  static const String underweight = "Insuffisance pondérale";
  static const String normal = "Poids normal";
  static const String overweight = "Surpoids";
  static const String obese = "Obésité";

  static const String resultHint =
      "Le résultat doit être interprété comme un indicateur général. Il ne remplace pas une évaluation clinique ou nutritionnelle complète.";

  static const String statusInfo =
      "Cette classification reste une lecture indicative basée sur les seuils usuels du BMI.";

  static const String infoSectionTitle = "Informations";
  static const String infoSectionBody =
      "La formule Nick Trefethen vise à améliorer l’estimation du BMI en corrigeant l’exposant de la taille.\n\n"
      "Elle peut être utile pour comparer plus finement différents profils corporels, mais doit toujours être interprétée avec prudence.";

  static const String formulaTitle = "Formule utilisée";
  static const String formulaText = "BMIₙᵢ꜀ₖ = 1.3 × Poids (kg) / (Taille (m))^2.5";

  static const String imageNote =
      "Le BMI reste un repère pratique, mais il doit être replacé dans un contexte plus large : âge, masse musculaire, morphologie et niveau d’activité.";

  static const String actionToResults = "Voir résultat";
  static const String actionToInfo = "Voir infos";
}

class _NickTrefethenImcViewState extends State<NickTrefethenImcView>
    with TickerProviderStateMixin {
  static const String _bg = "assets/images/BgS.jfif";

  final TextEditingController heightCtl = TextEditingController(text: "0");
  final TextEditingController weightCtl = TextEditingController(text: "0");

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _calcKey = GlobalKey();
  final GlobalKey _resultsKey = GlobalKey();
  final GlobalKey _infoKey = GlobalKey();

  late final AnimationController _enterCtrl;

  double _bmi = 0.0;
  bool _hasResult = false;

  double _safeDouble(String s) =>
      double.tryParse(s.trim().replaceAll(',', '.')) ?? 0.0;

  void _compute() {
    final hCm = _safeDouble(heightCtl.text);
    final wKg = _safeDouble(weightCtl.text);
    if (hCm <= 0 || wKg <= 0) {
      setState(() {
        _bmi = 0;
        _hasResult = false;
      });
      return;
    }
    final hM = hCm / 100.0;
    final bmi = 1.3 * wKg / pow(hM, 2.5);
    setState(() {
      _bmi = bmi;
      _hasResult = true;
    });
  }

  String _whoLabel(double v) {
    if (v <= 0) return "";
    if (v < 18.5) return _TXT.underweight;
    if (v < 25) return _TXT.normal;
    if (v < 30) return _TXT.overweight;
    return _TXT.obese;
  }

  Color _whoColor(BuildContext context, double v) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (v < 18.5) {
      return isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6);
    }
    if (v < 25) {
      return isDark ? const Color(0xFF34D399) : const Color(0xFF10B981);
    }
    if (v < 30) {
      return isDark ? const Color(0xFFF59E0B) : const Color(0xFFFB923C);
    }
    return isDark ? const Color(0xFFF472B6) : const Color(0xFFEF4444);
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
    weightCtl.dispose();
    super.dispose();
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
                          onInfo: () => _scrollTo(_infoKey),
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
                                          weightCtl: weightCtl,
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
                                          bmi: _bmi,
                                          hasResult: _hasResult,
                                          statusLabel: _whoLabel(_bmi),
                                          statusColor: _whoColor(context, _bmi),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    _StaggerReveal(
                                      controller: _enterCtrl,
                                      index: 4,
                                      child: KeyedSubtree(
                                        key: _infoKey,
                                        child: const _SectionTextCard(
                                          icon: Icons.functions_rounded,
                                          title: _TXT.infoSectionTitle,
                                          body: _TXT.infoSectionBody,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    _StaggerReveal(
                                      controller: _enterCtrl,
                                      index: 5,
                                      child: const _FormulaCard(),
                                    ),
                                    const SizedBox(height: 10),
                                    _StaggerReveal(
                                      controller: _enterCtrl,
                                      index: 6,
                                      child: const _ImageInfoCard(),
                                    ),
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
  final VoidCallback onInfo;

  const _QuickActions({
    required this.onCalc,
    required this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _Glass(
          radius: 18,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.monitor_weight_outlined,
                size: 18,
                color: cs.primary.withOpacity(0.92),
              ),
              const SizedBox(width: 8),
              Text(
                _TXT.quickLabel,
                style: t.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withOpacity(0.86),
                ),
              ),
            ],
          ),
        ),
        _ActionChip(
          icon: Icons.calculate_rounded,
          label: _TXT.quickCalc,
          onTap: onCalc,
        ),
        _ActionChip(
          icon: Icons.info_rounded,
          label: _TXT.quickInfo,
          onTap: onInfo,
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
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
  final TextEditingController weightCtl;
  final VoidCallback onCompute;

  const _CalcCard({
    required this.heightCtl,
    required this.weightCtl,
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
                  label: _TXT.weight,
                  suffix: "kg",
                  controller: weightCtl,
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
  final double bmi;
  final bool hasResult;
  final String statusLabel;
  final Color statusColor;

  const _ResultsCard({
    required this.bmi,
    required this.hasResult,
    required this.statusLabel,
    required this.statusColor,
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
            label: _TXT.bmiNick,
            value: hasResult ? bmi.toStringAsFixed(2) : _TXT.noResult,
          ),
          const SizedBox(height: 10),
          if (hasResult)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: statusColor.withOpacity(0.12),
                border: Border.all(color: statusColor.withOpacity(0.55)),
              ),
              child: Column(
                children: [
                  Text(
                    statusLabel,
                    textAlign: TextAlign.center,
                    style: t.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withOpacity(0.96),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _TXT.statusInfo,
                    textAlign: TextAlign.center,
                    style: t.textTheme.bodySmall?.copyWith(
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.78),
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              _TXT.resultHint,
              textAlign: TextAlign.center,
              style: t.textTheme.bodySmall?.copyWith(
                height: 1.3,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.72),
              ),
            ),
        ],
      ),
    );
  }
}

class _FormulaCard extends StatelessWidget {
  const _FormulaCard();

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
                  Icons.functions_rounded,
                  color: cs.primary.withOpacity(0.92),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _TXT.formulaTitle,
                  style: t.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.96),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Text(
              _TXT.formulaText,
              textAlign: TextAlign.center,
              style: t.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white.withOpacity(0.92),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageInfoCard extends StatelessWidget {
  const _ImageInfoCard();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return _Glass(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          const _NetImage(
            url:
                "https://www.calculersonimc.fr/wp-content/uploads/2018/04/femme-balance-dans-les-mains.jpg",
          ),
          const SizedBox(height: 12),
          Text(
            _TXT.imageNote,
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
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

class _NetImage extends StatelessWidget {
  final String url;

  const _NetImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      height: MediaQuery.of(context).size.height * 0.22,
      width: double.infinity,
      imageUrl: url,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      placeholder: (context, url) => Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withOpacity(0.06),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withOpacity(0.06),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.white.withOpacity(0.7),
        ),
      ),
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