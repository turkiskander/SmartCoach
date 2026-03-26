// lib/feature/ppCalculator/traning_calculation/cat.dart
// ✅ LOGIQUE INCHANGÉE (formules + validations + setState résultats identiques)
// ✅ NO localization import
// ✅ Correction overflow horizontal/vertical
// ✅ Design identique TrainingCalculationView

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Cat extends StatefulWidget {
  const Cat({super.key});

  @override
  State<Cat> createState() => _CatState();
}

/// ✅ Texts (no localization)
class _TXT {
  static const String title = "CAT";
  static const String desc =
      "Select the test distance and enter your time to calculate VMA, speed (m/s) and VO2max.";

  static const String distance = "Distance";
  static const String minutes = "Minutes";
  static const String seconds = "Seconds";
  static const String calc = "Calculate";

  static const String m = "m";
  static const String min = "min";
  static const String sec = "sec";

  static const String invalid = "Input is invalid";
  static const String timeInvalid = "Time must be greater than 0";

  static const String col1 = "Parameter";
  static const String col2 = "Result";

  static const String rVma = "VMA (km/h)";
  static const String rSpeed = "Speed (m/s)";
  static const String rVo2 = "VO2max";
}

class _CatState extends State<Cat> {
  // --- Contrôleurs & état ---
  final TextEditingController distanceController = TextEditingController();
  final TextEditingController Time_minController = TextEditingController();
  final TextEditingController Time_secController = TextEditingController();

  String VMA = "";
  String Either = "";
  String VO2max = "";

  bool _loading = false;

  // === Helpers pour reproduire exactement la logique JS (formuleCAT) ===
  double _round1(num x) => (x * 10).round() / 10.0;
  String _fmtNum(num x) => _round1(x).toStringAsFixed(1);

  void _onCalculate(BuildContext context) {
    if (_loading) return;

    final rawDistance = distanceController.text;
    final distanceMatch = RegExp(r'\d+').stringMatch(rawDistance);
    final distance = double.tryParse(distanceMatch ?? "");

    final tMin = int.tryParse(Time_minController.text.trim());
    final tSec = int.tryParse(Time_secController.text.trim());

    if (distance == null || distance <= 0 || tMin == null || tSec == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(_TXT.invalid),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final totalSec = tMin * 60 + tSec;
    if (totalSec <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(_TXT.timeInvalid),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    // ----- LOGIQUE identique à formuleCAT() du web -----
    final vma = _round1(((distance / 1000.0) * 3600.0) / totalSec);
    final vmams = _round1((vma * 1000.0) / 3600.0);

    double vo2 = 0;
    final dInt = distance.toInt();
    if (dInt == 3000) {
      vo2 = _round1(vma * 3.7);
    } else if (dInt == 2000) {
      vo2 = _round1(vma * 3.55);
    } else if (dInt == 1500) {
      vo2 = _round1(vma * 3.5);
    } else if (dInt == 1000) {
      vo2 = _round1(vma * 3.2);
    }

    setState(() {
      VMA = _fmtNum(vma);
      Either = _fmtNum(vmams);
      VO2max = _fmtNum(vo2);
      _loading = false;
    });
  }

  @override
  void dispose() {
    distanceController.dispose();
    Time_minController.dispose();
    Time_secController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final isDark = t.brightness == Brightness.dark;

    final distances = const [
      "3000m",
      "2000m",
      "1500m",
      "1000m",
    ];

    if (distanceController.text.isEmpty) {
      distanceController.text = distances.first;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/BgS.jfif",
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
            child: LayoutBuilder(
              builder: (context, viewport) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    16,
                    10,
                    16,
                    14 + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: viewport.maxHeight - 24,
                    ),
                    child: IntrinsicHeight(
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

                                  LayoutBuilder(
                                    builder: (context, c) {
                                      final wide = c.maxWidth > 720;

                                      final distanceField = _FancyDropdown(
                                        label: _TXT.distance,
                                        value: distanceController.text,
                                        items: distances,
                                        onChanged: (v) {
                                          if (v == null) return;
                                          setState(() => distanceController.text = v);
                                        },
                                      );

                                      final minField = _FancyTextField(
                                        controller: Time_minController,
                                        label: _TXT.minutes,
                                        hint: '00',
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                          signed: false,
                                          decimal: false,
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          LengthLimitingTextInputFormatter(2),
                                        ],
                                        suffix: _TXT.min,
                                        icon: Icons.timer_rounded,
                                      );

                                      final secField = _FancyTextField(
                                        controller: Time_secController,
                                        label: _TXT.seconds,
                                        hint: '00',
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                          signed: false,
                                          decimal: false,
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          LengthLimitingTextInputFormatter(2),
                                        ],
                                        suffix: _TXT.sec,
                                        icon: Icons.timer_rounded,
                                      );

                                      final button = _NeoButton(
                                        text: _TXT.calc,
                                        loading: _loading,
                                        onTap: () => _onCalculate(context),
                                      );

                                      if (wide) {
                                        return Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Expanded(child: distanceField),
                                            const SizedBox(width: 12),
                                            Expanded(child: minField),
                                            const SizedBox(width: 12),
                                            Expanded(child: secField),
                                            const SizedBox(width: 12),
                                            Flexible(child: button),
                                          ],
                                        );
                                      }

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          distanceField,
                                          const SizedBox(height: 12),
                                          minField,
                                          const SizedBox(height: 12),
                                          secField,
                                          const SizedBox(height: 12),
                                          SizedBox(
                                            width: double.infinity,
                                            child: button,
                                          ),
                                        ],
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 16),

                                  _ResultsPanel(
                                    rows: [
                                      _ResultRow(label: _TXT.rVma, value: VMA),
                                      _ResultRow(
                                        label: _TXT.rSpeed,
                                        value: Either,
                                      ),
                                      _ResultRow(
                                        label: _TXT.rVo2,
                                        value: VO2max,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
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
          border: Border.all(
            color: Colors.white.withOpacity(0.14),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white.withOpacity(0.92),
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
  void initState() {
    super.initState();
    _fn.addListener(() {
      if (mounted) setState(() {});
    });
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
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          prefixIcon: Icon(
            widget.icon,
            size: 20,
            color: Colors.white.withOpacity(0.75),
          ),
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
          suffixText: widget.suffix,
          suffixStyle: t.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: Colors.white.withOpacity(0.82),
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _FancyDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FancyDropdown({
    required this.label,
    required this.value,
    required this.items,
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
          Icon(
            Icons.straighten_rounded,
            size: 20,
            color: Colors.white.withOpacity(0.75),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: const Color(0xFF0B0F14).withOpacity(0.96),
                items: items
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(
                          e,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
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
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: t.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(0.72),
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                widget.text,
                                overflow: TextOverflow.ellipsis,
                                style: t.textTheme.titleSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.3,
                                ),
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

class _ResultsPanel extends StatelessWidget {
  final List<_ResultRow> rows;

  const _ResultsPanel({
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
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