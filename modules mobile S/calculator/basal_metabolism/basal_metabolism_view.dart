// lib/features/ppCalculator/basal_metabolism/basal_metabolism_view.dart

import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _TXT {
  static const String screenTitle = "Basal Metabolism";

  static const String navCalc = "Calculator";
  static const String navResults = "Results";
  static const String navInfo = "Info";
  static const String navFormulas = "Formulas";

  static const String heroTitle = "Métabolisme basal";
  static const String heroSubtitle =
      "Calcule ton BMI et ton BMR avec une interface plus moderne et une navigation fluide.";

  static const String calcIntro =
      "Entre le sexe, le poids, la taille et l’âge. Le calcul s’effectue avec la même logique qu’avant.";

  static const String sex = "Sex";
  static const String sexFemale = "Female";
  static const String sexMale = "Male";
  static const String weight = "Weight (kg)";
  static const String height = "Height (cm)";
  static const String age = "Age";

  static const String calculate = "Calculate";
  static const String yourResults = "Your Results";
  static const String bmiShort = "BMI";
  static const String bmrShort = "BMR";
  static const String kcalPerDay = "kcal/day";

  static const String sectionNeeds = "Daily energy needs";
  static const String sectionHealth = "Useful information";
  static const String sectionDefinition = "Definition";
  static const String sectionClassicFormula = "Classic equations";
  static const String sectionAdjustedFormula = "Adjusted equations";

  static const String resultText1 =
      "Le métabolisme basal correspond à la dépense énergétique minimale nécessaire au fonctionnement du corps au repos.";
  static const String resultText2 =
      "Le besoin énergétique total dépend ensuite du niveau d’activité quotidienne.";
  static const String resultText3 =
      "Ces estimations aident à mieux structurer un objectif de maintien, prise de masse ou perte de poids.";
  static const String resultText4 =
      "Les valeurs restent indicatives et doivent être interprétées avec le contexte sportif, nutritionnel et clinique.";

  static const String infoText1 =
      "Le métabolisme basal représente l’énergie utilisée par l’organisme pour maintenir les fonctions vitales : respiration, circulation, activité cellulaire et thermorégulation.";
  static const String infoText2 =
      "Il varie notamment selon l’âge, le sexe, la taille, le poids et la composition corporelle.";

  static const String formulaClassicText =
      "BMR (Male) = 13.7516 × Weight (kg) + 500.33 × Height (m) - 6.7550 × Age + 66.473\n\n"
      "BMR (Female) = 9.5634 × Weight (kg) + 184.96 × Height (m) - 4.6756 × Age + 655.0955";

  static const String formulaAdjustedText =
      "BMR (Male) = 13.707 × Weight (kg) + 492.3 × Height (m) - 6.673 × Age + 77.607\n\n"
      "BMR (Female) = 9.740 × Weight (kg) + 172.9 × Height (m) - 4.737 × Age + 667.051";

  static const String formulaAdjustedText2 =
      "BMR (Male) = 259 × Weight (kg)^0.48 × Height (m)^0.50 × Age^-0.13\n\n"
      "BMR (Female) = 230 × Weight (kg)^0.48 × Height (m)^0.50 × Age^-0.13";

  static const String formulaNote1 =
      "Les équations changent selon l’âge et le profil corporel.";
  static const String formulaNote2 =
      "Dans cette logique, une formule ajustée est utilisée pour certains profils.";

  static const String activityTable1 = "Activity level";
  static const String activityTable2 = "Description";
  static const String activityTable3 = "Multiplier";

  static const String activity1 = "Sedentary";
  static const String activityDesc1 = "Very little physical activity";
  static const String activityMul1 = "BMR × 1.2";

  static const String activity2 = "Light";
  static const String activityDesc2 = "Light activity 1 to 3 days/week";
  static const String activityMul2 = "BMR × 1.375";

  static const String activity3 = "Moderate";
  static const String activityDesc3 = "Moderate activity 3 to 5 days/week";
  static const String activityMul3 = "BMR × 1.55";

  static const String activity4 = "High";
  static const String activityDesc4 = "Intense activity 6 to 7 days/week";
  static const String activityMul4 = "BMR × 1.725";

  static const String activity5 = "Very high";
  static const String activityDesc5 = "Very intense or twice-a-day training";
  static const String activityMul5 = "BMR × 1.9";

  static const String imageCaption1 =
      "Un excédent énergétique prolongé favorise généralement la prise de poids.";
  static const String imageCaption2 =
      "Un déficit énergétique maîtrisé favorise généralement la perte de poids.";

  static const String quickCalc = "Quick calc";
  static const String quickGuide = "Guide";
  static const String quickSections = "4 sections";
}

class BasalMetabolismView extends StatefulWidget {
  const BasalMetabolismView({super.key});

  @override
  State<BasalMetabolismView> createState() => _BasalMetabolismViewState();
}

class _BasalMetabolismViewState extends State<BasalMetabolismView>
    with TickerProviderStateMixin {
  static const String _bg = "assets/images/BgS.jfif";

  final TextEditingController heightCtl = TextEditingController(text: "0");
  final TextEditingController weightCtl = TextEditingController(text: "0");
  final TextEditingController sexCtl = TextEditingController();
  final TextEditingController ageCtl = TextEditingController(text: "0");

  late final AnimationController _enterCtrl;
  late final PageController _pageController;

  int _pageIndex = 0;

  double _bmi = 0;
  double _bmr = 0;
  bool _hasResult = false;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    )..forward();

    _pageController = PageController();
    sexCtl.text = _TXT.sexMale;
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _pageController.dispose();
    heightCtl.dispose();
    weightCtl.dispose();
    sexCtl.dispose();
    ageCtl.dispose();
    super.dispose();
  }

  double _safeDouble(String s) =>
      double.tryParse(s.trim().replaceAll(',', '.')) ?? 0.0;

  int _safeInt(String s) => int.tryParse(s.trim()) ?? 0;

  void _goToPage(int index) {
    HapticFeedback.selectionClick();
    setState(() => _pageIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _compute() {
    final hCm = _safeDouble(heightCtl.text);
    final wKg = _safeDouble(weightCtl.text);
    final age = _safeInt(ageCtl.text);

    if (hCm <= 0 || wKg <= 0 || age <= 0) {
      setState(() {
        _bmi = 0;
        _bmr = 0;
        _hasResult = false;
      });
      return;
    }

    final h = hCm / 100.0;
    final bmi = wKg / (h * h);
    final isMale = (sexCtl.text == _TXT.sexMale);

    double bmr;
    if (age <= 60 && bmi < 25) {
      if (isMale) {
        bmr = 13.707 * wKg + 492.3 * h - 6.673 * age + 77.607;
      } else {
        bmr = 9.74 * wKg + 172.9 * h - 4.737 * age + 667.051;
      }
    } else {
      if (isMale) {
        bmr =
            259.0 * pow(wKg, 0.48) * pow(h, 0.50) * pow(age.toDouble(), -0.13);
      } else {
        bmr =
            230.0 * pow(wKg, 0.48) * pow(h, 0.50) * pow(age.toDouble(), -0.13);
      }
    }

    setState(() {
      _bmi = bmi;
      _bmr = bmr;
      _hasResult = true;
    });
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
                          Colors.black.withOpacity(0.28),
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
                          onResults: () => _goToPage(1),
                        ),
                        const SizedBox(height: 12),
                        _QuickActions(
                          onCalc: () => _goToPage(0),
                          onGuide: () => _goToPage(2),
                        ),
                        const SizedBox(height: 12),
                        _ModernSectionNav(
                          currentIndex: _pageIndex,
                          onTap: _goToPage,
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: _Glass(
                            radius: 22,
                            padding: EdgeInsets.zero,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: PageView(
                                controller: _pageController,
                                onPageChanged: (i) {
                                  setState(() => _pageIndex = i);
                                },
                                children: [
                                  _buildCalcPage(context),
                                  _buildResultsPage(context),
                                  _buildInfoPage(context),
                                  _buildFormulasPage(context),
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

  Widget _buildCalcPage(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: _InfoBanner(
              title: _TXT.heroTitle,
              subtitle: _TXT.heroSubtitle,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: _Glass(
              radius: 18,
              padding: const EdgeInsets.all(14),
              child: Text(
                _TXT.calcIntro,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.82),
                      height: 1.3,
                    ),
              ),
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
                  _SectionHead(
                    icon: Icons.tune_rounded,
                    title: _TXT.navCalc,
                  ),
                  const SizedBox(height: 12),
                  _ModernDropdownField(
                    label: _TXT.sex,
                    controller: sexCtl,
                    items: const [_TXT.sexFemale, _TXT.sexMale],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ModernNumberField(
                          label: _TXT.weight,
                          controller: weightCtl,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ModernNumberField(
                          label: _TXT.height,
                          controller: heightCtl,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ModernNumberField(
                    label: _TXT.age,
                    controller: ageCtl,
                  ),
                  const SizedBox(height: 14),
                  _ActionButton(
                    label: _TXT.calculate,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      _compute();
                      _goToPage(1);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
            child: Row(
              children: [
                Expanded(
                  child: _HeroMetricCard(
                    label: _TXT.bmiShort,
                    value: _hasResult ? _bmi.toStringAsFixed(2) : "—",
                    icon: Icons.monitor_weight_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _HeroMetricCard(
                    label: _TXT.bmrShort,
                    value: _hasResult
                        ? "${_bmr.toStringAsFixed(0)} ${_TXT.kcalPerDay}"
                        : "—",
                    icon: Icons.local_fire_department_outlined,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsPage(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: _Glass(
              radius: 18,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _SectionHead(
                    icon: Icons.analytics_rounded,
                    title: _TXT.yourResults,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _ResultChip(
                        label: _TXT.bmiShort,
                        value: _hasResult ? _bmi.toStringAsFixed(2) : "—",
                      ),
                      _ResultChip(
                        label: _TXT.bmrShort,
                        value: _hasResult
                            ? "${_bmr.toStringAsFixed(0)} ${_TXT.kcalPerDay}"
                            : "—",
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _BodyText(_TXT.resultText1),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: _Glass(
              radius: 18,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  _SectionHead(
                    icon: Icons.bolt_rounded,
                    title: _TXT.sectionNeeds,
                  ),
                  SizedBox(height: 10),
                  _BodyText("${_TXT.resultText2}\n\n${_TXT.resultText3}"),
                  SizedBox(height: 12),
                  _ActivityTable(),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: _Glass(
              radius: 18,
              padding: const EdgeInsets.all(14),
              child: const _BodyText(
                "${_TXT.resultText4}\n\n${_TXT.resultText2}",
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: _Glass(
              radius: 18,
              padding: const EdgeInsets.all(14),
              child: Column(
                children: const [
                  _RemoteImage(
                    url:
                        "https://www.calculersonimc.fr/images/balance-energetique-gain-poids.png",
                  ),
                  SizedBox(height: 10),
                  _BodyText(
                    _TXT.imageCaption1,
                    weight: FontWeight.w700,
                    size: 13,
                    align: TextAlign.center,
                  ),
                ],
              ),
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
                children: const [
                  _RemoteImage(
                    url:
                        "https://www.calculersonimc.fr/images/balance-energetique-perte-poids.png",
                  ),
                  SizedBox(height: 10),
                  _BodyText(
                    _TXT.imageCaption2,
                    align: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoPage(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: _Glass(
              radius: 18,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  _SectionHead(
                    icon: Icons.menu_book_rounded,
                    title: _TXT.sectionDefinition,
                  ),
                  SizedBox(height: 10),
                  _BodyText("${_TXT.infoText1}\n\n${_TXT.infoText2}"),
                ],
              ),
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
                children: const [
                  _SectionHead(
                    icon: Icons.functions_rounded,
                    title: _TXT.sectionClassicFormula,
                  ),
                  SizedBox(height: 10),
                  _BodyText(_TXT.formulaClassicText),
                  SizedBox(height: 10),
                  _BodyText(_TXT.formulaNote1),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormulasPage(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: _Glass(
              radius: 18,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  _SectionHead(
                    icon: Icons.calculate_rounded,
                    title: _TXT.sectionAdjustedFormula,
                  ),
                  SizedBox(height: 10),
                  _BodyText(_TXT.formulaAdjustedText),
                  SizedBox(height: 10),
                  _BodyText(_TXT.formulaNote1),
                ],
              ),
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
                children: const [
                  _SectionHead(
                    icon: Icons.science_rounded,
                    title: "Alternative formula",
                  ),
                  SizedBox(height: 10),
                  _BodyText(_TXT.formulaAdjustedText2),
                  SizedBox(height: 10),
                  _BodyText("${_TXT.formulaNote2}\n\n- BMI < 25 and age <= 60\n- Other profiles use adjusted equation"),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/* ========================================================================== */
/* Modern Header / Navigation */
/* ========================================================================== */

class _HeaderModern extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onResults;

  const _HeaderModern({
    required this.title,
    required this.onBack,
    required this.onResults,
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
            icon: Icons.analytics_rounded,
            onTap: onResults,
            accent: cs.primary.withOpacity(0.90),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onCalc;
  final VoidCallback onGuide;

  const _QuickActions({
    required this.onCalc,
    required this.onGuide,
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
                  Icons.auto_graph_rounded,
                  size: 18,
                  color: cs.primary.withOpacity(0.92),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "${_TXT.quickCalc} • ${_TXT.quickSections}",
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
            onGuide();
          },
          child: _Glass(
            radius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 18,
                  color: cs.primary.withOpacity(0.92),
                ),
                const SizedBox(width: 8),
                Text(
                  _TXT.quickGuide,
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

class _ModernSectionNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _ModernSectionNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = const [
      (Icons.tune_rounded, _TXT.navCalc),
      (Icons.analytics_rounded, _TXT.navResults),
      (Icons.menu_book_rounded, _TXT.navInfo),
      (Icons.calculate_rounded, _TXT.navFormulas),
    ];

    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (_, i) {
          final item = items[i];
          final selected = i == currentIndex;
          return _NavPill(
            icon: item.$1,
            label: item.$2,
            selected: selected,
            onTap: () => onTap(i),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: items.length,
      ),
    );
  }
}

class _NavPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavPill({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected
              ? cs.primary.withOpacity(0.22)
              : Colors.white.withOpacity(0.08),
          border: Border.all(
            color: selected
                ? cs.primary.withOpacity(0.45)
                : Colors.white.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: selected
                  ? cs.primary.withOpacity(0.95)
                  : Colors.white.withOpacity(0.84),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: t.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(selected ? 0.96 : 0.82),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ========================================================================== */
/* Sections / Cards */
/* ========================================================================== */

class _SectionHead extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHead({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: cs.primary.withOpacity(0.92)),
        const SizedBox(width: 10),
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
    final cs = Theme.of(context).colorScheme;

    return _Glass(
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
            child: Icon(
              Icons.local_fire_department_rounded,
              size: 22,
              color: cs.primary.withOpacity(0.92),
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
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: t.textTheme.bodySmall?.copyWith(
                    height: 1.25,
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

class _BodyText extends StatelessWidget {
  final String text;
  final TextAlign align;
  final FontWeight? weight;
  final double? size;

  const _BodyText(
    this.text, {
    this.align = TextAlign.start,
    this.weight,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Text(
      text,
      textAlign: align,
      style: t.textTheme.bodyMedium?.copyWith(
        color: Colors.white.withOpacity(0.80),
        fontWeight: weight,
        fontSize: size,
        height: 1.38,
      ),
    );
  }
}

class _ResultChip extends StatelessWidget {
  final String label;
  final String value;

  const _ResultChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: cs.primary.withOpacity(0.18),
        border: Border.all(color: cs.primary.withOpacity(0.25), width: 1),
      ),
      child: RichText(
        text: TextSpan(
          style: t.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withOpacity(0.92),
          ),
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _HeroMetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

    return _Glass(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white.withOpacity(0.10),
              border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
            ),
            child: Icon(icon, size: 20, color: cs.primary.withOpacity(0.92)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: t.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withOpacity(0.72),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: t.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.96),
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
/* Fields / Buttons */
/* ========================================================================== */

class _ModernDropdownField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final List<String> items;

  const _ModernDropdownField({
    required this.label,
    required this.controller,
    required this.items,
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
        DropdownButtonFormField<String>(
          value: controller.text.isEmpty ? null : controller.text,
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
                color: Theme.of(context).colorScheme.primary.withOpacity(0.85),
                width: 1.2,
              ),
            ),
          ),
          dropdownColor: const Color(0xFF101722),
          style: t.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.white.withOpacity(0.96),
          ),
          iconEnabledColor: Colors.white.withOpacity(0.90),
          items: items
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(
                    e,
                    style: t.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.96),
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) {
            controller.text = v ?? "";
          },
        ),
      ],
    );
  }
}

class _ModernNumberField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _ModernNumberField({
    required this.label,
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
          style: t.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: Colors.white.withOpacity(0.96),
          ),
          decoration: InputDecoration(
            hintText: "0",
            hintStyle: t.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.40),
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

class _ActionButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _animateTo(double t) =>
      _ctl.animateTo(t.clamp(0.0, 1.0), curve: Curves.easeOut);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final colors = [
      cs.primary.withOpacity(0.95),
      (cs.secondary == cs.primary ? cs.primaryContainer : cs.secondary)
          .withOpacity(0.92),
    ];

    return MouseRegion(
      onEnter: (_) => _animateTo(0.5),
      onExit: (_) => _animateTo(0.0),
      child: GestureDetector(
        onTapDown: (_) => _animateTo(1.0),
        onTapUp: (_) {
          _animateTo(0.5);
          widget.onTap();
        },
        onTapCancel: () => _animateTo(0.0),
        child: AnimatedBuilder(
          animation: _ctl,
          builder: (_, __) {
            final v = _ctl.value;
            final scale = 1.0 - (0.03 * v);
            final blur = 12.0 + (10.0 * v);
            final spread = 0.0 + (2.0 * v);

            return Transform.scale(
              scale: scale,
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.last.withOpacity(0.45 * (0.3 + 0.7 * v)),
                      blurRadius: blur,
                      spreadRadius: spread,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/* ========================================================================== */
/* Table / Images */
/* ========================================================================== */

class _ActivityTable extends StatelessWidget {
  const _ActivityTable();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final zebra1 = Colors.blue.withOpacity(isDark ? 0.18 : 0.10);
    final zebra2 = Colors.indigo.withOpacity(isDark ? 0.16 : 0.08);
    final textColor = Colors.white.withOpacity(0.92);

    final rows = <List<String>>[
      [_TXT.activity1, _TXT.activityDesc1, _TXT.activityMul1],
      [_TXT.activity2, _TXT.activityDesc2, _TXT.activityMul2],
      [_TXT.activity3, _TXT.activityDesc3, _TXT.activityMul3],
      [_TXT.activity4, _TXT.activityDesc4, _TXT.activityMul4],
      [_TXT.activity5, _TXT.activityDesc5, _TXT.activityMul5],
    ];

    return Table(
      border: TableBorder.all(color: Colors.white.withOpacity(0.16)),
      columnWidths: const {
        0: FlexColumnWidth(1.1),
        1: FlexColumnWidth(1.6),
        2: FlexColumnWidth(1.0),
      },
      children: [
        TableRow(
          children: [
            _th(context, _TXT.activityTable1),
            _th(context, _TXT.activityTable2),
            _th(context, _TXT.activityTable3),
          ],
        ),
        ...List.generate(rows.length, (i) {
          final bg = i.isEven ? zebra1 : zebra2;
          return TableRow(
            children: [
              _td(rows[i][0], bg, textColor),
              _td(rows[i][1], bg, textColor),
              _td(rows[i][2], bg, textColor),
            ],
          );
        }),
      ],
    );
  }

  Widget _th(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primary.withOpacity(0.95),
            (cs.secondary == cs.primary ? cs.primaryContainer : cs.secondary)
                .withOpacity(0.88),
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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      color: bg,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: color),
      ),
    );
  }
}

class _RemoteImage extends StatelessWidget {
  final String url;

  const _RemoteImage({
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      height: MediaQuery.of(context).size.height * 0.22,
      width: MediaQuery.of(context).size.width * 0.9,
      imageUrl: url,
      imageBuilder: (context, imageProvider) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        );
      },
      placeholder: (context, url) => SizedBox(
        height: 220,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        height: 220,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.08),
        ),
        child: Icon(Icons.broken_image_rounded,
            color: Colors.white.withOpacity(0.70)),
      ),
    );
  }
}

/* ========================================================================== */
/* UI Kit */
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