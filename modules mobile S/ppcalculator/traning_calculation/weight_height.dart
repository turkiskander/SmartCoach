// lib/feature/ppCalculator/traning_calculation/weight_height.dart
//
// ✅ LOGIQUE INCHANGÉE (BMI = kg / (m^2), parsing, SnackBar, setState)
// ✅ NO localization import
// ✅ Design identique TrainingCalculationView (BgS.jfif + overlay + orbs + glass + header)

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WeightHeight extends StatefulWidget {
  const WeightHeight({super.key});

  @override
  State<WeightHeight> createState() => _WeightHeightState();
}

class _WeightHeightState extends State<WeightHeight> {
  // Controllers (fonctionnel inchangé)
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  // Résultat
  String BMI = "";

  bool _loading = false; // UI only

  /* ====================================================================== */
  /* TEXTS (no localization) */
  /* ====================================================================== */

  static const String _bg = "assets/images/BgS.jfif";

  static const String _title = "Weight & Height";
  static const String _desc =
      "Enter your weight (kg) and height (cm) to calculate your BMI and see the reference table.";

  static const String _weightLabel = "Weight";
  static const String _heightLabel = "Height";
  static const String _weightHint = "e.g. 72";
  static const String _heightHint = "e.g. 175";
  static const String _kg = "kg";
  static const String _cm = "cm";
  static const String _calc = "Calculate";

  static const String _invalid = "Invalid input";

  static const String _resultLeft = "Metric";
  static const String _resultRight = "Value";
  static const String _bmiLabel = "BMI";

  static const String _guideTitle = "BMI Guide";
  static const String _guideCol1 = "Category";
  static const String _guideCol2 = "BMI";

  /* ====================================================================== */
  /* LOGIQUE LOCALE (sans API) */
  /* ====================================================================== */

  /// Web classique :
  ///  - Poids en kg
  ///  - Taille en cm
  ///  - BMI = poids(kg) / (taille(m)^2)
  void getResult(dynamic weight, dynamic height, BuildContext context) {
    if (_loading) return;
    setState(() => _loading = true);

    // Normalisation & parsing (support "72,5" aussi)
    final wStr = weight.toString().trim().replaceAll(',', '.');
    final hStr = height.toString().trim().replaceAll(',', '.');

    final double? w = double.tryParse(wStr);
    final double? hCm = double.tryParse(hStr);

    if (w == null || hCm == null || w <= 0 || hCm <= 0) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(_invalid),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final double hM = hCm / 100.0;
    final double bmi = w / (hM * hM);

    setState(() {
      BMI = bmi.toStringAsFixed(1); // ex: 22.8
      _loading = false;
    });
  }

  @override
  void dispose() {
    weightController.dispose();
    heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final isDark = t.brightness == Brightness.dark;

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
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFF0B0F14)),
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
              child: Column(
                children: [
                  _HeaderModern(
                    title: _title,
                    onBack: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: _Glass(
                      radius: 20,
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Title
                          Text(
                            _title,
                            textAlign: TextAlign.center,
                            style: t.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: Colors.white.withOpacity(0.96),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Desc
                          Text(
                            _desc,
                            textAlign: TextAlign.center,
                            style: t.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.80),
                              height: 1.25,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Inputs (responsive)
                          LayoutBuilder(
                            builder: (context, c) {
                              final wide = c.maxWidth > 780;

                              final weightField = _FancyTextField(
                                controller: weightController,
                                label: _weightLabel,
                                hint: _weightHint,
                                suffix: _kg,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                                ],
                                icon: Icons.monitor_weight_rounded,
                              );

                              final heightField = _FancyTextField(
                                controller: heightController,
                                label: _heightLabel,
                                hint: _heightHint,
                                suffix: _cm,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                                ],
                                icon: Icons.height_rounded,
                              );

                              final btn = _NeoButton(
                                text: _calc,
                                loading: _loading,
                                onTap: () {
                                  debugPrint('[weight_height] → Click CALCUL');
                                  debugPrint(
                                      '[weight_height] inputs: weight=${weightController.text}, height=${heightController.text}');
                                  getResult(
                                    weightController.text,
                                    heightController.text,
                                    context,
                                  );
                                },
                              );

                              if (wide) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(child: weightField),
                                    const SizedBox(width: 12),
                                    Expanded(child: heightField),
                                    const SizedBox(width: 12),
                                    btn,
                                  ],
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  weightField,
                                  const SizedBox(height: 12),
                                  heightField,
                                  const SizedBox(height: 12),
                                  Align(alignment: Alignment.centerLeft, child: btn),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                children: [
                                  _ResultsPanel(
                                    leftTitle: _resultLeft,
                                    rightTitle: _resultRight,
                                    rows: [
                                      _ResultRow(label: _bmiLabel, value: BMI),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _BmiGuideTable(title: _guideTitle),
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
            ),
          ),
        ],
      ),
    );
  }
}

/* ========================================================================== */
/* UI helpers (style TrainingCalculationView) */
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

  const _PillIconButton({required this.icon, required this.onTap});

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

class _FancyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? suffix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final IconData icon;

  const _FancyTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.suffix,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  State<_FancyTextField> createState() => _FancyTextFieldState();
}

class _FancyTextFieldState extends State<_FancyTextField> {
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
          color: focused ? cs.primary.withOpacity(0.55) : Colors.white.withOpacity(0.14),
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
                labelText: widget.label,
                labelStyle: t.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withOpacity(0.75),
                ),
                hintText: widget.hint,
                hintStyle: t.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.55),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (widget.suffix != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                widget.suffix!,
                style: t.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withOpacity(0.82),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NeoButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final bool loading;

  const _NeoButton({
    required this.text,
    required this.onTap,
    required this.loading,
  });

  @override
  State<_NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<_NeoButton> with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtl;

  @override
  void initState() {
    super.initState();
    _pressCtl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
  }

  @override
  void dispose() {
    _pressCtl.dispose();
    super.dispose();
  }

  Future<void> _tap() async {
    if (widget.loading) return;
    await _pressCtl.forward();
    await _pressCtl.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cs.primary.withOpacity(0.95),
                      cs.secondary.withOpacity(0.95),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withOpacity(0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: widget.loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
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
  _ResultRow({required this.label, required this.value});
}

class _ResultsPanel extends StatelessWidget {
  final String leftTitle;
  final String rightTitle;
  final List<_ResultRow> rows;

  const _ResultsPanel({
    required this.leftTitle,
    required this.rightTitle,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.07),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                    leftTitle,
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
                      rightTitle,
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
          // Rows
          for (int i = 0; i < rows.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: i.isOdd ? Colors.white.withOpacity(0.03) : Colors.transparent,
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
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.86),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: const Color(0xFF0EA5E9).withOpacity(0.18),
                          border: Border.all(
                            color: const Color(0xFF22D3EE).withOpacity(0.35),
                          ),
                        ),
                        child: Text(
                          rows[i].value.isEmpty ? '—' : rows[i].value,
                          style: t.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
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
    );
  }
}

class _BmiGuideTable extends StatelessWidget {
  final String title;
  const _BmiGuideTable({required this.title});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    Widget headerCell(String text) => Expanded(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: t.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.86),
            ),
          ),
        );

    Widget cell(String text) => Expanded(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: t.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.82),
            ),
          ),
        );

    Widget row(String c1, String c2, {bool shaded = false}) => Container(
          decoration: BoxDecoration(
            color: shaded ? Colors.white.withOpacity(0.03) : Colors.transparent,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(children: [cell(c1), cell(c2)]),
        );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.07),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
      ),
      width: double.infinity,
      child: Column(
        children: [
          // Header (title + columns)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Text(
                  title,
                  style: t.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.92),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    headerCell(_WeightHeightState._guideCol1),
                    headerCell(_WeightHeightState._guideCol2),
                  ],
                ),
              ],
            ),
          ),

          // Rows (contenu)
          row('Underweight', '< 18.5', shaded: false),
          row('Normal', '18.5 – 24.9', shaded: true),
          row('Overweight', '25.0 – 29.9', shaded: false),
          row('Obesity', '≥ 30.0', shaded: true),
          row('Severe obesity', '≥ 40.0', shaded: false),
        ],
      ),
    );
  }
}