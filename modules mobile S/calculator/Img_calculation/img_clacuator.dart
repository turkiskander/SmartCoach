// lib/features/.../calculating_img.dart
//
// ✅ Logique BMI + IMG inchangée
// ✅ Suppression de intl/localization
// ✅ Suppression de Dimensions
// ✅ Design identique à BeepIntermittentTrainingView
// ✅ Même fond premium + overlay + glass cards + animations

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/widget/loading_widget.dart';

class CalculatingIMG extends StatefulWidget {
  const CalculatingIMG({super.key});

  @override
  State<CalculatingIMG> createState() => _CalculatingIMGState();
}

class _TXT {
  static const String screenTitle = "Calculating IMG";

  static const String introTitle = "Indice de masse grasse";
  static const String introSubtitle =
      "Calcule le BMI et l’IMG selon le sexe, le poids, la taille et l’âge.";

  static const String calcTitle = "Calculateur";
  static const String calcDesc =
      "Choisis le sexe puis saisis le poids, la taille et l’âge avant de lancer le calcul.";

  static const String sex = "Sexe";
  static const String sexValue2 = "Femme";
  static const String sexValue3 = "Homme";

  static const String weight = "Poids";
  static const String height = "Taille";
  static const String age = "Âge";

  static const String kg = "kg";
  static const String cm = "cm";

  static const String calculate = "Calculer IMG";
  static const String img = "IMG";

  static const String yourResults = "Résultats";
  static const String bmi = "BMI";
  static const String chipMethod = "IMG";
  static const String chipEstimate = "Masse grasse";

  static const String introText1 =
      "L’IMG permet d’estimer la masse grasse à partir du BMI, de l’âge et du sexe.";
  static const String introText2 =
      "Cette valeur reste une estimation théorique et doit être interprétée avec prudence.";

  static const String womenTableTitle = "Tableau femme";
  static const String menTableTitle = "Tableau homme";

  static const String womenHeader1 = "Classification";
  static const String womenHeader2 = "IMG (%)";
  static const String womenRow1Col1 = "Trop maigre";
  static const String womenRow1Col2 = "< 25";
  static const String womenRow2Col1 = "Normale";
  static const String womenRow2Col2 = "25 à 30";
  static const String womenRow3Col1 = "Trop élevée";
  static const String womenRow3Col2 = "> 30";

  static const String menHeader1 = "Classification";
  static const String menHeader2 = "IMG (%)";
  static const String menRow1Col1 = "Trop maigre";
  static const String menRow1Col2 = "< 15";
  static const String menRow2Col1 = "Normale";
  static const String menRow2Col2 = "15 à 20";
  static const String menRow3Col1 = "Trop élevée";
  static const String menRow3Col2 = "> 20";

  static const String infoTitle1 = "Comprendre l’IMG";
  static const String infoBody1 =
      "L’indice de masse grasse complète le BMI en donnant une estimation du pourcentage de graisse corporelle.";
  static const String infoBody2 =
      "Il existe plusieurs formules selon l’âge ou le contexte d’utilisation.";
  static const String infoBody3 =
      "Le résultat obtenu doit être interprété avec le sexe, l’âge et le niveau d’activité physique.";

  static const String infoTitle2 = "Formules utilisées";
  static const String infoTitle3 = "Formules complémentaires";
  static const String infoTitle4 = "Interprétation";
  static const String infoTitle5 = "Excès de masse grasse";

  static const String bodyAfterTables1 =
      "L’IMG est souvent utilisée avec le BMI pour avoir une vision plus fine de la composition corporelle.";
  static const String bodyAfterTables2 =
      "Une même valeur de BMI peut correspondre à des situations très différentes selon la masse musculaire.";
  static const String bodyAfterTables3 =
      "L’âge et le sexe influencent fortement l’interprétation finale.";

  static const String formula1 =
      "IMG (%) = (1.20 × BMI) + (0.23 × âge) − (10.8 × sexe) − 5.4";
  static const String formula2 =
      "IMG (%) = (1.29 × BMI) + (0.20 × âge) − (11.4 × sexe) − 8.0";
  static const String formula3 =
      "IMG (%) = (1.46 × BMI) + (0.14 × âge) − (11.6 × sexe) − 10.0";
  static const String formula4 =
      "IMG (%) = (1.61 × BMI) + (0.13 × âge) − (12.1 × sexe) − 13.9";
  static const String formula5 =
      "IMG (%) = (1.51 × BMI) + (0.70 × âge) − (3.6 × sexe) + 1.4";

  static const String formulaHint1 =
      "La formule principale utilisée dans ce calcul est celle de Deurenberg.";
  static const String formulaHint2 =
      "D’autres variantes existent selon la population étudiée.";
  static const String formulaHint3 =
      "Le sexe vaut 1 pour homme et 0 pour femme dans la formule principale.";

  static const String excessFatText1 =
      "Un excès de masse grasse peut être associé à différents risques pour la santé.";
  static const String excessFatText2 =
      "Le suivi doit toujours être remis dans son contexte global : alimentation, activité physique, âge et antécédents.";
}

class _CalculatingIMGState extends State<CalculatingIMG>
    with TickerProviderStateMixin {
  static const String _bg = "assets/images/BgS.jfif";

  final TextEditingController height = TextEditingController(text: "0");
  final TextEditingController weight = TextEditingController(text: "0");
  final TextEditingController sexController = TextEditingController();
  final TextEditingController ageController = TextEditingController(text: "0");

  late final AnimationController _enterCtrl;

  double _bmi = 0;
  double _img = 0;
  bool _hasResult = false;

  int _safeInt(String s) => int.tryParse(s.trim()) ?? 0;
  double _safeDouble(String s) => double.tryParse(s.trim()) ?? 0.0;

  void _compute() {
    final hCm = _safeDouble(height.text);
    final wKg = _safeDouble(weight.text);
    final age = _safeInt(ageController.text);
    if (hCm <= 0 || wKg <= 0 || age <= 0) {
      setState(() {
        _bmi = 0;
        _img = 0;
        _hasResult = false;
      });
      return;
    }

    // ✅ Logique inchangée
    final h = hCm / 100.0;
    final bmi = wKg / (h * h);
    final sexe = (sexController.text == _TXT.sexValue3) ? 1 : 0;
    final img = (1.20 * bmi) + (0.23 * age) - (10.8 * sexe) - 5.4;

    setState(() {
      _bmi = bmi;
      _img = img;
      _hasResult = true;
    });
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
    height.dispose();
    weight.dispose();
    sexController.dispose();
    ageController.dispose();
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
                        ),
                        const SizedBox(height: 12),
                        _QuickActions(
                          bmi: _hasResult ? _bmi.toStringAsFixed(2) : "—",
                          img: _hasResult ? "${_img.toStringAsFixed(2)}%" : "—",
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
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                slivers: [
                                  const SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(12, 12, 12, 8),
                                      child: _InfoBanner(
                                        title: _TXT.introTitle,
                                        subtitle: _TXT.introSubtitle,
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _CalcCard(
                                        heightCtl: height,
                                        weightCtl: weight,
                                        ageCtl: ageController,
                                        sexCtl: sexController,
                                        onCompute: () {
                                          HapticFeedback.selectionClick();
                                          _compute();
                                        },
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _IntroTextCard(),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _ResultCard(
                                        hasResult: _hasResult,
                                        bmi: _bmi,
                                        img: _img,
                                      ),
                                    ),
                                  ),
                                  const SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _ImgTableCard(
                                        title: _TXT.womenTableTitle,
                                        headerLeft: _TXT.womenHeader1,
                                        headerRight: _TXT.womenHeader2,
                                        rows: [
                                          [_TXT.womenRow1Col1, _TXT.womenRow1Col2],
                                          [_TXT.womenRow2Col1, _TXT.womenRow2Col2],
                                          [_TXT.womenRow3Col1, _TXT.womenRow3Col2],
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _ImgTableCard(
                                        title: _TXT.menTableTitle,
                                        headerLeft: _TXT.menHeader1,
                                        headerRight: _TXT.menHeader2,
                                        rows: [
                                          [_TXT.menRow1Col1, _TXT.menRow1Col2],
                                          [_TXT.menRow2Col1, _TXT.menRow2Col2],
                                          [_TXT.menRow3Col1, _TXT.menRow3Col2],
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _TextInfoCard(
                                        title: _TXT.infoTitle1,
                                        paragraphs: [
                                          _TXT.infoBody1,
                                          _TXT.infoBody2,
                                          _TXT.infoBody3,
                                          _TXT.bodyAfterTables1,
                                          _TXT.bodyAfterTables2,
                                          _TXT.bodyAfterTables3,
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _ImageInfoCard(
                                        title: "Mesure de la masse grasse",
                                        body:
                                            "L’IMG vient compléter le BMI pour mieux estimer la part de masse grasse corporelle.",
                                        url:
                                            "https://www.calculersonimc.fr/wp-content/uploads/2018/04/docteur-mesurant-masse-graisseuse.jpg",
                                      ),
                                    ),
                                  ),
                                  const SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _FormulasCard(),
                                    ),
                                  ),
                                  const SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(12, 0, 12, 14),
                                      child: _ImageInfoCard(
                                        title: _TXT.infoTitle5,
                                        body:
                                            "${_TXT.excessFatText1}\n\n${_TXT.excessFatText2}",
                                        url:
                                            "https://www.calculersonimc.fr/wp-content/uploads/2018/04/femme-en-surpoids.jpg",
                                      ),
                                    ),
                                  ),
                                  const SliverToBoxAdapter(
                                    child: SizedBox(height: 8),
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
/* Header + top */
/* ========================================================================== */

class _HeaderModern extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _HeaderModern({
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

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
          const _PillIconStatic(icon: Icons.calculate_rounded),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final String bmi;
  final String img;

  const _QuickActions({
    required this.bmi,
    required this.img,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _Glass(
            radius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  Icons.insights_rounded,
                  size: 18,
                  color: cs.primary.withOpacity(0.92),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "${_TXT.chipMethod} • ${_TXT.chipEstimate}",
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
        _Glass(
          radius: 18,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Text(
            "BMI $bmi",
            style: t.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.90),
            ),
          ),
        ),
        const SizedBox(width: 10),
        _Glass(
          radius: 18,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Text(
            "IMG $img",
            style: t.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.90),
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
            child: Icon(
              Icons.monitor_heart_rounded,
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

/* ========================================================================== */
/* Cards */
/* ========================================================================== */

class _CalcCard extends StatelessWidget {
  final TextEditingController heightCtl;
  final TextEditingController weightCtl;
  final TextEditingController ageCtl;
  final TextEditingController sexCtl;
  final VoidCallback onCompute;

  const _CalcCard({
    required this.heightCtl,
    required this.weightCtl,
    required this.ageCtl,
    required this.sexCtl,
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
                  border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
                ),
                child: Icon(
                  Icons.calculate_rounded,
                  color: cs.primary.withOpacity(0.92),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _TXT.calcTitle,
                  style: t.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.96),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _TXT.calcDesc,
            style: t.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.72),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          _DropdownField(
            label: _TXT.sex,
            controller: sexCtl,
            items: const [_TXT.sexValue2, _TXT.sexValue3],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _NumberField(
                  label: "${_TXT.weight} (${_TXT.kg})",
                  hint: "0",
                  controller: weightCtl,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NumberField(
                  label: "${_TXT.height} (${_TXT.cm})",
                  hint: "0",
                  controller: heightCtl,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _NumberField(
            label: _TXT.age,
            hint: "0",
            controller: ageCtl,
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                HapticFeedback.lightImpact();
                onCompute();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

class _IntroTextCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return _Glass(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Text(
        "${_TXT.introText1}\n\n${_TXT.introText2}",
        style: t.textTheme.bodyMedium?.copyWith(
          height: 1.25,
          fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.82),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final bool hasResult;
  final double bmi;
  final double img;

  const _ResultCard({
    required this.hasResult,
    required this.bmi,
    required this.img,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

    return _Glass(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _TXT.yourResults,
            style: t.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.96),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white.withOpacity(0.10),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        _TXT.bmi,
                        style: t.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withOpacity(0.78),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        hasResult ? bmi.toStringAsFixed(2) : "—",
                        style: t.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: cs.primary.withOpacity(0.92),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 48,
                  color: Colors.white.withOpacity(0.10),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        _TXT.img,
                        style: t.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withOpacity(0.78),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        hasResult ? "${img.toStringAsFixed(2)}%" : "—",
                        style: t.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: cs.primary.withOpacity(0.92),
                        ),
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
}

class _ImgTableCard extends StatelessWidget {
  final String title;
  final String headerLeft;
  final String headerRight;
  final List<List<String>> rows;

  const _ImgTableCard({
    required this.title,
    required this.headerLeft,
    required this.headerRight,
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
          _ImgTable(
            headerLeft: headerLeft,
            headerRight: headerRight,
            rows: rows,
          ),
        ],
      ),
    );
  }
}

class _TextInfoCard extends StatelessWidget {
  final String title;
  final List<String> paragraphs;

  const _TextInfoCard({
    required this.title,
    required this.paragraphs,
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
          for (final p in paragraphs) ...[
            const SizedBox(height: 10),
            Text(
              p,
              style: t.textTheme.bodyMedium?.copyWith(
                height: 1.25,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.82),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FormulasCard extends StatelessWidget {
  const _FormulasCard();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    Widget formulaBox(String text) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withOpacity(0.10),
          border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: t.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: Colors.white.withOpacity(0.96),
          ),
        ),
      );
    }

    return _Glass(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _TXT.infoTitle2,
            style: t.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.96),
            ),
          ),
          const SizedBox(height: 10),
          formulaBox(_TXT.formula1),
          const SizedBox(height: 10),
          formulaBox(_TXT.formula2),
          const SizedBox(height: 10),
          formulaBox(_TXT.formula3),
          const SizedBox(height: 10),
          formulaBox(_TXT.formula4),
          const SizedBox(height: 12),
          Text(
            _TXT.formulaHint1,
            style: t.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.72),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _TXT.infoTitle3,
            style: t.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.96),
            ),
          ),
          const SizedBox(height: 8),
          formulaBox(_TXT.formula5),
          const SizedBox(height: 10),
          Text(
            "${_TXT.formulaHint2}\n\n${_TXT.formulaHint3}",
            style: t.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.72),
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageInfoCard extends StatelessWidget {
  final String title;
  final String body;
  final String url;

  const _ImageInfoCard({
    required this.title,
    required this.body,
    required this.url,
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
          _NetImage(url: url),
          const SizedBox(height: 12),
          Text(
            title,
            style: t.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.96),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: t.textTheme.bodyMedium?.copyWith(
              height: 1.25,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.82),
            ),
          ),
        ],
      ),
    );
  }
}

/* ========================================================================== */
/* UI kit */
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

class _PillIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _PillIconButton({
    required this.icon,
    required this.onTap,
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
        child: Icon(icon, color: Colors.white.withOpacity(0.92), size: 20),
      ),
    );
  }
}

class _PillIconStatic extends StatelessWidget {
  final IconData icon;

  const _PillIconStatic({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withOpacity(0.10),
        border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
      ),
      child: Icon(icon, color: Colors.white.withOpacity(0.92), size: 20),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final List<String> items;

  const _DropdownField({
    required this.label,
    required this.controller,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

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
        DropdownButtonFormField<String>(
          value: controller.text.isEmpty ? null : controller.text,
          isExpanded: true,
          items: items
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(e, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (v) => controller.text = v ?? "",
          dropdownColor: const Color(0xFF11161D),
          iconEnabledColor: Colors.white.withOpacity(0.86),
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

class _NumberField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;

  const _NumberField({
    required this.label,
    required this.hint,
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
            hintText: hint,
            hintStyle: t.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.45),
              fontWeight: FontWeight.w700,
            ),
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

class _ImgTable extends StatelessWidget {
  final String headerLeft;
  final String headerRight;
  final List<List<String>> rows;

  const _ImgTable({
    required this.headerLeft,
    required this.headerRight,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final headerColor =
        isDark ? const Color(0xFF1E3A8A) : const Color(0xFF2563EB);
    final headerStyle =
        const TextStyle(fontWeight: FontWeight.w800, color: Colors.white);

    final c1 = Colors.blue.withOpacity(isDark ? 0.18 : 0.10);
    final c2 = Colors.indigo.withOpacity(isDark ? 0.16 : 0.08);
    final textColor = isDark ? Colors.white : Colors.black87;

    final body = <TableRow>[];
    for (int i = 0; i < rows.length; i++) {
      final bg = (i % 2 == 0) ? c1 : c2;
      body.add(
        TableRow(
          children: [
            Container(
              color: bg,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
              child: Text(
                rows[i][0],
                textAlign: TextAlign.center,
                style: TextStyle(color: textColor),
              ),
            ),
            Container(
              color: bg,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
              child: Text(
                rows[i][1],
                textAlign: TextAlign.center,
                style: TextStyle(color: textColor),
              ),
            ),
          ],
        ),
      );
    }

    return Table(
      border: TableBorder.all(color: Colors.grey.withOpacity(0.4)),
      children: [
        TableRow(
          children: [
            Container(
              color: headerColor,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              child: Text(
                headerLeft,
                textAlign: TextAlign.center,
                style: headerStyle,
              ),
            ),
            Container(
              color: headerColor,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              child: Text(
                headerRight,
                textAlign: TextAlign.center,
                style: headerStyle,
              ),
            ),
          ],
        ),
        ...body,
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
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ),
      ),
      placeholder: (context, url) => const SizedBox(
        height: 220,
        child: Center(child: LoadingWidget()),
      ),
      errorWidget: (context, url, error) => Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withOpacity(0.06),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: const Center(
          child: Icon(Icons.broken_image_rounded, color: Colors.white70),
        ),
      ),
    );
  }
}