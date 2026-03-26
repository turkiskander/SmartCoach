import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BiologicalAgeView extends StatefulWidget {
  const BiologicalAgeView({super.key});

  @override
  State<BiologicalAgeView> createState() => _BiologicalAgeViewState();
}

class _TXT {
  static const String screenTitle = "Biological Age";

  static const String navProfile = "Profile";
  static const String navHealth = "Health";
  static const String navDiet = "Diet";
  static const String navMind = "Mind";
  static const String navResults = "Results";

  static const String heroTitle = "Biological age estimator";
  static const String heroSubtitle =
      "Complete the sections, enter your current age, then calculate your biological age and expected lifespan.";

  static const String quickGuide = "Guide";
  static const String quickResults = "Results";
  static const String quickSections = "5 sections";

  static const String profileLifestyle = "Profile & lifestyle";
  static const String cardioHealth = "Cardiovascular risk";
  static const String medicalHealth = "General medical health";
  static const String womenHealth = "Women-specific health";
  static const String dietHealth = "Nutrition";
  static const String psychHealth = "Psychological & social";
  static const String safetyHealth = "Driving safety";

  static const String sex = "Sex";
  static const String male = "Male";
  static const String female = "Female";

  static const String race = "Ethnicity";
  static const String raceWhite = "White";
  static const String raceBlack = "Black";
  static const String raceHispanic = "Hispanic";
  static const String raceAsian = "Asian";
  static const String raceAmerindian = "Amerindian";
  static const String raceOther = "Other";

  static const String longevity = "Family longevity";
  static const String education = "Education level";
  static const String sleep = "Sleep";

  static const String hdl = "Cholesterol / HDL";
  static const String blood = "Blood pressure";
  static const String smoking = "Smoking";
  static const String heredity = "Family history";
  static const String bodyIndex = "Weight / body index";
  static const String stress = "Stress";
  static const String physical = "Physical activity";

  static const String tests = "Medical check-ups";
  static const String heart = "Heart condition";
  static const String lungs = "Lung condition";
  static const String digestive = "Digestive system";
  static const String diabetes = "Diabetes";
  static const String drugs = "Medication / drug exposure";

  static const String women = "Gynecological health";
  static const String pill = "Contraceptive pill";

  static const String breakfast = "Breakfast habits";
  static const String dailyMeals = "Daily meals";
  static const String fruitVeg = "Fruit & vegetables";
  static const String fats = "Dietary fats";
  static const String refinedFood = "Refined food";
  static const String alcohol = "Alcohol";

  static const String happy = "Happiness";
  static const String depression = "Depression";
  static const String anxiety = "Anxiety";
  static const String relaxation = "Relaxation";
  static const String love = "Love / relationship";
  static const String job = "Job satisfaction";
  static const String social = "Social life";

  static const String driving = "Driving behavior";
  static const String seatbelt = "Seatbelt use";
  static const String risk = "Risk-taking";

  static const String currentAge = "Current age";
  static const String calculate = "Calculate";
  static const String invalidAge = "Please enter a valid current age.";

  static const String results = "Your Results";
  static const String noResultsTitle = "No calculation yet";
  static const String noResultsText =
      "Complete the sections, enter your current age, then calculate to see your biological age.";
  static const String subtotalProfile = "Personal (lifestyle)";
  static const String subtotalCad = "CAD (heart risk)";
  static const String subtotalMedical = "Medical";
  static const String subtotalDiet = "Diet";
  static const String subtotalPsych = "Psychological";
  static const String subtotalSafety = "Safety";
  static const String totalScore = "Total score";
  static const String typicalLife = "Typical life expectancy";
  static const String expectedLife = "Expected lifespan";
  static const String biologicalAge = "Biological (health) age";
  static const String diffAge = "Difference vs current age";

  static const String tipsTitle = "How it works";
  static const String tipsText =
      "Each selection adds or subtracts points. The total score adjusts life expectancy and biological age estimate.";
}

class _BiologicalAgeViewState extends State<BiologicalAgeView>
    with TickerProviderStateMixin {
  static const String _bg = "assets/images/BgS.jfif";

  late final AnimationController _enterCtrl;
  late final PageController _pageController;

  int _pageIndex = 0;

  // Profil & mode de vie
  int? vSex;
  int? vRace;
  int? vLongevity;
  int? vEducation;
  int? vSleep;

  // Données CAD
  int? vCholesterol;
  int? vBp;
  int? vSmoking;
  int? vHeredity;
  int? vWeight;
  int? vStress;
  int? vActivity;

  // Médical global
  int? vMedExam;
  int? vHeart;
  int? vLung;
  int? vDigestive;
  int? vDiabetes;
  int? vDrugs;
  int? vFemaleHealth;
  int? vPill;

  // Diet
  int? vBreakfast;
  int? vMeals;
  int? vVeg;
  int? vFats;
  int? vRefined;
  int? vAlcohol;

  // Psycho & social
  int? vHappiness;
  int? vDepression;
  int? vAnxiety;
  int? vRelax;
  int? vLove;
  int? vJob;
  int? vSocial;

  // Sécurité routière
  int? vDriving;
  int? vSeatbelt;
  int? vRisk;

  final ageController = TextEditingController();

  // Résultats
  int? _personalT;
  int? _medicalT;
  int? _cadT;
  int? _dietT;
  int? _psychT;
  int? _safetyT;
  int? _total;

  double? _typicLifeExp;
  double? _expectancy;
  double? _healthAge;
  double? _difference;

  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    )..forward();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _pageController.dispose();
    ageController.dispose();
    super.dispose();
  }

  int _sum(List<int?> values) =>
      values.fold<int>(0, (prev, v) => prev + (v ?? 0));

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _goToPage(int index) {
    HapticFeedback.selectionClick();
    setState(() => _pageIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  double _baseLifeExpectancy() {
    double base = 76.0;

    if (vSex == 1) {
      base += 5;
    }

    switch (vRace) {
      case 1:
        base -= 2;
        break;
      case 2:
        base += 1;
        break;
      case 3:
        base += 2;
        break;
      case 4:
        base -= 1;
        break;
      case 5:
      case 0:
      default:
        break;
    }
    return base;
  }

  void _computeBiologicalAge(BuildContext context) {
    final rawText = ageController.text.trim();

    if (rawText.isEmpty) {
      _showError(context, _TXT.invalidAge);
      return;
    }

    final normalized = rawText.replaceAll(',', '.');
    final age = double.tryParse(normalized);

    if (age == null || age <= 0 || age > 120) {
      _showError(context, _TXT.invalidAge);
      return;
    }

    setState(() => _isCalculating = true);

    final personalT = _sum([
      vLongevity,
      vEducation,
      vSleep,
    ]);

    final cadT = _sum([
      vCholesterol,
      vBp,
      vSmoking,
      vHeredity,
      vWeight,
      vStress,
      vActivity,
    ]);

    final medicalT = _sum([
      vMedExam,
      vHeart,
      vLung,
      vDigestive,
      vDiabetes,
      vDrugs,
      vFemaleHealth,
      vPill,
    ]);

    final dietT = _sum([
      vBreakfast,
      vMeals,
      vVeg,
      vFats,
      vRefined,
      vAlcohol,
    ]);

    final psychT = _sum([
      vHappiness,
      vDepression,
      vAnxiety,
      vRelax,
      vLove,
      vJob,
      vSocial,
    ]);

    final safetyT = _sum([
      vDriving,
      vSeatbelt,
      vRisk,
    ]);

    final total = personalT + cadT + medicalT + dietT + psychT + safetyT;

    final base = _baseLifeExpectancy();
    final expectancy = base + total;
    final healthAge = age - total;
    final diff = healthAge - age;

    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() {
        _isCalculating = false;
        _personalT = personalT;
        _cadT = cadT;
        _medicalT = medicalT;
        _dietT = dietT;
        _psychT = psychT;
        _safetyT = safetyT;
        _total = total;
        _typicLifeExp = base;
        _expectancy = expectancy;
        _healthAge = healthAge;
        _difference = diff;
      });
    });
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
                          onResults: () => _goToPage(4),
                        ),
                        const SizedBox(height: 12),
                        _QuickActions(
                          onGuide: () => _goToPage(0),
                          onResults: () => _goToPage(4),
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
                                  _buildProfilePage(context),
                                  _buildHealthPage(context),
                                  _buildDietPage(context),
                                  _buildMindPage(context),
                                  _buildResultsPage(context),
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

  Widget _buildProfilePage(BuildContext context) {
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
            child: const _Glass(
              radius: 18,
              padding: EdgeInsets.all(14),
              child: _BodyText(
                _TXT.tipsText,
                align: TextAlign.center,
                weight: FontWeight.w700,
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
                    icon: Icons.person_rounded,
                    title: _TXT.profileLifestyle,
                  ),
                  const SizedBox(height: 12),
                  _FieldLine(
                    icon: '🚻',
                    child: _DropdownScore(
                      label: _TXT.sex,
                      value: vSex,
                      items: const [
                        _ScoreItem(0, _TXT.male),
                        _ScoreItem(1, _TXT.female),
                      ],
                      onChanged: (v) => setState(() => vSex = v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FieldLine(
                    icon: '🌍',
                    child: _DropdownScore(
                      label: _TXT.race,
                      value: vRace,
                      items: const [
                        _ScoreItem(0, _TXT.raceWhite),
                        _ScoreItem(1, _TXT.raceBlack),
                        _ScoreItem(2, _TXT.raceHispanic),
                        _ScoreItem(3, _TXT.raceAsian),
                        _ScoreItem(4, _TXT.raceAmerindian),
                        _ScoreItem(5, _TXT.raceOther),
                      ],
                      onChanged: (v) => setState(() => vRace = v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FieldLine(
                    icon: '⏳',
                    child: _DropdownScore(
                      label: _TXT.longevity,
                      value: vLongevity,
                      items: const [
                        _ScoreItem(2, "Family members often live beyond 90"),
                        _ScoreItem(1, "Many relatives live into their 80s"),
                        _ScoreItem(0, "Average family longevity"),
                        _ScoreItem(-1, "Several early chronic illnesses"),
                        _ScoreItem(-3, "Frequent early deaths in family"),
                      ],
                      onChanged: (v) => setState(() => vLongevity = v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FieldLine(
                    icon: '🎓',
                    child: _DropdownScore(
                      label: _TXT.education,
                      value: vEducation,
                      items: const [
                        _ScoreItem(1, "Higher education / strong health literacy"),
                        _ScoreItem(0, "Average education"),
                        _ScoreItem(-1, "Limited education"),
                        _ScoreItem(-2, "Very limited access to education"),
                      ],
                      onChanged: (v) => setState(() => vEducation = v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FieldLine(
                    icon: '😴',
                    child: _DropdownScore(
                      label: _TXT.sleep,
                      value: vSleep,
                      items: const [
                        _ScoreItem(1, "7–8 hours regularly"),
                        _ScoreItem(0, "8–9 hours"),
                        _ScoreItem(0, "6–7 hours"),
                        _ScoreItem(-1, "Less than 6 hours"),
                        _ScoreItem(-2, "Very irregular or poor sleep"),
                      ],
                      onChanged: (v) => setState(() => vSleep = v),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthPage(BuildContext context) {
    return CustomScrollView(
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
                  const _SectionHead(
                    icon: Icons.favorite_rounded,
                    title: _TXT.cardioHealth,
                  ),
                  const SizedBox(height: 12),
                  _FieldLine(
                    icon: '🧪',
                    child: _DropdownScore(
                      label: _TXT.hdl,
                      value: vCholesterol,
                      items: const [
                        _ScoreItem(2, "Excellent"),
                        _ScoreItem(1, "Good"),
                        _ScoreItem(-1, "Borderline"),
                        _ScoreItem(-2, "High risk"),
                        _ScoreItem(-4, "Very high risk"),
                      ],
                      onChanged: (v) => setState(() => vCholesterol = v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FieldLine(
                    icon: '🩸',
                    child: _DropdownScore(
                      label: _TXT.blood,
                      value: vBp,
                      items: const [
                        _ScoreItem(1, "Optimal"),
                        _ScoreItem(0, "Normal"),
                        _ScoreItem(-1, "Slightly elevated"),
                        _ScoreItem(-2, "Hypertension"),
                        _ScoreItem(-5, "Severe hypertension"),
                      ],
                      onChanged: (v) => setState(() => vBp = v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FieldLine(
                    icon: '🚬',
                    child: _DropdownScore(
                      label: _TXT.smoking,
                      value: vSmoking,
                      items: const [
                        _ScoreItem(1, "Never smoked", id: 10),
                        _ScoreItem(1, "Quit long ago", id: 11),
                        _ScoreItem(0, "Former smoker"),
                        _ScoreItem(-1, "Occasional smoker", id: 20),
                        _ScoreItem(-1, "Frequent passive smoke", id: 21),
                        _ScoreItem(-3, "Regular smoker"),
                        _ScoreItem(-5, "Heavy smoker", id: 22),
                      ],
                      onChanged: (v) => setState(() => vSmoking = v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FieldLine(
                    icon: '🧬',
                    child: _DropdownScore(
                      label: _TXT.heredity,
                      value: vHeredity,
                      items: const [
                        _ScoreItem(2, "Very favorable family history"),
                        _ScoreItem(0, "Neutral family history"),
                        _ScoreItem(-1, "Some cardiovascular history"),
                        _ScoreItem(-2, "Strong family history"),
                        _ScoreItem(-4, "Very strong early history"),
                      ],
                      onChanged: (v) => setState(() => vHeredity = v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FieldLine(
                    icon: '📊',
                    child: _DropdownScore(
                      label: _TXT.bodyIndex,
                      value: vWeight,
                      items: const [
                        _ScoreItem(1, "Healthy body composition"),
                        _ScoreItem(0, "Slightly above/below ideal"),
                        _ScoreItem(-3, "Overweight"),
                        _ScoreItem(-5, "Obesity or severe underweight"),
                      ],
                      onChanged: (v) => setState(() => vWeight = v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FieldLine(
                    icon: '💼',
                    child: _DropdownScore(
                      label: _TXT.stress,
                      value: vStress,
                      items: const [
                        _ScoreItem(1, "Low stress"),
                        _ScoreItem(0, "Moderate and well managed", id: 10),
                        _ScoreItem(0, "Average", id: 11),
                        _ScoreItem(-1, "High stress"),
                        _ScoreItem(-3, "Chronic severe stress"),
                      ],
                      onChanged: (v) => setState(() => vStress = v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FieldLine(
                    icon: '🏃‍♂️',
                    child: _DropdownScore(
                      label: _TXT.physical,
                      value: vActivity,
                      items: const [
                        _ScoreItem(2, "Very active"),
                        _ScoreItem(1, "Regular activity"),
                        _ScoreItem(0, "Occasional activity"),
                        _ScoreItem(-2, "Sedentary"),
                      ],
                      onChanged: (v) => setState(() => vActivity = v),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: _Glass(
              radius: 18,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _SectionHead(
                    icon: Icons.local_hospital_rounded,
                    title: _TXT.medicalHealth,
                  ),
                  const SizedBox(height: 12),
                  _FieldLine(
                    icon: '🧪',
                    child: _DropdownScore(
                      label: _TXT.tests,
                      value: vMedExam,
                      items: const [
                        _ScoreItem(1, "Regular preventive check-ups"),
                        _ScoreItem(0, "Check-ups from time to time", id: 10),
                        _ScoreItem(0, "Only when needed", id: 11),
                        _ScoreItem(-1, "Rarely or never"),
                      ],
                      onChanged: (v) => setState(() => vMedExam = v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FieldLine(
                    icon: '❤️',
                    child: _DropdownScore(
                      label: _TXT.heart,
                      value: vHeart,
                      items: const [
                        _ScoreItem(1, "No known issue"),
                        _ScoreItem(0, "Minor history"),
                        _ScoreItem(-1, "Managed condition"),
                        _ScoreItem(-2, "Significant heart issue"),
                        _ScoreItem(-3, "Severe / limiting condition"),
                      ],
                      onChanged: (v) => setState(() => vHeart = v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FieldLine(
                    icon: '🌬️',
                    child: _DropdownScore(
                      label: _TXT.lungs,
                      value: vLung,
                      items: const [
                        _ScoreItem(1, "Healthy"),
                        _ScoreItem(0, "Mild symptoms"),
                        _ScoreItem(-1, "Managed respiratory issue"),
                        _ScoreItem(-2, "Frequent symptoms"),
                        _ScoreItem(-3, "Severe limitation"),
                      ],
                      onChanged: (v) => setState(() => vLung = v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FieldLine(
                    icon: '🍽️',
                    child: _DropdownScore(
                      label: _TXT.digestive,
                      value: vDigestive,
                      items: const [
                        _ScoreItem(1, "Healthy"),
                        _ScoreItem(0, "Occasional discomfort"),
                        _ScoreItem(-1, "Chronic manageable issue"),
                        _ScoreItem(-2, "Frequent issue"),
                        _ScoreItem(-3, "Severe digestive disorder"),
                      ],
                      onChanged: (v) => setState(() => vDigestive = v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FieldLine(
                    icon: '🩹',
                    child: _DropdownScore(
                      label: _TXT.diabetes,
                      value: vDiabetes,
                      items: const [
                        _ScoreItem(1, "No diabetes risk"),
                        _ScoreItem(0, "No diabetes, moderate risk", id: 10),
                        _ScoreItem(0, "Predisposition monitored", id: 11),
                        _ScoreItem(-1, "Prediabetes"),
                        _ScoreItem(-2, "Controlled diabetes"),
                        _ScoreItem(-4, "Complicated diabetes"),
                      ],
                      onChanged: (v) => setState(() => vDiabetes = v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FieldLine(
                    icon: '💊',
                    child: _DropdownScore(
                      label: _TXT.drugs,
                      value: vDrugs,
                      items: const [
                        _ScoreItem(1, "No chronic medication"),
                        _ScoreItem(0, "Light medication"),
                        _ScoreItem(-1, "Several medications"),
                        _ScoreItem(-2, "Heavy medication burden"),
                        _ScoreItem(-3, "Serious substance / medication issue"),
                      ],
                      onChanged: (v) => setState(() => vDrugs = v),
                    ),
                  ),
                ],
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
                    icon: Icons.woman_rounded,
                    title: _TXT.womenHealth,
                  ),
                  const SizedBox(height: 12),
                  _FieldLine(
                    icon: '🧫',
                    child: _DropdownScore(
                      label: _TXT.women,
                      value: vFemaleHealth,
                      items: const [
                        _ScoreItem(1, "Healthy / not applicable"),
                        _ScoreItem(0, "Minor history"),
                        _ScoreItem(-1, "Managed issue"),
                        _ScoreItem(-2, "Significant issue"),
                        _ScoreItem(-4, "Severe / recurrent issue"),
                      ],
                      onChanged: (v) => setState(() => vFemaleHealth = v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FieldLine(
                    icon: '📦',
                    child: _DropdownScore(
                      label: _TXT.pill,
                      value: vPill,
                      items: const [
                        _ScoreItem(1, "Not used / well monitored"),
                        _ScoreItem(0, "Used with no issue", id: 10),
                        _ScoreItem(0, "Neutral / not applicable", id: 11),
                        _ScoreItem(-2, "Some complications"),
                        _ScoreItem(-3, "High-risk use"),
                      ],
                      onChanged: (v) => setState(() => vPill = v),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDietPage(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            child: _Glass(
              radius: 18,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _SectionHead(
                    icon: Icons.restaurant_rounded,
                    title: _TXT.dietHealth,
                  ),
                  const SizedBox(height: 12),
                  _FieldLine(
                    icon: '🌅',
                    child: _DropdownScore(
                      label: _TXT.breakfast,
                      value: vBreakfast,
                      items: const [
                        _ScoreItem(1, "Balanced breakfast daily"),
                        _ScoreItem(0, "Breakfast most days"),
                        _ScoreItem(-1, "Irregular breakfast"),
                        _ScoreItem(-2, "Often skipped"),
                        _ScoreItem(-3, "Almost never"),
                      ],
                      onChanged: (v) => setState(() => vBreakfast = v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FieldLine(
                    icon: '🍽️',
                    child: _DropdownScore(
                      label: _TXT.dailyMeals,
                      value: vMeals,
                      items: const [
                        _ScoreItem(1, "Regular balanced meals"),
                        _ScoreItem(0, "Mostly regular"),
                        _ScoreItem(-1, "Irregular timing"),
                        _ScoreItem(-3, "Very poor meal structure"),
                      ],
                      onChanged: (v) => setState(() => vMeals = v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FieldLine(
                    icon: '🍎',
                    child: _DropdownScore(
                      label: _TXT.fruitVeg,
                      value: vVeg,
                      items: const [
                        _ScoreItem(1, "High intake daily"),
                        _ScoreItem(0, "Good intake"),
                        _ScoreItem(-1, "Low intake", id: 10),
                        _ScoreItem(-1, "Very low intake", id: 11),
                      ],
                      onChanged: (v) => setState(() => vVeg = v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FieldLine(
                    icon: '🧈',
                    child: _DropdownScore(
                      label: _TXT.fats,
                      value: vFats,
                      items: const [
                        _ScoreItem(1, "Mostly healthy fats"),
                        _ScoreItem(0, "Mixed fats", id: 10),
                        _ScoreItem(0, "Average intake", id: 11),
                        _ScoreItem(0, "Occasional excess", id: 12),
                        _ScoreItem(-1, "High saturated fat"),
                        _ScoreItem(-2, "Very high unhealthy fat"),
                      ],
                      onChanged: (v) => setState(() => vFats = v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FieldLine(
                    icon: '🍔',
                    child: _DropdownScore(
                      label: _TXT.refinedFood,
                      value: vRefined,
                      items: const [
                        _ScoreItem(1, "Rarely consumed"),
                        _ScoreItem(0, "Occasionally"),
                        _ScoreItem(-1, "Often"),
                        _ScoreItem(-2, "Very often"),
                      ],
                      onChanged: (v) => setState(() => vRefined = v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FieldLine(
                    icon: '🍷',
                    child: _DropdownScore(
                      label: _TXT.alcohol,
                      value: vAlcohol,
                      items: const [
                        _ScoreItem(1, "None / very rare", id: 10),
                        _ScoreItem(1, "Moderate and controlled", id: 11),
                        _ScoreItem(0, "Occasional"),
                        _ScoreItem(-1, "Regular drinking"),
                        _ScoreItem(-2, "Heavy drinking"),
                      ],
                      onChanged: (v) => setState(() => vAlcohol = v),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMindPage(BuildContext context) {
    return CustomScrollView(
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
                  const _SectionHead(
                    icon: Icons.psychology_rounded,
                    title: _TXT.psychHealth,
                  ),
                  const SizedBox(height: 12),
                  _FieldLine(
                    icon: '😊',
                    child: _DropdownScore(
                      label: _TXT.happy,
                      value: vHappiness,
                      items: const [
                        _ScoreItem(1, "Very happy"),
                        _ScoreItem(0, "Generally okay"),
                        _ScoreItem(-1, "Often dissatisfied"),
                        _ScoreItem(-2, "Frequently unhappy"),
                        _ScoreItem(-3, "Persistently unhappy"),
                      ],
                      onChanged: (v) => setState(() => vHappiness = v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FieldLine(
                    icon: '😞',
                    child: _DropdownScore(
                      label: _TXT.depression,
                      value: vDepression,
                      items: const [
                        _ScoreItem(1, "No depression symptoms"),
                        _ScoreItem(0, "Rare low mood"),
                        _ScoreItem(-1, "Mild depressive symptoms"),
                        _ScoreItem(-2, "Frequent depressive symptoms"),
                        _ScoreItem(-3, "Severe / persistent depression"),
                      ],
                      onChanged: (v) => setState(() => vDepression = v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FieldLine(
                    icon: '😬',
                    child: _DropdownScore(
                      label: _TXT.anxiety,
                      value: vAnxiety,
                      items: const [
                        _ScoreItem(1, "Calm and stable"),
                        _ScoreItem(0, "Occasional anxiety"),
                        _ScoreItem(-1, "Mild anxiety"),
                        _ScoreItem(-2, "Frequent anxiety"),
                        _ScoreItem(-3, "Severe anxiety"),
                      ],
                      onChanged: (v) => setState(() => vAnxiety = v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FieldLine(
                    icon: '🧘‍♀️',
                    child: _DropdownScore(
                      label: _TXT.relaxation,
                      value: vRelax,
                      items: const [
                        _ScoreItem(1, "Regular relaxation practice"),
                        _ScoreItem(0, "Sometimes relax well"),
                        _ScoreItem(-1, "Poor relaxation habits"),
                        _ScoreItem(-2, "Rarely relax"),
                        _ScoreItem(-3, "Never disconnect / chronic tension"),
                      ],
                      onChanged: (v) => setState(() => vRelax = v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FieldLine(
                    icon: '❤️‍🔥',
                    child: _DropdownScore(
                      label: _TXT.love,
                      value: vLove,
                      items: const [
                        _ScoreItem(2, "Very supportive relationship"),
                        _ScoreItem(1, "Stable and positive"),
                        _ScoreItem(0, "Neutral"),
                        _ScoreItem(-1, "Difficult relationship"),
                        _ScoreItem(-3, "Severely harmful relationship"),
                      ],
                      onChanged: (v) => setState(() => vLove = v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FieldLine(
                    icon: '💼',
                    child: _DropdownScore(
                      label: _TXT.job,
                      value: vJob,
                      items: const [
                        _ScoreItem(1, "Very satisfied"),
                        _ScoreItem(0, "Mostly okay"),
                        _ScoreItem(-1, "Often dissatisfied"),
                        _ScoreItem(-2, "Highly stressful / unhappy"),
                      ],
                      onChanged: (v) => setState(() => vJob = v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FieldLine(
                    icon: '👥',
                    child: _DropdownScore(
                      label: _TXT.social,
                      value: vSocial,
                      items: const [
                        _ScoreItem(1, "Strong social support"),
                        _ScoreItem(0, "Average social life"),
                        _ScoreItem(-1, "Limited social support"),
                        _ScoreItem(-2, "Isolated"),
                        _ScoreItem(-3, "Very isolated / distressed"),
                      ],
                      onChanged: (v) => setState(() => vSocial = v),
                    ),
                  ),
                ],
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
                    icon: Icons.directions_car_rounded,
                    title: _TXT.safetyHealth,
                  ),
                  const SizedBox(height: 12),
                  _FieldLine(
                    icon: '🛞',
                    child: _DropdownScore(
                      label: _TXT.driving,
                      value: vDriving,
                      items: const [
                        _ScoreItem(1, "Careful driver"),
                        _ScoreItem(0, "Average driver"),
                        _ScoreItem(-1, "Occasionally risky"),
                        _ScoreItem(-2, "Frequently risky"),
                      ],
                      onChanged: (v) => setState(() => vDriving = v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FieldLine(
                    icon: '🪑',
                    child: _DropdownScore(
                      label: _TXT.seatbelt,
                      value: vSeatbelt,
                      items: const [
                        _ScoreItem(1, "Always"),
                        _ScoreItem(0, "Usually"),
                        _ScoreItem(-1, "Sometimes"),
                        _ScoreItem(-2, "Rarely"),
                        _ScoreItem(-4, "Never"),
                      ],
                      onChanged: (v) => setState(() => vSeatbelt = v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FieldLine(
                    icon: '⚠️',
                    child: _DropdownScore(
                      label: _TXT.risk,
                      value: vRisk,
                      items: const [
                        _ScoreItem(1, "Low risk-taking"),
                        _ScoreItem(0, "Moderate"),
                        _ScoreItem(-1, "Sometimes impulsive", id: 10),
                        _ScoreItem(-1, "Small but repeated risks", id: 11),
                        _ScoreItem(-2, "High risk-taking"),
                      ],
                      onChanged: (v) => setState(() => vRisk = v),
                    ),
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
                    icon: Icons.monitor_heart_rounded,
                    title: _TXT.results,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ModernTextInput(
                          label: _TXT.currentAge,
                          controller: ageController,
                          hint: "0",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          label: _TXT.calculate,
                          isLoading: _isCalculating,
                          onTap: () {
                            if (_isCalculating) return;
                            HapticFeedback.selectionClick();
                            _computeBiologicalAge(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_total == null)
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
                      icon: Icons.info_outline_rounded,
                      title: _TXT.noResultsTitle,
                    ),
                    SizedBox(height: 10),
                    _BodyText(_TXT.noResultsText),
                  ],
                ),
              ),
            ),
          )
        else
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: _Glass(
                radius: 18,
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _SectionHead(
                      icon: Icons.analytics_rounded,
                      title: _TXT.results,
                    ),
                    const SizedBox(height: 12),
                    _ResultLine(label: _TXT.subtotalProfile, value: _personalT),
                    _ResultLine(label: _TXT.subtotalCad, value: _cadT),
                    _ResultLine(label: _TXT.subtotalMedical, value: _medicalT),
                    _ResultLine(label: _TXT.subtotalDiet, value: _dietT),
                    _ResultLine(label: _TXT.subtotalPsych, value: _psychT),
                    _ResultLine(label: _TXT.subtotalSafety, value: _safetyT),
                    const SizedBox(height: 8),
                    const Divider(color: Color(0x22FFFFFF), height: 1),
                    const SizedBox(height: 8),
                    _ResultLine(
                      label: _TXT.totalScore,
                      value: _total,
                      highlight: true,
                    ),
                    if (_typicLifeExp != null)
                      _ResultLine(
                        label: _TXT.typicalLife,
                        value: _typicLifeExp!.toStringAsFixed(1),
                      ),
                    if (_expectancy != null)
                      _ResultLine(
                        label: _TXT.expectedLife,
                        value: _expectancy!.toStringAsFixed(1),
                      ),
                    if (_healthAge != null)
                      _ResultLine(
                        label: _TXT.biologicalAge,
                        value: _healthAge!.toStringAsFixed(1),
                      ),
                    if (_difference != null)
                      _ResultLine(
                        label: _TXT.diffAge,
                        value: _difference!.toStringAsFixed(1),
                      ),
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
                    icon: Icons.lightbulb_outline_rounded,
                    title: _TXT.tipsTitle,
                  ),
                  SizedBox(height: 10),
                  _BodyText(_TXT.tipsText),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/* ========================================================================== */
/* Nav data */
/* ========================================================================== */

class _NavItemData {
  final IconData icon;
  final String label;

  const _NavItemData({
    required this.icon,
    required this.label,
  });
}

/* ========================================================================== */
/* Widgets */
/* ========================================================================== */

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
            accent: cs.primary.withOpacity(0.90),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onGuide;
  final VoidCallback onResults;

  const _QuickActions({
    required this.onGuide,
    required this.onResults,
  });

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
                  Icons.dashboard_customize_rounded,
                  size: 18,
                  color: cs.primary.withOpacity(0.92),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "${_TXT.quickGuide} • ${_TXT.quickSections}",
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
            onResults();
          },
          child: _Glass(
            radius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.analytics_rounded,
                  size: 18,
                  color: cs.primary.withOpacity(0.92),
                ),
                const SizedBox(width: 8),
                Text(
                  _TXT.quickResults,
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
      _NavItemData(icon: Icons.person_rounded, label: _TXT.navProfile),
      _NavItemData(icon: Icons.favorite_rounded, label: _TXT.navHealth),
      _NavItemData(icon: Icons.restaurant_rounded, label: _TXT.navDiet),
      _NavItemData(icon: Icons.psychology_rounded, label: _TXT.navMind),
      _NavItemData(icon: Icons.analytics_rounded, label: _TXT.navResults),
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
    final cs = t.colorScheme;

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
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white.withOpacity(0.10),
              border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
            ),
            child: Icon(
              Icons.biotech_rounded,
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

class _FieldLine extends StatelessWidget {
  final String icon;
  final Widget child;

  const _FieldLine({
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(width: 8),
        Expanded(child: child),
      ],
    );
  }
}

class _ModernTextInput extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;

  const _ModernTextInput({
    required this.label,
    required this.controller,
    this.hint,
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
            hintText: hint ?? "0",
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

class _ScoreItem {
  final int score;
  final String label;
  final int id;

  const _ScoreItem(this.score, this.label, {int? id}) : id = id ?? score;
}

class _DropdownScore extends StatelessWidget {
  final String label;
  final int? value;
  final List<_ScoreItem> items;
  final ValueChanged<int?> onChanged;

  const _DropdownScore({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    int? selectedId;
    if (value != null) {
      for (final item in items) {
        if (item.score == value) {
          selectedId = item.id;
          break;
        }
      }
    }

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
        DropdownButtonFormField<int>(
          value: selectedId,
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
                (e) => DropdownMenuItem<int>(
                  value: e.id,
                  child: Text(
                    e.label,
                    overflow: TextOverflow.ellipsis,
                    style: t.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.96),
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (selectedId) {
            if (selectedId == null) {
              onChanged(null);
              return;
            }
            final match = items.firstWhere((e) => e.id == selectedId);
            onChanged(match.score);
          },
        ),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  const _ActionButton({
    required this.label,
    this.onTap,
    this.isLoading = false,
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
    final cs = Theme.of(context).colorScheme;
    final colors = [
      cs.primary.withOpacity(0.95),
      (cs.secondary == cs.primary ? cs.primaryContainer : cs.secondary)
          .withOpacity(0.92),
    ];

    return MouseRegion(
      onEnter: (_) {
        if (!widget.isLoading) _animateTo(0.5);
      },
      onExit: (_) {
        if (!widget.isLoading) _animateTo(0.0);
      },
      child: GestureDetector(
        onTapDown: (_) {
          if (!widget.isLoading) _animateTo(1.0);
        },
        onTapUp: (_) {
          if (!widget.isLoading) {
            _animateTo(0.5);
            widget.onTap?.call();
          }
        },
        onTapCancel: () {
          if (!widget.isLoading) _animateTo(0.0);
        },
        child: AnimatedBuilder(
          animation: _ctl,
          builder: (_, __) {
            final v = _ctl.value;
            final scale = 1.0 - (0.03 * v);
            final blur = 12.0 + (10.0 * v);
            final spread = 0.0 + (2.0 * v);

            return Transform.scale(
              scale: scale,
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.last.withOpacity(0.45 * (0.3 + 0.7 * v)),
                      blurRadius: blur,
                      spreadRadius: spread,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: widget.isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          widget.label,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
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