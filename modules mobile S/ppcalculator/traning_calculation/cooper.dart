// lib/feature/ppCalculator/traning_calculation/cooper.dart
//
// ✅ LOGIQUE DE CALCUL INCHANGÉE (formules + conditions + setState résultats)
// ✅ NO localization import (removed)
// ✅ Design identique à TrainingCalculationView (BgS.jfif + overlay + orbs + glass + header)
//
// NOTE: imports RELATIFS (même dossier)

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Cooper extends StatefulWidget {
  const Cooper({super.key});

  @override
  State<Cooper> createState() => _CooperState();
}

/// ✅ Texts (no localization)
class _TXT {
  static const String title = "Cooper";
  static const String desc =
      "Choose sex, enter age and distance (12 minutes), then calculate VMA, speed (m/s), VO2max and rating.";

  static const String sex = "Sex";
  static const String age = "Age";
  static const String distance = "Distance";
  static const String calc = "Calculate";

  static const String male = "Male";
  static const String female = "Female";

  static const String yrs = "yrs";
  static const String m = "m";

  static const String invalid = "Input is invalid";

  static const String col1 = "Parameter";
  static const String col2 = "Result";

  static const String rVma = "VMA";
  static const String rSpeed = "Speed (m/s)";
  static const String rVo2 = "VO2max";
  static const String rRating = "Rating";
}

class _CooperState extends State<Cooper> {
  // --- Contrôleurs/état ---
  final TextEditingController DistanceController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController sexController = TextEditingController();

  String VMA = "";
  String Either = "";
  String VO2max = "";
  String Result = "";
  bool _loading = false; // UI only

  // === Helpers pour reproduire la logique JS ===
  double _round2(num x) => (x * 100).round() / 100.0; // Math.round(x * 100) / 100
  double _round1(num x) => (x * 10).round() / 10.0;   // Math.round(x * 10) / 10

  void _onCalculate(BuildContext context) {
    if (_loading) return;

    final age = int.tryParse(ageController.text.trim());
    final distance = int.tryParse(DistanceController.text.trim());
    final sex = sexController.text.trim(); // "Male" ou "Female"

    if (age == null ||
        age <= 0 ||
        distance == null ||
        distance <= 0 ||
        (sex != _TXT.male && sex != _TXT.female)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(_TXT.invalid),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    // ----- LOGIQUE identique à formuleCooper() du web -----
    final vo2 = _round2(((distance / 1000.0) * 22.351 - 11.288));
    final vma = _round2(vo2 / 3.5);
    final vmams = _round1((vma * 1000.0) / 3600.0);

    final couru = distance;
    final int item = (sex == _TXT.male) ? 0 : 1; // 0 homme, 1 femme

    String notation = "";

    // Toutes les conditions copiées du JS (inchangées)
    if (age < 30 && couru < 1601 && item == 0) notation = "très médiocre";
    if (age < 30 && couru > 1600 && couru < 2001 && item == 0) notation = "médiocre";
    if (age < 30 && couru > 2000 && couru < 2401 && item == 0) notation = "moyen";
    if (age < 30 && couru > 2400 && couru < 2799 && item == 0) notation = "bon";
    if (age < 30 && couru > 2800 && item == 0) notation = "excellent";

    if (age < 30 && couru < 1501 && item == 1) notation = "très médiocre";
    if (age < 30 && couru > 1500 && couru < 1851 && item == 1) notation = "médiocre";
    if (age < 30 && couru > 1850 && couru < 2151 && item == 1) notation = "moyen";
    if (age < 30 && couru > 2150 && couru < 2651 && item == 1) notation = "bon";
    if (age < 30 && couru > 2650 && item == 1) notation = "excellent";

    if (age > 29 && age < 40 && couru < 1501 && item == 0) notation = "très médiocre";
    if (age > 29 && age < 40 && couru > 1500 && couru < 1851 && item == 0) notation = "médiocre";
    if (age > 29 && age < 40 && couru > 1850 && couru < 2251 && item == 0) notation = "moyen";
    if (age > 29 && age < 40 && couru > 2250 && couru < 2651 && item == 0) notation = "bon";
    if (age > 29 && age < 40 && couru > 2650 && item == 0) notation = "excellent";

    if (age > 29 && age < 40 && couru < 1351 && item == 1) notation = "très médiocre";
    if (age > 29 && age < 40 && couru > 1350 && couru < 1701 && item == 1) notation = "médiocre";
    if (age > 29 && age < 40 && couru > 1700 && couru < 2001 && item == 1) notation = "moyen";
    if (age > 29 && age < 40 && couru > 2000 && couru < 2501 && item == 1) notation = "bon";
    if (age > 29 && age < 40 && couru > 2500 && item == 1) notation = "excellent";

    if (age > 39 && age < 50 && couru < 1351 && item == 0) notation = "très médiocre";
    if (age > 39 && age < 50 && couru > 1350 && couru < 1701 && item == 0) notation = "médiocre";
    if (age > 39 && age < 50 && couru > 1700 && couru < 2101 && item == 0) notation = "moyen";
    if (age > 39 && age < 50 && couru > 2100 && couru < 2501 && item == 0) notation = "bon";
    if (age > 39 && age < 50 && couru > 2500 && item == 0) notation = "excellent";

    if (age > 39 && age < 50 && couru < 1201 && item == 1) notation = "très médiocre";
    if (age > 39 && age < 50 && couru > 1200 && couru < 1501 && item == 1) notation = "médiocre";
    if (age > 39 && age < 50 && couru > 1500 && couru < 1851 && item == 1) notation = "moyen";
    if (age > 39 && age < 50 && couru > 1850 && couru < 2351 && item == 1) notation = "bon";
    if (age > 39 && age < 50 && couru > 2350 && item == 1) notation = "excellent";

    if (age > 49 && couru < 1251 && item == 0) notation = "très médiocre";
    if (age > 49 && couru > 1250 && couru < 1601 && item == 0) notation = "médiocre";
    if (age > 49 && couru > 1600 && couru < 2001 && item == 0) notation = "moyen";
    if (age > 49 && couru > 2000 && couru < 2401 && item == 0) notation = "bon";
    if (age > 49 && couru > 2400 && item == 0) notation = "excellent";

    if (age > 49 && couru < 1101 && item == 1) notation = "très médiocre";
    if (age > 49 && couru > 1100 && couru < 1351 && item == 1) notation = "médiocre";
    if (age > 49 && couru > 1350 && couru < 1701 && item == 1) notation = "moyen";
    if (age > 49 && couru > 1700 && couru < 2201 && item == 1) notation = "bon";
    if (age > 49 && couru > 2200 && item == 1) notation = "excellent";

    setState(() {
      VMA = vma.toString();      // resultCooper
      Either = vmams.toString(); // resultmsCooper
      VO2max = vo2.toString();   // resultVO2maxCooper
      Result = notation;         // notationCooper
      _loading = false;
    });
  }

  @override
  void dispose() {
    DistanceController.dispose();
    ageController.dispose();
    sexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final isDark = t.brightness == Brightness.dark;

    // Default sex
    final sexes = const [_TXT.male, _TXT.female];
    if (sexController.text.isEmpty) sexController.text = sexes.first;

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
                          // Title + desc
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

                          // Inputs
                          LayoutBuilder(
                            builder: (context, c) {
                              final wide = c.maxWidth > 720;

                              final sexField = _FancyDropdown(
                                label: _TXT.sex,
                                value: sexController.text,
                                items: sexes,
                                isDark: isDark,
                                onChanged: (v) {
                                  if (v == null) return;
                                  setState(() => sexController.text = v);
                                },
                              );

                              final ageField = _FancyTextField(
                                controller: ageController,
                                label: _TXT.age,
                                hint: 'e.g. 25',
                                isDark: isDark,
                                keyboardType: const TextInputType.numberWithOptions(
                                  signed: false,
                                  decimal: false,
                                ),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                suffix: _TXT.yrs,
                              );

                              final distanceField = _FancyTextField(
                                controller: DistanceController,
                                label: _TXT.distance,
                                hint: 'e.g. 2400',
                                isDark: isDark,
                                keyboardType: const TextInputType.numberWithOptions(
                                  signed: false,
                                  decimal: false,
                                ),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                suffix: _TXT.m,
                              );

                              final button = _NeoButton(
                                text: _TXT.calc,
                                loading: _loading,
                                onTap: () => _onCalculate(context),
                              );

                              if (wide) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(child: sexField),
                                    const SizedBox(width: 12),
                                    Expanded(child: ageField),
                                    const SizedBox(width: 12),
                                    Expanded(child: distanceField),
                                    const SizedBox(width: 12),
                                    button,
                                  ],
                                );
                              } else {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    sexField,
                                    const SizedBox(height: 12),
                                    ageField,
                                    const SizedBox(height: 12),
                                    distanceField,
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: button,
                                    ),
                                  ],
                                );
                              }
                            },
                          ),

                          const SizedBox(height: 16),

                          // Results
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: _ResultsPanel(
                                isDark: isDark,
                                rows: [
                                  _ResultRow(label: _TXT.rVma, value: VMA),
                                  _ResultRow(label: _TXT.rSpeed, value: Either),
                                  _ResultRow(label: _TXT.rVo2, value: VO2max),
                                  _ResultRow(label: _TXT.rRating, value: Result),
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
/* UI helpers (repris & adaptés au style TrainingCalculationView) */
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
  final bool isDark;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _FancyTextField({
    required this.controller,
    required this.label,
    required this.isDark,
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
          Icon(Icons.edit_rounded, size: 20, color: Colors.white.withOpacity(0.75)),
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

class _FancyDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final bool isDark;
  final ValueChanged<String?> onChanged;

  const _FancyDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.10),
        border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.person_rounded, size: 20, color: Colors.white.withOpacity(0.75)),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: const Color(0xFF0B0F14).withOpacity(0.96),
                items: items
                    .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                    .toList(),
                onChanged: onChanged,
                style: t.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withOpacity(0.92),
                ),
                iconEnabledColor: Colors.white.withOpacity(0.75),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: t.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.72),
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

class _NeoButtonState extends State<_NeoButton>
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
    if (widget.loading) return;
    await _pressCtl.forward();
    await _pressCtl.reverse();
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
  final bool isDark;
  final List<_ResultRow> rows;
  const _ResultsPanel({required this.isDark, required this.rows});

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