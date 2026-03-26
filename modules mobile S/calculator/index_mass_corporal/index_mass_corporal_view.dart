// lib/features/.../imc_calculator.dart
//
// ✅ Logique IMC inchangée
// ✅ Suppression de intl / Dimensions
// ✅ Design identique à BeepIntermittentTrainingView
// ✅ Même fond premium + overlay + glass cards + animations

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/widget/loading_widget.dart';

class ImcCalculator extends StatefulWidget {
  const ImcCalculator({super.key});

  @override
  State<ImcCalculator> createState() => _ImcCalculatorState();
}

class _TXT {
  static const String screenTitle = "BMI Calculator";
  static const String introTitle = "Body Mass Index";
  static const String introSubtitle =
      "Calculate your BMI using weight and height.";

  static const String calcTitle = "Calculator";
  static const String calcDesc =
      "Enter your weight and height, then calculate your BMI.";

  static const String weight = "Weight";
  static const String height = "Height";
  static const String kg = "kg";
  static const String cm = "cm";
  static const String calculateImc = "Calculate BMI";

  static const String yourResults = "Your Results";
  static const String bmiValue = "BMI";
  static const String status = "Status";
  static const String noResult = "—";

  static const String chipMethod = "BMI";
  static const String chipEstimate = "Body evaluation";

  static const String performCalculation = "PERFORM YOUR BMI CALCULATION";

  static const String imcTitle1 = "BMI Classification Table";
  static const String imcTitle2 = "What is BMI?";
  static const String imcTitle3 = "How to interpret BMI?";
  static const String imcTitle4 = "BMI limits";
  static const String imcTitle5 = "Body weight and BMI";

  static const String imcPar1 = "Interpretation of your BMI";
  static const String imcPar2 = "Your BMI is";
  static const String imcPar3 =
      "BMI is a simple indicator used to estimate corpulence from weight and height. It is useful as a general guideline, but it does not distinguish between fat mass and muscle mass.";
  static const String imcPar4 =
      "BMI gives a broad estimate of body build. It should always be interpreted in context with age, sex, physical activity and body composition.";
  static const String imcPar5 =
      "BMI has limitations: it may overestimate fatness in muscular people and underestimate it in others. It remains a practical screening tool, not a diagnosis.";
  static const String imcPar6 =
      "Body weight alone is not enough to assess health. BMI is only one indicator among others and should be combined with lifestyle and medical context.";

  static const String tableRange = "BMI Range";
  static const String tableMeaning = "Interpretation";

  static const String row1a = "< 16";
  static const String row1b = "Undernutrition";

  static const String row2a = "16 - 18.5";
  static const String row2b = "Skinny";

  static const String row3a = "18.5 - 25";
  static const String row3b = "Normal Body";

  static const String row4a = "25 - 30";
  static const String row4b = "Overweight";

  static const String row5a = "30 - 35";
  static const String row5b = "Moderate obesity (Class 1)";

  static const String row6a = "35 - 40";
  static const String row6b = "Severe obesity (Class 2)";

  static const String row7a = "> 40";
  static const String row7b = "Morbid / massive obesity (Class 3)";
}

class _ImcCalculatorState extends State<ImcCalculator>
    with TickerProviderStateMixin {
  static const String _bg = "assets/images/BgS.jfif";

  final TextEditingController height = TextEditingController(text: "0");
  final TextEditingController weight = TextEditingController(text: "0");

  late final AnimationController _enterCtrl;

  double result = 0;
  String paragraph = "";
  String imcTitle = "";
  Color imcColor = Colors.white;
  bool visible = false;

  int _safeInt(String s) => int.tryParse(s.trim()) ?? 0;

  void _compute() {
    final hCm = _safeInt(height.text);
    final wKg = _safeInt(weight.text);
    if (hCm <= 0 || wKg <= 0) {
      setState(() {
        result = 0;
        visible = false;
        imcTitle = "";
        paragraph = "";
      });
      return;
    }

    // ✅ Logique inchangée
    final h = hCm / 100.0;
    final bmi = wKg / (h * h);

    String title;
    Color color;
    String text;

    switch (bmi) {
      case < 16:
        color = Colors.cyanAccent;
        title = "Undernutrition";
        text =
            "Watch your build, this BMI is very low. Try to stay above 18.5. "
            "Your body lacks energy and nutrients which can cause serious issues "
            "(immune weakness, sarcopenia, deficiencies, fatigue...). Consider "
            "seeing a nutritionist/dietitian for a safe gain plan.";
      case < 18.5:
        color = const Color(0xFF188FFF);
        title = "Skinny";
        text =
            "Your BMI is low. Aim to be ≥ 18.5 with a balanced diet rich in "
            "quality carbs, proteins, and fats. Professional guidance can help "
            "you reach a healthy weight safely.";
      case < 25:
        color = Colors.green;
        title = "Normal Body";
        text =
            "Great! Your BMI is in the normal range. Keep a balanced diet "
            "(50–55% low-GI carbs, 30–35% quality fats, 10–15% lean proteins) "
            "and regular physical activity to maintain it.";
      case < 30:
        color = Colors.orange;
        title = "Overweight";
        text =
            "Your BMI indicates overweight. Prefer a gentle nutrition rebalancing "
            "over restrictive diets and keep regular activity to reduce health risks.";
      case < 35:
        color = Colors.red.shade500;
        title = "Moderate obesity (Class 1)";
        text =
            "Your BMI suggests class-1 obesity. Losing weight will reduce health risk. "
            "Choose a progressive, body-respectful plan with professional support.";
      case < 40:
        color = Colors.red.shade700;
        title = "Severe obesity (Class 2)";
        text =
            "Severe obesity. Avoid crash diets; consult your doctor/nutritionist "
            "to set up a safe and effective plan.";
      default:
        color = Colors.red.shade900;
        title = "Morbid / massive obesity (Class 3)";
        text =
            "Very high BMI. Medical guidance is strongly recommended to manage weight "
            "safely and reduce complications.";
    }

    setState(() {
      result = bmi;
      imcTitle = title;
      imcColor = color;
      paragraph = text;
      visible = true;
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
                          result: result == 0 ? "—" : result.toStringAsFixed(2),
                          status: visible ? imcTitle : "—",
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
                                      child: _IntroCard(),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _CalcCard(
                                        weightCtl: weight,
                                        heightCtl: height,
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
                                      child: _ResultCard(
                                        visible: visible,
                                        result: result,
                                        imcTitle: imcTitle,
                                        imcColor: imcColor,
                                        paragraph: paragraph,
                                      ),
                                    ),
                                  ),
                                  const SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _ImcTableCard(),
                                    ),
                                  ),
                                  const SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _ImageInfoCard(
                                        title: _TXT.imcTitle2,
                                        body: _TXT.imcPar3,
                                        url:
                                            "https://www.calculersonimc.fr/wp-content/uploads/2018/04/balance-poids-imc.jpg",
                                      ),
                                    ),
                                  ),
                                  const SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _TextInfoCard(
                                        title: _TXT.imcTitle3,
                                        body: _TXT.imcPar4,
                                      ),
                                    ),
                                  ),
                                  const SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _TextInfoCard(
                                        title: _TXT.imcTitle4,
                                        body: _TXT.imcPar5,
                                      ),
                                    ),
                                  ),
                                  const SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(12, 0, 12, 14),
                                      child: _ImageInfoCard(
                                        title: _TXT.imcTitle5,
                                        body: _TXT.imcPar6,
                                        url:
                                            "https://www.calculersonimc.fr/wp-content/uploads/2018/04/poids-imc.jpg",
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
/* Header */
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
          const _PillIconStatic(icon: Icons.monitor_weight_rounded),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final String result;
  final String status;

  const _QuickActions({
    required this.result,
    required this.status,
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
                  Icons.monitor_heart_rounded,
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
            "BMI $result",
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
              border: Border.all(
                color: Colors.white.withOpacity(0.14),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.health_and_safety_rounded,
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

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return _Glass(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Text(
        _TXT.performCalculation,
        textAlign: TextAlign.center,
        style: t.textTheme.bodyMedium?.copyWith(
          color: Colors.white.withOpacity(0.82),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CalcCard extends StatelessWidget {
  final TextEditingController weightCtl;
  final TextEditingController heightCtl;
  final VoidCallback onCompute;

  const _CalcCard({
    required this.weightCtl,
    required this.heightCtl,
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
                      _TXT.calculateImc,
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

class _ResultCard extends StatelessWidget {
  final bool visible;
  final double result;
  final String imcTitle;
  final Color imcColor;
  final String paragraph;

  const _ResultCard({
    required this.visible,
    required this.result,
    required this.imcTitle,
    required this.imcColor,
    required this.paragraph,
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
            _TXT.yourResults,
            style: t.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.96),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.amber.withOpacity(0.22),
              border: Border.all(color: Colors.amber.withOpacity(0.35)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _TXT.imcPar2,
                    style: t.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withOpacity(0.78),
                    ),
                  ),
                ),
                Text(
                  result == 0 ? "—" : result.toStringAsFixed(2),
                  style: t.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.96),
                  ),
                ),
              ],
            ),
          ),
          if (visible) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: imcColor.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: imcColor.withOpacity(0.60)),
              ),
              child: Text(
                "🏷️ $imcTitle\n${_TXT.imcPar1}",
                textAlign: TextAlign.center,
                style: t.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withOpacity(0.96),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              paragraph,
              textAlign: TextAlign.center,
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

class _ImcTableCard extends StatelessWidget {
  const _ImcTableCard();

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
            _TXT.imcTitle1,
            style: t.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.96),
            ),
          ),
          const SizedBox(height: 10),
          const _ImcTable(),
        ],
      ),
    );
  }
}

class _TextInfoCard extends StatelessWidget {
  final String title;
  final String body;

  const _TextInfoCard({
    required this.title,
    required this.body,
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
/* Table */
/* ========================================================================== */

class _ImcTable extends StatelessWidget {
  const _ImcTable();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    TextStyle st(Color c) => t.textTheme.bodyMedium!.copyWith(
          color: c,
          fontWeight: FontWeight.w700,
        );

    return Table(
      border: TableBorder.all(color: Colors.grey.withOpacity(0.5)),
      children: [
        TableRow(
          children: [
            _cell(_TXT.tableRange, align: TextAlign.center),
            _cell(_TXT.tableMeaning, align: TextAlign.center),
          ],
        ),
        TableRow(
          children: [
            _cell(_TXT.row1a, align: TextAlign.center, style: st(Colors.cyanAccent)),
            _cell(_TXT.row1b, align: TextAlign.center, style: st(Colors.cyanAccent)),
          ],
        ),
        TableRow(
          children: [
            _cell(_TXT.row2a,
                align: TextAlign.center, style: st(const Color(0xFF188FFF))),
            _cell(_TXT.row2b,
                align: TextAlign.center, style: st(const Color(0xFF188FFF))),
          ],
        ),
        TableRow(
          children: [
            _cell(_TXT.row3a, align: TextAlign.center, style: st(Colors.green)),
            _cell(_TXT.row3b, align: TextAlign.center, style: st(Colors.green)),
          ],
        ),
        TableRow(
          children: [
            _cell(_TXT.row4a, align: TextAlign.center, style: st(Colors.orange)),
            _cell(_TXT.row4b, align: TextAlign.center, style: st(Colors.orange)),
          ],
        ),
        TableRow(
          children: [
            _cell(_TXT.row5a,
                align: TextAlign.center, style: st(Colors.red.shade500)),
            _cell(_TXT.row5b,
                align: TextAlign.center, style: st(Colors.red.shade500)),
          ],
        ),
        TableRow(
          children: [
            _cell(_TXT.row6a,
                align: TextAlign.center, style: st(Colors.red.shade700)),
            _cell(_TXT.row6b,
                align: TextAlign.center, style: st(Colors.red.shade700)),
          ],
        ),
        TableRow(
          children: [
            _cell(_TXT.row7a,
                align: TextAlign.center, style: st(Colors.red.shade900)),
            _cell(_TXT.row7b,
                align: TextAlign.center, style: st(Colors.red.shade900)),
          ],
        ),
      ],
    );
  }

  Widget _cell(String s, {TextAlign align = TextAlign.start, TextStyle? style}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: Text(
        s,
        textAlign: align,
        style: style,
      ),
    );
  }
}

/* ========================================================================== */
/* UI kit */
/* ========================================================================== */

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
        child: Icon(
          icon,
          color: Colors.white.withOpacity(0.92),
          size: 20,
        ),
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
      child: Icon(
        icon,
        color: Colors.white.withOpacity(0.92),
        size: 20,
      ),
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
      imageBuilder: (context, imageProvider) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        );
      },
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