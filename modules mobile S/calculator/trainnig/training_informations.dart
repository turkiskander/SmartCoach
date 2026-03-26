import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'training_calcul.dart';

class TrainingInformations extends StatelessWidget {
  const TrainingInformations({super.key});

  static const String _bg = "assets/images/BgS.jfif";

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final isDark = t.brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

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

    const colorG1 = Color(0xFF22C55E);
    const colorG2 = Color(0xFFF59E0B);
    const colorG3 = Color(0xFFEF4444);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              _bg,
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Column(
                children: [
                  _HeaderModern(
                    title: _TXT.screenTitle,
                    onBack: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(height: 12),
                  _QuickActions(
                    onNext: () {
                      HapticFeedback.selectionClick();
                      Navigator.of(context).push(
                        _fancyRoute(const TrainingCalcul()),
                      );
                    },
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
                                padding:
                                    const EdgeInsets.fromLTRB(12, 12, 12, 8),
                                child: const _InfoBanner(
                                  title: _TXT.forInformation,
                                  subtitle:
                                      "This screen explains the workflow, the 15 blocks, the coefficients and the rules before opening the calculator.",
                                  icon: Icons.info_outline_rounded,
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                child: _Glass(
                                  radius: 18,
                                  padding: const EdgeInsets.all(14),
                                  child: const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _SectionTitle(
                                        title: _TXT.forInformation,
                                        emoji: "ℹ️",
                                      ),
                                      SizedBox(height: 12),
                                      _Bullet(text: _TXT.forInformation1),
                                      _Bullet(text: _TXT.forInformation2),
                                      _Bullet(text: _TXT.forInformation3),
                                      _Bullet(text: _TXT.forInformation4),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                child: _Glass(
                                  radius: 18,
                                  padding: const EdgeInsets.all(14),
                                  child: const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _SectionTitle(
                                        title: _TXT.trainingCalculation,
                                        emoji: "🏷️",
                                      ),
                                      SizedBox(height: 12),
                                      _GroupPreview(
                                        items: [
                                          _GroupItem(
                                            rangeLabel: "1–5",
                                            color: colorG1,
                                            emoji: "🟢",
                                          ),
                                          _GroupItem(
                                            rangeLabel: "6–10",
                                            color: colorG2,
                                            emoji: "🟠",
                                          ),
                                          _GroupItem(
                                            rangeLabel: "11–15",
                                            color: colorG3,
                                            emoji: "🔴",
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      _HintLine(text: _TXT.forInformation3),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                child: _Glass(
                                  radius: 18,
                                  padding: const EdgeInsets.all(14),
                                  child: const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _SectionTitle(
                                        title: _TXT.sessionLoadNormTitle,
                                        emoji: "📈",
                                      ),
                                      SizedBox(height: 12),
                                      _NormCard(text: _TXT.sessionLoadNormInline),
                                      SizedBox(height: 12),
                                      _SubBlockTitle(
                                        title: _TXT.forInformationLabel,
                                      ),
                                      SizedBox(height: 8),
                                      _Bullet(text: _TXT.trainingCoeffIntro),
                                      _Bullet(text: _TXT.trainingCoeffMax),
                                      _Bullet(
                                        text: _TXT.trainingCoeffVeryDifficult,
                                      ),
                                      _Bullet(text: _TXT.trainingCoeffDifficult),
                                      _Bullet(
                                        text: _TXT.trainingCoeffQuiteDifficult,
                                      ),
                                      _Bullet(text: _TXT.trainingCoeffMean),
                                      _Bullet(text: _TXT.trainingCoeffEasy),
                                      SizedBox(height: 12),
                                      _SubBlockTitle(title: _TXT.examplesLabel),
                                      SizedBox(height: 8),
                                      _Bullet(text: _TXT.trainingExample1),
                                      _Bullet(text: _TXT.trainingExample2),
                                      _Bullet(text: _TXT.trainingExample3),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                child: _Glass(
                                  radius: 18,
                                  padding: const EdgeInsets.all(14),
                                  child: const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _SectionTitle(
                                        title: _TXT.training,
                                        emoji: "📚",
                                      ),
                                      SizedBox(height: 12),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          _LegendChip(
                                            label: _TXT.maximum,
                                            emoji: "🚀",
                                            chipColor: Color(0xFF0EA5E9),
                                          ),
                                          _LegendChip(
                                            label: _TXT.veryDifficult,
                                            emoji: "🔥",
                                            chipColor: Color(0xFFEF4444),
                                          ),
                                          _LegendChip(
                                            label: _TXT.difficult,
                                            emoji: "💪",
                                            chipColor: Color(0xFFF59E0B),
                                          ),
                                          _LegendChip(
                                            label: _TXT.quiteDifficult,
                                            emoji: "⚡",
                                            chipColor: Color(0xFF22C55E),
                                          ),
                                          _LegendChip(
                                            label: _TXT.mean,
                                            emoji: "🎯",
                                            chipColor: Color(0xFF6366F1),
                                          ),
                                          _LegendChip(
                                            label: _TXT.easy,
                                            emoji: "🧘",
                                            chipColor: Color(0xFF84CC16),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 0, 12, 14),
                                child: _Glass(
                                  radius: 18,
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _NavButton(
                                          label: _TXT.back,
                                          icon: isRtl
                                              ? Icons.keyboard_arrow_right_rounded
                                              : Icons.keyboard_arrow_left_rounded,
                                          onTap: () {
                                            HapticFeedback.selectionClick();
                                            Navigator.of(context).maybePop();
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _NavButton(
                                          label: _TXT.next,
                                          icon: isRtl
                                              ? Icons.keyboard_arrow_left_rounded
                                              : Icons.keyboard_arrow_right_rounded,
                                          iconAtEnd: true,
                                          accent:
                                              cs.primary.withOpacity(0.92),
                                          onTap: () {
                                            HapticFeedback.selectionClick();
                                            Navigator.of(context).push(
                                              _fancyRoute(
                                                const TrainingCalcul(),
                                              ),
                                            );
                                          },
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TXT {
  static const String screenTitle = "Training Information";

  static const String forInformation = "For Information";
  static const String forInformation1 =
      "This screen explains how training load is organized before starting the calculation.";
  static const String forInformation2 =
      "The 15 blocks are split into 3 visual groups to make the workflow easier to read.";
  static const String forInformation3 =
      "Each group contains 5 blocks and follows the same calculation logic.";
  static const String forInformation4 =
      "You can review the rules here, then move to the calculator screen.";

  static const String trainingCalculation = "Training Calculation";
  static const String sessionLoadNormTitle = "Session Load Norm";
  static const String sessionLoadNormInline =
      "Indicative norm: Weak < 7000 • Average 7000–17000 • Big 17001–30000 • Very Large > 30000";

  static const String forInformationLabel = "Calculation Rules";
  static const String trainingCoeffIntro =
      "Each level of intensity has a coefficient used in the final block total.";
  static const String trainingCoeffMax = "Maximum = quantity × 64";
  static const String trainingCoeffVeryDifficult =
      "Very Difficult = quantity × 48";
  static const String trainingCoeffDifficult = "Difficult = quantity × 32";
  static const String trainingCoeffQuiteDifficult =
      "Quite Difficult = quantity × 16";
  static const String trainingCoeffMean = "Mean = quantity × 8";
  static const String trainingCoeffEasy = "Easy = quantity × 4";

  static const String examplesLabel = "Examples";
  static const String trainingExample1 =
      "Example 1: 2 Maximum + 1 Difficult = 2×64 + 1×32 = 160";
  static const String trainingExample2 =
      "Example 2: 3 Mean + 2 Easy = 3×8 + 2×4 = 32";
  static const String trainingExample3 =
      "Example 3: 1 Very Difficult + 2 Quite Difficult = 48 + 32 = 80";

  static const String training = "Training Intensities";
  static const String maximum = "Maximum";
  static const String veryDifficult = "Very Difficult";
  static const String difficult = "Difficult";
  static const String quiteDifficult = "Quite Difficult";
  static const String mean = "Mean";
  static const String easy = "Easy";

  static const String back = "Back";
  static const String next = "Next";
}

class _HeaderModern extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _HeaderModern({
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
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

class _QuickActions extends StatelessWidget {
  final VoidCallback onNext;

  const _QuickActions({required this.onNext});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Row(
      children: [
        Expanded(
          child: _Glass(
            radius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  Icons.rule_folder_outlined,
                  size: 18,
                  color: cs.primary.withOpacity(0.92),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Rules • Workflow",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withOpacity(0.84),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onNext,
          child: _Glass(
            radius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calculate_rounded,
                  size: 18,
                  color: cs.primary.withOpacity(0.92),
                ),
                const SizedBox(width: 8),
                Text(
                  _TXT.next,
                  style: t.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.90),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
              border: Border.all(
                color: Colors.white.withOpacity(0.14),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: cs.primary.withOpacity(0.92),
              size: 22,
            ),
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

class _SectionTitle extends StatelessWidget {
  final String title;
  final String emoji;

  const _SectionTitle({
    required this.title,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Row(
      children: [
        Text(emoji, style: t.textTheme.titleLarge),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.96),
            ),
          ),
        ),
      ],
    );
  }
}

class _SubBlockTitle extends StatelessWidget {
  final String title;

  const _SubBlockTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: Colors.white.withOpacity(0.96),
          ),
    );
  }
}

class _HintLine extends StatelessWidget {
  final String text;

  const _HintLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.72),
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
    );
  }
}

class _NormCard extends StatelessWidget {
  final String text;

  const _NormCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.10),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white.withOpacity(0.92),
              height: 1.3,
            ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;

  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.10),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "•",
            style: t.textTheme.titleMedium?.copyWith(
              color: Colors.white.withOpacity(0.90),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: t.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.82),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final String label;
  final String emoji;
  final Color chipColor;

  const _LegendChip({
    required this.label,
    required this.emoji,
    required this.chipColor,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: chipColor.withOpacity(0.18),
        border: Border.all(
          color: chipColor.withOpacity(0.45),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: t.textTheme.titleSmall),
          const SizedBox(width: 6),
          Text(
            label,
            style: t.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white.withOpacity(0.92),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupItem {
  final String rangeLabel;
  final Color color;
  final String emoji;

  const _GroupItem({
    required this.rangeLabel,
    required this.color,
    required this.emoji,
  });
}

class _GroupPreview extends StatelessWidget {
  final List<_GroupItem> items;

  const _GroupPreview({required this.items});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Row(
      children: items.map((g) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: g.color.withOpacity(0.18),
              border: Border.all(
                color: g.color.withOpacity(0.45),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(g.emoji, style: t.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  g.rangeLabel,
                  style: t.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.96),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool iconAtEnd;
  final Color? accent;

  const _NavButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.iconAtEnd = false,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final iconColor =
        accent ?? Theme.of(context).colorScheme.primary.withOpacity(0.92);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withOpacity(0.10),
          border: Border.all(
            color: Colors.white.withOpacity(0.14),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: iconAtEnd
              ? [
                  Text(
                    label,
                    style: t.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withOpacity(0.94),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(icon, size: 18, color: iconColor),
                ]
              : [
                  Icon(icon, size: 18, color: iconColor),
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
    final border = isDark
        ? Colors.white.withOpacity(0.10)
        : Colors.white.withOpacity(0.14);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
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
          border: Border.all(
            color: Colors.white.withOpacity(0.14),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: accent ?? Colors.white.withOpacity(0.92),
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

Route _fancyRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, anim, __, child) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: Curves.easeInOut,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween(begin: 0.98, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}