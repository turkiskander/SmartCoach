// ignore_for_file: unused_element

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ---------------------------------------------------------------------------
/// Brand colors
/// ---------------------------------------------------------------------------

List<Color> _brandBluesFrom(bool isDark) => isDark
    ? const [Color(0xFF0B2447), Color(0xFF19376D)]
    : const [Color(0xFF1D4ED8), Color(0xFF3B82F6)];

List<Color> _headlineBluesFrom(bool isDark) => isDark
    ? const [Color(0xFF93C5FD), Color(0xFF60A5FA)]
    : const [Color(0xFF1D4ED8), Color(0xFF3B82F6)];

List<Color> _brandBlues(BuildContext c) =>
    _brandBluesFrom(Theme.of(c).brightness == Brightness.dark);

List<Color> _headlineBlues(BuildContext c) =>
    _headlineBluesFrom(Theme.of(c).brightness == Brightness.dark);

class _TXT {
  static const String screenTitle = "One Rep Max Tool";
  static const String heroTitle = "1RM Strength Estimator";
  static const String heroSubtitle =
      "Estimate your one-repetition maximum from lifted weight and completed reps.";

  static const String intro =
      "This tool estimates your one rep max using a standard predictive formula. It is useful for strength planning, progression tracking and load prescription.";

  static const String intro2 =
      "Choose your unit, enter the number of repetitions and the lifted weight, then calculate your estimated maximum.";

  static const String unitTitle = "Units";
  static const String kilogram = "Kilogram";
  static const String pounds = "Pounds";

  static const String inputTitle = "Training Inputs";
  static const String reps = "Number of reps";
  static const String weightLifted = "Weight lifted";

  static const String navUnits = "Units";
  static const String navInputs = "Inputs";
  static const String navResult = "Result";
  static const String navLoads = "Loads";

  static const String go = "Calculate";
  static const String yourOneRepMaxIs = "Your one rep max is";

  static const String resultTitle = "Estimated Max";
  static const String resultHint =
      "The result is expressed in the same unit as the entered weight.";
  static const String resultEmpty =
      "Enter your values and press calculate to generate your estimated one rep max.";

  static const String loadsTitle = "Suggested Training Loads";
  static const String loadsSubtitle =
      "Approximate percentages of your estimated one rep max.";

  static const String kgShort = "kg";
  static const String lbShort = "lb";
}

class OneRepMAxToolView extends StatefulWidget {
  const OneRepMAxToolView({super.key});

  @override
  State<OneRepMAxToolView> createState() => _OneRepMAxToolViewState();
}

class _OneRepMAxToolViewState extends State<OneRepMAxToolView>
    with TickerProviderStateMixin {
  static const String _bg = "assets/images/BgS.jfif";

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _unitsKey = GlobalKey();
  final GlobalKey _inputsKey = GlobalKey();
  final GlobalKey _resultKey = GlobalKey();
  final GlobalKey _loadsKey = GlobalKey();

  // ✅ logique conservée
  final double param1 = 1.0278;
  final double param2 = 0.0278;
  final double param3 = 0.75;
  final int maxReps = 10;

  String? _unit = "kg";
  int oneRepMax = 0;

  final TextEditingController _repsCtl = TextEditingController(text: "1");
  final TextEditingController _weightCtl = TextEditingController(text: "0");

  late final AnimationController _enterCtrl;

  int _safeInt(TextEditingController c, {int fallback = 0}) {
    final v = int.tryParse(c.text.trim());
    return v == null ? fallback : v;
  }

  void _calculate() {
    setState(() {
      final reps = _safeInt(_repsCtl, fallback: 1).clamp(1, maxReps);
      final w = _safeInt(_weightCtl, fallback: 0).toDouble();

      if (reps < maxReps) {
        oneRepMax = (w / (param1 - param2 * reps)).ceil();
      } else {
        oneRepMax = (w / param3).ceil();
      }
    });
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
    _scrollController.dispose();
    _enterCtrl.dispose();
    _repsCtl.dispose();
    _weightCtl.dispose();
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

    final unitLabel = _unit == 'lb' ? _TXT.lbShort : _TXT.kgShort;

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
                          onUnits: () => _jumpTo(_unitsKey),
                          onInputs: () => _jumpTo(_inputsKey),
                          onResult: () => _jumpTo(_resultKey),
                          onLoads: () => _jumpTo(_loadsKey),
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
                                  const SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(12, 12, 12, 8),
                                      child: _HeroBanner(
                                        title: _TXT.heroTitle,
                                        subtitle: _TXT.heroSubtitle,
                                      ),
                                    ),
                                  ),
                                  const SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _IntroCard(),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    key: _unitsKey,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _UnitsCard(
                                        unit: _unit,
                                        onChanged: (v) =>
                                            setState(() => _unit = v),
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    key: _inputsKey,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _InputsCard(
                                        repsCtl: _repsCtl,
                                        weightCtl: _weightCtl,
                                        maxReps: maxReps,
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    key: _resultKey,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _ResultCard(
                                        oneRepMax: oneRepMax,
                                        unitLabel: unitLabel,
                                        onCalculate: () {
                                          HapticFeedback.selectionClick();
                                          _calculate();
                                        },
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    key: _loadsKey,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(12, 0, 12, 14),
                                      child: _LoadsCard(
                                        oneRepMax: oneRepMax,
                                        unitLabel: unitLabel,
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
          const _PillIconStatic(icon: Icons.fitness_center_rounded),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onUnits;
  final VoidCallback onInputs;
  final VoidCallback onResult;
  final VoidCallback onLoads;

  const _QuickActions({
    required this.onUnits,
    required this.onInputs,
    required this.onResult,
    required this.onLoads,
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
            icon: Icons.straighten_rounded,
            label: _TXT.navUnits,
            onTap: onUnits,
          ),
          const SizedBox(width: 10),
          _NavChip(
            icon: Icons.edit_note_rounded,
            label: _TXT.navInputs,
            onTap: onInputs,
          ),
          const SizedBox(width: 10),
          _NavChip(
            icon: Icons.analytics_rounded,
            label: _TXT.navResult,
            onTap: onResult,
          ),
          const SizedBox(width: 10),
          _NavChip(
            icon: Icons.donut_large_rounded,
            label: _TXT.navLoads,
            onTap: onLoads,
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
/// Cards
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
              Icons.bolt_rounded,
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

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return _Glass(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Text(
        "${_TXT.intro}\n\n${_TXT.intro2}",
        textAlign: TextAlign.center,
        style: t.textTheme.bodyMedium?.copyWith(
          color: Colors.white.withOpacity(0.82),
          height: 1.35,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _UnitsCard extends StatelessWidget {
  final String? unit;
  final ValueChanged<String?> onChanged;

  const _UnitsCard({
    required this.unit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _Glass(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _RadioPill<String?>(
            label: _TXT.kilogram,
            value: "kg",
            groupValue: unit,
            onChanged: onChanged,
          ),
          _RadioPill<String?>(
            label: _TXT.pounds,
            value: "lb",
            groupValue: unit,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _InputsCard extends StatelessWidget {
  final TextEditingController repsCtl;
  final TextEditingController weightCtl;
  final int maxReps;

  const _InputsCard({
    required this.repsCtl,
    required this.weightCtl,
    required this.maxReps,
  });

  @override
  Widget build(BuildContext context) {
    return _Glass(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _StepperField(
              emoji: '🔢',
              label: _TXT.reps,
              controller: repsCtl,
              min: 1,
              max: maxReps,
              onChanged: (_) {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StepperField(
              emoji: '🧮',
              label: _TXT.weightLifted,
              controller: weightCtl,
              min: 0,
              onChanged: (_) {},
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final int oneRepMax;
  final String unitLabel;
  final VoidCallback onCalculate;

  const _ResultCard({
    required this.oneRepMax,
    required this.unitLabel,
    required this.onCalculate,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return _Glass(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          _PulseButton(
            label: _TXT.go,
            onTap: onCalculate,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: _brandBlues(context).last),
              borderRadius: BorderRadius.circular(14),
              color: Colors.white.withOpacity(0.06),
            ),
            child: Column(
              children: [
                Text(
                  _TXT.resultTitle,
                  style: t.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.95),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  oneRepMax > 0
                      ? "${_TXT.yourOneRepMaxIs}: $oneRepMax $unitLabel"
                      : _TXT.resultEmpty,
                  textAlign: TextAlign.center,
                  style: t.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withOpacity(0.88),
                  ),
                ),
                if (oneRepMax > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    _TXT.resultHint,
                    textAlign: TextAlign.center,
                    style: t.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.68),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadsCard extends StatelessWidget {
  final int oneRepMax;
  final String unitLabel;

  const _LoadsCard({
    required this.oneRepMax,
    required this.unitLabel,
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
            _TXT.loadsTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withOpacity(0.96),
                ),
          ),
          const SizedBox(height: 6),
          Text(
            _TXT.loadsSubtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.72),
                ),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ProgressBadge(
                    value: 50,
                    label: "${(oneRepMax * 0.50).ceil()} $unitLabel",
                  ),
                  _ProgressBadge(
                    value: 55,
                    label: "${(oneRepMax * 0.55).ceil()} $unitLabel",
                  ),
                  _ProgressBadge(
                    value: 60,
                    label: "${(oneRepMax * 0.60).ceil()} $unitLabel",
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ProgressBadge(
                    value: 65,
                    label: "${(oneRepMax * 0.65).ceil()} $unitLabel",
                  ),
                  _ProgressBadge(
                    value: 70,
                    label: "${(oneRepMax * 0.70).ceil()} $unitLabel",
                  ),
                  _ProgressBadge(
                    value: 75,
                    label: "${(oneRepMax * 0.75).ceil()} $unitLabel",
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ProgressBadge(
                    value: 80,
                    label: "${(oneRepMax * 0.80).ceil()} $unitLabel",
                  ),
                  _ProgressBadge(
                    value: 85,
                    label: "${(oneRepMax * 0.85).ceil()} $unitLabel",
                  ),
                  _ProgressBadge(
                    value: 90,
                    label: "${(oneRepMax * 0.90).ceil()} $unitLabel",
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ProgressBadge(
                    value: 95,
                    label: "${(oneRepMax * 0.95).ceil()} $unitLabel",
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// UI helpers
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
            color: (isDark ? Colors.white24 : Colors.black12).withOpacity(0.14),
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

class _StepperField extends StatefulWidget {
  final String label;
  final String emoji;
  final TextEditingController controller;
  final int? min;
  final int? max;
  final ValueChanged<String> onChanged;

  const _StepperField({
    required this.label,
    required this.emoji,
    required this.controller,
    required this.onChanged,
    this.min,
    this.max,
  });

  @override
  State<_StepperField> createState() => _StepperFieldState();
}

class _StepperFieldState extends State<_StepperField> {
  int _safe(String s) => int.tryParse(s.trim()) ?? 0;

  void _dec() {
    var v = _safe(widget.controller.text);
    if (widget.min != null && v <= widget.min!) return;
    widget.controller.text = (v - 1).toString();
    widget.onChanged(widget.controller.text);
    setState(() {});
  }

  void _inc() {
    var v = _safe(widget.controller.text);
    if (widget.max != null && v >= widget.max!) return;
    widget.controller.text = (v + 1).toString();
    widget.onChanged(widget.controller.text);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isDark = t.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "${widget.emoji} ${widget.label}",
          style: t.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
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
                onPressed: _dec,
                splashRadius: 22,
              ),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  onChanged: widget.onChanged,
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
                onPressed: _inc,
                splashRadius: 22,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PulseButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _PulseButton({
    required this.label,
    required this.onTap,
  });

  @override
  State<_PulseButton> createState() => _PulseButtonState();
}

class _PulseButtonState extends State<_PulseButton>
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
        onTapDown: (_) {
          _animateTo(1.0);
        },
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
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
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

/// ---------------------------------------------------------------------------
/// Progress badges
/// ---------------------------------------------------------------------------

List<Color> _gradCyanViolet(bool dark) => dark
    ? const [Color(0xFF22D3EE), Color(0xFF818CF8)]
    : const [Color(0xFF06B6D4), Color(0xFF6366F1)];

List<Color> _gradLimeEmerald(bool dark) => dark
    ? const [Color(0xFFA7F3D0), Color(0xFF10B981)]
    : const [Color(0xFF34D399), Color(0xFF10B981)];

List<Color> _gradAmberOrange(bool dark) => dark
    ? const [Color(0xFFFDE68A), Color(0xFFF59E0B)]
    : const [Color(0xFFF59E0B), Color(0xFFFB923C)];

List<Color> _gradRedRose(bool dark) => dark
    ? const [Color(0xFFFCA5A5), Color(0xFFF43F5E)]
    : const [Color(0xFFEF4444), Color(0xFFE11D48)];

String _tierEmoji(int value) {
  if (value >= 95) return "🏆";
  if (value >= 80) return "🚀";
  if (value >= 65) return "⚙️";
  return "🧪";
}

List<Color> _tierGradient(BuildContext c, int value) {
  final dark = Theme.of(c).brightness == Brightness.dark;
  if (value >= 95) return _gradRedRose(dark);
  if (value >= 80) return _gradAmberOrange(dark);
  if (value >= 65) return _gradLimeEmerald(dark);
  return _gradCyanViolet(dark);
}

class _ProgressBadge extends StatelessWidget {
  final int value;
  final String label;

  const _ProgressBadge({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isDark = t.brightness == Brightness.dark;
    final colors = _tierGradient(context, value);
    final emoji = _tierEmoji(value);

    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: SizedBox(
        width: 92,
        height: 110,
        child: Column(
          children: [
            SizedBox(
              width: 86,
              height: 86,
              child: CustomPaint(
                painter: _RingPainter(
                  percent: value / 100.0,
                  trackColor: (isDark ? Colors.white24 : Colors.black12)
                      .withOpacity(0.25),
                  gradient: SweepGradient(
                    colors: [...colors, colors.first],
                    stops: const [0.0, 0.9, 1.0],
                    startAngle: 0.0,
                    endAngle: 3.14159 * 2,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(emoji, style: t.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        "$value%",
                        style: t.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  final Color trackColor;
  final SweepGradient gradient;

  _RingPainter({
    required this.percent,
    required this.trackColor,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 8.0;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide - stroke) / 2;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = trackColor;
    canvas.drawCircle(center, radius, trackPaint);

    final sweepPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader =
          gradient.createShader(Rect.fromCircle(center: center, radius: radius));

    final startAngle = -3.14159 / 2;
    final sweepAngle = (3.14159 * 2) * percent.clamp(0.0, 1.0);
    final arcRect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(arcRect, startAngle, sweepAngle, false, sweepPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.percent != percent || old.trackColor != trackColor;
}