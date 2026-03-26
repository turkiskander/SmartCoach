// lib/feature/ppCalculator/yoyo/yoyo_endurance_12.dart
//
// ✅ DESIGN updated to match BeepIntermittentTrainingView (BgS.jfif + overlay + orbs + glass UI)
// ✅ NO localization (removed intl usage)
// ✅ Calculation logic (getResult) unchanged
// ✅ Keeps dropdown fix (solid dropdown background) but adapted to new glass theme
//
// REQUIRED ASSET:
// - assets/images/BgS.jfif  (declared in pubspec.yaml)

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/widget/custom_input.dart';

class _TXT {
  static const String screenTitle = "Yo-Yo Endurance (Level 1/2)";
  static const String introTitle = "Yo-Yo Endurance Test";
  static const String introSubtitle =
      "Select the version, enter level and shuttles, then calculate distance, total shuttles and VO₂max.";

  static const String versionTitle = "Version";
  static const String unitVersion = "Yo-Yo Endurance (1/2)";

  static const String levelTitle = "Level";
  static const String shuttlesTitle = "Shuttles";

  static const String calc = "Calculate";

  static const String distanceTitle = "Distance";
  static const String totalShuttlesTitle = "Total shuttles";
  static const String vo2Title = "VO₂max";

  static const String meters = "m";
  static const String vo2Unit = "ml/kg/min";

  static const String notesTitle = "Notes";
  static const String notesBody =
      "Validation: Level must be between 5 and 21, shuttles between 0 and 16. "
      "Version '1' uses internal offset 0, version '2' uses offset 1180.";

  static const String errTitle = "Error";
}

class YoyoEndurance12 extends StatefulWidget {
  const YoyoEndurance12({super.key});

  @override
  State<YoyoEndurance12> createState() => _YoyoEndurance12State();
}

class _YoyoEndurance12State extends State<YoyoEndurance12>
    with SingleTickerProviderStateMixin {
  // BG animé
  late final AnimationController _bgCtl;

  // Contrôleurs
  final TextEditingController levelController = TextEditingController();
  final TextEditingController shuttlesController = TextEditingController();
  final TextEditingController versionController = TextEditingController(); // "1" ou "2"

  // État
  bool _isLoading = false;

  // Résultats
  String distance_result = "0";
  String totalshuttles_result = "0";
  String calcval_result = "0";

  bool get _canSubmit =>
      levelController.text.trim().isNotEmpty &&
      shuttlesController.text.trim().isNotEmpty &&
      versionController.text.trim().isNotEmpty &&
      !_isLoading;

  static const String _bg = "assets/images/BgS.jfif";

  @override
  void initState() {
    super.initState();
    _bgCtl =
        AnimationController(vsync: this, duration: const Duration(seconds: 12))
          ..repeat();
    for (final c in [levelController, shuttlesController, versionController]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _bgCtl.dispose();
    levelController.dispose();
    shuttlesController.dispose();
    versionController.dispose();
    super.dispose();
  }

  /// ⚙️ Logique locale = même calcul que la fonction JS `FigureBEEP()` du fichier web
  ///
  /// - validation :
  ///   level ∈ [5,21] ; shuttles ∈ [0,16]
  /// - version :
  ///   web : 0 (v1) ou 1180 (v2)
  ///   mobile : on choisit "1" ou "2", mappé en 0 / 1180
  Future<void> getResult(
    dynamic level,
    dynamic shuttles,
    dynamic version,
    BuildContext context,
  ) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    HapticFeedback.selectionClick();

    try {
      String _norm(dynamic v) => v == null ? '' : v.toString().trim();

      final String levelStr = _norm(level);
      final String shuttlesStr = _norm(shuttles);
      final String versionStr = _norm(version);

      final int? lvl = int.tryParse(levelStr);
      final int? sh = int.tryParse(shuttlesStr);

      // Vérif nombre
      if (lvl == null || sh == null) {
        _showError(
          context,
          "invalid input - please enter numeric values for level and shuttles",
        );
        return;
      }

      // Validation identique au JS
      String message = "";
      bool error = false;

      if (!(lvl >= 5 && lvl <= 21)) {
        message += "invalid level - enter between 5 and 21\n";
        error = true;
      }

      if (!(sh >= 0 && sh <= 16)) {
        message += "invalid shuttle value - enter between 0 and 16";
        error = true;
      }

      if (error) {
        _showError(context, message.trim());
        return;
      }

      // Tableaux comme dans JS
      final List<int> shuttleTOTAL = [
        0,
        7,
        8,
        8,
        8,
        9,
        9,
        10,
        10,
        11,
        11,
        11,
        12,
        12,
        13,
        13,
        13,
        14,
        14,
        15,
        15,
        16
      ];

      final List<int> distTOTAL = [
        0,
        0,
        140,
        300,
        460,
        620,
        800,
        980,
        1180,
        1380,
        1600,
        1820,
        2040,
        2280,
        2520,
        2780,
        3040,
        3300,
        3580,
        3860,
        4160,
        4460
      ];

      if (lvl < 0 ||
          lvl >= shuttleTOTAL.length ||
          lvl >= distTOTAL.length ||
          shuttleTOTAL[lvl] == 0) {
        _showError(context, "Level out of range for internal tables.");
        return;
      }

      // Fract = shuttles / shuttleTOTAL[level]
      final double fract = sh / shuttleTOTAL[lvl];

      // Score = level + Fract
      final double score = lvl + fract;

      // Version interne identique au web : 0 ou 1180
      final int versionInternal;
      if (versionStr == "1" || versionStr == "0") {
        versionInternal = 0; // Version 1
      } else if (versionStr == "2" || versionStr == "1180") {
        versionInternal = 1180; // Version 2
      } else {
        // fallback : si jamais autre chose, on essaie de parser
        versionInternal = int.tryParse(versionStr) ?? 0;
      }

      // distance = distTOTAL[level] + shuttles*20 - Number(version)
      final int distance = distTOTAL[lvl] + (sh * 20) - versionInternal;

      // totalshuttles = distance / 20
      final double totalShuttles = distance / 20.0;

      // calcval = poly(Score).toFixed(1)
      final double calcVal = (0.0028 * score * score * score) -
          (0.0968 * score * score) +
          (4.5226 * score) +
          5.5137;

      setState(() {
        distance_result = distance.toString();
        totalshuttles_result = totalShuttles.toStringAsFixed(1);
        calcval_result = calcVal.toStringAsFixed(1);
      });

      HapticFeedback.lightImpact();

      debugPrint(
        '[YoYo Local] level=$lvl shuttles=$sh version=$versionInternal '
        'distance=$distance_result total=$totalshuttles_result vo2=$calcval_result',
      );
    } catch (e) {
      debugPrint('❌ YoYo local calc error: $e');
      _showError(context, "Unexpected error, please check your input");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(_TXT.errTitle),
        content: Text(message),
      ),
    );
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

    // ✅ Keep "no transparent dropdown menu" behavior, adapted to new theme.
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
          // ✅ Background image (same as Beep design)
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

          // ✅ Orbs discrets
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
                                                    controller: versionController,
                                                    inputType: InputType.dropdown,
                                                    title: _TXT.versionTitle,
                                                    dropdownItems: const ["1", "2"],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              _UnitPill(text: _TXT.unitVersion, isDark: isDark),
                                            ],
                                          ),
                                          const SizedBox(height: 12),

                                          Row(
                                            children: [
                                              Expanded(
                                                child: CustomInput(
                                                  controller: levelController,
                                                  inputType: InputType.text,
                                                  title: _TXT.levelTitle,
                                                  hint: '10',
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: CustomInput(
                                                  controller: shuttlesController,
                                                  inputType: InputType.text,
                                                  title: _TXT.shuttlesTitle,
                                                  hint: '6',
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),

                                          _ActionButton(
                                            enabled: _canSubmit,
                                            loading: _isLoading,
                                            onTap: _canSubmit
                                                ? () => getResult(
                                                      levelController.text,
                                                      shuttlesController.text,
                                                      versionController.text,
                                                      context,
                                                    )
                                                : null,
                                            label: _TXT.calc,
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
                                          _SectionTitle(
                                            emoji: "🏁",
                                            title: _TXT.distanceTitle,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "$distance_result ${_TXT.meters}",
                                            textAlign: TextAlign.center,
                                            style: t.textTheme.headlineSmall?.copyWith(
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white.withOpacity(0.96),
                                            ),
                                          ),
                                          const SizedBox(height: 16),

                                          _SectionTitle(
                                            emoji: "🔁",
                                            title: _TXT.totalShuttlesTitle,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            totalshuttles_result,
                                            textAlign: TextAlign.center,
                                            style: t.textTheme.headlineSmall?.copyWith(
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white.withOpacity(0.96),
                                            ),
                                          ),
                                          const SizedBox(height: 16),

                                          _SectionTitle(
                                            emoji: "🫁",
                                            title: _TXT.vo2Title,
                                          ),
                                          const SizedBox(height: 8),
                                          _AnimatedMetric(
                                            value: double.tryParse(calcval_result) ?? 0,
                                            unit: _TXT.vo2Unit,
                                            isDark: isDark,
                                          ),
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
/* Header + Banners (same style family as Beep) */
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
            child: Icon(Icons.fitness_center_rounded,
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

  const _SectionTitle({
    required this.emoji,
    required this.title,
  });

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

/* ========================================================================== */
/* Buttons / Metrics */
/* ========================================================================== */

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

/* ========================================================================== */
/* Pills + Glass kit + Orbs */
/* ========================================================================== */

class _UnitPill extends StatelessWidget {
  final String text;
  final bool isDark;

  const _UnitPill({
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
        color: Colors.white.withOpacity(0.10),
      ),
      child: Text(
        text,
        style: t.textTheme.labelLarge?.copyWith(
          color: Colors.white.withOpacity(0.82),
          fontWeight: FontWeight.w800,
        ),
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