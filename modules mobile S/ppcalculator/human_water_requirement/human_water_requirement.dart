// lib/feature/ppCalculator/hydration/human_water_requirement.dart
//
// ✅ LOGIQUE DE CALCUL INCHANGÉE (NE PAS TOUCHER)
// ✅ Design aligné sur BeepIntermittentTrainingView (background + overlay + orbs + glass cards + header moderne)
// ✅ Form / Results / Tips en cards glass premium
// ✅ Dropdown fixé sur fond blur (canvasColor)

import 'dart:math' as math;
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/widget/custom_input.dart';
import '../../../shared/widget/loading_widget.dart';

class HumanWaterRequirement extends StatefulWidget {
  const HumanWaterRequirement({super.key});

  @override
  State<HumanWaterRequirement> createState() => _HumanWaterRequirementState();
}

class _HumanWaterRequirementState extends State<HumanWaterRequirement>
    with SingleTickerProviderStateMixin {
  // ✅ Design (comme Beep)
  static const String _bg = "assets/images/BgS.jfif";
  late final AnimationController _enterCtrl;

  // Contrôleurs
  final TextEditingController kgController = TextEditingController();
  final TextEditingController minController = TextEditingController();
  final TextEditingController envController = TextEditingController();

  // État
  bool _isLoading = false;

  // Résultats
  String ml = "0";
  String oz = "0";
  String ozi = "0";
  String gl = "0";

  bool get _canSubmit =>
      kgController.text.trim().isNotEmpty &&
      minController.text.trim().isNotEmpty &&
      envController.text.trim().isNotEmpty &&
      !_isLoading;

  /// Table de données comme dans le JS :
  /// [kg, min, ml]
  static const List<List<int>> _hwrTable = [
    [27, 0, 900],
    [27, 20, 1140],
    [27, 40, 1320],
    [27, 60, 1500],
    [28, 0, 945],
    [28, 20, 1185],
    [28, 40, 1365],
    [27, 60, 1560],
    [29, 0, 990],
    [29, 20, 1230],
    [29, 40, 1410],
    [29, 60, 1620],
    [30, 0, 1020],
    [30, 20, 1260],
    [30, 40, 1440],
    [30, 60, 1665],
    [31, 0, 1050],
    [31, 20, 1290],
    [31, 40, 1470],
    [31, 60, 1710],
    [32, 0, 1095],
    [32, 20, 1350],
    [32, 40, 1530],
    [32, 60, 1770],
    [33, 0, 1140],
    [33, 20, 1410],
    [33, 40, 1590],
    [33, 60, 1830],
    [34, 0, 1170],
    [34, 20, 1440],
    [34, 40, 1650],
    [34, 60, 1885],
    [35, 0, 1185],
    [35, 20, 1455],
    [35, 40, 1680],
    [35, 60, 1950],
    [36, 0, 1200],
    [36, 20, 1470],
    [36, 40, 1710],
    [36, 60, 2040],
    [37, 0, 1245],
    [37, 20, 1515],
    [37, 40, 1755],
    [37, 60, 2100],
    [38, 0, 1290],
    [38, 20, 1560],
    [38, 40, 1800],
    [38, 60, 2160],
    [39, 0, 1335],
    [39, 20, 1605],
    [39, 40, 1845],
    [39, 60, 2205],
    [40, 0, 1350],
    [40, 20, 1650],
    [40, 40, 1890],
    [40, 60, 2250],
    [41, 0, 1395],
    [41, 20, 1695],
    [41, 40, 1935],
    [41, 60, 2310],
    [42, 0, 1440],
    [42, 20, 1740],
    [42, 40, 1980],
    [42, 60, 2370],
    [43, 0, 1470],
    [43, 20, 1795],
    [43, 40, 2040],
    [43, 60, 2480],
    [44, 0, 1500],
    [44, 20, 1850],
    [44, 40, 2210],
    [44, 60, 2520],
    [45, 0, 1550],
    [45, 20, 1950],
    [45, 40, 2190],
    [45, 60, 2580],
    [46, 0, 1570],
    [46, 20, 2010],
    [46, 40, 2250],
    [46, 60, 2640],
    [47, 0, 1590],
    [47, 20, 2070],
    [47, 40, 2310],
    [47, 60, 2700],
    [48, 0, 1620],
    [48, 20, 2100],
    [48, 40, 2380],
    [48, 60, 2745],
    [49, 0, 1650],
    [49, 20, 2130],
    [49, 40, 2430],
    [49, 60, 2790],
    [50, 0, 1695],
    [50, 20, 2175],
    [50, 40, 2475],
    [50, 60, 2850],
    [51, 0, 1740],
    [51, 20, 2220],
    [51, 40, 2520],
    [51, 60, 2910],
    [52, 0, 1755],
    [52, 20, 2240],
    [52, 40, 2560],
    [52, 60, 2940],
    [53, 0, 1770],
    [53, 20, 2260],
    [53, 40, 2600],
    [53, 60, 2970],
    [54, 0, 1800],
    [54, 20, 2280],
    [54, 40, 2640],
    [54, 60, 3000],
    [55, 0, 1845],
    [55, 20, 2325],
    [55, 40, 2685],
    [55, 60, 3045],
    [56, 0, 1890],
    [56, 20, 2370],
    [56, 40, 2730],
    [56, 60, 3090],
    [57, 0, 1925],
    [57, 20, 2400],
    [57, 40, 2760],
    [57, 60, 3120],
    [58, 0, 1950],
    [58, 20, 2430],
    [58, 40, 2790],
    [58, 60, 3150],
    [59, 0, 1995],
    [59, 20, 2475],
    [59, 40, 2835],
    [59, 60, 3195],
    [60, 0, 2040],
    [60, 20, 2520],
    [60, 40, 2880],
    [60, 60, 3240],
    [61, 0, 2060],
    [61, 20, 2540],
    [61, 40, 2900],
    [61, 60, 3260],
    [62, 0, 2080],
    [62, 20, 2560],
    [62, 40, 2920],
    [62, 60, 3280],
    [63, 0, 2100],
    [63, 20, 2580],
    [63, 40, 2940],
    [63, 60, 3300],
    [64, 0, 2145],
    [64, 20, 2625],
    [64, 40, 2985],
    [64, 60, 3345],
    [65, 0, 2190],
    [65, 20, 2670],
    [65, 40, 3030],
    [65, 60, 3390],
    [66, 0, 2230],
    [66, 20, 2700],
    [66, 40, 3060],
    [66, 60, 3420],
    [67, 0, 2250],
    [67, 20, 2730],
    [67, 40, 3090],
    [67, 60, 3450],
    [68, 0, 2295],
    [68, 20, 2775],
    [68, 40, 3145],
    [68, 60, 3495],
    [69, 0, 2340],
    [69, 20, 2820],
    [69, 40, 3180],
    [69, 60, 3540],
    [70, 0, 2360],
    [70, 20, 2840],
    [70, 40, 3200],
    [70, 60, 3560],
    [71, 0, 2380],
    [71, 20, 2860],
    [71, 40, 3220],
    [71, 60, 3580],
    [72, 0, 2400],
    [72, 20, 2880],
    [72, 40, 3240],
    [72, 60, 3600],
    [73, 0, 2445],
    [73, 20, 2925],
    [73, 40, 3285],
    [73, 60, 3645],
    [74, 0, 2490],
    [74, 20, 2970],
    [74, 40, 3330],
    [74, 60, 3690],
    [75, 0, 2520],
    [75, 20, 3000],
    [75, 40, 3360],
    [75, 60, 3720],
    [76, 0, 2550],
    [76, 20, 3030],
    [76, 40, 3390],
    [76, 60, 3750],
    [77, 0, 2595],
    [77, 20, 3075],
    [77, 40, 3435],
    [77, 60, 3795],
    [78, 0, 2640],
    [78, 20, 3120],
    [78, 40, 3480],
    [78, 60, 3840],
    [79, 0, 2660],
    [79, 20, 3140],
    [79, 40, 3500],
    [79, 60, 3860],
    [80, 0, 2680],
    [80, 20, 3160],
    [80, 40, 3520],
    [80, 60, 3880],
    [81, 0, 2700],
    [81, 20, 3180],
    [81, 40, 3540],
    [81, 60, 3900],
    [82, 0, 2745],
    [82, 20, 3225],
    [82, 40, 3585],
    [82, 60, 3945],
    [83, 0, 2790],
    [83, 20, 3270],
    [83, 40, 3630],
    [83, 60, 3990],
    [84, 0, 2820],
    [84, 20, 3300],
    [84, 40, 3660],
    [84, 60, 4020],
    [85, 0, 2850],
    [85, 20, 3330],
    [85, 40, 3690],
    [85, 60, 4050],
    [86, 0, 2895],
    [86, 20, 3375],
    [86, 40, 3735],
    [86, 60, 4095],
    [87, 0, 2940],
    [87, 20, 3420],
    [87, 40, 3780],
    [87, 60, 4140],
    [88, 0, 2960],
    [88, 20, 3440],
    [88, 40, 3820],
    [88, 60, 4160],
    [89, 0, 2980],
    [89, 20, 3460],
    [89, 40, 3840],
    [89, 60, 4180],
    [90, 0, 3000],
    [90, 20, 3480],
    [90, 40, 3840],
    [90, 60, 4200],
    [91, 0, 3045],
    [91, 20, 3525],
    [91, 40, 3885],
    [91, 60, 4245],
    [92, 0, 3090],
    [92, 20, 3570],
    [92, 40, 3930],
    [92, 60, 4290],
    [93, 0, 3120],
    [93, 20, 3600],
    [93, 40, 3960],
    [93, 60, 4320],
    [94, 0, 3150],
    [94, 20, 3630],
    [94, 40, 3990],
    [94, 60, 4350],
    [95, 0, 3195],
    [95, 20, 3675],
    [95, 40, 4035],
    [95, 60, 4395],
    [96, 0, 3240],
    [96, 20, 3720],
    [96, 40, 4080],
    [96, 60, 4440],
    [97, 0, 3260],
    [97, 20, 3740],
    [97, 40, 4100],
    [97, 60, 4460],
    [98, 0, 3280],
    [98, 20, 3760],
    [98, 40, 4120],
    [98, 60, 4480],
    [99, 0, 3300],
    [99, 20, 3780],
    [99, 40, 4140],
    [99, 60, 4500],
    [100, 0, 3345],
    [100, 20, 3825],
    [100, 40, 4185],
    [100, 60, 4545],
    [101, 0, 3390],
    [101, 20, 3870],
    [101, 40, 4230],
    [101, 60, 4590],
    [102, 0, 3420],
    [102, 20, 3900],
    [102, 40, 4260],
    [102, 60, 4620],
    [103, 0, 3450],
    [103, 20, 3930],
    [103, 40, 4290],
    [103, 60, 4650],
    [104, 0, 3495],
    [104, 20, 3975],
    [104, 40, 4335],
    [104, 60, 4695],
    [105, 0, 3540],
    [105, 20, 4020],
    [105, 40, 4380],
    [105, 60, 4740],
    [106, 0, 3560],
    [106, 20, 4040],
    [106, 40, 4400],
    [106, 60, 4760],
    [107, 0, 3580],
    [107, 20, 4060],
    [107, 40, 4420],
    [107, 60, 4780],
    [108, 0, 3600],
    [108, 20, 4080],
    [108, 40, 4440],
    [108, 60, 4800],
    [109, 0, 3645],
    [109, 20, 4125],
    [109, 40, 4485],
    [109, 60, 4845],
    [110, 0, 3690],
    [110, 20, 4170],
    [110, 40, 4530],
    [110, 60, 4890],
    [111, 0, 3730],
    [111, 20, 4200],
    [111, 40, 4560],
    [111, 60, 4920],
    [112, 0, 3750],
    [112, 20, 4230],
    [112, 40, 4590],
    [112, 60, 4950],
  ];

  // Labels fixes (sans traduction)
  static const _title = 'Hydration Calculator';
  static const _subtitle = 'Human Water Requirement';
  static const _desc1 =
      'Estimate daily water needs based on weight, exercise, and environment.';
  static const _desc2 =
      'This is an estimate. Adjust for medical conditions and professional advice.';
  static const _weightLabel = 'Body weight';
  static const _minutesLabel = 'Daily exercise';
  static const _minutesUnit = 'minutes';
  static const _envLabel = 'Environment';
  static const _calc = 'Calculate';
  static const _results = 'RESULTS';

  static const _env1 = 'Extreme Heat - Arid Or Desert Conditions';
  static const _env2 = 'Normally Warm Environment';
  static const _env3 = 'Normally Cool Environment';
  static const _env4 = 'Extreme Cold - At/Below Freezing';

  static const _tipsTitle = 'Hydration Tips';
  static const _tip1 = 'Drink regularly throughout the day, not only when thirsty.';
  static const _tip2 = 'Increase intake during exercise and in hot environments.';
  static const _tip3 = 'If you sweat a lot, consider electrolytes (as appropriate).';
  static const _tip4 = 'Watch urine color: pale yellow usually indicates good hydration.';
  static const _tip5 = 'Adjust for altitude, illness, and medications when needed.';
  static const _note1 = 'These values are approximate and can vary from person to person.';
  static const _note2 = 'If you have kidney/heart conditions, consult a healthcare professional.';
  static const _note3 = 'You can split your target into smaller portions across the day.';

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    )..forward();

    for (final c in [kgController, minController, envController]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    kgController.dispose();
    minController.dispose();
    envController.dispose();
    super.dispose();
  }

  void _showValidationError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // -----------------------------
  // NE PAS TOUCHER LA LOGIQUE
  // -----------------------------
  double _mapEnvFactor(String envText) {
    // Même mapping que le select HTML (value="1" ".85" ".68" ".88")
    final envMap = <String, String>{
      _env1: "1",
      _env2: ".85",
      _env3: ".68",
      _env4: ".88",
    };

    final raw = envMap[envText] ??
        ({
          'extreme heat - arid or desert conditions': '1',
          'normally warm environment': '.85',
          'normally cool environment': '.68',
          'extreme cold - at/below freezing': '.88',
          'extreme cold - at, near or below freezing': '.88',
        }[envText.toLowerCase().trim()] ??
            '');

    if (raw.isEmpty) return 0;
    return double.tryParse(raw) ?? 0;
  }

  int? _lookupBaseMl(int kg, int min) {
    for (final row in _hwrTable) {
      if (row[0] == kg && row[1] == min) return row[2];
    }
    return null;
  }

  Future<void> getResult(dynamic kg, dynamic min, dynamic env, BuildContext context) async {
    try {
      setState(() => _isLoading = true);
      HapticFeedback.selectionClick();

      final int? kgVal = int.tryParse(kg.toString().trim());
      final int? minVal = int.tryParse(min.toString().trim());
      final String envText = env.toString();

      if (kgVal == null || minVal == null) {
        _showValidationError("Weight and minutes must be valid numbers.");
        setState(() => ml = oz = ozi = gl = "0");
        return;
      }

      // Plage de kg comme sur le web
      if (kgVal < 27 || kgVal > 112) {
        _showValidationError(
          "Weight must be at least 27 kilograms (60 pounds) and no more than 112 kilograms (247 pounds)! Please correct the entry.",
        );
        setState(() => ml = oz = ozi = gl = "0");
        return;
      }

      // Env doit être selectionné
      final double envFactor = _mapEnvFactor(envText);
      if (envFactor <= 0) {
        _showValidationError("Please select the environmental condition that is applicable.");
        setState(() => ml = oz = ozi = gl = "0");
        return;
      }

      // Minutes (dans le web, ils valident min != "1" ; ici min vient du dropdown 0/20/40/60)
      const allowedMinutes = [0, 20, 40, 60];
      if (!allowedMinutes.contains(minVal)) {
        _showValidationError("Please select the daily exercise level that is applicable.");
        setState(() => ml = oz = ozi = gl = "0");
        return;
      }

      final int? baseMl = _lookupBaseMl(kgVal, minVal);
      if (baseMl == null) {
        _showValidationError("No data found for this weight / minutes combination.");
        setState(() => ml = oz = ozi = gl = "0");
        return;
      }

      // Même calcul que dans le JS :
      // mlEnv = baseMl * env
      final double mlVal = baseMl * envFactor;

      // us oz
      final double ozVal = (33.814022701843 / 1000.0) * mlVal;
      // imp oz
      final double oziVal = (35.18628793111174 / 1000.0) * mlVal;
      // verres = us-oz / 8
      final double glVal = ozVal / 8.0;

      setState(() {
        ml = mlVal % 1 == 0 ? mlVal.toInt().toString() : mlVal.toStringAsFixed(3);
        oz = ozVal.toStringAsFixed(3);
        ozi = oziVal.toStringAsFixed(3);
        gl = glVal.toStringAsFixed(3);
      });

      HapticFeedback.lightImpact();
    } catch (_) {
      _showValidationError('Check your input and try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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

    // ✅ Fix dropdown sur fond blur
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
          // ✅ Background (identique Beep)
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
                          title: _title,
                          onBack: () => Navigator.of(context).maybePop(),
                          onAction: () {
                            HapticFeedback.selectionClick();
                            // Focus sur le formulaire (pas de logique ajoutée)
                            FocusScope.of(context).unfocus();
                          },
                          actionIcon: Icons.water_drop_rounded,
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
                                  physics: const BouncingScrollPhysics(),
                                  slivers: [
                                    SliverToBoxAdapter(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                                        child: _InfoBanner(
                                          title: _subtitle,
                                          subtitle: "Fill inputs then calculate your daily target.",
                                          icon: Icons.opacity_rounded,
                                        ),
                                      ),
                                    ),

                                    // Intro card
                                    SliverToBoxAdapter(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                        child: _Glass(
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
                                                      Icons.water_drop_rounded,
                                                      color: cs.primary.withOpacity(0.92),
                                                      size: 22,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      _subtitle,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: t.textTheme.titleMedium?.copyWith(
                                                        fontWeight: FontWeight.w900,
                                                        color: Colors.white.withOpacity(0.96),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(14),
                                                child: CachedNetworkImage(
                                                  height: 180,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  imageUrl:
                                                      "https://application.sportspedagogue.com/_nuxt/img/analysis.02326f1.jpg",
                                                  placeholder: (context, url) => const SizedBox(
                                                    height: 180,
                                                    child: Center(child: LoadingWidget()),
                                                  ),
                                                  errorWidget: (context, url, error) => const SizedBox(
                                                    height: 180,
                                                    child: Center(child: Icon(Icons.broken_image_rounded)),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                _desc1,
                                                textAlign: TextAlign.center,
                                                style: t.textTheme.bodyMedium?.copyWith(
                                                  height: 1.25,
                                                  color: Colors.white.withOpacity(0.82),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                _desc2,
                                                textAlign: TextAlign.center,
                                                style: t.textTheme.bodySmall?.copyWith(
                                                  height: 1.25,
                                                  color: Colors.white.withOpacity(0.70),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Form card
                                    SliverToBoxAdapter(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                        child: _Glass(
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
                                                    child: Text(
                                                      "Parameters",
                                                      style: t.textTheme.titleMedium?.copyWith(
                                                        fontWeight: FontWeight.w900,
                                                        color: Colors.white.withOpacity(0.96),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),

                                              // Weight
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: CustomInput(
                                                      controller: kgController,
                                                      inputType: InputType.text,
                                                      title: _weightLabel,
                                                      hint: '70',
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  _UnitPill(text: 'kg'),
                                                ],
                                              ),
                                              const SizedBox(height: 12),

                                              // Minutes
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: CustomInput(
                                                      controller: minController,
                                                      inputType: InputType.dropdown,
                                                      title: _minutesLabel,
                                                      dropdownItems: const ["0", "20", "40", "60"],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  _UnitPill(text: _minutesUnit),
                                                ],
                                              ),
                                              const SizedBox(height: 12),

                                              // Environment
                                              CustomInput(
                                                controller: envController,
                                                inputType: InputType.dropdown,
                                                title: _envLabel,
                                                dropdownItems: const [_env1, _env2, _env3, _env4],
                                              ),

                                              const SizedBox(height: 14),

                                              Align(
                                                alignment: Alignment.centerRight,
                                                child: InkWell(
                                                  borderRadius: BorderRadius.circular(14),
                                                  onTap: _canSubmit
                                                      ? () => getResult(
                                                            kgController.text,
                                                            minController.text,
                                                            envController.text,
                                                            context,
                                                          )
                                                      : null,
                                                  child: Opacity(
                                                    opacity: _canSubmit ? 1.0 : 0.55,
                                                    child: _ActionButton(
                                                      icon: Icons.auto_awesome_rounded,
                                                      label: _calc,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Results card
                                    SliverToBoxAdapter(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                        child: _Glass(
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
                                                      Icons.analytics_rounded,
                                                      color: cs.primary.withOpacity(0.92),
                                                      size: 22,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      _results,
                                                      style: t.textTheme.titleMedium?.copyWith(
                                                        fontWeight: FontWeight.w900,
                                                        color: Colors.white.withOpacity(0.96),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              _ResultRowGlass(title: 'Milliliters', value: ml, unit: 'ml', alt: true),
                                              _ResultRowGlass(title: 'US Fluid Ounces', value: oz, unit: 'oz'),
                                              _ResultRowGlass(
                                                title: 'Imperial Fluid Ounces',
                                                value: ozi,
                                                unit: 'fl oz (Imp)',
                                                alt: true,
                                              ),
                                              _ResultRowGlass(title: 'Glasses (8 oz)', value: gl, unit: 'gl'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Tips card
                                    SliverToBoxAdapter(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                                        child: _Glass(
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
                                                      Icons.lightbulb_rounded,
                                                      color: cs.primary.withOpacity(0.92),
                                                      size: 22,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      _tipsTitle,
                                                      style: t.textTheme.titleMedium?.copyWith(
                                                        fontWeight: FontWeight.w900,
                                                        color: Colors.white.withOpacity(0.96),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              const _TipLine(index: 1, emoji: '🚰', text: _tip1),
                                              const _TipLine(index: 2, emoji: '⏱️', text: _tip2, alt: true),
                                              const _TipLine(index: 3, emoji: '🧂', text: _tip3),
                                              const _TipLine(index: 4, emoji: '🎨', text: _tip4, alt: true),
                                              const _TipLine(index: 5, emoji: '🧠', text: _tip5),
                                              const SizedBox(height: 10),
                                              const _NoteLine(emoji: 'ℹ️', text: _note1),
                                              const _NoteLine(emoji: '⚠️', text: _note2),
                                              const _NoteLine(emoji: '🧪', text: _note3),
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

class _ResultRowGlass extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final bool alt;

  const _ResultRowGlass({
    required this.title,
    required this.value,
    required this.unit,
    this.alt = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: (alt ? Colors.white.withOpacity(0.11) : Colors.white.withOpacity(0.08)),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: t.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white.withOpacity(0.78),
              ),
            ),
          ),
          Text(
            '$value $unit',
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

class _TipLine extends StatelessWidget {
  final int index;
  final String emoji;
  final String text;
  final bool alt;

  const _TipLine({
    required this.index,
    required this.emoji,
    required this.text,
    this.alt = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final bg = alt ? Colors.white.withOpacity(0.10) : Colors.white.withOpacity(0.06);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: Colors.white.withOpacity(0.14),
              border: Border.all(color: Colors.white.withOpacity(0.14)),
            ),
            child: Text(
              '$index',
              style: t.textTheme.labelLarge?.copyWith(
                color: Colors.white.withOpacity(0.95),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(emoji, style: t.textTheme.titleMedium),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    text,
                    softWrap: true,
                    style: t.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.82),
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
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

class _NoteLine extends StatelessWidget {
  final String emoji;
  final String text;

  const _NoteLine({required this.emoji, required this.text});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
        color: Colors.white.withOpacity(0.06),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: t.textTheme.titleSmall),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              softWrap: true,
              style: t.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.82),
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
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