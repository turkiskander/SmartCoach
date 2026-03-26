// lib/features/ppcalculator/target_heart_rate/target_heart_rate.dart
//
// ✅ LOGIQUE DE CALCUL INCHANGÉE (NE PAS TOUCHER)
// ✅ Design IDENTIQUE à BeepIntermittentTrainingView (BG + overlay + orbs + glass + header moderne)
// ✅ SANS TRADUCTION (pas de localization / pas de intl)

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../shared/widget/custom_input.dart';
import '../../../shared/widget/loading_widget.dart';

class _TXT {
  static const String screenTitle = "Target Heart Rate";
  static const String heroTitle = "Target Heart Rate Zones";
  static const String heroDesc1 =
      "Calculate your maximum heart rate and training zones.";
  static const String heroDesc2 =
      "This is an estimate. Adjust for your condition and professional advice.";

  static const String paramsTitle = "Parameters";
  static const String age = "Age";
  static const String ageHint = "30";
  static const String unitYears = "yrs";
  static const String calc = "Calculate";

  static const String resultsTitle = "YOUR RESULTS";
  static const String headerLeft = "Zone";
  static const String headerRight = "Value";

  static const String zMax = "Max HR";
  static const String z90 = "90% Zone";
  static const String z80 = "80% Zone";
  static const String z70 = "70% Zone";
  static const String z60 = "60% Zone";
}

class TargetHeartRate extends StatefulWidget {
  const TargetHeartRate({super.key});

  @override
  State<TargetHeartRate> createState() => _TargetHeartRateState();
}

class _TargetHeartRateState extends State<TargetHeartRate>
    with SingleTickerProviderStateMixin {
  static const String _bg = "assets/images/BgS.jfif";

  late final AnimationController _enterCtrl;

  final TextEditingController ageController = TextEditingController();

  bool _isLoading = false; // toujours false maintenant (plus d’API)

  String maxRate = "0";
  String rate90 = "0";
  String rate80 = "0";
  String rate70 = "0";
  String rate60 = "0";

  bool get _canSubmit => ageController.text.trim().isNotEmpty && !_isLoading;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    )..forward();
    ageController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    ageController.dispose();
    super.dispose();
  }

  /// ✅ NE PAS TOUCHER LA LOGIQUE
  void _computeTargetHeartRate() {
    final raw = ageController.text.trim();

    final age = int.tryParse(raw);
    if (age == null) {
      _showMessage("Input in the age field is invalid !!");
      return;
    }

    if (age < 10 || age > 100) {
      _showMessage(
        "Age must be between 10 and 100 years.\nPlease correct the entry.",
      );
      return;
    }

    HapticFeedback.selectionClick();

    final max = 220 - age;
    final v90 = (max * 0.90).round();
    final v80 = (max * 0.80).round();
    final v70 = (max * 0.70).round();
    final v60 = (max * 0.60).round();

    setState(() {
      maxRate = max.toString();
      rate90 = v90.toString();
      rate80 = v80.toString();
      rate70 = v70.toString();
      rate60 = v60.toString();
    });

    HapticFeedback.lightImpact();
  }

  void _showMessage(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Info'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
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

    // ✅ Fix dropdown sur fond blur (canvasColor)
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
          // ✅ Background
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

          // Orbs discrets
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
                  final fade = CurvedAnimation(
                    parent: _enterCtrl,
                    curve: Curves.easeOut,
                  ).value;

                  return Opacity(
                    opacity: fade,
                    child: Column(
                      children: [
                        _HeaderModern(
                          title: _TXT.screenTitle,
                          onBack: () => Navigator.of(context).maybePop(),
                          onAction: () {
                            HapticFeedback.selectionClick();
                            FocusScope.of(context).unfocus();
                          },
                          actionIcon: Icons.favorite_rounded,
                        ),
                        const SizedBox(height: 12),

                        Expanded(
                          child: _Glass(
                            radius: 20,
                            padding: EdgeInsets.zero,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Theme(
                                data: dropdownTheme,
                                child: CustomScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  slivers: [
                                    SliverToBoxAdapter(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            12, 12, 12, 8),
                                        child: _InfoBanner(
                                          title: "Ready",
                                          subtitle:
                                              "Enter your age, then calculate zones.",
                                          icon: Icons.monitor_heart_rounded,
                                        ),
                                      ),
                                    ),

                                    // Hero / Intro (image)
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
                                                  Container(
                                                    width: 44,
                                                    height: 44,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              14),
                                                      color: Colors.white
                                                          .withOpacity(0.10),
                                                      border: Border.all(
                                                        color: Colors.white
                                                            .withOpacity(0.14),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Icon(
                                                      Icons.favorite_rounded,
                                                      color: cs.primary
                                                          .withOpacity(0.92),
                                                      size: 22,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      _TXT.heroTitle,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: t.textTheme
                                                          .titleMedium
                                                          ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color: Colors.white
                                                            .withOpacity(0.96),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                child: CachedNetworkImage(
                                                  height: 180,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  imageUrl:
                                                      "https://application.sportspedagogue.com/_nuxt/img/target.2d03b59.jpg",
                                                  placeholder: (context, url) =>
                                                      const SizedBox(
                                                    height: 180,
                                                    child: Center(
                                                        child: LoadingWidget()),
                                                  ),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const SizedBox(
                                                    height: 180,
                                                    child: Center(
                                                      child: Icon(Icons
                                                          .broken_image_rounded),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                _TXT.heroDesc1,
                                                textAlign: TextAlign.center,
                                                style: t.textTheme.bodyMedium
                                                    ?.copyWith(
                                                  height: 1.25,
                                                  color: Colors.white
                                                      .withOpacity(0.82),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                _TXT.heroDesc2,
                                                textAlign: TextAlign.center,
                                                style: t.textTheme.bodySmall
                                                    ?.copyWith(
                                                  height: 1.25,
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

                                    // Form
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
                                                  Container(
                                                    width: 44,
                                                    height: 44,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              14),
                                                      color: Colors.white
                                                          .withOpacity(0.10),
                                                      border: Border.all(
                                                        color: Colors.white
                                                            .withOpacity(0.14),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Icon(
                                                      Icons.tune_rounded,
                                                      color: cs.primary
                                                          .withOpacity(0.92),
                                                      size: 22,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      _TXT.paramsTitle,
                                                      style: t.textTheme
                                                          .titleMedium
                                                          ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color: Colors.white
                                                            .withOpacity(0.96),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: CustomInput(
                                                      controller: ageController,
                                                      inputType: InputType.text,
                                                      title: _TXT.age,
                                                      hint: _TXT.ageHint,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  _UnitPill(text: _TXT.unitYears),
                                                ],
                                              ),
                                              const SizedBox(height: 14),
                                              Align(
                                                alignment: Alignment.centerRight,
                                                child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  onTap: _canSubmit
                                                      ? _computeTargetHeartRate
                                                      : null,
                                                  child: Opacity(
                                                    opacity:
                                                        _canSubmit ? 1.0 : 0.55,
                                                    child: _ActionButton(
                                                      icon: Icons
                                                          .auto_awesome_rounded,
                                                      label: _TXT.calc,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Results
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
                                                children: [
                                                  Container(
                                                    width: 44,
                                                    height: 44,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              14),
                                                      color: Colors.white
                                                          .withOpacity(0.10),
                                                      border: Border.all(
                                                        color: Colors.white
                                                            .withOpacity(0.14),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Icon(
                                                      Icons.analytics_rounded,
                                                      color: cs.primary
                                                          .withOpacity(0.92),
                                                      size: 22,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      _TXT.resultsTitle,
                                                      style: t.textTheme
                                                          .titleMedium
                                                          ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color: Colors.white
                                                            .withOpacity(0.96),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              _HeaderRowGlass(
                                                left: _TXT.headerLeft,
                                                right: _TXT.headerRight,
                                              ),
                                              const SizedBox(height: 8),
                                              _ResultRowGlass(
                                                alt: true,
                                                title: _TXT.zMax,
                                                value: maxRate,
                                              ),
                                              _ResultRowGlass(
                                                title: _TXT.z90,
                                                value: rate90,
                                              ),
                                              _ResultRowGlass(
                                                alt: true,
                                                title: _TXT.z80,
                                                value: rate80,
                                              ),
                                              _ResultRowGlass(
                                                title: _TXT.z70,
                                                value: rate70,
                                              ),
                                              _ResultRowGlass(
                                                alt: true,
                                                title: _TXT.z60,
                                                value: rate60,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SliverToBoxAdapter(
                                        child: SizedBox(height: 6)),
                                  ],
                                ),
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
/*                                    UI Kit                                  */
/* ========================================================================== */

class _HeaderModern extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onAction;
  final IconData actionIcon;

  const _HeaderModern({
    required this.title,
    required this.onBack,
    required this.onAction,
    required this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

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
          const SizedBox(width: 10),
          _PillIconButton(
            icon: actionIcon,
            onTap: onAction,
            accent: cs.primary.withOpacity(0.90),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _InfoBanner({
    required this.title,
    required this.subtitle,
    required this.icon,
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
            child: Icon(icon, color: cs.primary.withOpacity(0.92), size: 22),
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionButton({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.12),
        border: Border.all(color: Colors.white.withOpacity(0.16), width: 1),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            color: Colors.black.withOpacity(0.25),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: cs.primary.withOpacity(0.92)),
          const SizedBox(width: 8),
          Text(
            label,
            style: t.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.94),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderRowGlass extends StatelessWidget {
  final String left;
  final String right;

  const _HeaderRowGlass({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.12),
        border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              left,
              style: t.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(0.90),
              ),
            ),
          ),
          Text(
            right,
            style: t.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.90),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultRowGlass extends StatelessWidget {
  final String title;
  final String value;
  final bool alt;

  const _ResultRowGlass({
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
        color: alt ? Colors.white.withOpacity(0.11) : Colors.white.withOpacity(0.08),
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
          Row(
            children: [
              const Text('🫀'),
              const SizedBox(width: 6),
              Text(
                value,
                style: t.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withOpacity(0.96),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'bpm',
                style: t.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withOpacity(0.72),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UnitPill extends StatelessWidget {
  final String text;
  const _UnitPill({required this.text});

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
          color: Colors.white.withOpacity(0.85),
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
  final Color? accent;

  const _PillIconButton({
    required this.icon,
    required this.onTap,
    this.accent,
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
        child: Icon(icon, color: (accent ?? Colors.white.withOpacity(0.92)), size: 20),
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