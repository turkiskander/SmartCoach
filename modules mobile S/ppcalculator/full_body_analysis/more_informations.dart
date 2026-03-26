// lib/features/ppcalculator/full_body_analysis/more_informations.dart
//
// ✅ DESIGN aligned to BeepIntermittentTrainingView (BgS.jfif + overlay + orbs + glass)
// ✅ Même contenu (sections) + même logique de recherche/filtre (inchangée)
// ✅ BottomSheet détails + chips navigation + FAB menu
// ✅ Aucun intl / aucun package externe
//
// REQUIRED ASSET:
// - assets/images/BgS.jfif

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MoreInformations extends StatefulWidget {
  const MoreInformations({super.key});

  @override
  State<MoreInformations> createState() => _MoreInformationsState();
}

class _MoreInformationsState extends State<MoreInformations>
    with TickerProviderStateMixin {
  static const String _bg = "assets/images/BgS.jfif";

  late final AnimationController _enterCtl;

  final ScrollController _scrollCtrl = ScrollController();
  final GlobalKey _kTop = GlobalKey();
  final GlobalKey _kList = GlobalKey();
  final GlobalKey _kBottom = GlobalKey();

  final TextEditingController _searchCtl = TextEditingController();
  String _q = '';

  @override
  void initState() {
    super.initState();

    _enterCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 820),
    )..forward();

    _searchCtl.addListener(() {
      setState(() => _q = _searchCtl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _enterCtl.dispose();
    _scrollCtrl.dispose();
    _searchCtl.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    HapticFeedback.selectionClick();
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      alignment: 0.06,
    );
  }

  void _clearSearch() {
    HapticFeedback.lightImpact();
    _searchCtl.clear();
    FocusScope.of(context).unfocus();
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

    final allSections = <({String n, String title, String body})>[
      (n: '1', title: 'BMI (Body Mass Index)', body: 'A quick estimate based on height and weight. It does not measure body fat directly.'),
      (n: '2', title: 'BMI Classification', body: 'Categories such as underweight, normal, overweight, obese are derived from BMI ranges.'),
      (n: '3', title: 'Waist / Hip Ratio', body: 'Compares waist to hip size. It is commonly used to estimate fat distribution.'),
      (n: '4', title: 'Body Shape', body: 'A simple classification (Apple/Pear) based on waist and hip measurements.'),
      (n: '5', title: 'Waist/Hip Interpretation', body: 'A risk level interpretation using the waist/hip ratio.'),
      (n: '6', title: 'Frame Size', body: 'Estimated using height and elbow measure to classify small/medium/large frame.'),
      (n: '7', title: 'Ideal Weight Range', body: 'A reference range (in lb) based on height and frame size.'),
      (n: '8', title: 'Lean Mass', body: 'Estimated weight of everything except fat (muscle, bone, organs, water).'),
      (n: '9', title: 'Fat Mass', body: 'Estimated fat weight and fat percentage derived from lean mass estimation.'),
      (n: '10', title: 'RMR (Resting Metabolic Rate)', body: 'Estimated calories burned per day at rest (baseline energy needs).'),
      (n: '11', title: 'Average Daily Calories', body: 'RMR multiplied by activity factor to estimate daily energy expenditure.'),
      (n: '12', title: 'Target Heart Rate', body: 'Karvonen method uses max HR and resting HR to estimate training zones.'),
      (n: '13', title: 'Max Heart Rate', body: 'A rough estimate based on age (different formulas for male/female).'),
    ];

    final sections = _q.isEmpty
        ? allSections
        : allSections
            .where((s) =>
                s.title.toLowerCase().contains(_q) ||
                s.body.toLowerCase().contains(_q) ||
                s.n.toLowerCase().contains(_q))
            .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _ScrollFAB(
        onTop: () => _scrollTo(_kTop),
        onList: () => _scrollTo(_kList),
        onBottom: () => _scrollTo(_kBottom),
      ),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              _bg,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0B0F14)),
            ),
          ),

          // Overlay premium
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [
                          Colors.black.withOpacity(0.55),
                          Colors.black.withOpacity(0.30),
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
            top: -170,
            left: -170,
            child: _GlowOrb(
              size: 390,
              color: cs.primary.withOpacity(isDark ? 0.10 : 0.08),
            ),
          ),
          Positioned(
            bottom: -180,
            right: -180,
            child: _GlowOrb(
              size: 420,
              color: (cs.tertiary == cs.primary ? cs.secondary : cs.tertiary)
                  .withOpacity(isDark ? 0.12 : 0.10),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: AnimatedBuilder(
                animation: _enterCtl,
                builder: (_, __) {
                  final fade = CurvedAnimation(parent: _enterCtl, curve: Curves.easeOut).value;

                  return Opacity(
                    opacity: fade,
                    child: Column(
                      children: [
                        _HeaderModern(
                          title: "More Information",
                          onBack: () => Navigator.of(context).maybePop(),
                          onClear: _clearSearch,
                        ),
                        const SizedBox(height: 12),

                        _QuickNavChips(
                          onTop: () => _scrollTo(_kTop),
                          onList: () => _scrollTo(_kList),
                          onBottom: () => _scrollTo(_kBottom),
                        ),
                        const SizedBox(height: 12),

                        Expanded(
                          child: _Glass(
                            radius: 20,
                            padding: EdgeInsets.zero,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: CustomScrollView(
                                key: _kTop,
                                controller: _scrollCtrl,
                                physics: const BouncingScrollPhysics(),
                                slivers: [
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                                      child: _Glass(
                                        radius: 18,
                                        padding: const EdgeInsets.all(14),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text('ℹ️', style: t.textTheme.headlineSmall),
                                                const SizedBox(width: 8),
                                                Flexible(
                                                  child: Text(
                                                    "How to read these results",
                                                    textAlign: TextAlign.center,
                                                    style: t.textTheme.titleLarge?.copyWith(
                                                      fontWeight: FontWeight.w900,
                                                      color: Colors.white.withOpacity(0.96),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              "These explanations help you understand what each metric means.",
                                              textAlign: TextAlign.center,
                                              style: t.textTheme.bodyMedium?.copyWith(
                                                color: Colors.white.withOpacity(0.80),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 12),

                                            _SearchBar(
                                              controller: _searchCtl,
                                              hint: "Search (BMI, RMR, heart rate...)",
                                              onClear: _clearSearch,
                                            ),
                                            const SizedBox(height: 10),

                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    "Items: ${sections.length}/${allSections.length}",
                                                    style: t.textTheme.bodySmall?.copyWith(
                                                      fontWeight: FontWeight.w700,
                                                      color: Colors.white.withOpacity(0.72),
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  _q.isEmpty ? "All" : "Filtered",
                                                  style: t.textTheme.bodySmall?.copyWith(
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.white.withOpacity(0.88),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  SliverToBoxAdapter(
                                    key: _kList,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
                                      child: _SectionTitle(
                                        icon: Icons.menu_book_rounded,
                                        title: "Explanations",
                                        subtitle: "Tap a card for details.",
                                      ),
                                    ),
                                  ),

                                  SliverList.builder(
                                    itemCount: sections.length,
                                    itemBuilder: (context, i) {
                                      final s = sections[i];
                                      final alt = i.isOdd;

                                      return Padding(
                                        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                                        child: _InfoCard(
                                          number: s.n,
                                          title: s.title,
                                          body: s.body,
                                          alt: alt,
                                          onTap: () {
                                            HapticFeedback.lightImpact();
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              backgroundColor: Colors.transparent,
                                              builder: (_) => _InfoSheet(
                                                number: s.n,
                                                title: s.title,
                                                body: s.body,
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),

                                  SliverToBoxAdapter(
                                    key: _kBottom,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                                      child: _Glass(
                                        radius: 20,
                                        padding: const EdgeInsets.all(14),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.health_and_safety_rounded,
                                                    color: cs.primary.withOpacity(0.92)),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    "Tip: If you have health concerns, consult a healthcare professional.",
                                                    style: t.textTheme.titleSmall?.copyWith(
                                                      fontWeight: FontWeight.w900,
                                                      color: Colors.white.withOpacity(0.94),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              "These values are estimations and do not replace medical diagnosis.",
                                              style: t.textTheme.bodySmall?.copyWith(
                                                color: Colors.white.withOpacity(0.72),
                                                fontWeight: FontWeight.w600,
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
/* UI */
/* ========================================================================== */

class _HeaderModern extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onClear;

  const _HeaderModern({
    required this.title,
    required this.onBack,
    required this.onClear,
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
          const SizedBox(width: 10),
          _PillIconButton(
            icon: Icons.clear_rounded,
            onTap: () {
              HapticFeedback.lightImpact();
              onClear();
            },
          ),
        ],
      ),
    );
  }
}

class _QuickNavChips extends StatelessWidget {
  final VoidCallback onTop;
  final VoidCallback onList;
  final VoidCallback onBottom;

  const _QuickNavChips({
    required this.onTop,
    required this.onList,
    required this.onBottom,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    Widget chip(IconData icon, String label, VoidCallback onTap) {
      return InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: _Glass(
          radius: 18,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: cs.primary.withOpacity(0.92)),
              const SizedBox(width: 8),
              Text(
                label,
                style: t.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withOpacity(0.90),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          chip(Icons.arrow_upward_rounded, "Top", onTop),
          const SizedBox(width: 10),
          chip(Icons.view_list_rounded, "List", onList),
          const SizedBox(width: 10),
          chip(Icons.info_outline_rounded, "Tip", onBottom),
        ],
      ),
    );
  }
}

class _ScrollFAB extends StatefulWidget {
  final VoidCallback onTop;
  final VoidCallback onList;
  final VoidCallback onBottom;

  const _ScrollFAB({
    required this.onTop,
    required this.onList,
    required this.onBottom,
  });

  @override
  State<_ScrollFAB> createState() => _ScrollFABState();
}

class _ScrollFABState extends State<_ScrollFAB> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget mini(IconData icon, String tag, VoidCallback onTap) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton.small(
          heroTag: tag,
          onPressed: () {
            HapticFeedback.selectionClick();
            setState(() => _open = false);
            onTap();
          },
          backgroundColor: Colors.white.withOpacity(0.12),
          elevation: 0,
          child: Icon(icon, color: cs.primary.withOpacity(0.92)),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_open) ...[
          mini(Icons.info_outline_rounded, "MI_fab_bottom", widget.onBottom),
          mini(Icons.view_list_rounded, "MI_fab_list", widget.onList),
          mini(Icons.arrow_upward_rounded, "MI_fab_top", widget.onTop),
        ],
        FloatingActionButton(
          heroTag: "MI_fab_main",
          onPressed: () {
            HapticFeedback.lightImpact();
            setState(() => _open = !_open);
          },
          backgroundColor: Colors.white.withOpacity(0.14),
          elevation: 0,
          child: Icon(
            _open ? Icons.close_rounded : Icons.navigation_rounded,
            color: cs.primary.withOpacity(0.95),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.hint,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return TextFormField(
      controller: controller,
      style: t.textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.92)),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.80)),
        suffixIcon: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onClear,
          child: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.72)),
        ),
        hintText: hint,
        hintStyle: t.textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.38)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.85)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.icon,
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

class _InfoCard extends StatelessWidget {
  final String number;
  final String title;
  final String body;
  final bool alt;
  final VoidCallback onTap;

  const _InfoCard({
    required this.number,
    required this.title,
    required this.body,
    required this.alt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: _Glass(
        radius: 20,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _NumberBadge(n: number),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: t.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withOpacity(0.96),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(Icons.open_in_full_rounded, size: 18, color: cs.primary.withOpacity(0.85)),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withOpacity(alt ? 0.10 : 0.08),
                border: Border.all(color: Colors.white.withOpacity(0.10)),
              ),
              child: Text(
                body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: t.textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                  color: Colors.white.withOpacity(0.78),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSheet extends StatelessWidget {
  final String number;
  final String title;
  final String body;

  const _InfoSheet({
    required this.number,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return _Glass(
      radius: 22,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          color: Colors.black.withOpacity(0.16),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: Colors.white.withOpacity(0.25),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _NumberBadge(n: number),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          style: t.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: Colors.white.withOpacity(0.96),
                          ),
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: Colors.white.withOpacity(0.10),
                            border: Border.all(color: Colors.white.withOpacity(0.14)),
                          ),
                          child: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.92)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    body,
                    style: t.textTheme.bodyLarge?.copyWith(
                      height: 1.55,
                      color: Colors.white.withOpacity(0.82),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  final String n;
  const _NumberBadge({required this.n});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: cs.primary.withOpacity(0.22),
        border: Border.all(color: cs.primary.withOpacity(0.45), width: 1),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.16),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Text(
        n,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

/* ========================================================================== */
/* Glass kit */
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