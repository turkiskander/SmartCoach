// lib/feature/ppCalculator/traning_calculation/karnoven.dart
//
// ✅ LOGIQUE INCHANGÉE (formules + validations + arrondi)
// ✅ NO localization import (removed)
// ✅ Design identique TrainingCalculationView (BgS.jfif + overlay + orbs + glass + header)
//
// NOTE: imports RELATIFS (même dossier)

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Karnoven extends StatefulWidget {
  const Karnoven({super.key});

  @override
  State<Karnoven> createState() => _KarnovenState();
}

/// ✅ Texts (no localization)
class _TXT {
  static const String title = "Karvonen";
  static const String desc =
      "Enter HRmax and resting HR to compute training heart-rate zones.";

  static const String hrMax = "HRmax";
  static const String hrRest = "Resting HR";
  static const String bpm = "bpm";
  static const String calc = "Calculate";

  static const String invalid = "Check your input values.";

  static const String colZone = "Zone";
  static const String colRange = "Target range";
  static const String colPercent = "%";

  static const String between = "Between";
  static const String and = "and";

  static const String z1 = "Zone 1";
  static const String z2 = "Zone 2";
  static const String z3 = "Zone 3";
  static const String z4 = "Zone 4";
  static const String z5 = "Zone 5";
}

class _KarnovenState extends State<Karnoven> {
  // --- Controllers / state ---
  final TextEditingController hRmaxController = TextEditingController();
  final TextEditingController hRController = TextEditingController();

  String zone1inf = "";
  String zone1sup = "";
  String zone2inf = "";
  String zone2sup = "";
  String zone3inf = "";
  String zone3sup = "";
  String zone4inf = "";
  String zone4sup = "";
  String zone5inf = "";
  String zone5sup = "";

  void _computeKarnoven(BuildContext context) {
    final rawHrmax = hRmaxController.text.trim();
    final rawHr = hRController.text.trim();

    final fcmax = double.tryParse(rawHrmax);
    final fcrep = double.tryParse(rawHr);

    // Validation simple (inchangée)
    if (fcmax == null || fcrep == null || fcmax <= 0 || fcrep < 0 || fcmax <= fcrep) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(_TXT.invalid),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final fcres = fcmax - fcrep;

    final fcrecinf = _round1((fcres * 40) / 100 + fcrep * 1);
    final fcrecsup = _round1((fcres * 60) / 100 + fcrep * 1);

    final fcendinf = _round1((fcres * 60) / 100 + fcrep * 1);
    final fcendsup = _round1((fcres * 70) / 100 + fcrep * 1);

    final fcemainf = _round1((fcres * 70) / 100 + fcrep * 1);
    final fcemasup = _round1((fcres * 85) / 100 + fcrep * 1);

    final fcpmainf = _round1((fcres * 85) / 100 + fcrep * 1);
    final fcpmasup = _round1((fcres * 95) / 100 + fcrep * 1);

    final fcvmainf = _round1((fcres * 95) / 100 + fcrep * 1);
    final fcvmasup = _round1((fcres * 100) / 100 + fcrep * 1);

    setState(() {
      zone1inf = _numToStr(fcrecinf);
      zone1sup = _numToStr(fcrecsup);

      zone2inf = _numToStr(fcendinf);
      zone2sup = _numToStr(fcendsup);

      zone3inf = _numToStr(fcemainf);
      zone3sup = _numToStr(fcemasup);

      zone4inf = _numToStr(fcpmainf);
      zone4sup = _numToStr(fcpmasup);

      zone5inf = _numToStr(fcvmainf);
      zone5sup = _numToStr(fcvmasup);
    });
  }

  // arrondir(x) = Math.round(x * 10) / 10  (inchangé)
  double _round1(num x) => (x * 10).round() / 10.0;

  String _numToStr(num value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  @override
  void dispose() {
    hRmaxController.dispose();
    hRController.dispose();
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
              "assets/images/BgS.jfif",
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
              child: Column(
                children: [
                  _HeaderModern(
                    title: _TXT.title,
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
                            _TXT.title,
                            textAlign: TextAlign.center,
                            style: t.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: Colors.white.withOpacity(0.96),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _TXT.desc,
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
                              final wide = c.maxWidth > 720;

                              final hrMaxField = _FancyTextField(
                                controller: hRmaxController,
                                label: _TXT.hrMax,
                                hint: 'e.g. 190',
                                suffix: _TXT.bpm,
                                keyboardType: const TextInputType.numberWithOptions(
                                  signed: false,
                                  decimal: false,
                                ),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                icon: Icons.favorite_rounded,
                              );

                              final hrField = _FancyTextField(
                                controller: hRController,
                                label: _TXT.hrRest,
                                hint: 'e.g. 60',
                                suffix: _TXT.bpm,
                                keyboardType: const TextInputType.numberWithOptions(
                                  signed: false,
                                  decimal: false,
                                ),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                icon: Icons.monitor_heart_rounded,
                              );

                              final button = _NeoButton(
                                text: _TXT.calc,
                                onTap: () => _computeKarnoven(context),
                              );

                              if (wide) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(child: hrMaxField),
                                    const SizedBox(width: 12),
                                    Expanded(child: hrField),
                                    const SizedBox(width: 12),
                                    button,
                                  ],
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  hrMaxField,
                                  const SizedBox(height: 12),
                                  hrField,
                                  const SizedBox(height: 12),
                                  Align(alignment: Alignment.centerLeft, child: button),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          // Results table
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: _ResultsTable(
                                rows: [
                                  _ZoneRow(
                                    label: _TXT.z1,
                                    percent: '40 - 60',
                                    valueText: '${_TXT.between} $zone1inf ${_TXT.and} $zone1sup',
                                  ),
                                  _ZoneRow(
                                    label: _TXT.z2,
                                    percent: '60 - 70',
                                    valueText: '${_TXT.between} $zone2inf ${_TXT.and} $zone2sup',
                                  ),
                                  _ZoneRow(
                                    label: _TXT.z3,
                                    percent: '70 - 85',
                                    valueText: '${_TXT.between} $zone3inf ${_TXT.and} $zone3sup',
                                  ),
                                  _ZoneRow(
                                    label: _TXT.z4,
                                    percent: '85 - 95',
                                    valueText: '${_TXT.between} $zone4inf ${_TXT.and} $zone4sup',
                                  ),
                                  _ZoneRow(
                                    label: _TXT.z5,
                                    percent: '95 - 100',
                                    valueText: '${_TXT.between} $zone5inf ${_TXT.and} $zone5sup',
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

class _NeoButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _NeoButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_arrow_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  text,
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
    );
  }
}

class _ZoneRow {
  final String label;
  final String valueText;
  final String percent;

  _ZoneRow({
    required this.label,
    required this.valueText,
    required this.percent,
  });
}

class _ResultsTable extends StatelessWidget {
  final List<_ZoneRow> rows;
  const _ResultsTable({required this.rows});

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
                  flex: 2,
                  child: Text(
                    _TXT.colZone,
                    style: t.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withOpacity(0.86),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    _TXT.colRange,
                    style: t.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withOpacity(0.86),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      _TXT.colPercent,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      rows[i].label,
                      style: t.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.86),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      rows[i].valueText.isEmpty ? '—' : rows[i].valueText,
                      style: t.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.82),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
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
                          rows[i].percent,
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