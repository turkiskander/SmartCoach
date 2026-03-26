// lib/feature/ppCalculator/hydration/water_loss.dart
//
// ✅ DESIGN updated to match BeepIntermittentTrainingView (same BG image + overlay + orbs + glass UI)
// ✅ NO localization (removed intl usage)
// ✅ Calculation logic (getResult) unchanged
// ✅ Keeps controllers/state/validation exactly as before
//
// REQUIRED ASSET:
// - assets/images/BgS.jfif  (declared in pubspec.yaml)

import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/widget/custom_input.dart';
import '../../../shared/widget/loading_widget.dart';

/// ✅ Texts (no localization)
class _TXT {
  static const String screenTitle = "Water Loss";
  static const String introTitle = "Hydration check";
  static const String introSubtitle =
      "Enter your weight before and after exercise to estimate water loss.";

  static const String imageUrl =
      "https://application.sportspedagogue.com/_nuxt/img/loss.deef005.jpg";

  static const String beforeTitle = "Weight before exercise";
  static const String afterTitle = "Weight after exercise";
  static const String pounds = "lbs";

  static const String calc = "Calculate";

  static const String resultsTitle = "Your Results";
  static const String r1 = "Total weight loss";
  static const String r2 = "Water loss";
  static const String r3 = "Percent loss";

  static const String tipsTitle = "Tips";
  static const List<String> tips = [
    "Drink water regularly during exercise.",
    "Weigh yourself under similar conditions for accuracy.",
    "Replace fluids progressively after training.",
    "In hot conditions, increase hydration frequency.",
    "Avoid starting exercise dehydrated.",
    "Use electrolytes if the session is long.",
    "Monitor urine color as a simple indicator.",
    "Plan hydration based on intensity and duration.",
  ];

  static const String errTitle = "Error";
  static const String errInvalid = "Input in the weight fields is invalid";
  static const String errUnexpected = "Unexpected error, please check your input";
}

class WaterLoss extends StatefulWidget {
  const WaterLoss({super.key});

  @override
  State<WaterLoss> createState() => _WaterLossState();
}

class _WaterLossState extends State<WaterLoss> with SingleTickerProviderStateMixin {
  // BG animé (kept, but only used for subtle entrance timing if needed)
  late final AnimationController _bgCtl;

  // Contrôleurs
  final TextEditingController weightbController = TextEditingController(); // Before
  final TextEditingController weightaController = TextEditingController(); // After

  // État
  bool _isLoading = false;

  // Résultats (calculés en local)
  String losswt = "0"; // perte de poids (lbs)
  String lossh2o = "0"; // eau perdue (fl oz)
  String losspct = "0"; // % de perte

  bool get _canSubmit =>
      weightbController.text.trim().isNotEmpty &&
      weightaController.text.trim().isNotEmpty &&
      !_isLoading;

  static const String _bg = "assets/images/BgS.jfif";

  @override
  void initState() {
    super.initState();
    _bgCtl = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();
    for (final c in [weightbController, weightaController]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _bgCtl.dispose();
    weightbController.dispose();
    weightaController.dispose();
    super.dispose();
  }

  /// ⚙️ Logique locale = même calcul que la fonction JS `calc()` du fichier web
  ///
  /// JS :
  ///  temp_1 = weightb - weighta
  ///  losswt = temp_1
  ///  temp_2 = temp_1 * 15.3
  ///  r_temp_2 = round(temp_2 * 10) / 10
  ///  lossh2o = r_temp_2
  ///  temp_3 = (temp_1 / weightb) * 100
  ///  r_temp_3 = round(temp_3 * 100) / 100
  ///  losspct = r_temp_3
  Future<void> getResult(dynamic weightb, dynamic weighta, BuildContext context) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    HapticFeedback.selectionClick();

    try {
      String _norm(dynamic v) => v == null ? '' : v.toString().trim().replaceAll(',', '.');

      final String wbStr = _norm(weightb);
      final String waStr = _norm(weighta);

      final double? wb = double.tryParse(wbStr);
      final double? wa = double.tryParse(waStr);

      // Validation simple : entrées valides & > 0
      if (wb == null || wa == null || wb <= 0 || wa <= 0) {
        setState(() {
          losswt = "0";
          lossh2o = "0";
          losspct = "0";
        });
        _showError(_TXT.errInvalid);
        setState(() => _isLoading = false);
        return;
      }

      // Si dans le web ils mettent 0 => tout à 0
      if (wb == 0 || wa == 0) {
        setState(() {
          losswt = "0";
          lossh2o = "0";
          losspct = "0";
        });
      } else {
        // temp_1 = weightb - weighta
        final double temp1 = wb - wa; // perte de poids en lbs

        // Perte de poids (on formate : entier => 0 décimale, sinon 2)
        String formatLossWeight(double v) {
          if (v.isNaN || v.isInfinite) return "0";
          return v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
        }

        final String lossWtStr = formatLossWeight(temp1);

        // temp_2 = temp_1 * 15.3
        final double temp2 = temp1 * 15.3;
        // r_temp_2 = round(temp_2 * 10) / 10  => 1 décimale
        final double rTemp2 = (temp2 * 10).round() / 10.0;
        final String lossH2OStr = rTemp2.toStringAsFixed(1);

        // temp_3 = (temp_1 / weightb) * 100
        final double temp3 = (temp1 / wb) * 100.0;
        // r_temp_3 = round(temp_3 * 100) / 100 => 2 décimales
        final double rTemp3 = (temp3 * 100).round() / 100.0;
        final String lossPctStr = rTemp3.toStringAsFixed(2);

        setState(() {
          losswt = lossWtStr;
          lossh2o = lossH2OStr;
          losspct = lossPctStr;
        });
      }

      HapticFeedback.lightImpact();

      debugPrint(
        '[WaterLoss Local] weightb=$wb weighta=$wa '
        'losswt=$losswt lossh2o=$lossh2o losspct=$losspct',
      );
    } catch (e) {
      debugPrint('❌ WaterLoss local calc error: $e');
      _showError(_TXT.errUnexpected);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ✅ Background image (same style as Beep file)
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

                                // Intro + image
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
                                              Container(
                                                width: 44,
                                                height: 44,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(14),
                                                  color: Colors.white.withOpacity(0.10),
                                                  border: Border.all(
                                                    color: Colors.white.withOpacity(0.14),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.water_drop_rounded,
                                                  color: cs.primary.withOpacity(0.92),
                                                  size: 22,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  _TXT.introTitle,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: t.textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.white.withOpacity(0.96),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(14),
                                            child: CachedNetworkImage(
                                              height: 180,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              imageUrl: _TXT.imageUrl,
                                              placeholder: (context, url) => const SizedBox(
                                                height: 180,
                                                child: Center(child: LoadingWidget()),
                                              ),
                                              errorWidget: (context, url, error) => const SizedBox(
                                                height: 180,
                                                child: Center(child: Icon(Icons.broken_image_rounded)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Formulaire
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                    child: _Glass(
                                      radius: 18,
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: CustomInput(
                                                        controller: weightbController,
                                                        inputType: InputType.text,
                                                        title: _TXT.beforeTitle,
                                                        hint: '170',
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    _UnitPill(text: _TXT.pounds, isDark: isDark),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: CustomInput(
                                                        controller: weightaController,
                                                        inputType: InputType.text,
                                                        title: _TXT.afterTitle,
                                                        hint: '166',
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    _UnitPill(text: _TXT.pounds, isDark: isDark),
                                                  ],
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
                                                      weightbController.text,
                                                      weightaController.text,
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

                                // Résultats
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                    child: _Glass(
                                      radius: 18,
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            _TXT.resultsTitle,
                                            style: t.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white.withOpacity(0.96),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          _ResultRowDark(title: _TXT.r1, value: losswt),
                                          _ResultRowDark(title: _TXT.r2, value: lossh2o, alt: true),
                                          _ResultRowDark(title: _TXT.r3, value: losspct),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Tips
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
                                            _TXT.tipsTitle,
                                            style: t.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white.withOpacity(0.96),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          for (int i = 0; i < _TXT.tips.length; i++)
                                            _TipRowDark(
                                              index: i + 1,
                                              text: _TXT.tips[i],
                                              alt: i.isOdd,
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
/* Header (same spirit as Beep file) */
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
            child: Icon(Icons.info_outline_rounded, color: cs.primary.withOpacity(0.92), size: 22),
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

/* ========================================================================== */
/* Buttons / Rows */
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

class _ResultRowDark extends StatelessWidget {
  final String title;
  final String value;
  final bool alt;

  const _ResultRowDark({
    required this.title,
    required this.value,
    this.alt = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(alt ? 0.11 : 0.08),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: t.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white.withOpacity(0.78),
              ),
            ),
          ),
          Text(
            value,
            style: t.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.96),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipRowDark extends StatelessWidget {
  final int index;
  final String text;
  final bool alt;

  const _TipRowDark({
    required this.index,
    required this.text,
    this.alt = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(alt ? 0.11 : 0.08),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: cs.primary.withOpacity(0.18),
              border: Border.all(color: cs.primary.withOpacity(0.30), width: 1),
            ),
            child: Text(
              '$index',
              style: t.textTheme.labelLarge?.copyWith(
                color: Colors.white.withOpacity(0.95),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              softWrap: true,
              style: t.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.82),
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitPill extends StatelessWidget {
  final String text;
  final bool isDark;

  const _UnitPill({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(isDark ? 0.14 : 0.14)),
        color: Colors.white.withOpacity(isDark ? 0.10 : 0.10),
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

/* ========================================================================== */
/* UI Kit (same as Beep file style) */
/* ========================================================================== */

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