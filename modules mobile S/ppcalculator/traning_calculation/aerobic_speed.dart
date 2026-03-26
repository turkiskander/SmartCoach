// lib/feature/ppCalculator/traning_calculation/aerobic_speed.dart
//
// ✅ LOGIQUE INCHANGÉE (toutes formules + setState résultats identiques)
// ✅ NO localization import (removed)
// ✅ Design identique TrainingCalculationView (overlay + orbs + glass + header)
// ✅ Background: assets/images/aerobic_speed.jfif

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ✅ Table headers (global scope so _HeaderRow can access)
const String _col1 = "Zone";
const String _col2 = "Speed / Pace";
const String _col3 = "%";

class AerobicSpeed extends StatefulWidget {
  const AerobicSpeed({super.key});

  @override
  State<AerobicSpeed> createState() => _AerobicSpeedState();
}

class _AerobicSpeedState extends State<AerobicSpeed>
    with SingleTickerProviderStateMixin {
  final TextEditingController vMAController = TextEditingController();
  bool _loading = false;

  // --- State résultats (inchangé côté nommage) ---
  String zone1recupinf = "";
  String zone1recupsup = "";
  String zone2endinf = "";
  String zone2endsup = "";
  String zone3emainf = "";
  String zone3emasup = "";
  String zone4pmainf = "";
  String zone4pmasup = "";
  String zone5vmainf = "";
  String zone5vmasup = "";
  String zone1tpskmmnrecupinf = "";
  String zone1tpskmmnrecupsup = "";
  String zone2tpskmmnendinf = "";
  String zone2pskmmnendsup = "";
  String zone3tpskmmnemainf = "";
  String zone3tpskmmnemasup = "";
  String zone4tpskmmnpmainf = "";
  String zone4tpskmmnpmasup = "";
  String zone5tpskmmnvmainf = "";
  String zone5tpskmmnvmasup = "";
  String zone1tpskmsecrecupinf = "";
  String zone1tpskmsecrecupsup = "";
  String zone2tpskmsecendinf = "";
  String zone2tpskmsecendsup = "";
  String zone3tpskmsecemainf = "";
  String zone3tpskmsecemasup = "";
  String zone4tpskmsecpmainf = "";
  String zone4tpskmsecpmasup = "";
  String zone5tpskmsecvmainf = "";
  String zone5tpskmsecvmasup = "";

  /* ====================================================================== */
  /* TEXTS (no localization) */
  /* ====================================================================== */

  static const String _bg = "assets/images/aerobic_speed.jfif";

  // Screen
  static const String _title = "Aerobic Speed";
  static const String _desc =
      "Enter your VMA (km/h) to get speed ranges and pace per km for each training zone.";

  // Input
  static const String _vmaLabel = "VMA";
  static const String _vmaHint = "e.g. 16.5";
  static const String _kmh = "km/h";
  static const String _calc = "Calculate";

  // Snack
  static const String _invalid = "Input is invalid";

  // Helpers text
  static const String _between = "Between";
  static const String _and = "and";
  static const String _minutes = "min";
  static const String _seconds = "sec";

  // Zones labels
  static const String _zRecup = "Recovery";
  static const String _zEnd = "Endurance";
  static const String _zEma = "EMA";
  static const String _zPma = "PMA";
  static const String _zVma = "VMA";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(_bg), context);
  }

  /* ====================================================================== */
  /* LOGIQUE CALCUL LOCALE (équivalent formuleZoneVitesse du web) */
  /* ====================================================================== */

  double _round1(num x) => (x * 10).round() / 10.0;

  int _mnPerKm(double vma, double pourcent) {
    final tps = _round1(60.0 / ((vma * pourcent) / 100.0));
    return tps.truncate();
  }

  int _secPerKm(double vma, double pourcent) {
    final tps = _round1(60.0 / ((vma * pourcent) / 100.0));
    final mn = tps.truncate();
    final frac = tps - mn;
    return (60.0 * frac).truncate();
  }

  String _fmtNum(num x) => _round1(x).toStringAsFixed(1);

  void _onCalculate(BuildContext context) {
    if (_loading) return;

    final raw = vMAController.text.trim().replaceAll(',', '.');
    final vma = double.tryParse(raw);

    if (vma == null || vma <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(_invalid),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    // Vitesses par zone
    final allRecupInf = _round1(vma * 40 / 100);
    final allRecupSup = _round1(vma * 60 / 100);
    final allEndInf = _round1(vma * 60 / 100);
    final allEndSup = _round1(vma * 70 / 100);
    final allEmaInf = _round1(vma * 70 / 100);
    final allEmaSup = _round1(vma * 85 / 100);
    final allPmaInf = _round1(vma * 85 / 100);
    final allPmaSup = _round1(vma * 95 / 100);
    final allVmaInf = _round1(vma * 95 / 100);
    final allVmaSup = _round1(vma * 100 / 100);

    // Temps / km (mn)
    final z1MnRecupInf = _mnPerKm(vma, 40);
    final z1MnRecupSup = _mnPerKm(vma, 60);
    final z2MnEndInf = _mnPerKm(vma, 60);
    final z2MnEndSup = _mnPerKm(vma, 70);
    final z3MnEmaInf = _mnPerKm(vma, 70);
    final z3MnEmaSup = _mnPerKm(vma, 85);
    final z4MnPmaInf = _mnPerKm(vma, 85);
    final z4MnPmaSup = _mnPerKm(vma, 95);
    final z5MnVmaInf = _mnPerKm(vma, 95);
    final z5MnVmaSup = _mnPerKm(vma, 100);

    // Temps / km (sec)
    final z1SecRecupInf = _secPerKm(vma, 40);
    final z1SecRecupSup = _secPerKm(vma, 60);
    final z2SecEndInf = _secPerKm(vma, 60);
    final z2SecEndSup = _secPerKm(vma, 70);
    final z3SecEmaInf = _secPerKm(vma, 70);
    final z3SecEmaSup = _secPerKm(vma, 85);
    final z4SecPmaInf = _secPerKm(vma, 85);
    final z4SecPmaSup = _secPerKm(vma, 95);
    final z5SecVmaInf = _secPerKm(vma, 95);
    final z5SecVmaSup = _secPerKm(vma, 100);

    setState(() {
      // vitesses
      zone1recupinf = _fmtNum(allRecupInf);
      zone1recupsup = _fmtNum(allRecupSup);
      zone2endinf = _fmtNum(allEndInf);
      zone2endsup = _fmtNum(allEndSup);
      zone3emainf = _fmtNum(allEmaInf);
      zone3emasup = _fmtNum(allEmaSup);
      zone4pmainf = _fmtNum(allPmaInf);
      zone4pmasup = _fmtNum(allPmaSup);
      zone5vmainf = _fmtNum(allVmaInf);
      zone5vmasup = _fmtNum(allVmaSup);

      // temps mn / km
      zone1tpskmmnrecupinf = z1MnRecupInf.toString();
      zone1tpskmmnrecupsup = z1MnRecupSup.toString();
      zone2tpskmmnendinf = z2MnEndInf.toString();
      zone2pskmmnendsup = z2MnEndSup.toString();
      zone3tpskmmnemainf = z3MnEmaInf.toString();
      zone3tpskmmnemasup = z3MnEmaSup.toString();
      zone4tpskmmnpmainf = z4MnPmaInf.toString();
      zone4tpskmmnpmasup = z4MnPmaSup.toString();
      zone5tpskmmnvmainf = z5MnVmaInf.toString();
      zone5tpskmmnvmasup = z5MnVmaSup.toString();

      // temps sec / km
      zone1tpskmsecrecupinf = z1SecRecupInf.toString();
      zone1tpskmsecrecupsup = z1SecRecupSup.toString();
      zone2tpskmsecendinf = z2SecEndInf.toString();
      zone2tpskmsecendsup = z2SecEndSup.toString();
      zone3tpskmsecemainf = z3SecEmaInf.toString();
      zone3tpskmsecemasup = z3SecEmaSup.toString();
      zone4tpskmsecpmainf = z4SecPmaInf.toString();
      zone4tpskmsecpmasup = z4SecPmaSup.toString();
      zone5tpskmsecvmainf = z5SecVmaInf.toString();
      zone5tpskmsecvmasup = z5SecVmaSup.toString();

      _loading = false;
    });
  }

  @override
  void dispose() {
    vMAController.dispose();
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
                              final wide = c.maxWidth > 520;

                              final field = _FancyTextField(
                                controller: vMAController,
                                label: _vmaLabel,
                                hint: _vmaHint,
                                suffix: _kmh,
                                keyboardType:
                                    const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}'),
                                  ),
                                ],
                                icon: Icons.speed_rounded,
                              );

                              final btn = _NeoButton(
                                text: _calc,
                                loading: _loading,
                                onTap: () => _onCalculate(context),
                              );

                              if (wide) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(child: field),
                                    const SizedBox(width: 12),
                                    btn,
                                  ],
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  field,
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
                                rows: [
                                  _ZoneRow(
                                    label: _zRecup,
                                    percent: '40 - 60',
                                    speedText:
                                        '$_between $zone1recupinf $_and $zone1recupsup\n'
                                        '$_between\n'
                                        '$zone1tpskmmnrecupinf $_minutes $zone1tpskmmnrecupsup $_seconds\n'
                                        '$_and\n'
                                        '$zone1tpskmsecrecupinf $_minutes $zone1tpskmsecrecupsup $_seconds',
                                  ),
                                  _ZoneRow(
                                    label: _zEnd,
                                    percent: '60 - 70',
                                    speedText:
                                        '$_between $zone2endinf $_and $zone2endsup\n'
                                        '$_between\n'
                                        '$zone2tpskmmnendinf $_minutes $zone2pskmmnendsup $_seconds\n'
                                        '$_and\n'
                                        '$zone2tpskmsecendinf $_minutes $zone2tpskmsecendsup $_seconds',
                                  ),
                                  _ZoneRow(
                                    label: _zEma,
                                    percent: '70 - 85',
                                    speedText:
                                        '$_between $zone3emainf $_and $zone3emasup\n'
                                        '$_between\n'
                                        '$zone3tpskmmnemainf $_minutes $zone3tpskmmnemasup $_seconds\n'
                                        '$_and\n'
                                        '$zone3tpskmsecemainf $_minutes $zone3tpskmsecemasup $_seconds',
                                  ),
                                  _ZoneRow(
                                    label: _zPma,
                                    percent: '85 - 95',
                                    speedText:
                                        '$_between $zone4pmainf $_and $zone4pmasup\n'
                                        '$_between\n'
                                        '$zone4tpskmmnpmainf $_minutes $zone4tpskmmnpmasup $_seconds\n'
                                        '$_and\n'
                                        '$zone4tpskmsecpmainf $_minutes $zone4tpskmsecpmasup $_seconds',
                                  ),
                                  _ZoneRow(
                                    label: _zVma,
                                    percent: '95 - 100',
                                    speedText:
                                        '$_between $zone5vmainf $_and $zone5vmasup\n'
                                        '$_between\n'
                                        '$zone5tpskmmnvmainf $_minutes $zone5tpskmmnvmasup $_seconds\n'
                                        '$_and\n'
                                        '$zone5tpskmsecvmainf $_minutes $zone5tpskmsecvmasup $_seconds',
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
          BoxShadow(color: color, blurRadius: 150, spreadRadius: 10),
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

class _ZoneRow {
  final String label;
  final String speedText;
  final String percent;

  _ZoneRow({
    required this.label,
    required this.speedText,
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
          const _HeaderRow(),
          for (int i = 0; i < rows.length; i++)
            Container(
              decoration: BoxDecoration(
                color: i.isOdd ? Colors.white.withOpacity(0.03) : Colors.transparent,
                borderRadius: i == rows.length - 1
                    ? const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      )
                    : BorderRadius.zero,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                      rows[i].speedText.isEmpty ? '—' : rows[i].speedText,
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

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
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
              _col1,
              style: t.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(0.86),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              _col2,
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
                _col3,
                style: t.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withOpacity(0.86),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}