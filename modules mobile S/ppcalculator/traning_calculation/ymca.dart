// lib/feature/ppCalculator/traning_calculation/ymca.dart
//
// ✅ LOGIQUE INCHANGÉE (formule YMCA + conversions + validations + setState)
// ✅ NO localization import (removed)
// ✅ Design identique TrainingCalculationView (BgS.jfif + overlay + orbs + glass + header)

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Ymca extends StatefulWidget {
  const Ymca({super.key});

  @override
  State<Ymca> createState() => _YmcaState();
}

class _YmcaState extends State<Ymca> {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController waistController = TextEditingController();
  final TextEditingController sexController = TextEditingController();

  String percentage = "";
  bool _loading = false;

  /* ===================== TEXTS (no localization) ====================== */

  static const String _bg = "assets/images/BgS.jfif";

  static const String _title = "YMCA";
  static const String _desc =
      "Choose sex, enter weight and waist, then calculate body fat percentage (YMCA method).";

  static const String _male = "Male";
  static const String _female = "Female";

  static const String _sexLabel = "Sex";
  static const String _weightLabel = "Weight";
  static const String _waistLabel = "Waist";

  static const String _weightHint = "e.g. 72";
  static const String _waistHint = "e.g. 82";

  static const String _kg = "kg";
  static const String _cm = "cm";
  static const String _calc = "Calculate";

  static const String _invalid = "Invalid input";

  static const String _resultLeft = "Metric";
  static const String _resultRight = "Value";
  static const String _bodyFat = "Body fat";

  /* ===================== LOGIQUE (inchangée) ====================== */

  void getResult(
    dynamic weight,
    dynamic waist,
    dynamic sex,
    BuildContext context,
  ) {
    if (_loading) return;
    setState(() => _loading = true);

    final wStr = weight.toString().trim().replaceAll(',', '.');
    final waistStr = waist.toString().trim().replaceAll(',', '.');

    final double? wKg = double.tryParse(wStr);
    final double? waistCm = double.tryParse(waistStr);

    final bool isMale = sex == _male;

    if (wKg == null ||
        waistCm == null ||
        wKg <= 0 ||
        waistCm <= 0 ||
        (!isMale && sex != _female)) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(_invalid),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final double weightLb = wKg * 2.20462;
    final double waistIn = waistCm / 2.54;

    final double constant = isMale ? 98.42 : 76.76;
    final double fatMassLb =
        (waistIn * 4.15) - (weightLb * 0.082) - constant;
    double bodyFatPercent = (fatMassLb / weightLb) * 100.0;

    if (bodyFatPercent.isNaN || bodyFatPercent.isInfinite) {
      bodyFatPercent = 0;
    }
    if (bodyFatPercent < 0) bodyFatPercent = 0;

    setState(() {
      percentage = bodyFatPercent.toStringAsFixed(1);
      _loading = false;
    });
  }

  @override
  void dispose() {
    weightController.dispose();
    waistController.dispose();
    sexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final isDark = t.brightness == Brightness.dark;

    if (sexController.text.isEmpty) sexController.text = _male;

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
                          Text(
                            _title,
                            textAlign: TextAlign.center,
                            style: t.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: Colors.white.withOpacity(0.96),
                            ),
                          ),
                          const SizedBox(height: 8),
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

                          LayoutBuilder(
                            builder: (context, c) {
                              final wide = c.maxWidth > 900;

                              final sexField = _FancyDropdown(
                                controller: sexController,
                                label: _sexLabel,
                                items: const [_male, _female],
                              );

                              final weightField = _FancyTextField(
                                controller: weightController,
                                label: _weightLabel,
                                hint: _weightHint,
                                suffix: _kg,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}'),
                                  ),
                                ],
                                icon: Icons.monitor_weight_rounded,
                              );

                              final waistField = _FancyTextField(
                                controller: waistController,
                                label: _waistLabel,
                                hint: _waistHint,
                                suffix: _cm,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}'),
                                  ),
                                ],
                                icon: Icons.straighten_rounded,
                              );

                              final button = _NeoButton(
                                text: _calc,
                                loading: _loading,
                                onTap: () => getResult(
                                  weightController.text,
                                  waistController.text,
                                  sexController.text,
                                  context,
                                ),
                              );

                              if (wide) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(child: sexField),
                                    const SizedBox(width: 12),
                                    Expanded(child: weightField),
                                    const SizedBox(width: 12),
                                    Expanded(child: waistField),
                                    const SizedBox(width: 12),
                                    button,
                                  ],
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  sexField,
                                  const SizedBox(height: 12),
                                  weightField,
                                  const SizedBox(height: 12),
                                  waistField,
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: button,
                                  ),
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
                                      _ResultRow(
                                        label: _bodyFat,
                                        value: percentage.isEmpty
                                            ? ''
                                            : '$percentage %',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _GuideTable(title: 'Guide'),
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

/* ===================== UI helpers ====================== */

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

class _FancyDropdown extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final List<String> items;

  const _FancyDropdown({
    required this.controller,
    required this.label,
    required this.items,
  });

  @override
  State<_FancyDropdown> createState() => _FancyDropdownState();
}

class _FancyDropdownState extends State<_FancyDropdown> {
  final FocusNode _fn = FocusNode();
  String? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.controller.text.isEmpty ? null : widget.controller.text;
  }

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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
          Icon(Icons.person_rounded, size: 20, color: Colors.white.withOpacity(0.75)),
          const SizedBox(width: 8),
          Expanded(
            child: Focus(
              focusNode: _fn,
              child: DropdownButtonFormField<String>(
                value: _value,
                decoration: InputDecoration(
                  labelText: widget.label,
                  labelStyle: t.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withOpacity(0.75),
                  ),
                  border: InputBorder.none,
                ),
                items: widget.items
                    .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {
                  setState(() => _value = v);
                  widget.controller.text = v ?? '';
                },
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

class _GuideTable extends StatelessWidget {
  final String title;
  const _GuideTable({required this.title});

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

    Widget rowCell(String text) => Expanded(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: t.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.82),
            ),
          ),
        );

    Widget row(List<String> cols, {bool shaded = false}) => Container(
          decoration: BoxDecoration(
            color: shaded ? Colors.white.withOpacity(0.03) : Colors.transparent,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(children: [rowCell(cols[0]), rowCell(cols[1]), rowCell(cols[2])]),
        );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: t.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white.withOpacity(0.92),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.07),
            border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
          ),
          width: double.infinity,
          child: Column(
            children: [
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
                    headerCell('Category'),
                    headerCell('Male'),
                    headerCell('Female'),
                  ],
                ),
              ),
              row(['Athletes', '15%', '25%'], shaded: false),
              row(['Fitness', '17.5%', '27.5%'], shaded: true),
              row(['Average', '20%', '30%'], shaded: false),
            ],
          ),
        ),
      ],
    );
  }
}