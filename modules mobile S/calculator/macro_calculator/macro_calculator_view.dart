import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

/// Bleu de marque
List<Color> _brandBluesFrom(bool isDark) => isDark
    ? const [Color(0xFF0B2447), Color(0xFF19376D)]
    : const [Color(0xFF1D4ED8), Color(0xFF3B82F6)];

List<Color> _headlineBluesFrom(bool isDark) => isDark
    ? const [Color(0xFF93C5FD), Color(0xFF60A5FA)]
    : const [Color(0xFF1D4ED8), Color(0xFF3B82F6)];

List<Color> _brandBlues(BuildContext c) =>
    _brandBluesFrom(Theme.of(c).brightness == Brightness.dark);

// ignore: unused_element
List<Color> _headlineBlues(BuildContext c) =>
    _headlineBluesFrom(Theme.of(c).brightness == Brightness.dark);

/// Dégradés des macros
List<Color> _carbGradient(bool isDark) => isDark
    ? const [Color(0xFF06B6D4), Color(0xFF22D3EE), Color(0xFF6366F1)]
    : const [Color(0xFF06B6D4), Color(0xFF22D3EE), Color(0xFF3B82F6)];

List<Color> _proteinGradient(bool isDark) => isDark
    ? const [Color(0xFFA7F3D0), Color(0xFF34D399), Color(0xFF10B981)]
    : const [Color(0xFF34D399), Color(0xFF22C55E), Color(0xFF10B981)];

List<Color> _fatGradient(bool isDark) => isDark
    ? const [Color(0xFFFDE68A), Color(0xFFF59E0B), Color(0xFFFB7185)]
    : const [Color(0xFFF59E0B), Color(0xFFFB923C), Color(0xFFEF4444)];

const _stops = [0.0, 0.6, 1.0];

class _TXT {
  static const String screenTitle = "Macro Calculator";
  static const String heroTitle = "Macro Nutrition Split";
  static const String heroSubtitle =
      "Configure your daily calories, meals, and macro distribution.";

  static const String sectionPresets = "Presets";
  static const String sectionGauges = "Gauges";
  static const String sectionInputs = "Inputs";
  static const String sectionResults = "Results";

  static const String macro = "Macros";
  static const String macroDescription =
      "Choose a preset or adjust each macro manually with the gauges. Results update automatically.";

  static const String preset1 = "High carb";
  static const String preset2 = "Moderate";
  static const String preset3 = "Zone diet";
  static const String preset4 = "Low carb";

  static const String carbohydrates = "Carbohydrates";
  static const String protein = "Protein";
  static const String fat = "Fat";

  static const String grams = "g";
  static const String day = "day";
  static const String meal = "meal";

  static const String mealsPerDay = "Meals per day";
  static const String calories = "Calories";

  static const String macroResultsTitle = "Daily Macro Results";
  static const String gramsPerDay = "g/day";
  static const String gramsPerMeal = "g/meal";

  static const String summaryTitle = "Live Summary";
  static const String summarySubtitle =
      "Macros are recalculated instantly from calories and meals.";

  static const String carbShort = "Carbs";
  static const String proteinShort = "Protein";
  static const String fatShort = "Fat";
}

class MacroCalculatorView extends StatefulWidget {
  const MacroCalculatorView({super.key});

  @override
  State<MacroCalculatorView> createState() => _MacroCalculatorViewState();
}

class _MacroCalculatorViewState extends State<MacroCalculatorView>
    with TickerProviderStateMixin {
  static const String _bg = "assets/images/BgS.jfif";

  final ScrollController _scrollController = ScrollController();

  final GlobalKey _presetsKey = GlobalKey();
  final GlobalKey _gaugesKey = GlobalKey();
  final GlobalKey _inputsKey = GlobalKey();
  final GlobalKey _resultsKey = GlobalKey();

  String? _character = "";
  double _volumeValue1 = 50;
  double _volumeValue2 = 50;
  double _volumeValue3 = 50;

  double carbsday = 0, carbsmeal = 0;
  double proteinday = 0, proteinmeal = 0;
  double fatday = 0, fatmeal = 0;

  final TextEditingController mealsPerDay = TextEditingController(text: '1');
  final TextEditingController calories = TextEditingController(text: '1200');

  late final AnimationController _enterCtrl;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    )..forward();
    _recalc();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _enterCtrl.dispose();
    mealsPerDay.dispose();
    calories.dispose();
    super.dispose();
  }

  Future<void> _jumpTo(GlobalKey key) async {
    final ctx = key.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: 0.06,
    );
  }

  void _setSplit(double c, double p, double f) {
    _volumeValue1 = c;
    _volumeValue2 = p;
    _volumeValue3 = f;
    _recalc();
  }

  void _recalc() {
    final cal = double.tryParse(calories.text.trim()) ?? 0;
    final meals = (double.tryParse(mealsPerDay.text.trim()) ?? 1).clamp(1, 99);

    carbsday = (cal * _volumeValue1 / 100) / 4;
    proteinday = (cal * _volumeValue2 / 100) / 4;
    fatday = (cal * _volumeValue3 / 100) / 9;

    carbsmeal = carbsday / meals;
    proteinmeal = proteinday / meals;
    fatmeal = fatday / meals;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isDark = t.brightness == Brightness.dark;
    final cs = t.colorScheme;
    final gaugeAxisColor =
        (isDark ? Colors.white24 : Colors.black12).withOpacity(0.20);

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
                          onPresets: () => _jumpTo(_presetsKey),
                          onGauges: () => _jumpTo(_gaugesKey),
                          onInputs: () => _jumpTo(_inputsKey),
                          onResults: () => _jumpTo(_resultsKey),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: _Glass(
                            radius: 20,
                            padding: EdgeInsets.zero,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: CustomScrollView(
                                controller: _scrollController,
                                physics: const BouncingScrollPhysics(),
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                slivers: [
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(12, 12, 12, 8),
                                      child: _HeroBanner(
                                        title: _TXT.heroTitle,
                                        subtitle: _TXT.heroSubtitle,
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    key: _presetsKey,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _PresetCard(
                                        groupValue: _character,
                                        onPresetSelected: (value) {
                                          setState(() {
                                            _character = value;
                                            switch (value) {
                                              case "60/25/15(High carb)":
                                                _setSplit(60, 25, 15);
                                                break;
                                              case "50/30/20(Moderate)":
                                                _setSplit(50, 30, 20);
                                                break;
                                              case "40/30/30(Zone diet)":
                                                _setSplit(40, 30, 30);
                                                break;
                                              case "25/45/30(Low carb)":
                                                _setSplit(25, 45, 30);
                                                break;
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    key: _gaugesKey,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _GaugeCard(
                                        title: _TXT.carbohydrates,
                                        emoji: "🍚",
                                        value: _volumeValue1,
                                        axisColor: gaugeAxisColor,
                                        gradient: _carbGradient(isDark),
                                        dayValue: carbsday,
                                        mealValue: carbsmeal,
                                        onChanged: (v) {
                                          setState(() {
                                            _volumeValue1 = v;
                                            _recalc();
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _GaugeCard(
                                        title: _TXT.protein,
                                        emoji: "🥩",
                                        value: _volumeValue2,
                                        axisColor: gaugeAxisColor,
                                        gradient: _proteinGradient(isDark),
                                        dayValue: proteinday,
                                        mealValue: proteinmeal,
                                        onChanged: (v) {
                                          setState(() {
                                            _volumeValue2 = v;
                                            _recalc();
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _GaugeCard(
                                        title: _TXT.fat,
                                        emoji: "🧈",
                                        value: _volumeValue3,
                                        axisColor: gaugeAxisColor,
                                        gradient: _fatGradient(isDark),
                                        dayValue: fatday,
                                        mealValue: fatmeal,
                                        onChanged: (v) {
                                          setState(() {
                                            _volumeValue3 = v;
                                            _recalc();
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    key: _inputsKey,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _InputsCard(
                                        mealsPerDay: mealsPerDay,
                                        calories: calories,
                                        onChanged: () => setState(_recalc),
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    key: _resultsKey,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(12, 0, 12, 14),
                                      child: _ResultsCard(
                                        carbsday: carbsday,
                                        carbsmeal: carbsmeal,
                                        proteinday: proteinday,
                                        proteinmeal: proteinmeal,
                                        fatday: fatday,
                                        fatmeal: fatmeal,
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

/// ---------------------------------------------------------------------------
/// Header
/// ---------------------------------------------------------------------------

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
                color: Colors.white.withOpacity(0.96),
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const _PillIconStatic(icon: Icons.pie_chart_rounded),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onPresets;
  final VoidCallback onGauges;
  final VoidCallback onInputs;
  final VoidCallback onResults;

  const _QuickActions({
    required this.onPresets,
    required this.onGauges,
    required this.onInputs,
    required this.onResults,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _NavChip(
            icon: Icons.tune_rounded,
            label: _TXT.sectionPresets,
            onTap: onPresets,
          ),
          const SizedBox(width: 10),
          _NavChip(
            icon: Icons.speed_rounded,
            label: _TXT.sectionGauges,
            onTap: onGauges,
          ),
          const SizedBox(width: 10),
          _NavChip(
            icon: Icons.edit_note_rounded,
            label: _TXT.sectionInputs,
            onTap: onInputs,
          ),
          const SizedBox(width: 10),
          _NavChip(
            icon: Icons.analytics_rounded,
            label: _TXT.sectionResults,
            onTap: onResults,
          ),
        ],
      ),
    );
  }
}

class _NavChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: _Glass(
        radius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: cs.primary.withOpacity(0.92)),
            const SizedBox(width: 8),
            Text(
              label,
              style: t.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white.withOpacity(0.88),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Hero
/// ---------------------------------------------------------------------------

class _HeroBanner extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HeroBanner({
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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withOpacity(0.10),
              border: Border.all(color: Colors.white.withOpacity(0.14)),
            ),
            child: Icon(
              Icons.auto_graph_rounded,
              size: 24,
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
                  style: t.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.96),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: t.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    color: Colors.white.withOpacity(0.74),
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

/// ---------------------------------------------------------------------------
/// Presets
/// ---------------------------------------------------------------------------

class _PresetCard extends StatelessWidget {
  final String? groupValue;
  final ValueChanged<String> onPresetSelected;

  const _PresetCard({
    required this.groupValue,
    required this.onPresetSelected,
  });

  @override
  Widget build(BuildContext context) {
    return _Glass(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _TXT.macroDescription,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.82),
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _RadioPill<String>(
                label: _TXT.preset1,
                value: "60/25/15(High carb)",
                groupValue: groupValue,
                onChanged: (v) => onPresetSelected(v!),
              ),
              _RadioPill<String>(
                label: _TXT.preset2,
                value: "50/30/20(Moderate)",
                groupValue: groupValue,
                onChanged: (v) => onPresetSelected(v!),
              ),
              _RadioPill<String>(
                label: _TXT.preset3,
                value: "40/30/30(Zone diet)",
                groupValue: groupValue,
                onChanged: (v) => onPresetSelected(v!),
              ),
              _RadioPill<String>(
                label: _TXT.preset4,
                value: "25/45/30(Low carb)",
                groupValue: groupValue,
                onChanged: (v) => onPresetSelected(v!),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RadioPill<T> extends StatelessWidget {
  final String label;
  final T value;
  final T? groupValue;
  final ValueChanged<T?> onChanged;

  const _RadioPill({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = value == groupValue;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: selected ? LinearGradient(colors: _brandBlues(context)) : null,
          border: Border.all(
            color: (isDark ? Colors.white24 : Colors.black12).withOpacity(0.14),
          ),
          color: selected
              ? null
              : (isDark ? const Color(0x1AFFFFFF) : const Color(0x10FFFFFF)),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _brandBlues(context).last.withOpacity(0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 18,
              color: selected
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Gauges
/// ---------------------------------------------------------------------------

class _GaugeCard extends StatelessWidget {
  final String title;
  final String emoji;
  final double value;
  final Color axisColor;
  final List<Color> gradient;
  final double dayValue;
  final double mealValue;
  final ValueChanged<double> onChanged;

  const _GaugeCard({
    required this.title,
    required this.emoji,
    required this.value,
    required this.axisColor,
    required this.gradient,
    required this.dayValue,
    required this.mealValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return _Glass(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Text(
            "$emoji $title",
            style: t.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.96),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.26,
            child: SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: 100,
                  startAngle: 180,
                  endAngle: 360,
                  showLabels: false,
                  showTicks: false,
                  radiusFactor: 0.92,
                  axisLineStyle: AxisLineStyle(
                    cornerStyle: CornerStyle.bothFlat,
                    color: axisColor,
                    thickness: 12,
                  ),
                  pointers: <GaugePointer>[
                    RangePointer(
                      value: value,
                      cornerStyle: CornerStyle.bothFlat,
                      width: 12,
                      sizeUnit: GaugeSizeUnit.logicalPixel,
                      gradient: SweepGradient(
                        colors: gradient,
                        stops: _stops,
                      ),
                    ),
                    MarkerPointer(
                      value: value,
                      enableDragging: true,
                      onValueChanged: onChanged,
                      markerHeight: 20,
                      markerWidth: 20,
                      markerType: MarkerType.circle,
                      color: gradient.last,
                      borderWidth: 2,
                      borderColor: Colors.white54,
                    ),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      angle: 90,
                      positionFactor: 0.1,
                      widget: Text(
                        "$emoji $title\n"
                        "${value.ceil()} %\n"
                        "${_TXT.grams}/${_TXT.day}: ${dayValue.ceil()}\n"
                        "${_TXT.grams}/${_TXT.meal}: ${mealValue.ceil()}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: gradient.last,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Inputs
/// ---------------------------------------------------------------------------

class _InputsCard extends StatelessWidget {
  final TextEditingController mealsPerDay;
  final TextEditingController calories;
  final VoidCallback onChanged;

  const _InputsCard({
    required this.mealsPerDay,
    required this.calories,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _Glass(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          _StepperField(
            label: _TXT.mealsPerDay,
            controller: mealsPerDay,
            onMinus: () {
              final x = int.tryParse(mealsPerDay.text) ?? 0;
              if (x > 1) mealsPerDay.text = (x - 1).toString();
              onChanged();
            },
            onPlus: () {
              final x = int.tryParse(mealsPerDay.text) ?? 1;
              mealsPerDay.text = (x + 1).toString();
              onChanged();
            },
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 12),
          _StepperField(
            label: _TXT.calories,
            controller: calories,
            onMinus: () {
              final x = int.tryParse(calories.text) ?? 0;
              if (x > 0) calories.text = (x - 1).toString();
              onChanged();
            },
            onPlus: () {
              final x = int.tryParse(calories.text) ?? 0;
              calories.text = (x + 1).toString();
              onChanged();
            },
            onChanged: (_) => onChanged(),
          ),
        ],
      ),
    );
  }
}

class _StepperField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final ValueChanged<String> onChanged;

  const _StepperField({
    required this.label,
    required this.controller,
    required this.onMinus,
    required this.onPlus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isDark = t.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: t.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: (isDark ? const Color(0x1AFFFFFF) : const Color(0x10FFFFFF)),
            border: Border.all(
              color: (isDark ? Colors.white24 : Colors.black12).withOpacity(0.16),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_rounded),
                onPressed: onMinus,
                splashRadius: 22,
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  onChanged: onChanged,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  style: t.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_rounded),
                onPressed: onPlus,
                splashRadius: 22,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// Results
/// ---------------------------------------------------------------------------

class _ResultsCard extends StatelessWidget {
  final double carbsday;
  final double carbsmeal;
  final double proteinday;
  final double proteinmeal;
  final double fatday;
  final double fatmeal;

  const _ResultsCard({
    required this.carbsday,
    required this.carbsmeal,
    required this.proteinday,
    required this.proteinmeal,
    required this.fatday,
    required this.fatmeal,
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
            _TXT.macroResultsTitle,
            style: t.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.95),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _TXT.summarySubtitle,
            style: t.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.72),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _MacroResultRow(
            label: _TXT.carbShort,
            dayValue: carbsday,
            mealValue: carbsmeal,
            gradient: const [Color(0xFF06B6D4), Color(0xFF3B82F6)],
          ),
          const SizedBox(height: 8),
          _MacroResultRow(
            label: _TXT.proteinShort,
            dayValue: proteinday,
            mealValue: proteinmeal,
            gradient: const [Color(0xFF22C55E), Color(0xFF10B981)],
          ),
          const SizedBox(height: 8),
          _MacroResultRow(
            label: _TXT.fatShort,
            dayValue: fatday,
            mealValue: fatmeal,
            gradient: const [Color(0xFFF59E0B), Color(0xFFEF4444)],
          ),
        ],
      ),
    );
  }
}

class _MacroResultRow extends StatelessWidget {
  final String label;
  final double dayValue;
  final double mealValue;
  final List<Color> gradient;

  const _MacroResultRow({
    required this.label,
    required this.dayValue,
    required this.mealValue,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.10),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(colors: gradient),
            ),
            child: const Icon(
              Icons.insights_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: t.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(0.96),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${dayValue.toStringAsFixed(1)} ${_TXT.gramsPerDay}",
                style: t.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withOpacity(0.90),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "${mealValue.toStringAsFixed(1)} ${_TXT.gramsPerMeal}",
                style: t.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.72),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Base UI
/// ---------------------------------------------------------------------------

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