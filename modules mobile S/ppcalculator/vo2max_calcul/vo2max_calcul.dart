/// lib/feature/ppCalculator/vo2max_calcul/vo2max_calcul.dart
///
/// ✅ LOGIQUE DE CALCUL INCHANGÉE (getResult identique)
/// ✅ Traduction supprimée (no localization) -> remplace intl.* par _TXT
/// ✅ Design identique à BeepIntermittentTrainingView/VMA (BG image + overlay + orbs + header moderne + glass cards)
/// ✅ Tables gardées (mêmes valeurs), juste les libellés trad remplacés par _TXT
///
/// REQUIRED ASSET:
/// - assets/images/BgS.jfif  (déclaré dans pubspec.yaml)

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _TXT {
  // Titles
  static const String screenTitle = "VO2max Calculator";
  static const String bannerTitle = "VO2max (Cooper-like)";
  static const String bannerSubtitle =
      "Enter distance + time. Result is computed locally using the same formula (no API).";

  // Form
  static const String distance = "Distance";
  static const String units = "Units";
  static const String kilometers = "Kilometers";
  static const String miles = "Miles";
  static const String time = "Time";
  static const String hours = "Hours";
  static const String minutes = "Minutes";
  static const String seconds = "Seconds";
  static const String compute = "Calculate";

  // Result
  static const String resultTitle = "Result";
  static const String vo2Label = "VO2max";
  static const String vo2Unit = "ml/min/kg";

  // Table headers
  static const String tableWomen = "Women reference table";
  static const String tableMen = "Men reference table";
  static const String age = "Age";
  static const String veryInsufficient = "Very insufficient";
  static const String insufficient = "Insufficient";
  static const String satisfactory = "Satisfactory";
  static const String good = "Good";
  static const String veryGood = "Very good";
  static const String excellent = "Excellent";

  // Errors
  static const String errDistance = "Distance input is invalid";
  static const String errTime = "Time input is invalid";
  static const String errUnexpected = "Unexpected error, please check your input";
}

class vo2maxCalcul extends StatefulWidget {
  const vo2maxCalcul({super.key});

  @override
  State<vo2maxCalcul> createState() => _vo2maxCalculState();
}

class _vo2maxCalculState extends State<vo2maxCalcul> with TickerProviderStateMixin {
  static const String _bg = "assets/images/BgS.jfif";

  late final AnimationController _enterCtrl;

  final TextEditingController unitsController = TextEditingController(text: _TXT.kilometers);
  final TextEditingController hrsController = TextEditingController();
  final TextEditingController minsController = TextEditingController();
  final TextEditingController secsController = TextEditingController();
  final TextEditingController distController = TextEditingController();

  bool _isLoading = false;
  String vo2 = "0";

  @override
  void initState() {
    super.initState();

    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    )..forward();

    // même esprit que vo2clear() dans le web
    hrsController.text = "0";
    minsController.text = "0";
    secsController.text = "0";

    for (final c in [unitsController, hrsController, minsController, secsController, distController]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    unitsController.dispose();
    hrsController.dispose();
    minsController.dispose();
    secsController.dispose();
    distController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      (unitsController.text.trim().isNotEmpty) &&
      (distController.text.trim().isNotEmpty) &&
      (hrsController.text.trim().isNotEmpty ||
          minsController.text.trim().isNotEmpty ||
          secsController.text.trim().isNotEmpty) &&
      !_isLoading;

  /// -------- LOGIQUE LOCALE (sans API) ----------
  Future<void> getResult(
    dynamic units,
    dynamic hrs,
    dynamic mins,
    dynamic secs,
    dynamic dist,
    BuildContext context,
  ) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    HapticFeedback.selectionClick();

    try {
      // Récup & normalisation texte → double
      final unitsStr = (units ?? '').toString().trim();

      String _norm(dynamic v) => v == null ? '' : v.toString().trim().replaceAll(',', '.');

      final double? hrsVal = double.tryParse(_norm(hrs));
      final double? minsVal = double.tryParse(_norm(mins));
      final double? secsVal = double.tryParse(_norm(secs));
      final double? distVal = double.tryParse(_norm(dist));

      final h = hrsVal ?? 0.0;
      final m = minsVal ?? 0.0;
      final s = secsVal ?? 0.0;

      if (distVal == null || distVal <= 0) {
        _showSnack(context, _TXT.errDistance);
        setState(() => _isLoading = false);
        return;
      }

      // Conversion km/miles → comme dans le web :
      // if (units == "miles") dist = dist * 1.609;
      double distKm = distVal;
      if (unitsStr == _TXT.miles || unitsStr.toLowerCase().contains('mile')) {
        distKm = distKm * 1.609;
      }

      // Temps en minutes
      final double time = h * 60.0 + m + (s / 60.0);

      if (time <= 0) {
        _showSnack(context, _TXT.errTime);
        setState(() => _isLoading = false);
        return;
      }

      // d en m/min
      final double d = (distKm * 1000.0) / time;

      // p, v, vo2 → formules identiques au JS
      final double p = 0.8 +
          0.1894393 * math.exp(-0.012778 * time) +
          0.2989558 * math.exp(-0.1932605 * time);

      final double v = -4.6 + 0.182258 * d + 0.000104 * d * d;

      final double vo2max = v / p;

      setState(() {
        vo2 = vo2max.toString(); // _AnimatedMetric formate en 2 décimales
      });

      HapticFeedback.lightImpact();
      debugPrint('[VO2MAX] local calc → units=$unitsStr, distKm=$distKm, time=$time, d=$d, p=$p, v=$v, vo2=$vo2max');
    } catch (e) {
      debugPrint('❌ [VO2MAX] Local calc error: $e');
      _showSnack(context, _TXT.errUnexpected);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<Map<String, String>> get femaleTable => [
        {
          "Age": _TXT.age,
          "Very insufficient": _TXT.veryInsufficient,
          "Insufficient": _TXT.insufficient,
          "Satisfactory": _TXT.satisfactory,
          "Good": _TXT.good,
          "Very good": _TXT.veryGood,
          "Excellent": _TXT.excellent,
        },
        {
          "Age": "13-19",
          "Very insufficient": "<25.0",
          "Insufficient": "25.0 - 30.9",
          "Satisfactory": "25.0 - 30.9",
          "Good": "35.0 - 38.9",
          "Very good": "39.0 - 41.9",
          "Excellent": ">41.9"
        },
        {
          "Age": "20-29",
          "Very insufficient": "<23.6",
          "Insufficient": "23.6 - 28.9",
          "Satisfactory": "29.0 - 32.9",
          "Good": "33.0 - 36.9",
          "Very good": "37.0 - 41.0",
          "Excellent": ">41.0"
        },
        {
          "Age": "30-39",
          "Very insufficient": "<22.8",
          "Insufficient": "22.8 - 26.9",
          "Satisfactory": "27.0 - 31.4",
          "Good": "31.5 - 35.6",
          "Very good": "35.7 - 40.0",
          "Excellent": ">40.0"
        },
        {
          "Age": "40-49",
          "Very insufficient": "<21.0",
          "Insufficient": "21.0 - 24.4",
          "Satisfactory": "24.5 - 28.9",
          "Good": "29.0 - 32.8",
          "Very good": "32.9 - 36.9",
          "Excellent": ">36.9"
        },
        {
          "Age": "50-59",
          "Very insufficient": "<20.2",
          "Insufficient": "20.2 - 22.7",
          "Satisfactory": "22.8 - 26.9",
          "Good": "27.0 - 31.4",
          "Very good": "31.5 - 35.7",
          "Excellent": ">35.7"
        },
        {
          "Age": "60+",
          "Very insufficient": "<17.5",
          "Insufficient": "17.5 - 20.1",
          "Satisfactory": "20.2 - 24.4",
          "Good": "24.5 - 30.2",
          "Very good": "30.3 - 31.4",
          "Excellent": ">31.4"
        },
      ];

  List<Map<String, String>> get maleTable => [
        {
          "Age": _TXT.age,
          "Very insufficient": _TXT.veryInsufficient,
          "Insufficient": _TXT.insufficient,
          "Satisfactory": _TXT.satisfactory,
          "Good": _TXT.good,
          "Very good": _TXT.veryGood,
          "Excellent": _TXT.excellent,
        },
        {
          "Age": "13-19",
          "Very insufficient": "<35.0",
          "Insufficient": "35.0 - 38.3",
          "Satisfactory": "38.4 - 45.1",
          "Good": "45.2 - 50.9",
          "Very good": "51.0 - 55.9",
          "Excellent": ">55.9"
        },
        {
          "Age": "20-29",
          "Very insufficient": "<33.0",
          "Insufficient": "33.0 - 36.4",
          "Satisfactory": "36.5 - 42.4",
          "Good": "42.5 - 46.4",
          "Very good": "46.5 - 52.4",
          "Excellent": ">52.4"
        },
        {
          "Age": "30-39",
          "Very insufficient": "<31.5",
          "Insufficient": "31.5 - 35.4",
          "Satisfactory": "35.5 - 40.9",
          "Good": "41.0 - 44.9",
          "Very good": "45.0 - 49.4",
          "Excellent": ">49.4"
        },
        {
          "Age": "40-49",
          "Very insufficient": "<30.2",
          "Insufficient": "30.2 - 33.5",
          "Satisfactory": "33.6 - 38.9",
          "Good": "39.0 - 43.7",
          "Very good": "43.8 - 48.0",
          "Excellent": ">48.0"
        },
        {
          "Age": "50-59",
          "Very insufficient": "<26.1",
          "Insufficient": "26.1 - 30.9",
          "Satisfactory": "31.0 - 35.7",
          "Good": "35.8 - 40.9",
          "Very good": "41.0 - 45.3",
          "Excellent": ">45.3"
        },
        {
          "Age": "60+",
          "Very insufficient": "<20.5",
          "Insufficient": "20.5 - 26.0",
          "Satisfactory": "26.1 - 32.2",
          "Good": "32.3 - 36.4",
          "Very good": "36.5 - 44.2",
          "Excellent": ">44.2"
        },
      ];

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
          // ✅ Background image (comme Beep/VMA)
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

          // Orbs
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
                          title: _TXT.screenTitle,
                          onBack: () => Navigator.of(context).maybePop(),
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
                                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                                      child: _InfoBanner(
                                        title: _TXT.bannerTitle,
                                        subtitle: _TXT.bannerSubtitle,
                                      ),
                                    ),
                                  ),

                                  // Form card (distance + units + time)
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
                                                Expanded(
                                                  child: _TextInputField(
                                                    controller: distController,
                                                    label: _TXT.distance,
                                                    hint: _TXT.distance,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Theme(
                                                    data: dropdownTheme,
                                                    child: _DropdownField(
                                                      controller: unitsController,
                                                      label: _TXT.units,
                                                      items: const [_TXT.kilometers, _TXT.miles],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),

                                            Text(
                                              _TXT.time,
                                              style: t.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white.withOpacity(0.90),
                                              ),
                                            ),
                                            const SizedBox(height: 8),

                                            Row(
                                              children: [
                                                Expanded(
                                                  child: _SmallNumberField(
                                                    controller: hrsController,
                                                    label: _TXT.hours,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: _SmallNumberField(
                                                    controller: minsController,
                                                    label: _TXT.minutes,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: _SmallNumberField(
                                                    controller: secsController,
                                                    label: _TXT.seconds,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 16),

                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: InkWell(
                                                borderRadius: BorderRadius.circular(14),
                                                onTap: _canSubmit
                                                    ? () => getResult(
                                                          unitsController.text,
                                                          hrsController.text,
                                                          minsController.text,
                                                          secsController.text,
                                                          distController.text,
                                                          context,
                                                        )
                                                    : null,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(14),
                                                    color: Colors.white.withOpacity(_canSubmit ? 0.12 : 0.08),
                                                    border: Border.all(
                                                      color: Colors.white.withOpacity(_canSubmit ? 0.16 : 0.10),
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
                                                      if (_isLoading)
                                                        const SizedBox(
                                                          height: 16,
                                                          width: 16,
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: Colors.white,
                                                          ),
                                                        )
                                                      else
                                                        Icon(
                                                          Icons.auto_awesome_rounded,
                                                          size: 18,
                                                          color: cs.primary.withOpacity(0.92),
                                                        ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        _TXT.compute,
                                                        style: t.textTheme.labelLarge?.copyWith(
                                                          fontWeight: FontWeight.w900,
                                                          color: Colors.white.withOpacity(_canSubmit ? 0.94 : 0.70),
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
                                    ),
                                  ),

                                  // Result card
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
                                                    border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
                                                  ),
                                                  child: Icon(Icons.flag_rounded, color: cs.primary.withOpacity(0.92), size: 22),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    _TXT.resultTitle,
                                                    style: t.textTheme.titleMedium?.copyWith(
                                                      fontWeight: FontWeight.w900,
                                                      color: Colors.white.withOpacity(0.96),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            _AnimatedMetric(
                                              value: double.tryParse(vo2) ?? 0,
                                              unit: _TXT.vo2Unit,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Women table
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _Glass(
                                        radius: 18,
                                        padding: const EdgeInsets.all(14),
                                        child: _FancyTable(
                                          title: _TXT.tableWomen,
                                          emoji: '👩',
                                          rows: femaleTable,
                                          isDark: isDark,
                                          headerGradient: const [Color(0xFF06B6D4), Color(0xFF3B82F6)],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Men table
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                                      child: _Glass(
                                        radius: 18,
                                        padding: const EdgeInsets.all(14),
                                        child: _FancyTable(
                                          title: _TXT.tableMen,
                                          emoji: '👨',
                                          rows: maleTable,
                                          isDark: isDark,
                                          headerGradient: const [Color(0xFF06B6D4), Color(0xFF3B82F6)],
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
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
/* UI kit (identique style Beep/VMA) */
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
        ],
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
              border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
            ),
            child: Icon(Icons.timer_rounded, color: cs.primary.withOpacity(0.92), size: 22),
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

class _TextInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;

  const _TextInputField({
    required this.controller,
    required this.label,
    required this.hint,
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
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              borderSide: BorderSide(color: cs.primary.withOpacity(0.85), width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final List<String> items;

  const _DropdownField({
    required this.controller,
    required this.label,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

    final current = items.contains(controller.text) ? controller.text : items.first;

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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white.withOpacity(0.10),
            border: Border.all(color: Colors.white.withOpacity(0.14)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: current,
              isExpanded: true,
              dropdownColor: Theme.of(context).canvasColor,
              icon: Icon(Icons.expand_more_rounded, color: Colors.white.withOpacity(0.90)),
              style: t.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(0.96),
              ),
              onChanged: (v) {
                if (v == null) return;
                controller.text = v;
                HapticFeedback.selectionClick();
              },
              items: items
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(e, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _SmallNumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _SmallNumberField({
    required this.controller,
    required this.label,
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
              borderSide: BorderSide(color: cs.primary.withOpacity(0.85), width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}

class _FancyTable extends StatelessWidget {
  final String title;
  final String emoji;
  final List<Map<String, String>> rows;
  final List<Color> headerGradient;
  final bool isDark;

  const _FancyTable({
    required this.title,
    required this.emoji,
    required this.rows,
    required this.headerGradient,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();

    final headers = rows.first.keys.toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        const double minCol = 120;
        const double maxCol = 220;
        double colW = constraints.maxWidth / headers.length;
        colW = colW.clamp(minCol, maxCol);
        final totalW = colW * headers.length;

        Widget buildHeader() {
          return Container(
            width: totalW,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: headerGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: headers
                  .map(
                    (h) => SizedBox(
                      width: colW,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        child: Text(
                          h,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          );
        }

        Widget buildRow(Map<String, String> row, bool even) {
          return Container(
            width: totalW,
            color: even
                ? (isDark ? const Color(0x0FFFFFFF) : const Color(0x08FFFFFF))
                : Colors.transparent,
            child: Row(
              children: headers
                  .map(
                    (h) => SizedBox(
                      width: colW,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        child: Text(
                          row[h] ?? '',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isDark ? Colors.white70 : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          foreground: Paint()
                            ..shader = LinearGradient(
                              colors: headerGradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(const Rect.fromLTWH(0, 0, 300, 40)),
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                children: [
                  SingleChildScrollView(scrollDirection: Axis.horizontal, child: buildHeader()),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: List.generate(rows.length - 1, (i) => buildRow(rows[i + 1], i.isEven)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AnimatedMetric extends StatelessWidget {
  final double value;
  final String unit;

  const _AnimatedMetric({
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => Column(
        children: [
          Text(
            v.toStringAsFixed(2),
            textAlign: TextAlign.center,
            style: t.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.0,
              color: Colors.white.withOpacity(0.96),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            unit,
            style: t.textTheme.titleMedium?.copyWith(
              color: Colors.white.withOpacity(0.72),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
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