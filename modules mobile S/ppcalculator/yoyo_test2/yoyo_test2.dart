// lib/feature/ppCalculator/yoyo/yoyo_endurance_2.dart
//
// ✅ DESIGN updated to match BeepIntermittentTrainingView (BgS.jfif + overlay + orbs + glass UI)
// ✅ NO localization (removed intl usage)
// ✅ Calculation logic (_calculate + _computeStatus) unchanged (same formulas, same tables, same validation ranges)
// ✅ Dropdown solid background fix kept (no transparent dropdown)
//
// REQUIRED ASSET:
// - assets/images/BgS.jfif  (declared in pubspec.yaml)

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/widget/custom_input.dart';

class _TXT {
  static const String screenTitle = "Yo-Yo Test 2";
  static const String introTitle = "Yo-Yo Intermittent Recovery Test Level 2";
  static const String introSubtitle =
      "Select sex, enter age, level and shuttles, then calculate distance, VO₂max and status.";

  static const String sex = "Sex";
  static const String male = "Male";
  static const String female = "Female";

  static const String age = "Age";
  static const String level = "Level";
  static const String shuttles = "Shuttles";

  static const String calculate = "Calculate";

  static const String distance = "Distance";
  static const String meters = "m";

  static const String vo2 = "VO₂max";
  static const String vo2Unit = "ml/kg/min";

  static const String status = "Status";

  static const String notesTitle = "Notes";
  static const String notesBody =
      "Validation: Level must be between 11 and 29, shuttles between 0 and 8. "
      "VO₂max = distance × 0.0136 + 45.3. Status is derived from the same tables as the web version.";

  static const String errTitle = "Error";
  static const String ok = "OK";
}

class YoyoTest2 extends StatefulWidget {
  const YoyoTest2({super.key});

  @override
  State<YoyoTest2> createState() => _YoyoTest2State();
}

class _YoyoTest2State extends State<YoyoTest2> with SingleTickerProviderStateMixin {
  late final AnimationController _bgCtl;

  // Données YOYO2 (distTOTAL du fichier web)
  final List<int> distTOTAL = const [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    40, 40, 40, 40, 80, 80, 120, 200, 320,
    480, 800, 1120, 1440, 1760, 2080, 2400, 2720, 3040, 3360
  ];

  // Matrices de classification comme dans le JS
  final List<List<int>> _maleTable = const [
    [1120, 57, 52, 46, 42, 38],
    [880, 49, 43, 39, 36, 33],
    [680, 43, 39, 36, 32, 29],
    [480, 40, 35, 32, 30, 26],
    [240, 35, 31, 29, 26, 22],
    [0, 30, 26, 25, 22, 20],
    [0, 0, 0, 0, 0, 0],
  ];

  final List<List<int>> _femaleTable = const [
    [680, 53, 46, 41, 38, 33],
    [560, 45, 38, 34, 32, 28],
    [440, 39, 34, 31, 28, 25],
    [320, 35, 31, 28, 25, 22],
    [160, 31, 27, 25, 22, 19],
    [0, 26, 22, 20, 18, 17],
    [0, 0, 0, 0, 0, 0],
  ];

  // Contrôleurs
  final TextEditingController sexCtl = TextEditingController(); // Male / Female
  final TextEditingController levelCtl = TextEditingController(); // Level
  final TextEditingController shuttlesCtl = TextEditingController(); // Shuttles
  final TextEditingController ageCtl = TextEditingController(text: '10'); // Age default 10

  // Résultats UI
  int distanceResult = 0;
  String calcvalResult = "0.0";
  String statusResult = "";

  bool get _canSubmit =>
      levelCtl.text.trim().isNotEmpty && shuttlesCtl.text.trim().isNotEmpty;

  static const String _bg = "assets/images/BgS.jfif";

  @override
  void initState() {
    super.initState();
    _bgCtl = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();
    for (final c in [sexCtl, levelCtl, shuttlesCtl, ageCtl]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _bgCtl.dispose();
    sexCtl.dispose();
    levelCtl.dispose();
    shuttlesCtl.dispose();
    ageCtl.dispose();
    super.dispose();
  }

  /// Validation + calcul EXACTEMENT comme la fonction JS `FigureBEEP` du fichier web
  void _calculate() {
    String message = "";
    bool error = false;

    // Parsers bruts (nullable)
    final int? lvlRaw = int.tryParse(levelCtl.text.trim());
    final int? shRaw = int.tryParse(shuttlesCtl.text.trim());

    // Age : par défaut 10 comme dans le web
    int age = int.tryParse(ageCtl.text.trim()) ?? 10;

    // Validation level : [11, 29]
    if (lvlRaw == null || lvlRaw < 11 || lvlRaw > 29) {
      message += "invalid level - enter between 11 and 29\n";
      error = true;
    }

    // Validation shuttles : [0, 8]
    if (shRaw == null || shRaw < 0 || shRaw > 8) {
      message += "invalid shuttle value - enter between 0 and 8";
      error = true;
    }

    if (error) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text(_TXT.errTitle),
          content: Text(message.trim()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(_TXT.ok),
            ),
          ],
        ),
      );
      return;
    }

    // À partir d'ici, ils sont garantis NON nuls
    final int lvl = lvlRaw!;
    final int sh = shRaw!;

    try {
      // Sécuriser l'accès dans le tableau distTOTAL
      if (lvl < 0 || lvl >= distTOTAL.length) {
        throw Exception('Level index out of range');
      }

      // distance = distTOTAL[level] + (shuttles * 40 - 40)
      final int distance = distTOTAL[lvl] + (sh * 40 - 40);

      // VO2max = distance * 0.0136 + 45.3
      final double vo2 = distance * 0.0136 + 45.3;

      // Classification (condition(distance))
      final String status = _computeStatus(distance, age);

      setState(() {
        distanceResult = distance;
        calcvalResult = vo2.toStringAsFixed(1);
        statusResult = status;
      });

      HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('❌ YoYo2 calc error: $e');
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text(_TXT.errTitle),
          content: const Text('Unexpected error, please check your input'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(_TXT.ok),
            ),
          ],
        ),
      );
    }
  }

  /// Reproduction de `condition(normdistance)` du fichier web
  String _computeStatus(int normDistance, int age) {
    // Groupe d'âge
    int ageGroup;
    if (age <= 25) {
      ageGroup = 0;
    } else if (age <= 35) {
      ageGroup = 1;
    } else if (age <= 45) {
      ageGroup = 2;
    } else if (age <= 55) {
      ageGroup = 3;
    } else if (age <= 65) {
      ageGroup = 4;
    } else {
      ageGroup = 5;
    }

    // Détermination du sexe : si dropdown = Female => female, sinon male
    final String sexLabel = sexCtl.text.trim();
    final bool isMale = sexLabel.isEmpty || sexLabel == _TXT.male;

    final List<List<int>> table = isMale ? _maleTable : _femaleTable;

    if (normDistance >= table[0][ageGroup]) {
      return "Elite";
    } else if (normDistance >= table[1][ageGroup]) {
      return "Excellent";
    } else if (normDistance >= table[2][ageGroup]) {
      return "Good";
    } else if (normDistance >= table[3][ageGroup]) {
      return "Average";
    } else if (normDistance >= table[4][ageGroup]) {
      return "Below Average";
    } else if (normDistance >= table[5][ageGroup]) {
      return "Poor";
    } else {
      return "Poor";
    }
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

    // ✅ Keep "no transparent dropdown menu"
    final solidDropdownBg = isDark ? const Color(0xFF0B1220) : Colors.white;
    final dropdownTheme = Theme.of(context).copyWith(
      canvasColor: solidDropdownBg,
      cardColor: solidDropdownBg,
      dialogBackgroundColor: solidDropdownBg,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ✅ Background image
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

          // ✅ Orbs
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
                animation: _bgCtl,
                builder: (_, __) {
                  return Column(
                    children: [
                      _HeaderModern(
                        title: _TXT.screenTitle,
                        onBack: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(height: 12),

                      Expanded(
                        child: _Glass(
                          radius: 20,
                          padding: EdgeInsets.zero,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CustomScrollView(
                              physics: const BouncingScrollPhysics(),
                              slivers: [
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                                    child: _InfoBanner(
                                      title: _TXT.introTitle,
                                      subtitle: _TXT.introSubtitle,
                                    ),
                                  ),
                                ),

                                // Form
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                    child: _Glass(
                                      radius: 18,
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Theme(
                                                  data: dropdownTheme,
                                                  child: CustomInput(
                                                    controller: sexCtl,
                                                    inputType: InputType.dropdown,
                                                    title: _TXT.sex,
                                                    dropdownItems: const [_TXT.male, _TXT.female],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: CustomInput(
                                                  controller: ageCtl,
                                                  inputType: InputType.text,
                                                  title: _TXT.age,
                                                  hint: '10',
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),

                                          Row(
                                            children: [
                                              Expanded(
                                                child: CustomInput(
                                                  controller: levelCtl,
                                                  inputType: InputType.text,
                                                  title: _TXT.level,
                                                  hint: '11',
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: CustomInput(
                                                  controller: shuttlesCtl,
                                                  inputType: InputType.text,
                                                  title: _TXT.shuttles,
                                                  hint: '4',
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),

                                          _ActionButton(
                                            enabled: _canSubmit,
                                            loading: false,
                                            onTap: _canSubmit ? _calculate : null,
                                            label: _TXT.calculate,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Results
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                    child: _Glass(
                                      radius: 18,
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          _SectionTitle(emoji: "🏁", title: _TXT.distance),
                                          const SizedBox(height: 8),
                                          Text(
                                            "$distanceResult ${_TXT.meters}",
                                            textAlign: TextAlign.center,
                                            style: t.textTheme.headlineSmall?.copyWith(
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white.withOpacity(0.96),
                                            ),
                                          ),
                                          const SizedBox(height: 16),

                                          _SectionTitle(emoji: "🫁", title: _TXT.vo2),
                                          const SizedBox(height: 8),
                                          _AnimatedMetric(
                                            value: double.tryParse(calcvalResult) ?? 0,
                                            unit: _TXT.vo2Unit,
                                            isDark: isDark,
                                          ),

                                          if (statusResult.isNotEmpty) ...[
                                            const SizedBox(height: 16),
                                            _SectionTitle(emoji: "📊", title: _TXT.status),
                                            const SizedBox(height: 8),
                                            Text(
                                              statusResult,
                                              textAlign: TextAlign.center,
                                              style: t.textTheme.headlineSmall?.copyWith(
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white.withOpacity(0.96),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Notes
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                                    child: _Glass(
                                      radius: 18,
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            _TXT.notesTitle,
                                            textAlign: TextAlign.center,
                                            style: t.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white.withOpacity(0.96),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            _TXT.notesBody,
                                            textAlign: TextAlign.center,
                                            style: t.textTheme.bodyMedium?.copyWith(
                                              color: Colors.white.withOpacity(0.78),
                                              fontWeight: FontWeight.w600,
                                              height: 1.25,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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

/* ========================================================================== */
/* UI Kit (same family as Beep design) */
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

class _InfoBanner extends StatelessWidget {
  final String title;
  final String subtitle;

  const _InfoBanner({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return _Glass(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white.withOpacity(0.10),
              border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
            ),
            child: Icon(Icons.directions_run_rounded,
                color: cs.primary.withOpacity(0.92), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.96),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: t.textTheme.bodySmall?.copyWith(
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.72),
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

class _SectionTitle extends StatelessWidget {
  final String emoji;
  final String title;

  const _SectionTitle({required this.emoji, required this.title});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(emoji, style: t.textTheme.titleLarge),
        const SizedBox(width: 8),
        Text(
          title,
          style: t.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: Colors.white.withOpacity(0.96),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final bool enabled;
  final bool loading;
  final VoidCallback? onTap;
  final String label;

  const _ActionButton({
    required this.enabled,
    required this.loading,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final isEnabled = enabled && !loading;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: isEnabled
          ? () {
              HapticFeedback.lightImpact();
              onTap?.call();
            }
          : null,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withOpacity(isEnabled ? 0.12 : 0.08),
          border: Border.all(color: Colors.white.withOpacity(isEnabled ? 0.16 : 0.12), width: 1),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              color: Colors.black.withOpacity(0.25),
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 18, color: cs.primary.withOpacity(0.92)),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: t.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white.withOpacity(isEnabled ? 0.94 : 0.70),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _AnimatedMetric extends StatelessWidget {
  final double value;
  final String unit;
  final bool isDark;

  const _AnimatedMetric({
    required this.value,
    required this.unit,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => Column(
        children: [
          Text(
            v.toStringAsFixed(1),
            textAlign: TextAlign.center,
            style: t.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.0,
              color: Colors.white.withOpacity(0.96),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            unit,
            style: t.textTheme.titleMedium?.copyWith(
              color: Colors.white.withOpacity(0.72),
              fontWeight: FontWeight.w700,
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