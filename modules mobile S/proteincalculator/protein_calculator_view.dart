// lib/features/proteincalculator/protein_calculator_view.dart
//
// ✅ Design aligned with BeepIntermittentTrainingView (premium background + overlay + glass header + chips + glass container)
// ✅ NO localization
// ✅ LOGIQUE _onCalculate() INCHANGÉE (copiée telle quelle)
// ✅ Calcul + Résultat via BottomSheet (UI seulement)

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProteinCalculatorView extends StatefulWidget {
  const ProteinCalculatorView({super.key});

  @override
  State<ProteinCalculatorView> createState() => _ProteinCalculatorViewState();
}

class _ProteinCalculatorViewState extends State<ProteinCalculatorView>
    with TickerProviderStateMixin {
  static const String _bg = "assets/images/BgHome.jfif";

  // Fields
  final ageController = TextEditingController();
  final heightTensController = TextEditingController();
  final heightUnitsController = TextEditingController();
  final weightValueController = TextEditingController();

  String sex = '';
  String heightSystem = ''; // 'Meters' or 'Feet'
  String weightSystem = ''; // 'Kg' or 'Lbs'
  String goal = ''; // 'Maintain' / 'Fat Loss' / 'Muscle Gain'
  String activity = ''; // 'Level 1'..'Level 5'

  double? _proteinIntake;

  late final AnimationController _enterCtrl;

  @override
  void initState() {
    super.initState();
    _enterCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 760))
          ..forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    ageController.dispose();
    heightTensController.dispose();
    heightUnitsController.dispose();
    weightValueController.dispose();
    super.dispose();
  }

  String get _heightMajorUnitLabel => heightSystem == 'Meters' ? 'm' : 'ft';
  String get _heightMinorUnitLabel => heightSystem == 'Meters' ? 'cm' : 'in';
  String get _weightUnitLabel => weightSystem == 'Lbs' ? 'lbs' : 'kg';

  void _openCalcSheet() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProteinCalcBottomSheet(
        // ✅ pass current values / controllers
        ageController: ageController,
        heightTensController: heightTensController,
        heightUnitsController: heightUnitsController,
        weightValueController: weightValueController,
        sex: sex,
        heightSystem: heightSystem,
        weightSystem: weightSystem,
        goal: goal,
        activity: activity,
        proteinIntake: _proteinIntake,
        onSexChanged: (v) => setState(() => sex = v),
        onHeightSystemChanged: (v) => setState(() => heightSystem = v),
        onWeightSystemChanged: (v) => setState(() => weightSystem = v),
        onGoalChanged: (v) => setState(() => goal = v),
        onActivityChanged: (v) => setState(() => activity = v),
        onCalculate: () {
          _onCalculate(); // ✅ unchanged logic
          // Rebuild sheet to show result
          setState(() {});
        },
        heightMajorUnitLabel: _heightMajorUnitLabel,
        heightMinorUnitLabel: _heightMinorUnitLabel,
        weightUnitLabel: _weightUnitLabel,
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
              errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0B0F14)),
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
                  final fade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut).value;

                  return Opacity(
                    opacity: fade,
                    child: Column(
                      children: [
                        _HeaderModern(
                          title: "Protein Intake Calculator",
                          onBack: () => Navigator.of(context).maybePop(),
                          onCalc: _openCalcSheet,
                        ),
                        const SizedBox(height: 12),

                        // ✅ Quick actions (chips)
                        _QuickActions(onCalc: _openCalcSheet),
                        const SizedBox(height: 12),

                        // ✅ Main content container (glass)
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
                                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                                      child: _InfoBanner(
                                        title: "Enter your details",
                                        subtitle:
                                            "Open the calculator, fill inputs, then calculate protein intake.",
                                      ),
                                    ),
                                  ),

                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                      child: _PreviewCard(
                                        isDark: isDark,
                                        sex: sex,
                                        heightSystem: heightSystem,
                                        weightSystem: weightSystem,
                                        goal: goal,
                                        activity: activity,
                                        proteinIntake: _proteinIntake,
                                      ),
                                    ),
                                  ),

                                  // CTA
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                                      child: _CalcEntryCard(
                                        onTap: _openCalcSheet,
                                      ),
                                    ),
                                  ),

                                  const SliverToBoxAdapter(child: SizedBox(height: 10)),
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

  // ------------ LOGIQUE LOCALE DE CALCUL PROTÉINE (INCHANGÉE) ------------
  void _onCalculate() {
    String message = "";
    bool error = false;

    final age = int.tryParse(ageController.text.trim());
    if (age == null || age <= 0 || age > 100) {
      message += "Age: invalid value\n";
      error = true;
    }

    if (sex.isEmpty) {
      message += "Sex: required\n";
      error = true;
    }

    final weightVal = double.tryParse(weightValueController.text.trim());
    if (weightSystem.isEmpty || weightVal == null || weightVal <= 0) {
      message += "Weight: invalid\n";
      error = true;
    }

    if (goal.isEmpty) {
      message += "Goal: required\n";
      error = true;
    }

    if (activity.isEmpty) {
      message += "Activity: required\n";
      error = true;
    }

    if (error) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text(message.trim()),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
      return;
    }

    final double weightKg = (weightSystem == 'Lbs') ? weightVal! * 0.453592 : weightVal!;

    int activityIndex = 0;
    if (activity == 'Level 2') activityIndex = 1;
    else if (activity == 'Level 3') activityIndex = 2;
    else if (activity == 'Level 4') activityIndex = 3;
    else if (activity == 'Level 5') activityIndex = 4;

    double gPerKg = 1.2 + activityIndex * 0.2;

    if (goal == 'Fat Loss') gPerKg += 0.2;
    else if (goal == 'Muscle Gain') gPerKg += 0.3;

    if (sex == 'Male') gPerKg += 0.1;

    if (gPerKg < 0.8) gPerKg = 0.8;
    if (gPerKg > 2.4) gPerKg = 2.4;

    final protein = weightKg * gPerKg;

    setState(() => _proteinIntake = protein);
  }
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
            onTap: () {
              HapticFeedback.lightImpact();
              onCalc();
            },
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
                Icon(Icons.fitness_center_rounded,
                    size: 18, color: cs.primary.withOpacity(0.92)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Calculator • Nutrition",
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
                  "Open calculator",
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
            child: Icon(Icons.info_outline_rounded,
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

class _PreviewCard extends StatelessWidget {
  final bool isDark;
  final String sex;
  final String heightSystem;
  final String weightSystem;
  final String goal;
  final String activity;
  final double? proteinIntake;

  const _PreviewCard({
    required this.isDark,
    required this.sex,
    required this.heightSystem,
    required this.weightSystem,
    required this.goal,
    required this.activity,
    required this.proteinIntake,
  });

  String _fmt(String v) => v.isEmpty ? "--" : v;

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
            "Current selection",
            style: t.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.96),
            ),
          ),
          const SizedBox(height: 10),

          _KV(label: "Sex", value: _fmt(sex)),
          _KV(label: "Height system", value: _fmt(heightSystem)),
          _KV(label: "Weight system", value: _fmt(weightSystem)),
          _KV(label: "Goal", value: _fmt(goal)),
          _KV(label: "Activity", value: _fmt(activity)),

          const SizedBox(height: 10),
          Container(
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
                    "Protein Intake",
                    style: t.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withOpacity(0.78),
                    ),
                  ),
                ),
                Text(
                  proteinIntake == null
                      ? "--"
                      : "${proteinIntake!.toStringAsFixed(0)} g/day",
                  style: t.textTheme.bodySmall?.copyWith(
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

class _KV extends StatelessWidget {
  final String label;
  final String value;
  const _KV({required this.label, required this.value});

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
                    "Open calculator",
                    style: t.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withOpacity(0.96),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Fill inputs and calculate your daily protein intake.",
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
            Icon(Icons.arrow_forward_rounded, color: Colors.white.withOpacity(0.88)),
          ],
        ),
      ),
    );
  }
}

/* ========================================================================== */
/*                              Calculator BottomSheet                        */
/* ========================================================================== */

class _ProteinCalcBottomSheet extends StatelessWidget {
  final TextEditingController ageController;
  final TextEditingController heightTensController;
  final TextEditingController heightUnitsController;
  final TextEditingController weightValueController;

  final String sex;
  final String heightSystem;
  final String weightSystem;
  final String goal;
  final String activity;

  final double? proteinIntake;

  final ValueChanged<String> onSexChanged;
  final ValueChanged<String> onHeightSystemChanged;
  final ValueChanged<String> onWeightSystemChanged;
  final ValueChanged<String> onGoalChanged;
  final ValueChanged<String> onActivityChanged;

  final VoidCallback onCalculate;

  final String heightMajorUnitLabel;
  final String heightMinorUnitLabel;
  final String weightUnitLabel;

  const _ProteinCalcBottomSheet({
    required this.ageController,
    required this.heightTensController,
    required this.heightUnitsController,
    required this.weightValueController,
    required this.sex,
    required this.heightSystem,
    required this.weightSystem,
    required this.goal,
    required this.activity,
    required this.proteinIntake,
    required this.onSexChanged,
    required this.onHeightSystemChanged,
    required this.onWeightSystemChanged,
    required this.onGoalChanged,
    required this.onActivityChanged,
    required this.onCalculate,
    required this.heightMajorUnitLabel,
    required this.heightMinorUnitLabel,
    required this.weightUnitLabel,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
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
                              "Protein Calculator",
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
                      Text(
                        "Enter values then tap Calculate.",
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
                    child: Column(
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
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.14),
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(Icons.tune_rounded,
                                        color: cs.primary.withOpacity(0.92), size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "Inputs",
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
                                      label: "Age",
                                      suffix: "",
                                      controller: ageController,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _SelectField(
                                      label: "Sex",
                                      hint: "Select",
                                      value: sex.isEmpty ? null : sex,
                                      items: const ["Male", "Female"],
                                      onChanged: (v) => onSexChanged(v ?? ''),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Expanded(
                                    child: _SelectField(
                                      label: "Height System",
                                      hint: "Select",
                                      value: heightSystem.isEmpty ? null : heightSystem,
                                      items: const ["Feet", "Meters"],
                                      onChanged: (v) => onHeightSystemChanged(v ?? ''),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _NumberField(
                                      label: heightMajorUnitLabel,
                                      suffix: "",
                                      controller: heightTensController,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _NumberField(
                                      label: heightMinorUnitLabel,
                                      suffix: "",
                                      controller: heightUnitsController,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Expanded(
                                    child: _SelectField(
                                      label: "Weight System",
                                      hint: "Select",
                                      value: weightSystem.isEmpty ? null : weightSystem,
                                      items: const ["Kg", "Lbs"],
                                      onChanged: (v) => onWeightSystemChanged(v ?? ''),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _NumberField(
                                      label: "Weight",
                                      suffix: weightUnitLabel,
                                      controller: weightValueController,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              _SelectField(
                                label: "Goal",
                                hint: "Select",
                                value: goal.isEmpty ? null : goal,
                                items: const ["Maintain", "Fat Loss", "Muscle Gain"],
                                onChanged: (v) => onGoalChanged(v ?? ''),
                              ),

                              const SizedBox(height: 12),

                              _SelectField(
                                label: "Activity Level",
                                hint: "Select",
                                value: activity.isEmpty ? null : activity,
                                items: const ["Level 1", "Level 2", "Level 3", "Level 4", "Level 5"],
                                onChanged: (v) => onActivityChanged(v ?? ''),
                              ),

                              const SizedBox(height: 14),

                              Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    onCalculate();
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
                                          "Calculate",
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
                                "Result",
                                style: t.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white.withOpacity(0.96),
                                ),
                              ),
                              const SizedBox(height: 10),
                              _ResultRow(
                                label: "Protein Intake",
                                value: proteinIntake == null
                                    ? "--"
                                    : "${proteinIntake!.toStringAsFixed(0)} g/day",
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Tip: Increase protein for muscle gain and higher activity.",
                                style: t.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withOpacity(0.72),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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
            suffixText: suffix.isEmpty ? null : suffix,
            suffixStyle: t.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.78),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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

class _SelectField extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _SelectField({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
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
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF111827),
          style: t.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.white.withOpacity(0.94),
          ),
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.white.withOpacity(0.80)),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.10),
            hintText: hint,
            hintStyle: t.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.55),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          menuMaxHeight: 380,
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
