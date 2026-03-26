import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class CaloriesCalculatorView extends StatefulWidget {
  const CaloriesCalculatorView({super.key});

  @override
  State<CaloriesCalculatorView> createState() => _CaloriesCalculatorViewState();
}

class _TXT {
  static const String screenTitle = "Calories Calculator";

  static const String navOverview = "Overview";
  static const String navBody = "Body";
  static const String navGoals = "Goals";
  static const String navResults = "Results";

  static const String heroTitle = "Daily calorie estimator";
  static const String heroSubtitle =
      "Adjust your body metrics, choose your goal and activity, then calculate your daily calories.";

  static const String intro =
      "This calculator estimates basal metabolic rate and daily calories using the same formula flow as your original screen.";

  static const String metric = "Metric";
  static const String imperial = "Imperial";
  static const String male = "Male";
  static const String female = "Female";

  static const String units = "Units";
  static const String sex = "Sex";
  static const String height = "Height";
  static const String weight = "Weight";
  static const String age = "Age";

  static const String centimeters = "cm";
  static const String feet = "ft";
  static const String kilogram = "kg";
  static const String pounds = "lb";
  static const String years = "years";

  static const String bodyMetrics = "Body metrics";
  static const String goalsSection = "Goal & activity";
  static const String resultsSection = "Results";

  static const String weightGoal = "Weight goal";
  static const String activityLevel = "Activity level";
  static const String calculate = "Calculate";

  static const String resultCalories = "Calories result";
  static const String calories = "calories";
  static const String bmr = "BMR";

  static const String quickGuide = "Guide";
  static const String quickResults = "Results";
  static const String quickSections = "4 sections";

  static const String goal1 = "Lose 2 Pounds per Week";
  static const String goal2 = "Lose 1.5 Pounds per Week";
  static const String goal3 = "Lose 1 Pound per Week";
  static const String goal4 = "Lose 0.5 Pound per Week";
  static const String goal5 = "Stay the Same Weight";
  static const String goal6 = "Gain 0.5 Pound per Week";
  static const String goal7 = "Gain 1 Pound per Week";
  static const String goal8 = "Gain 1.5 Pounds per Week";
  static const String goal9 = "Gain 2 Pounds per Week";

  static const String act1 = "Little to no exercise";
  static const String act2 = "Light exercise (1-3 days per week)";
  static const String act3 = "Moderate exercise (3-5 days per week)";
  static const String act4 = "Heavy exercise (6-7 days per week)";
  static const String act5 =
      "Very heavy exercise (twice per day, extra heavy workouts)";

  static const String noResultTitle = "No calculation yet";
  static const String noResultText =
      "Set your metrics, choose your goal and activity level, then calculate your daily calories.";
}

/// —— Palettes —— ///
List<Color> _brandBluesFrom(bool isDark) => isDark
    ? const [Color(0xFF0B2447), Color(0xFF19376D)]
    : const [Color(0xFF1D4ED8), Color(0xFF3B82F6)];

List<Color> _headlineBluesFrom(bool isDark) => isDark
    ? const [Color(0xFF93C5FD), Color(0xFF60A5FA)]
    : const [Color(0xFF1D4ED8), Color(0xFF3B82F6)];

List<Color> _brandBlues(BuildContext ctx) =>
    _brandBluesFrom(Theme.of(ctx).brightness == Brightness.dark);

List<Color> _headlineBlues(BuildContext ctx) =>
    _headlineBluesFrom(Theme.of(ctx).brightness == Brightness.dark);

List<Color> _heightGradient(bool isDark) => isDark
    ? const [Color(0xFF22D3EE), Color(0xFF818CF8), Color(0xFFF472B6)]
    : const [Color(0xFF06B6D4), Color(0xFF6366F1), Color(0xFFEC4899)];

List<Color> _weightGradient(bool isDark) => isDark
    ? const [Color(0xFFA7F3D0), Color(0xFF34D399), Color(0xFFF59E0B)]
    : const [Color(0xFF10B981), Color(0xFF22C55E), Color(0xFFF59E0B)];

List<Color> _ageGradient(bool isDark) => isDark
    ? const [Color(0xFFFDE68A), Color(0xFFF59E0B), Color(0xFFFB7185)]
    : const [Color(0xFFF59E0B), Color(0xFFFB923C), Color(0xFFEF4444)];

const List<double> _gaugeStops = [0.0, 0.6, 1.0];

class _CaloriesCalculatorViewState extends State<CaloriesCalculatorView>
    with TickerProviderStateMixin {
  static const String _bg = "assets/images/BgS.jfif";

  late final AnimationController _enterCtrl;
  late final PageController _pageController;

  int _pageIndex = 0;

  String? _goal;
  String? _activity;

  int goalControllerValue = 0;
  double activityControllerValue = 0;
  double bmr = 0;
  double calories = 0;

  double _volumeValue1 = 50; // height
  double _volumeValue2 = 50; // weight
  double _volumeValue3 = 18; // age

  double heigthMinMetric = 50, heigthMaxMetric = 220;
  double heigthMinImperial = 1.7, heigthMaxImperial = 7.2;
  double weightMinMetric = 0, weightMaxMetric = 300;
  double weightMinImperial = 0, weightMaxImperial = 600;

  String? _character = _TXT.metric;
  String? sex = _TXT.male;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    )..forward();
    _pageController = PageController();

    _goal = _TXT.goal5;
    _activity = _TXT.act1;
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    HapticFeedback.selectionClick();
    setState(() => _pageIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _calculate() {
    setState(() {
      switch (_goal) {
        case _TXT.goal1:
          goalControllerValue = -1000;
          break;
        case _TXT.goal2:
          goalControllerValue = -750;
          break;
        case _TXT.goal3:
          goalControllerValue = -500;
          break;
        case _TXT.goal4:
          goalControllerValue = -250;
          break;
        case _TXT.goal5:
          goalControllerValue = 0;
          break;
        case _TXT.goal6:
          goalControllerValue = 250;
          break;
        case _TXT.goal7:
          goalControllerValue = 500;
          break;
        case _TXT.goal8:
          goalControllerValue = 750;
          break;
        case _TXT.goal9:
          goalControllerValue = 1000;
          break;
        default:
          goalControllerValue = 0;
      }

      switch (_activity) {
        case _TXT.act1:
          activityControllerValue = 1.2;
          break;
        case _TXT.act2:
          activityControllerValue = 1.375;
          break;
        case _TXT.act3:
          activityControllerValue = 1.55;
          break;
        case _TXT.act4:
          activityControllerValue = 1.725;
          break;
        case _TXT.act5:
          activityControllerValue = 1.9;
          break;
        default:
          activityControllerValue = 1.2;
      }

      if (sex == _TXT.male) {
        bmr = 10 * _volumeValue2 + 6.25 * _volumeValue1 - 5 * _volumeValue3 + 5;
      } else {
        bmr = 10 * _volumeValue2 +
            6.25 * _volumeValue1 -
            5 * _volumeValue3 -
            161;
      }

      calories = bmr * activityControllerValue + bmr + goalControllerValue;
    });

    _goToPage(3);
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
                          onResults: () => _goToPage(3),
                        ),
                        const SizedBox(height: 12),
                        _QuickActions(
                          onGuide: () => _goToPage(0),
                          onResults: () => _goToPage(3),
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
                                  _buildOverviewPage(context),
                                  _buildBodyPage(context),
                                  _buildGoalsPage(context),
                                  _buildResultsPage(context),
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

  Widget _buildOverviewPage(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: const _InfoBanner(
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
                _TXT.intro,
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
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: _Glass(
              radius: 18,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _SectionHead(
                    icon: Icons.settings_suggest_rounded,
                    title: _TXT.units,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _RadioPill<String?>(
                        label: _TXT.imperial,
                        value: _TXT.imperial,
                        groupValue: _character,
                        onChanged: (v) => setState(() => _character = v),
                      ),
                      const SizedBox(width: 10),
                      _RadioPill<String?>(
                        label: _TXT.metric,
                        value: _TXT.metric,
                        groupValue: _character,
                        onChanged: (v) => setState(() => _character = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _SectionHead(
                    icon: Icons.person_rounded,
                    title: _TXT.sex,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _RadioPill<String?>(
                        label: _TXT.male,
                        value: _TXT.male,
                        groupValue: sex,
                        onChanged: (v) => setState(() => sex = v),
                      ),
                      const SizedBox(width: 10),
                      _RadioPill<String?>(
                        label: _TXT.female,
                        value: _TXT.female,
                        groupValue: sex,
                        onChanged: (v) => setState(() => sex = v),
                      ),
                    ],
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
                  child: _StatCard(
                    label: _TXT.bmr,
                    value: bmr > 0 ? bmr.ceil().toString() : "—",
                    icon: Icons.local_fire_department_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    label: _TXT.resultCalories,
                    value: calories > 0 ? calories.ceil().toString() : "—",
                    icon: Icons.bolt_rounded,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBodyPage(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gaugeAxisColor =
        (isDark ? Colors.white24 : Colors.black12).withOpacity(0.20);

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
                    icon: Icons.straighten_rounded,
                    title: _TXT.bodyMetrics,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.25,
                    child: SfRadialGauge(
                      axes: <RadialAxis>[
                        RadialAxis(
                          minimum: _character == _TXT.metric
                              ? heigthMinMetric
                              : heigthMinImperial,
                          maximum: _character == _TXT.metric
                              ? heigthMaxMetric
                              : heigthMaxImperial,
                          startAngle: 180,
                          endAngle: 360,
                          showLabels: false,
                          showTicks: false,
                          radiusFactor: 0.92,
                          axisLineStyle: AxisLineStyle(
                            cornerStyle: CornerStyle.bothFlat,
                            color: gaugeAxisColor,
                            thickness: 12,
                          ),
                          pointers: <GaugePointer>[
                            RangePointer(
                              value: _volumeValue1,
                              cornerStyle: CornerStyle.bothFlat,
                              width: 12,
                              sizeUnit: GaugeSizeUnit.logicalPixel,
                              gradient: SweepGradient(
                                colors: _heightGradient(isDark),
                                stops: _gaugeStops,
                              ),
                            ),
                            MarkerPointer(
                              value: _volumeValue1,
                              enableDragging: true,
                              onValueChanged: (double v) =>
                                  setState(() => _volumeValue1 = v),
                              markerHeight: 20,
                              markerWidth: 20,
                              markerType: MarkerType.circle,
                              color: _heightGradient(isDark).last,
                              borderWidth: 2,
                              borderColor: Colors.white54,
                            ),
                          ],
                          annotations: <GaugeAnnotation>[
                            GaugeAnnotation(
                              angle: 90,
                              positionFactor: 0.1,
                              widget: Text(
                                _character == _TXT.metric
                                    ? "📏 ${_TXT.height}\n${_volumeValue1.ceil()} ${_TXT.centimeters}"
                                    : "📏 ${_TXT.height}\n${_volumeValue1.toStringAsFixed(1)} ${_TXT.feet}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: _heightGradient(isDark).last,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.25,
                    child: SfRadialGauge(
                      axes: <RadialAxis>[
                        RadialAxis(
                          minimum: _character == _TXT.metric
                              ? weightMinMetric
                              : weightMinImperial,
                          maximum: _character == _TXT.metric
                              ? weightMaxMetric
                              : weightMaxImperial,
                          startAngle: 180,
                          endAngle: 360,
                          showLabels: false,
                          showTicks: false,
                          radiusFactor: 0.92,
                          axisLineStyle: AxisLineStyle(
                            cornerStyle: CornerStyle.bothFlat,
                            color: gaugeAxisColor,
                            thickness: 12,
                          ),
                          pointers: <GaugePointer>[
                            RangePointer(
                              value: _volumeValue2,
                              cornerStyle: CornerStyle.bothFlat,
                              width: 12,
                              sizeUnit: GaugeSizeUnit.logicalPixel,
                              gradient: SweepGradient(
                                colors: _weightGradient(isDark),
                                stops: _gaugeStops,
                              ),
                            ),
                            MarkerPointer(
                              value: _volumeValue2,
                              enableDragging: true,
                              onValueChanged: (double v) =>
                                  setState(() => _volumeValue2 = v),
                              markerHeight: 20,
                              markerWidth: 20,
                              markerType: MarkerType.circle,
                              color: _weightGradient(isDark).last,
                              borderWidth: 2,
                              borderColor: Colors.white54,
                            ),
                          ],
                          annotations: <GaugeAnnotation>[
                            GaugeAnnotation(
                              angle: 90,
                              positionFactor: 0.1,
                              widget: Text(
                                _character == _TXT.metric
                                    ? "⚖️ ${_TXT.weight}\n${_volumeValue2.ceil()} ${_TXT.kilogram}"
                                    : "⚖️ ${_TXT.weight}\n${_volumeValue2.ceil()} ${_TXT.pounds}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: _weightGradient(isDark).last,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.25,
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
                            color: gaugeAxisColor,
                            thickness: 12,
                          ),
                          pointers: <GaugePointer>[
                            RangePointer(
                              value: _volumeValue3,
                              cornerStyle: CornerStyle.bothFlat,
                              width: 12,
                              sizeUnit: GaugeSizeUnit.logicalPixel,
                              gradient: SweepGradient(
                                colors: _ageGradient(isDark),
                                stops: _gaugeStops,
                              ),
                            ),
                            MarkerPointer(
                              value: _volumeValue3,
                              enableDragging: true,
                              onValueChanged: (double v) =>
                                  setState(() => _volumeValue3 = v),
                              markerHeight: 20,
                              markerWidth: 20,
                              markerType: MarkerType.circle,
                              color: _ageGradient(isDark).last,
                              borderWidth: 2,
                              borderColor: Colors.white54,
                            ),
                          ],
                          annotations: <GaugeAnnotation>[
                            GaugeAnnotation(
                              angle: 90,
                              positionFactor: 0.1,
                              widget: Text(
                                "🕒 ${_TXT.age}\n${_volumeValue3.ceil()} ${_TXT.years}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: _ageGradient(isDark).last,
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
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsPage(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            child: _Glass(
              radius: 18,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _SectionHead(
                    icon: Icons.track_changes_rounded,
                    title: _TXT.goalsSection,
                  ),
                  const SizedBox(height: 12),
                  _ModernDropdownField(
                    label: _TXT.weightGoal,
                    value: _goal,
                    items: const [
                      _TXT.goal1,
                      _TXT.goal2,
                      _TXT.goal3,
                      _TXT.goal4,
                      _TXT.goal5,
                      _TXT.goal6,
                      _TXT.goal7,
                      _TXT.goal8,
                      _TXT.goal9,
                    ],
                    onChanged: (v) => setState(() => _goal = v),
                  ),
                  const SizedBox(height: 12),
                  _ModernDropdownField(
                    label: _TXT.activityLevel,
                    value: _activity,
                    items: const [
                      _TXT.act1,
                      _TXT.act2,
                      _TXT.act3,
                      _TXT.act4,
                      _TXT.act5,
                    ],
                    onChanged: (v) => setState(() => _activity = v),
                  ),
                  const SizedBox(height: 16),
                  _ActionButton(
                    label: _TXT.calculate,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      _calculate();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsPage(BuildContext context) {
    final hasResult = calories > 0 || bmr > 0;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        if (!hasResult)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: const _Glass(
                radius: 18,
                padding: EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SectionHead(
                      icon: Icons.info_outline_rounded,
                      title: _TXT.noResultTitle,
                    ),
                    SizedBox(height: 10),
                    _BodyText(_TXT.noResultText),
                  ],
                ),
              ),
            ),
          )
        else
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
                      title: _TXT.resultsSection,
                    ),
                    const SizedBox(height: 12),
                    _ResultLine(
                      label: _TXT.bmr,
                      value: "${bmr.ceil()} ${_TXT.calories}",
                    ),
                    _ResultLine(
                      label: _TXT.resultCalories,
                      value: "${calories.ceil()} ${_TXT.calories}",
                      highlight: true,
                    ),
                    _ResultLine(
                      label: _TXT.weightGoal,
                      value: _goal ?? "—",
                    ),
                    _ResultLine(
                      label: _TXT.activityLevel,
                      value: _activity ?? "—",
                    ),
                    _ResultLine(
                      label: _TXT.sex,
                      value: sex ?? "—",
                    ),
                    _ResultLine(
                      label: _TXT.units,
                      value: _character ?? "—",
                    ),
                  ],
                ),
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
            child: const _Glass(
              radius: 18,
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionHead(
                    icon: Icons.lightbulb_outline_rounded,
                    title: "Notes",
                  ),
                  SizedBox(height: 10),
                  _BodyText(
                    "This version keeps the original formula flow from your screen. Metric and imperial display modes are preserved as in your original logic.",
                  ),
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
/* Widgets */
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
  final VoidCallback onGuide;
  final VoidCallback onResults;

  const _QuickActions({
    required this.onGuide,
    required this.onResults,
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
                  Icons.dashboard_customize_rounded,
                  size: 18,
                  color: cs.primary.withOpacity(0.92),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "${_TXT.quickGuide} • ${_TXT.quickSections}",
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
            onResults();
          },
          child: _Glass(
            radius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.analytics_rounded,
                  size: 18,
                  color: cs.primary.withOpacity(0.92),
                ),
                const SizedBox(width: 8),
                Text(
                  _TXT.quickResults,
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
    const items = [
      _NavItemData(icon: Icons.home_rounded, label: _TXT.navOverview),
      _NavItemData(icon: Icons.straighten_rounded, label: _TXT.navBody),
      _NavItemData(icon: Icons.flag_rounded, label: _TXT.navGoals),
      _NavItemData(icon: Icons.analytics_rounded, label: _TXT.navResults),
    ];

    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (_, i) {
          final item = items[i];
          return _NavPill(
            icon: item.icon,
            label: item.label,
            selected: i == currentIndex,
            onTap: () => onTap(i),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: items.length,
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;

  const _NavItemData({
    required this.icon,
    required this.label,
  });
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

class _ModernDropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _ModernDropdownField({
    required this.label,
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
          iconEnabledColor: Colors.white.withOpacity(0.90),
          style: t.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white.withOpacity(0.96),
          ),
          items: items
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(
                    e,
                    overflow: TextOverflow.ellipsis,
                    style: t.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.96),
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
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
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: selected ? LinearGradient(colors: _brandBlues(context)) : null,
          border: Border.all(
            color:
                (isDark ? Colors.white24 : Colors.black12).withOpacity(0.14),
          ),
          color: selected
              ? null
              : (isDark ? const Color(0x1AFFFFFF) : const Color(0x10FFFFFF)),
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
    final blues = _brandBlues(context);

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
            final blur = 10.0 + (10.0 * v);
            final spread = 0.0 + (2.0 * v);

            return Transform.scale(
              scale: scale,
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: blues,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: blues.last.withOpacity(0.50 * (0.3 + 0.7 * v)),
                      blurRadius: blur,
                      spreadRadius: spread,
                      offset: const Offset(0, 6),
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

class _ResultLine extends StatelessWidget {
  final String label;
  final Object? value;
  final bool highlight;

  const _ResultLine({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    if (value == null) return const SizedBox.shrink();

    final t = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: highlight
            ? cs.primary.withOpacity(0.18)
            : Colors.white.withOpacity(0.10),
        border: Border.all(
          color: highlight
              ? cs.primary.withOpacity(0.28)
              : Colors.white.withOpacity(0.12),
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
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              "$value",
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: t.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(0.96),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
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

class _BodyText extends StatelessWidget {
  final String text;
  final TextAlign align;

  const _BodyText(this.text, {this.align = TextAlign.start});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Text(
      text,
      textAlign: align,
      style: t.textTheme.bodyMedium?.copyWith(
        color: Colors.white.withOpacity(0.80),
        height: 1.38,
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