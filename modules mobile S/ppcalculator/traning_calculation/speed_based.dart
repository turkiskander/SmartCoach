// lib/feature/ppCalculator/traning_calculation/speed_based.dart
//
// ✅ LOGIQUE INCHANGÉE (computeSpeedBased identique)
// ✅ NO localization import (removed)
// ✅ Design identique TrainingCalculationView (BgS.jfif + overlay + orbs + glass + header)
//
// NOTE: imports RELATIFS (même dossier)

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SpeedBased extends StatefulWidget {
  const SpeedBased({super.key});

  @override
  State<SpeedBased> createState() => _SpeedBasedState();
}

/// ✅ Texts (no localization)
class _TXT {
  static const String title = "Speed Based";
  static const String desc =
      "Use a reference performance (distance + time) to estimate the time for a planned distance.";

  static const String refDistance = "Reference distance";
  static const String plannedDistance = "Planned distance";
  static const String hours = "Hours";
  static const String minutes = "Minutes";
  static const String seconds = "Seconds";
  static const String calc = "Calculate";

  static const String m = "m";

  static const String invalid = "Invalid input in one of the fields.";
  static const String timeInvalid = "Reference time must be greater than zero.";

  static const String resultTitle = "Estimated time";
}

class _SpeedBasedState extends State<SpeedBased> {
  // --- Controllers ---
  final TextEditingController reference_distanceController = TextEditingController();
  final TextEditingController planned_distanceController = TextEditingController();
  final TextEditingController Time_herController = TextEditingController();
  final TextEditingController Time_minController = TextEditingController();
  final TextEditingController Time_secController = TextEditingController();

  // --- Résultats ---
  String Timemin = "";
  String Timesec = "";
  String Timeher = "";

  // ---------- Logique locale (sans API) ----------
  void _computeSpeedBased(BuildContext context) {
    final refDist = double.tryParse(reference_distanceController.text.trim());
    final plannedDist = double.tryParse(planned_distanceController.text.trim());
    final h = int.tryParse(Time_herController.text.trim().isEmpty ? '0' : Time_herController.text.trim());
    final m = int.tryParse(Time_minController.text.trim().isEmpty ? '0' : Time_minController.text.trim());
    final s = int.tryParse(Time_secController.text.trim().isEmpty ? '0' : Time_secController.text.trim());

    if (refDist == null ||
        plannedDist == null ||
        refDist <= 0 ||
        plannedDist <= 0 ||
        h == null ||
        m == null ||
        s == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(_TXT.invalid),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final totalRefSeconds = h * 3600 + m * 60 + s;
    if (totalRefSeconds <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(_TXT.timeInvalid),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final speedMps = refDist / totalRefSeconds;

    final plannedTotalSeconds = plannedDist / speedMps;
    int total = plannedTotalSeconds.round();
    if (total < 0) total = 0;

    final resH = total ~/ 3600;
    final rem = total % 3600;
    final resM = rem ~/ 60;
    final resS = rem % 60;

    setState(() {
      Timeher = resH.toString();
      Timemin = resM.toString().padLeft(2, '0');
      Timesec = resS.toString().padLeft(2, '0');
    });

    debugPrint(
        '[speed_based] refDist=$refDist, plannedDist=$plannedDist, refTime=${h}h${m}m${s}s → result=${Timeher}h ${Timemin}m ${Timesec}s');
  }

  @override
  void dispose() {
    reference_distanceController.dispose();
    planned_distanceController.dispose();
    Time_herController.dispose();
    Time_minController.dispose();
    Time_secController.dispose();
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
                              final wide = c.maxWidth > 980;

                              final refDistField = _FancyTextField(
                                controller: reference_distanceController,
                                label: _TXT.refDistance,
                                hint: 'e.g. 5000',
                                suffix: _TXT.m,
                                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                icon: Icons.straighten_rounded,
                              );

                              final hoursField = _FancyTextField(
                                controller: Time_herController,
                                label: _TXT.hours,
                                hint: '0',
                                suffix: _TXT.hours,
                                keyboardType: const TextInputType.numberWithOptions(signed: false),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                icon: Icons.schedule_rounded,
                              );

                              final minutesField = _FancyTextField(
                                controller: Time_minController,
                                label: _TXT.minutes,
                                hint: '20',
                                suffix: _TXT.minutes,
                                keyboardType: const TextInputType.numberWithOptions(signed: false),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                icon: Icons.timer_rounded,
                              );

                              final secondsField = _FancyTextField(
                                controller: Time_secController,
                                label: _TXT.seconds,
                                hint: '00',
                                suffix: _TXT.seconds,
                                keyboardType: const TextInputType.numberWithOptions(signed: false),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                icon: Icons.timer_rounded,
                              );

                              final plannedDistField = _FancyTextField(
                                controller: planned_distanceController,
                                label: _TXT.plannedDistance,
                                hint: 'e.g. 10000',
                                suffix: _TXT.m,
                                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                icon: Icons.flag_rounded,
                              );

                              final button = _NeoButton(
                                text: _TXT.calc,
                                loading: false,
                                onTap: () {
                                  debugPrint('[speed_based] → Click CALCUL');
                                  debugPrint(
                                      '[speed_based] inputs: ref=${reference_distanceController.text}, h=${Time_herController.text}, m=${Time_minController.text}, s=${Time_secController.text}, planned=${planned_distanceController.text}');
                                  _computeSpeedBased(context);
                                },
                              );

                              if (wide) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(flex: 2, child: refDistField),
                                    const SizedBox(width: 12),
                                    Expanded(child: hoursField),
                                    const SizedBox(width: 12),
                                    Expanded(child: minutesField),
                                    const SizedBox(width: 12),
                                    Expanded(child: secondsField),
                                    const SizedBox(width: 12),
                                    Expanded(flex: 2, child: plannedDistField),
                                    const SizedBox(width: 12),
                                    button,
                                  ],
                                );
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  refDistField,
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(child: hoursField),
                                      const SizedBox(width: 12),
                                      Expanded(child: minutesField),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  secondsField,
                                  const SizedBox(height: 12),
                                  plannedDistField,
                                  const SizedBox(height: 12),
                                  Align(alignment: Alignment.centerLeft, child: button),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: _ResultsPanel(
                                title: _TXT.resultTitle,
                                chips: [
                                  '${Timeher.isEmpty ? '—' : Timeher} ${_TXT.hours}',
                                  '${Timemin.isEmpty ? '—' : Timemin} ${_TXT.minutes}',
                                  '${Timesec.isEmpty ? '—' : Timesec} ${_TXT.seconds}',
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
  final bool loading;

  const _NeoButton({
    required this.text,
    required this.onTap,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          if (loading) return;
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
            child: loading
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

class _ResultsPanel extends StatelessWidget {
  final String title;
  final List<String> chips;

  const _ResultsPanel({
    required this.title,
    required this.chips,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    Widget pill(String text) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: const Color(0xFF0EA5E9).withOpacity(0.18),
            border: Border.all(
              color: const Color(0xFF22D3EE).withOpacity(0.35),
            ),
          ),
          child: Text(
            text,
            style: t.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white.withOpacity(0.92),
            ),
          ),
        );

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
                    title,
                    style: t.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withOpacity(0.86),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: chips.map(pill).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}