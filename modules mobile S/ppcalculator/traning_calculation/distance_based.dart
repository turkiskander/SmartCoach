// lib/feature/ppCalculator/traning_calculation/distance_based.dart
//
// ✅ LOGIQUE INCHANGÉE (calcul + parsing + résultat identiques)
// ✅ NO localization import (removed)
// ✅ Design identique TrainingCalculationView (BgS.jfif + overlay + orbs + glass + header)
//
// NOTE: imports RELATIFS (même dossier)

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DistanceBased extends StatefulWidget {
  const DistanceBased({super.key});

  @override
  State<DistanceBased> createState() => _DistanceBasedState();
}

/// ✅ Texts (no localization)
class _TXT {
  static const String title = "Distance Based";
  static const String desc =
      "Enter VMA (km/h), distance (m) and percentage to get the target time.";

  static const String vma = "VMA";
  static const String distance = "Distance";
  static const String percentage = "Percentage";
  static const String calc = "Calculate";

  static const String kmh = "km/h";
  static const String m = "m";
  static const String pct = "%";

  static const String invalid = "Input is invalid";

  static const String resultsTitle = "Time";
  static const String minutes = "min";
  static const String seconds = "sec";

  static const String col1 = "Parameter";
  static const String col2 = "Result";
}

class _DistanceBasedState extends State<DistanceBased> {
  // --- Contrôleurs / état ---
  final TextEditingController VMAController = TextEditingController();
  final TextEditingController distanceController = TextEditingController();
  final TextEditingController percentageController = TextEditingController();

  String Time_min = "";
  String Time_sec = "";
  bool _loading = false; // UI only

  // --- Calcul local : même logique que la version web ---
  void _calculate(BuildContext context) {
    if (_loading) return;

    final vma = double.tryParse(VMAController.text.replaceAll(',', '.'));
    final distance = double.tryParse(distanceController.text.replaceAll(',', '.'));
    final percentage = double.tryParse(percentageController.text.replaceAll(',', '.'));

    if (vma == null ||
        vma <= 0 ||
        distance == null ||
        distance <= 0 ||
        percentage == null ||
        percentage <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(_TXT.invalid),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    final vmaMs = vma * 1000.0 / 3600.0;
    final targetSpeedMs = vmaMs * (percentage / 100.0);

    if (targetSpeedMs <= 0) {
      setState(() {
        _loading = false;
        Time_min = "";
        Time_sec = "";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(_TXT.invalid),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final totalSeconds = distance / targetSpeedMs;

    int minutes = totalSeconds ~/ 60;
    int seconds = (totalSeconds - minutes * 60).round();

    if (seconds == 60) {
      minutes += 1;
      seconds = 0;
    }

    setState(() {
      Time_min = minutes.toString();
      Time_sec = seconds.toString().padLeft(2, '0');
      _loading = false;
    });
  }

  @override
  void dispose() {
    VMAController.dispose();
    distanceController.dispose();
    percentageController.dispose();
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

                              final vmaField = _FancyTextField(
                                controller: VMAController,
                                label: _TXT.vma,
                                hint: 'e.g. 16.5',
                                suffix: _TXT.kmh,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                                ],
                                icon: Icons.speed_rounded,
                              );

                              final distField = _FancyTextField(
                                controller: distanceController,
                                label: _TXT.distance,
                                hint: 'e.g. 400',
                                suffix: _TXT.m,
                                keyboardType: const TextInputType.numberWithOptions(
                                  signed: false,
                                  decimal: false,
                                ),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                icon: Icons.straighten_rounded,
                              );

                              final pctField = _FancyTextField(
                                controller: percentageController,
                                label: _TXT.percentage,
                                hint: 'e.g. 110',
                                suffix: _TXT.pct,
                                keyboardType: const TextInputType.numberWithOptions(
                                  signed: false,
                                  decimal: false,
                                ),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                icon: Icons.percent_rounded,
                              );

                              final btn = _NeoButton(
                                text: _TXT.calc,
                                loading: _loading,
                                onTap: () => _calculate(context),
                              );

                              if (wide) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(child: vmaField),
                                    const SizedBox(width: 12),
                                    Expanded(child: distField),
                                    const SizedBox(width: 12),
                                    Expanded(child: pctField),
                                    const SizedBox(width: 12),
                                    btn,
                                  ],
                                );
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  vmaField,
                                  const SizedBox(height: 12),
                                  distField,
                                  const SizedBox(height: 12),
                                  pctField,
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
                              child: _ResultsTable(
                                timeMin: Time_min,
                                timeSec: Time_sec,
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

class _ResultsTable extends StatelessWidget {
  final String timeMin;
  final String timeSec;

  const _ResultsTable({
    required this.timeMin,
    required this.timeSec,
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
                    _TXT.col1,
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
                      _TXT.col2,
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

          // Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _TXT.resultsTitle,
                    style: t.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.86),
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _ChipValue(text: timeMin.isEmpty ? '—' : '$timeMin ${_TXT.minutes}'),
                        _ChipValue(text: timeSec.isEmpty ? '—' : '$timeSec ${_TXT.seconds}'),
                      ],
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

class _ChipValue extends StatelessWidget {
  final String text;
  const _ChipValue({required this.text});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: const Color(0xFF0EA5E9).withOpacity(0.18),
        border: Border.all(color: const Color(0xFF22D3EE).withOpacity(0.35)),
      ),
      child: Text(
        text,
        style: t.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: Colors.white.withOpacity(0.92),
        ),
      ),
    );
  }
}