import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IdealMeasurementsView extends StatefulWidget {
  const IdealMeasurementsView({super.key});

  @override
  State<IdealMeasurementsView> createState() => _IdealMeasurementsViewState();
}

class _TXT {
  static const String screenTitle = "Ideal Measurements";

  static const String navCalc = "Calculator";
  static const String navResults = "Results";
  static const String navInfo = "Info";
  static const String navMore = "More";

  static const String heroTitle = "Waist / Hip Ratio";
  static const String heroSubtitle =
      "Measure waist and hip circumference, choose sex, then calculate the waist-to-hip ratio and profile interpretation.";

  static const String calcIntro =
      "This tool estimates your waist-to-hip ratio and gives a simple body fat distribution interpretation.";

  static const String sex = "Sex";
  static const String male = "Male";
  static const String female = "Female";
  static const String waist = "Waist";
  static const String hip = "Hip";
  static const String centimeters = "cm";

  static const String calculate = "Calculate";
  static const String yourResults = "Your Results";
  static const String interpretationTitle = "Interpretation";
  static const String whrShort = "WHR";

  static const String infoTitle1 = "What is WHR?";
  static const String infoTitle2 = "Fat distribution";
  static const String infoTitle3 = "Body profiles";
  static const String infoTitle4 = "More details";
  static const String infoTitle5 = "Limits";

  static const String genderError = "Please select a sex before interpretation.";

  static const String noResultTitle = "No result yet";
  static const String noResultText =
      "Complete the form and calculate to see your waist-to-hip ratio.";

  static const String maleHighWhr =
      "A high waist-to-hip ratio suggests a more android fat distribution pattern.";
  static const String femaleHighWhr =
      "A high waist-to-hip ratio suggests a higher abdominal fat distribution.";
  static const String gynoidProfile =
      "This ratio suggests a more gynoid fat distribution profile.";
  static const String mixedProfile =
      "This ratio suggests a mixed or intermediate fat distribution profile.";

  static const String parag2 =
      "The waist-to-hip ratio is a simple anthropometric indicator used to describe fat distribution.";
  static const String parag3 =
      "It is useful as a complementary indicator, but it should not replace a full clinical or sports assessment.";
  static const String parag4 =
      "Android distribution generally refers to more abdominal fat accumulation.";
  static const String parag5 =
      "Gynoid distribution generally refers to more fat stored around hips and thighs.";
  static const String parag6 =
      "These patterns are descriptive and should be interpreted with context.";
  static const String parag7 =
      "Training level, age, genetics and body composition all influence interpretation.";
  static const String parag8 =
      "Visual comparison can help understand the difference between body fat distribution profiles.";
  static const String parag9 =
      "Images and diagrams are illustrative and not diagnostic.";
  static const String parag10 =
      "WHR is one indicator among many and should be combined with other measurements.";
  static const String parag11 =
      "For better interpretation, consider waist circumference, body fat estimation and medical context.";
  static const String parag12 =
      "Athletes may present specific body patterns that differ from general population references.";
  static const String parag13 =
      "This screen is intended for educational and fitness guidance purposes.";
}

class _IdealMeasurementsViewState extends State<IdealMeasurementsView>
    with TickerProviderStateMixin {
  static const String _bg = "assets/images/BgS.jfif";

  late final AnimationController _enterCtrl;
  late final PageController _pageController;

  int _pageIndex = 0;

  final TextEditingController waistController = TextEditingController(text: "0");
  final TextEditingController hipController = TextEditingController(text: "0");
  final TextEditingController sexController = TextEditingController();

  double _rth = 0;
  String _message = "";
  bool _hasResult = false;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    )..forward();

    _pageController = PageController();
    sexController.text = _TXT.male;
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _pageController.dispose();
    waistController.dispose();
    hipController.dispose();
    sexController.dispose();
    super.dispose();
  }

  double _safeDouble(String s) =>
      double.tryParse(s.trim().replaceAll(',', '.')) ?? 0.0;

  void _goToPage(int index) {
    HapticFeedback.selectionClick();
    setState(() => _pageIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _compute() {
    final waist = _safeDouble(waistController.text);
    final hip = _safeDouble(hipController.text);

    if (waist <= 0 || hip <= 0) {
      setState(() {
        _hasResult = false;
        _rth = 0;
        _message = "";
      });
      return;
    }

    final rth = waist / hip;
    final sexText = sexController.text.trim();

    if (sexText.isEmpty) {
      setState(() {
        _rth = rth;
        _message = _TXT.genderError;
        _hasResult = true;
      });
      return;
    }

    final isMale = sexText == _TXT.male;

    String msg;
    if (isMale) {
      if (rth > 0.95) {
        msg = _TXT.maleHighWhr;
      } else if (rth < 0.90) {
        msg = _TXT.gynoidProfile;
      } else {
        msg = _TXT.mixedProfile;
      }
    } else {
      if (rth > 0.80) {
        msg = _TXT.femaleHighWhr;
      } else if (rth < 0.75) {
        msg = _TXT.gynoidProfile;
      } else {
        msg = _TXT.mixedProfile;
      }
    }

    setState(() {
      _rth = rth;
      _message = msg;
      _hasResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

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
                          Colors.black.withOpacity(0.30),
                          Colors.black.withOpacity(0.62),
                        ]
                      : [
                          Colors.black.withOpacity(0.28),
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
                          onResults: () => _goToPage(1),
                        ),
                        const SizedBox(height: 12),
                        _QuickActions(
                          onCalc: () => _goToPage(0),
                          onGuide: () => _goToPage(2),
                        ),
                        const SizedBox(height: 12),
                        _ModernSectionNav(
                          currentIndex: _pageIndex,
                          onTap: _goToPage,
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: _Glass(
                            radius: 22,
                            padding: EdgeInsets.zero,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: PageView(
                                controller: _pageController,
                                onPageChanged: (i) {
                                  setState(() => _pageIndex = i);
                                },
                                children: [
                                  _buildCalcPage(context),
                                  _buildResultsPage(context),
                                  _buildInfoPage(context),
                                  _buildMorePage(context),
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

  Widget _buildCalcPage(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: const _InfoBanner(
              title: _TXT.heroTitle,
              subtitle: _TXT.heroSubtitle,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: _Glass(
              radius: 18,
              padding: const EdgeInsets.all(14),
              child: Text(
                _TXT.calcIntro,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.82),
                      height: 1.3,
                    ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
            child: _Glass(
              radius: 18,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _SectionHead(
                    icon: Icons.tune_rounded,
                    title: _TXT.navCalc,
                  ),
                  const SizedBox(height: 12),
                  _ModernDropdownField(
                    label: _TXT.sex,
                    value: sexController.text,
                    items: const [_TXT.female, _TXT.male],
                    onChanged: (v) {
                      setState(() => sexController.text = v ?? "");
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ModernNumberField(
                          label: "${_TXT.waist} (${_TXT.centimeters})",
                          controller: waistController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ModernNumberField(
                          label: "${_TXT.hip} (${_TXT.centimeters})",
                          controller: hipController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _ActionButton(
                    label: _TXT.calculate,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      _compute();
                      _goToPage(1);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsPage(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        if (!_hasResult)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: const _Glass(
                radius: 18,
                padding: EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SectionHead(
                      icon: Icons.info_outline_rounded,
                      title: _TXT.noResultTitle,
                    ),
                    SizedBox(height: 10),
                    _BodyText(_TXT.noResultText),
                  ],
                ),
              ),
            ),
          )
        else
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: _Glass(
                radius: 18,
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _SectionHead(
                      icon: Icons.analytics_rounded,
                      title: _TXT.yourResults,
                    ),
                    const SizedBox(height: 12),
                    _ResultLine(
                      label: _TXT.whrShort,
                      value: _rth.toStringAsFixed(2),
                      highlight: true,
                    ),
                    const SizedBox(height: 8),
                    const _SectionHead(
                      icon: Icons.psychology_rounded,
                      title: _TXT.interpretationTitle,
                    ),
                    const SizedBox(height: 10),
                    _BodyText(
                      _message,
                      align: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoPage(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: const _Glass(
              radius: 18,
              padding: EdgeInsets.all(14),
              child: _BodyText(_TXT.parag2),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: const _Glass(
              radius: 18,
              padding: EdgeInsets.all(14),
              child: _BodyText(
                _TXT.parag3,
                weight: FontWeight.w700,
                size: 12,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: const _Glass(
              radius: 18,
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionHead(
                    icon: Icons.menu_book_rounded,
                    title: _TXT.infoTitle2,
                  ),
                  SizedBox(height: 10),
                  _BodyText("${_TXT.parag4}\n\n${_TXT.parag5}"),
                  SizedBox(height: 10),
                  _BodyText(
                    _TXT.parag6,
                    weight: FontWeight.w700,
                    size: 12,
                  ),
                  SizedBox(height: 10),
                  _BodyText(_TXT.parag7),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
            child: const _Glass(
              radius: 18,
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionHead(
                    icon: Icons.accessibility_new_rounded,
                    title: _TXT.infoTitle3,
                  ),
                  SizedBox(height: 10),
                  _RemoteImage(
                    url:
                        "https://www.calculersonimc.fr/wp-content/uploads/2018/03/androide-gynoide.jpg",
                  ),
                  SizedBox(height: 10),
                  _BodyText(_TXT.parag8),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMorePage(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: const _Glass(
              radius: 18,
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _RemoteImage(
                    url:
                        "https://www.calculersonimc.fr/wp-content/uploads/2018/03/premiS%CC%8Cre-image-mika-1.jpg",
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: const _Glass(
              radius: 18,
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionHead(
                    icon: Icons.image_rounded,
                    title: _TXT.infoTitle4,
                  ),
                  SizedBox(height: 10),
                  _BodyText(_TXT.parag9),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: const _Glass(
              radius: 18,
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _BodyText(
                    _TXT.parag10,
                    weight: FontWeight.w700,
                    size: 12,
                  ),
                  SizedBox(height: 10),
                  _SectionHead(
                    icon: Icons.build_circle_rounded,
                    title: _TXT.infoTitle5,
                  ),
                  SizedBox(height: 10),
                  _BodyText("${_TXT.parag11}\n\n${_TXT.parag12}"),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
            child: const _Glass(
              radius: 18,
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionHead(
                    icon: Icons.note_alt_rounded,
                    title: "Usage",
                  ),
                  SizedBox(height: 10),
                  _BodyText(_TXT.parag13),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderModern extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onResults;

  const _HeaderModern({
    required this.title,
    required this.onBack,
    required this.onResults,
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
            icon: Icons.analytics_rounded,
            onTap: onResults,
            accent: Theme.of(context).colorScheme.primary.withOpacity(0.90),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onCalc;
  final VoidCallback onGuide;

  const _QuickActions({
    required this.onCalc,
    required this.onGuide,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _Glass(
            radius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  Icons.straighten_rounded,
                  size: 18,
                  color: cs.primary.withOpacity(0.92),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Ratio • Body profile",
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
          onTap: () {
            HapticFeedback.lightImpact();
            onGuide();
          },
          child: _Glass(
            radius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 18,
                  color: cs.primary.withOpacity(0.92),
                ),
                const SizedBox(width: 8),
                Text(
                  "Guide",
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

class _ModernSectionNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _ModernSectionNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavItemData(icon: Icons.tune_rounded, label: _TXT.navCalc),
      _NavItemData(icon: Icons.analytics_rounded, label: _TXT.navResults),
      _NavItemData(icon: Icons.menu_book_rounded, label: _TXT.navInfo),
      _NavItemData(icon: Icons.widgets_rounded, label: _TXT.navMore),
    ];

    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (_, i) {
          final item = items[i];
          return _NavPill(
            icon: item.icon,
            label: item.label,
            selected: i == currentIndex,
            onTap: () => onTap(i),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: items.length,
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;

  const _NavItemData({
    required this.icon,
    required this.label,
  });
}

class _NavPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavPill({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected
              ? cs.primary.withOpacity(0.22)
              : Colors.white.withOpacity(0.08),
          border: Border.all(
            color: selected
                ? cs.primary.withOpacity(0.45)
                : Colors.white.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: selected
                  ? cs.primary.withOpacity(0.95)
                  : Colors.white.withOpacity(0.84),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: t.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(selected ? 0.96 : 0.82),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHead extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHead({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: cs.primary.withOpacity(0.92)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
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
    final cs = Theme.of(context).colorScheme;

    return _Glass(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white.withOpacity(0.10),
              border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
            ),
            child: Icon(
              Icons.straighten_rounded,
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
                    height: 1.25,
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

class _ModernDropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _ModernDropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

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
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.10),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.85),
                width: 1.2,
              ),
            ),
          ),
          dropdownColor: const Color(0xFF101722),
          iconEnabledColor: Colors.white.withOpacity(0.90),
          style: t.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white.withOpacity(0.96),
          ),
          items: items
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(
                    e,
                    overflow: TextOverflow.ellipsis,
                    style: t.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.96),
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ModernNumberField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _ModernNumberField({
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

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
            hintText: "0",
            hintStyle: t.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.40),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.10),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.85),
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _animateTo(double t) =>
      _ctl.animateTo(t.clamp(0.0, 1.0), curve: Curves.easeOut);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blues = isDark
        ? const [Color(0xFF0B2447), Color(0xFF19376D)]
        : const [Color(0xFF1D4ED8), Color(0xFF3B82F6)];

    return MouseRegion(
      onEnter: (_) => _animateTo(0.5),
      onExit: (_) => _animateTo(0.0),
      child: GestureDetector(
        onTapDown: (_) => _animateTo(1.0),
        onTapUp: (_) {
          _animateTo(0.5);
          widget.onTap();
        },
        onTapCancel: () => _animateTo(0.0),
        child: AnimatedBuilder(
          animation: _ctl,
          builder: (_, __) {
            final v = _ctl.value;
            final scale = 1.0 - (0.03 * v);
            final blur = 10.0 + (10.0 * v);
            final spread = 0.0 + (2.0 * v);

            return Transform.scale(
              scale: scale,
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: blues,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: blues.last.withOpacity(0.50 * (0.3 + 0.7 * v)),
                      blurRadius: blur,
                      spreadRadius: spread,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ResultLine extends StatelessWidget {
  final String label;
  final Object? value;
  final bool highlight;

  const _ResultLine({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    if (value == null) return const SizedBox.shrink();

    final t = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: highlight
            ? cs.primary.withOpacity(0.18)
            : Colors.white.withOpacity(0.10),
        border: Border.all(
          color: highlight
              ? cs.primary.withOpacity(0.28)
              : Colors.white.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: t.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white.withOpacity(0.78),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              "$value",
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: t.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(0.96),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  final String text;
  final TextAlign align;
  final FontWeight? weight;
  final double? size;

  const _BodyText(
    this.text, {
    this.align = TextAlign.start,
    this.weight,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Text(
      text,
      textAlign: align,
      style: t.textTheme.bodyMedium?.copyWith(
        color: Colors.white.withOpacity(0.80),
        fontWeight: weight,
        fontSize: size,
        height: 1.38,
      ),
    );
  }
}

class _RemoteImage extends StatelessWidget {
  final String url;

  const _RemoteImage({
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      height: MediaQuery.of(context).size.height * 0.22,
      width: MediaQuery.of(context).size.width * 0.9,
      imageUrl: url,
      imageBuilder: (context, imageProvider) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        );
      },
      placeholder: (context, url) => SizedBox(
        height: 220,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        height: 220,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.08),
        ),
        child: Icon(
          Icons.broken_image_rounded,
          color: Colors.white.withOpacity(0.70),
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
    final bg = isDark
        ? Colors.white.withOpacity(0.07)
        : Colors.white.withOpacity(0.10);
    final border = isDark
        ? Colors.white.withOpacity(0.10)
        : Colors.white.withOpacity(0.14);

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