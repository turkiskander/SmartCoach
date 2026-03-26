// lib/feature/ppCalculator/traning_calculation/kilometer_based.dart
//
// ✅ Design aligné sur HRmax / TrainingCalculationView
// ✅ LOGIQUE calcul INCHANGÉE
// ✅ SANS localization
// ✅ Peut être utilisé en écran standalone (Scaffold) OU appelé depuis ton bottomSheet

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KilometerBased extends StatefulWidget {
  const KilometerBased({super.key});

  @override
  State<KilometerBased> createState() => _KilometerBasedState();
}

class _TXT {
  static const String screenTitle = "Kilometer Based";
  static const String bannerTitle = "Kilometer Based Calculator";
  static const String bannerSubtitle =
      "Enter distance and total time to calculate speed, VMA range and pace per kilometer.";

  static const String distanceLabel = "Distance";
  static const String distanceHint = "e.g. 10";
  static const String distanceSuffix = "km";

  static const String hoursLabel = "Hours";
  static const String hoursHint = "0";
  static const String hoursSuffix = "h";

  static const String minutesLabel = "Minutes";
  static const String minutesHint = "45";
  static const String minutesSuffix = "min";

  static const String secondsLabel = "Seconds";
  static const String secondsHint = "30";
  static const String secondsSuffix = "sec";

  static const String calculate = "Calculate";

  static const String resultTitle = "Results";
  static const String colLabel = "Label";
  static const String colValue = "Value";

  static const String speedLabel = "Speed";
  static const String vmaLabel = "VMA";
  static const String paceLabel = "Pace";

  static const String invalidDistanceTime =
      "Invalid input in distance or time fields.";
  static const String totalTimeError = "Total time must be greater than 0.";
}

class _KilometerBasedState extends State<KilometerBased>
    with TickerProviderStateMixin {
  static const String _bg = "assets/images/BgS.jfif";

  final TextEditingController distanceController = TextEditingController();
  final TextEditingController time_seController = TextEditingController();
  final TextEditingController time_minController = TextEditingController();
  final TextEditingController time_herController = TextEditingController();

  String speed = "";
  String vmainf = "";
  String vmasup = "";
  String pacemin = "";
  String pacesec = "";

  void _computeKilometerBased(BuildContext context) {
    final rawDistance = distanceController.text.trim().replaceAll(',', '.');
    final d = double.tryParse(rawDistance);
    final h = int.tryParse(time_herController.text.trim());
    final m = int.tryParse(time_minController.text.trim());
    final s = int.tryParse(time_seController.text.trim());

    if (d == null || d <= 0 || h == null || m == null || s == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(_TXT.invalidDistanceTime),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final totalSeconds = h * 3600 + m * 60 + s;
    if (totalSeconds <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(_TXT.totalTimeError),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final vitesse = _round1((d / totalSeconds) * 3600);
    final vmaInfVal = _round1((vitesse * 100) / 90);
    final vmaSupVal = _round1((vitesse * 100) / 85);
    final paceMinVal = _mnPerKm(vitesse, 100);
    final paceSecVal = _secPerKm(vitesse, 100);

    setState(() {
      speed = _numToStr(vitesse);
      vmainf = _numToStr(vmaInfVal);
      vmasup = _numToStr(vmaSupVal);
      pacemin = paceMinVal.toString();
      pacesec = paceSecVal.toString();
    });
  }

  double _round1(num x) => (x * 10).round() / 10.0;

  String _numToStr(num value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  int _mnPerKm(double vma, int pourcent) {
    final tpsParKm = _round1(60 / ((vma * pourcent) / 100));
    return tpsParKm.truncate();
  }

  int _secPerKm(double vma, int pourcent) {
    final tpsParKm = _round1(60 / ((vma * pourcent) / 100));
    final mnParKm = tpsParKm.truncate();
    return (60 * (tpsParKm - mnParKm)).truncate();
  }

  @override
  void dispose() {
    distanceController.dispose();
    time_seController.dispose();
    time_minController.dispose();
    time_herController.dispose();
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
                          Colors.black.withOpacity(0.30),
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
              child: Column(
                children: [
                  _HeaderModern(
                    title: _TXT.screenTitle,
                    onBack: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Glass(
                            radius: 20,
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _TXT.bannerTitle,
                                  style: t.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white.withOpacity(0.96),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _TXT.bannerSubtitle,
                                  style: t.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withOpacity(0.72),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _Glass(
                            radius: 20,
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              children: [
                                _InputField(
                                  controller: distanceController,
                                  label: _TXT.distanceLabel,
                                  hint: _TXT.distanceHint,
                                  suffix: _TXT.distanceSuffix,
                                  icon: Icons.route_rounded,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.]'),
                                    ),
                                  ],
                                  onChanged: (_) => setState(() {}),
                                ),
                                const SizedBox(height: 12),
                                LayoutBuilder(
                                  builder: (context, c) {
                                    final wide = c.maxWidth > 700;

                                    final hourField = _InputField(
                                      controller: time_herController,
                                      label: _TXT.hoursLabel,
                                      hint: _TXT.hoursHint,
                                      suffix: _TXT.hoursSuffix,
                                      icon: Icons.schedule_rounded,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      onChanged: (_) => setState(() {}),
                                    );

                                    final minField = _InputField(
                                      controller: time_minController,
                                      label: _TXT.minutesLabel,
                                      hint: _TXT.minutesHint,
                                      suffix: _TXT.minutesSuffix,
                                      icon: Icons.timer_outlined,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      onChanged: (_) => setState(() {}),
                                    );

                                    final secField = _InputField(
                                      controller: time_seController,
                                      label: _TXT.secondsLabel,
                                      hint: _TXT.secondsHint,
                                      suffix: _TXT.secondsSuffix,
                                      icon: Icons.timelapse_rounded,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      onChanged: (_) => setState(() {}),
                                    );

                                    if (wide) {
                                      return Row(
                                        children: [
                                          Expanded(child: hourField),
                                          const SizedBox(width: 12),
                                          Expanded(child: minField),
                                          const SizedBox(width: 12),
                                          Expanded(child: secField),
                                        ],
                                      );
                                    }

                                    return Column(
                                      children: [
                                        hourField,
                                        const SizedBox(height: 12),
                                        minField,
                                        const SizedBox(height: 12),
                                        secField,
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: _PrimaryButton(
                                    text: _TXT.calculate,
                                    onTap: () => _computeKilometerBased(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _Glass(
                            radius: 20,
                            padding: const EdgeInsets.all(14),
                            child: _ResultsTable(
                              title: _TXT.resultTitle,
                              leftHeader: _TXT.colLabel,
                              rightHeader: _TXT.colValue,
                              rows: [
                                _ResultRow(
                                  label: _TXT.speedLabel,
                                  value: speed.isEmpty ? '—' : '$speed km/h',
                                ),
                                _ResultRow(
                                  label: _TXT.vmaLabel,
                                  value: (vmainf.isEmpty || vmasup.isEmpty)
                                      ? '—'
                                      : '$vmainf - $vmasup km/h',
                                ),
                                _ResultRow(
                                  label: _TXT.paceLabel,
                                  value: (pacemin.isEmpty || pacesec.isEmpty)
                                      ? '—'
                                      : '$pacemin min $pacesec sec per km',
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
        ],
      ),
    );
  }
}

/* ========================================================================== */
/* UI helpers */
/* ========================================================================== */

class _HeaderModern extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _HeaderModern({required this.title, required this.onBack});

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

class _InputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? suffix;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.suffix,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
  });

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  final FocusNode _fn = FocusNode();

  @override
  void dispose() {
    _fn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final focused = _fn.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.10),
        border: Border.all(
          color: focused
              ? cs.primary.withOpacity(0.55)
              : Colors.white.withOpacity(0.14),
          width: 1,
        ),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: cs.primary.withOpacity(0.20),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          Icon(widget.icon, size: 20, color: Colors.white.withOpacity(0.75)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              focusNode: _fn,
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              inputFormatters: widget.inputFormatters,
              style: t.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white.withOpacity(0.92),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: widget.label,
                labelStyle: t.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withOpacity(0.72),
                ),
                hintText: widget.hint,
                hintStyle: t.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.55),
                ),
              ),
              onChanged: widget.onChanged,
            ),
          ),
          if (widget.suffix != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                widget.suffix!,
                style: t.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withOpacity(0.80),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.text,
    required this.onTap,
  });

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtl;

  @override
  void initState() {
    super.initState();
    _pressCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
  }

  @override
  void dispose() {
    _pressCtl.dispose();
    super.dispose();
  }

  Future<void> _tap() async {
    await _pressCtl.forward();
    await _pressCtl.reverse();
    HapticFeedback.selectionClick();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return AnimatedBuilder(
      animation: _pressCtl,
      builder: (_, __) {
        final press = Curves.easeOut.transform(_pressCtl.value);
        final scale = 1.0 - press * 0.03;

        return Transform.scale(
          scale: scale,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _tap,
              child: Ink(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cs.primary.withOpacity(0.95),
                      (cs.tertiary == cs.primary ? cs.secondary : cs.tertiary)
                          .withOpacity(0.90),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withOpacity(0.20),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.play_arrow_rounded, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        widget.text,
                        style: t.textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ResultRow {
  final String label;
  final String value;

  _ResultRow({
    required this.label,
    required this.value,
  });
}

class _ResultsTable extends StatelessWidget {
  final String title;
  final String leftHeader;
  final String rightHeader;
  final List<_ResultRow> rows;

  const _ResultsTable({
    required this.title,
    required this.leftHeader,
    required this.rightHeader,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.insights_rounded,
                size: 18, color: cs.primary.withOpacity(0.90)),
            const SizedBox(width: 8),
            Text(
              title,
              style: t.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(0.96),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.06),
            border: Border.all(color: Colors.white.withOpacity(0.10), width: 1),
          ),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        leftHeader,
                        style: t.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withOpacity(0.86),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          rightHeader,
                          style: t.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: Colors.white.withOpacity(0.86),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              for (int i = 0; i < rows.length; i++)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: i.isOdd
                        ? Colors.white.withOpacity(0.03)
                        : Colors.transparent,
                    borderRadius: i == rows.length - 1
                        ? const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          )
                        : BorderRadius.zero,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          rows[i].label,
                          style: t.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withOpacity(0.90),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: cs.primary.withOpacity(0.18),
                              border: Border.all(
                                color: cs.primary.withOpacity(0.35),
                              ),
                            ),
                            child: Text(
                              rows[i].value,
                              style: t.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: Colors.white.withOpacity(0.92),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
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
    final border =
        isDark ? Colors.white.withOpacity(0.10) : Colors.white.withOpacity(0.14);

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
          color: (accent ?? Colors.white.withOpacity(0.92)),
          size: 20,
        ),
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