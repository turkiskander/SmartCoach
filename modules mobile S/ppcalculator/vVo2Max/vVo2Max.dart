/// lib/feature/ppCalculator/vvo2max/vvo2max.dart  (adapte ton chemin)
///
/// ✅ LOGIQUE DE CALCUL INCHANGÉE (getResult identique)
/// ✅ Traduction supprimée (no localization)
/// ✅ Design identique à BeepIntermittentTrainingView/VMA (BG image + overlay + orbs + header moderne + glass cards)
///
/// REQUIRED ASSET:
/// - assets/images/BgS.jfif  (déclaré dans pubspec.yaml)

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _TXT {
  // Screen
  static const String screenTitle = "vVO2max";
  static const String introTitle = "vVO2max Calculator";
  static const String introDesc =
      "Enter a distance (meters). Results are computed locally using the same formula.";

  // Form
  static const String distance = "Distance";
  static const String meters = "m";
  static const String compute = "Calculate";

  // Result
  static const String vvo2 = "vVO2max";
  static const String vvo2Unit = "m/s";

  // Details
  static const String detailsTitle = "Details";
  static const String detailsHint =
      "Useful training guidance derived from the computed values.";
  static const String d30Label = "30-15 distance (d30)";
  static const String s400Label = "400m time (sec)";
  static const String calcBlockTitle = "Computation";
  static const String tdistLabel = "tdist";
  static const String timeLabel = "Time";
  static const String approxLabel = "Approx. (r30)";

  // Errors
  static const String errTitle = "Error";
  static const String errDistance = "Distance input is invalid";
  static const String errUnexpected = "Unexpected error, please check your input";
}

class VVo2Max extends StatefulWidget {
  const VVo2Max({super.key});

  @override
  State<VVo2Max> createState() => _VVo2MaxState();
}

class _VVo2MaxState extends State<VVo2Max> with TickerProviderStateMixin {
  static const String _bg = "assets/images/BgS.jfif";

  late final AnimationController _enterCtrl;

  // UI
  final TextEditingController distController = TextEditingController();
  bool _isLoading = false;

  // Résultats (calculés en local)
  String vVO2max = "0"; // vitesse (vel)
  String times = "0"; // tdist
  String mins = "0"; // minutes
  String secs = "0"; // secondes
  String shortMeters = "0"; // d30
  String approximately = "0"; // r30
  String shortSecond = "0"; // secs400

  @override
  void initState() {
    super.initState();

    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    )..forward();

    distController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    distController.dispose();
    super.dispose();
  }

  bool get _canSubmit => distController.text.trim().isNotEmpty && !_isLoading;

  /// ⚙️ Logique locale = même calcul que la fonction JS `convert()`
  Future<void> getResult(dynamic dist, BuildContext context) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    HapticFeedback.selectionClick();

    try {
      String _norm(dynamic v) =>
          v == null ? '' : v.toString().trim().replaceAll(',', '.');

      final String distStr = _norm(dist);
      final double? distVal = double.tryParse(distStr);

      // validation input
      if (distVal == null || distVal <= 0) {
        _showErrorDialog(context, _TXT.errDistance);
        setState(() => _isLoading = false);
        return;
      }

      final double distMeters = distVal;

      // --- même logique que le JS ---
      final double vel = distMeters / 360.0; // vVO2max (m/s)
      final double tdist = (distMeters / 200.0).ceil() * 100.0;
      final double d30 = (tdist / 6.0).ceilToDouble();
      final double r30 = (d30 / 2.0).ceilToDouble();

      final double ttime = tdist / vel; // en secondes
      final int minsVal = (ttime / 60.0).floor();
      final int secsVal = (ttime - 60.0 * minsVal).ceil();

      final int secs400 = (400.0 / vel).ceil();

      setState(() {
        vVO2max = vel.toString(); // affichage en 2 décimales dans _AnimatedMetric
        times = tdist.toStringAsFixed(0);
        mins = minsVal.toString();
        secs = secsVal.toString();
        shortMeters = d30.toStringAsFixed(0);
        approximately = r30.toStringAsFixed(0);
        shortSecond = secs400.toString();
      });

      HapticFeedback.lightImpact();

      debugPrint(
        '[vVO2max Local] dist=$distMeters vel=$vel tdist=$tdist '
        'd30=$d30 r30=$r30 mins=$minsVal secs=$secsVal secs400=$secs400',
      );
    } catch (e) {
      debugPrint('❌ vVO2max local calc error: $e');
      _showErrorDialog(context, _TXT.errUnexpected);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
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
          // ✅ Background image
          Positioned.fill(
            child: Image.asset(
              _bg,
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
              child: AnimatedBuilder(
                animation: _enterCtrl,
                builder: (context, _) {
                  final fade =
                      CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut)
                          .value;

                  return Opacity(
                    opacity: fade,
                    child: Column(
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
                                      padding: const EdgeInsets.fromLTRB(
                                          12, 12, 12, 8),
                                      child: _InfoBanner(
                                        title: _TXT.introTitle,
                                        subtitle: _TXT.introDesc,
                                      ),
                                    ),
                                  ),

                                  // Formulaire
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          12, 0, 12, 10),
                                      child: _Glass(
                                        radius: 18,
                                        padding: const EdgeInsets.all(14),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: _TextInputField(
                                                    controller: distController,
                                                    label: _TXT.distance,
                                                    hint: _TXT.distance,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                _UnitChip(text: _TXT.meters),
                                              ],
                                            ),
                                            const SizedBox(height: 16),

                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                onTap: _canSubmit
                                                    ? () => getResult(
                                                          distController.text,
                                                          context,
                                                        )
                                                    : null,
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 14,
                                                    vertical: 12,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            14),
                                                    color: Colors.white
                                                        .withOpacity(_canSubmit
                                                            ? 0.12
                                                            : 0.08),
                                                    border: Border.all(
                                                      color: Colors.white
                                                          .withOpacity(_canSubmit
                                                              ? 0.16
                                                              : 0.10),
                                                      width: 1,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        blurRadius: 18,
                                                        color: Colors.black
                                                            .withOpacity(0.25),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      if (_isLoading)
                                                        const SizedBox(
                                                          height: 16,
                                                          width: 16,
                                                          child:
                                                              CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: Colors.white,
                                                          ),
                                                        )
                                                      else
                                                        Icon(
                                                          Icons.auto_awesome_rounded,
                                                          size: 18,
                                                          color: cs.primary
                                                              .withOpacity(
                                                                  0.92),
                                                        ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        _TXT.compute,
                                                        style: t.textTheme
                                                            .labelLarge
                                                            ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          color: Colors.white
                                                              .withOpacity(_canSubmit
                                                                  ? 0.94
                                                                  : 0.70),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Résultat principal
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          12, 0, 12, 10),
                                      child: _Glass(
                                        radius: 18,
                                        padding: const EdgeInsets.all(14),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text('🏁',
                                                    style:
                                                        t.textTheme.titleLarge),
                                                const SizedBox(width: 8),
                                                Text(
                                                  _TXT.vvo2,
                                                  style: t.textTheme.titleLarge
                                                      ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.w900,
                                                    foreground: Paint()
                                                      ..shader =
                                                          const LinearGradient(
                                                        colors: [
                                                          Color(0xFF06B6D4),
                                                          Color(0xFF3B82F6)
                                                        ],
                                                      ).createShader(
                                                              const Rect.fromLTWH(
                                                                  0,
                                                                  0,
                                                                  260,
                                                                  40)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            _AnimatedMetric(
                                              value: double.tryParse(vVO2max) ??
                                                  0,
                                              unit: _TXT.vvo2Unit,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Détails
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          12, 0, 12, 14),
                                      child: _Glass(
                                        radius: 18,
                                        padding: const EdgeInsets.all(14),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text('📌',
                                                    style:
                                                        t.textTheme.titleLarge),
                                                const SizedBox(width: 8),
                                                Text(
                                                  _TXT.detailsTitle,
                                                  style: t.textTheme.titleLarge
                                                      ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.w900,
                                                    color: Colors.white
                                                        .withOpacity(0.94),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              _TXT.detailsHint,
                                              textAlign: TextAlign.center,
                                              style: t.textTheme.bodyMedium
                                                  ?.copyWith(
                                                color: Colors.white
                                                    .withOpacity(0.70),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 12),

                                            _KeyValueRow(
                                              emoji: '↔️',
                                              label: _TXT.d30Label,
                                              value: shortMeters,
                                              isDark: isDark,
                                            ),
                                            const SizedBox(height: 6),
                                            _KeyValueRow(
                                              emoji: '⏱️',
                                              label: _TXT.s400Label,
                                              value: shortSecond,
                                              isDark: isDark,
                                            ),
                                            const SizedBox(height: 16),

                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text('🧮',
                                                    style:
                                                        t.textTheme.titleLarge),
                                                const SizedBox(width: 8),
                                                Text(
                                                  _TXT.calcBlockTitle,
                                                  style: t.textTheme.titleLarge
                                                      ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.w900,
                                                    color: Colors.white
                                                        .withOpacity(0.94),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),

                                            Text(
                                              "${_TXT.tdistLabel}: $times • ${_TXT.timeLabel}: $mins min $secs s",
                                              textAlign: TextAlign.center,
                                              style: t.textTheme.bodyMedium
                                                  ?.copyWith(
                                                color: Colors.white
                                                    .withOpacity(0.84),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "${_TXT.approxLabel}: $approximately",
                                              textAlign: TextAlign.center,
                                              style: t.textTheme.bodyMedium
                                                  ?.copyWith(
                                                color: Colors.white
                                                    .withOpacity(0.70),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SliverToBoxAdapter(
                                      child: SizedBox(height: 14)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
/* UI kit (même que Beep/VMA) */
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
            child: Icon(Icons.speed_rounded, color: cs.primary.withOpacity(0.92), size: 22),
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
                  maxLines: 3,
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

class _UnitChip extends StatelessWidget {
  final String text;
  const _UnitChip({required this.text});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
        color: Colors.white.withOpacity(0.10),
      ),
      child: Text(
        text,
        style: t.textTheme.labelLarge?.copyWith(
          color: Colors.white.withOpacity(0.86),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _TextInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;

  const _TextInputField({
    required this.controller,
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: t.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.white.withOpacity(0.78),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: t.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: Colors.white.withOpacity(0.96),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: t.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.45),
              fontWeight: FontWeight.w700,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.10),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.14)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: cs.primary.withOpacity(0.85), width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final bool isDark;

  const _KeyValueRow({
    required this.emoji,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white.withOpacity(0.78),
          fontWeight: FontWeight.w800,
        );
    final valueStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white.withOpacity(0.96),
          fontWeight: FontWeight.w900,
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(emoji, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            style: textStyle,
            textAlign: TextAlign.center,
          ),
        ),
        if (value.isNotEmpty) ...[
          const SizedBox(width: 8),
          Text(value, style: valueStyle),
        ],
      ],
    );
  }
}

class _AnimatedMetric extends StatelessWidget {
  final double value;
  final String unit;

  const _AnimatedMetric({
    required this.value,
    required this.unit,
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
            v.toStringAsFixed(2),
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
              fontWeight: FontWeight.w800,
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