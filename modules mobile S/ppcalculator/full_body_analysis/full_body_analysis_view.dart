// lib/features/ppcalculator/full_body_analysis/full_body_analysis_view.dart
//
// ✅ DESIGN aligned to BeepIntermittentTrainingView (BgS.jfif + overlay + orbs + glass)
// ✅ NO TabBar / NO TabBarView
// ✅ LOGIQUE _computeFullBody INCHANGÉE (copiée 1:1 de ton code fourni)
// ✅ Navigation moderne: header pill + quick actions + scroll premium + résultats en section
//
// REQUIRED ASSET:
// - assets/images/BgS.jfif

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'more_informations.dart';

class FullBodyAnalysisView extends StatefulWidget {
  const FullBodyAnalysisView({super.key});

  @override
  State<FullBodyAnalysisView> createState() => _FullBodyAnalysisViewState();
}

class _FullBodyAnalysisViewState extends State<FullBodyAnalysisView>
    with TickerProviderStateMixin {
  static const String _bg = "assets/images/BgS.jfif";

  // Entrance anim (UI only)
  late final AnimationController _enterCtrl;

  // Contrôleurs
  final TextEditingController unitsController = TextEditingController(); // US / Metric
  final TextEditingController genderController = TextEditingController(); // male / female
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightFeetController = TextEditingController();
  final TextEditingController heightInchController = TextEditingController();
  final TextEditingController heightCmController = TextEditingController();
  final TextEditingController waistController = TextEditingController();
  final TextEditingController neckController = TextEditingController(); // utilisé comme "elbow" dans la logique
  final TextEditingController hipController = TextEditingController();
  final TextEditingController activityLevelController = TextEditingController();
  final TextEditingController goalController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController rhrController = TextEditingController();

  bool _isLoading = false;

  // Résultats
  String _bmi = '0';
  String _bmiClass = '0';
  String _waistHipRatio = '0';
  String _bodyShape = '0';
  String _waistHipInterp = '0';
  String _frameSize = '0';
  String _idealWeight = '0';
  String _fatMass = '0';
  String _leanMass = '0';

  String _rmrDay = '0';
  String _rmrHour = '0';
  String _avgCalDay = '0';
  String _avgCalHour = '0';
  String _targetHrBpm = '0';
  String _targetHrPer10s = '0';
  String _maxHrBpm = '0';
  String _maxHrPer10s = '0';

  bool get _canSubmit => !_isLoading;

  // ----------------------------
  // ✅ Labels statiques (sans intl)
  // ----------------------------
  static const String _unitsUS = 'US';
  static const String _unitsMetric = 'Metric';

  static const String _genderMale = 'Male';
  static const String _genderFemale = 'Female';

  static const List<String> _activityLabels = [
    'Sedentary',
    'Lightly active',
    'Moderately active',
    'Very active',
    'Extra active',
  ];

  static const List<String> _goalLabels = [
    'Fat loss',
    'Fitness / cardio',
    'Muscle gain',
    'Athletic performance',
    'Maximum performance',
  ];

  bool get _isMetric {
    final txt = (unitsController.text).toLowerCase().trim();
    return txt.contains('metric') || txt == _unitsMetric.toLowerCase();
  }

  // Dropdown state (pour éviter erreurs et garder des valeurs exactes)
  String? _selectedUnits;
  String? _selectedGender;
  String? _selectedActivity;
  String? _selectedGoal;

  // Scroll
  final _scrollCtl = ScrollController();
  bool _showResults = false;

  @override
  void initState() {
    super.initState();

    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    )..forward();

    // Defaults
    _selectedUnits = _unitsMetric;
    unitsController.text = _unitsMetric;

    unitsController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _scrollCtl.dispose();

    unitsController.dispose();
    genderController.dispose();
    weightController.dispose();
    heightFeetController.dispose();
    heightInchController.dispose();
    heightCmController.dispose();
    waistController.dispose();
    neckController.dispose();
    hipController.dispose();
    activityLevelController.dispose();
    goalController.dispose();
    ageController.dispose();
    rhrController.dispose();
    super.dispose();
  }

  void _showValidationError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  double? _parsePositive(String text) {
    final cleaned = text.trim().replaceAll(',', '.');
    if (cleaned.isEmpty) return null;
    final v = double.tryParse(cleaned);
    if (v == null || v <= 0) return null;
    return v;
  }

  // ------------------------------------------------------------------
  // ✅ LOGIQUE CALCUL: NE PAS MODIFIER (copiée de ton code 1:1)
  // ------------------------------------------------------------------
  void _computeFullBody(BuildContext context) {
    final isMetric = _isMetric;

    // ---- GENDER ----
    final genderText = genderController.text.trim();
    final isMale = genderText == _genderMale ||
        genderText.toLowerCase().contains('male') ||
        genderText.toLowerCase().contains('homme');
    final isFemale = genderText == _genderFemale ||
        genderText.toLowerCase().contains('female') ||
        genderText.toLowerCase().contains('femme');

    if (!isMale && !isFemale) {
      _showValidationError(context, 'Please select gender.');
      return;
    }

    // ---- UNITS + INPUTS ----
    double? heightCm;
    double? weightKg;
    double? waistCm;
    double? hipCm;
    double? elbowCm;

    if (isMetric) {
      weightKg = _parsePositive(weightController.text);
      heightCm = _parsePositive(heightCmController.text);
      waistCm = _parsePositive(waistController.text);
      hipCm = _parsePositive(hipController.text);
      elbowCm = _parsePositive(neckController.text);
    } else {
      // US → conversion vers métrique, comme dans le JS
      final feet = _parsePositive(heightFeetController.text);
      if (feet == null) {
        _showValidationError(context, 'Please provide valid height (feet).');
        return;
      }

      double inches = 0;
      final inchesText = heightInchController.text.trim();
      if (inchesText.isNotEmpty) {
        final inchesParsed = _parsePositive(inchesText);
        if (inchesParsed == null) {
          _showValidationError(context, 'Please provide valid height (inches).');
          return;
        }
        inches = inchesParsed;
      }

      final totalInches = feet * 12 + inches;
      heightCm = totalInches * 2.54;

      final weightLbs = _parsePositive(weightController.text);
      if (weightLbs == null) {
        _showValidationError(context, 'Please provide valid weight.');
        return;
      }
      weightKg = weightLbs * 0.4536;

      final waistInch = _parsePositive(waistController.text);
      if (waistInch == null) {
        _showValidationError(context, 'Please provide valid waist.');
        return;
      }
      waistCm = waistInch * 2.54;

      final hipInch = _parsePositive(hipController.text);
      if (hipInch == null) {
        _showValidationError(context, 'Please provide valid hip.');
        return;
      }
      hipCm = hipInch * 2.54;

      final elbowInch = _parsePositive(neckController.text);
      if (elbowInch == null) {
        _showValidationError(context, 'Please provide valid elbow value.');
        return;
      }
      elbowCm = elbowInch * 2.54;
    }

    if (heightCm == null ||
        weightKg == null ||
        waistCm == null ||
        hipCm == null ||
        elbowCm == null) {
      _showValidationError(context, 'Please fill all numeric fields.');
      return;
    }

    // Age
    final ageText = ageController.text.trim();
    final ageInt = int.tryParse(ageText);
    if (ageInt == null || ageInt <= 0) {
      _showValidationError(context, 'Please provide a valid age.');
      return;
    }
    if (ageInt > 100) {
      _showValidationError(context, 'Please provide age less than 100.');
      return;
    }
    final age = ageInt.toDouble();

    // RHR
    final rhr = _parsePositive(rhrController.text);
    if (rhr == null) {
      _showValidationError(
          context, 'Please provide a valid Resting Heart Rate (RHR).');
      return;
    }

    // ---- Activity Level (actLevelFactor) ----
    final actLabels = <String>[
      _activityLabels[0],
      _activityLabels[1],
      _activityLabels[2],
      _activityLabels[3],
      _activityLabels[4],
    ];
    final actIndex = actLabels.indexOf(activityLevelController.text);
    if (actIndex == -1) {
      _showValidationError(context, 'Please select your activity level.');
      return;
    }
    const actFactors = <double>[1.2, 1.375, 1.55, 1.75, 1.9];
    final actLevelFactor = actFactors[actIndex];

    // ---- FitGoal ----
    final goalLabels = <String>[
      _goalLabels[0],
      _goalLabels[1],
      _goalLabels[2],
      _goalLabels[3],
      _goalLabels[4],
    ];
    final goalIndex = goalLabels.indexOf(goalController.text);
    if (goalIndex == -1) {
      _showValidationError(context, 'Please select your fitness goal.');
      return;
    }
    final fitGoal = goalIndex + 1; // 1..5

    // ---------------------------------------------------
    // LOGIQUE DE CALCUL PORTÉE DU FICHIER WEB (JS) 1:1
    // ---------------------------------------------------

    // BMI
    final bmi = (weightKg / (heightCm * heightCm)) * 10000;
    final bmiRounded = bmi.round();

    String bmiClass;
    if (bmiRounded < 19) {
      bmiClass = 'Underweight';
    } else if (bmiRounded >= 19 && bmiRounded <= 25) {
      bmiClass = 'Desirable weight';
    } else if (bmiRounded >= 26 && bmiRounded <= 29) {
      bmiClass = 'Prone to health risks';
    } else if (bmiRounded >= 30 && bmiRounded <= 40) {
      bmiClass = 'Obese';
    } else {
      bmiClass = 'Extremely obese';
    }

    // Waist / Hip
    double waistToHip = waistCm / hipCm;
    double wthPercent = waistToHip * 100;
    final wthStr = '${wthPercent.toStringAsFixed(2)} %';

    // Body shape + Waist to hip interpretation
    String bodyShape;
    String waistToHipInterp = '';

    if (isMale) {
      if (waistToHip > 95) {
        bodyShape = 'Apple';
      } else {
        bodyShape = 'Pear';
      }

      if (waistToHip < 0.75) {
        waistToHipInterp = 'Excellent';
      } else if (waistToHip >= 0.76 && waistToHip <= 0.85) {
        waistToHipInterp = 'Very Good';
      } else if (waistToHip >= 0.86 && waistToHip <= 0.9) {
        waistToHipInterp = 'Healthy';
      } else if (waistToHip >= 0.91 && waistToHip <= 0.99) {
        waistToHipInterp = 'Increased risk';
      } else if (waistToHip >= 1.0 && waistToHip <= 1.09) {
        waistToHipInterp = 'Serious risk';
      } else if (waistToHip >= 1.1 && waistToHip <= 1.25) {
        waistToHipInterp = 'Aggravated risk';
      } else if (waistToHip > 1.25) {
        waistToHipInterp = 'Severe health risk';
      }
    } else {
      if (waistToHip > 80) {
        bodyShape = 'Apple';
      } else {
        bodyShape = 'Pear';
      }

      if (waistToHip < 0.73) {
        waistToHipInterp = 'Excellent';
      } else if (waistToHip >= 0.74 && waistToHip <= 0.79) {
        waistToHipInterp = 'Very Good';
      } else if (waistToHip >= 0.8 && waistToHip <= 0.85) {
        waistToHipInterp = 'Healthy';
      } else if (waistToHip >= 0.86 && waistToHip <= 0.94) {
        waistToHipInterp = 'Increased risk';
      } else if (waistToHip >= 1.95 && waistToHip <= 1.04) {
        waistToHipInterp = 'Serious risk';
      } else if (waistToHip >= 1.05 && waistToHip <= 1.2) {
        waistToHipInterp = 'Aggravated risk';
      } else if (waistToHip > 1.2) {
        waistToHipInterp = 'Severe health risk';
      }
    }

    // Body Frame Size
    String bodyFrameSize = '';

    if (isMale) {
      if (heightCm < 155 && elbowCm < 57) {
        bodyFrameSize = 'Small';
      } else if ((heightCm >= 155 && heightCm <= 149) ||
          (elbowCm > 6.4 && elbowCm < 7.3) ||
          (heightCm >= 160 && heightCm <= 169) ||
          (elbowCm > 6.7 && elbowCm < 7.3) ||
          (heightCm >= 170 && heightCm <= 179) ||
          (elbowCm > 7.0 && elbowCm < 7.5) ||
          (heightCm >= 180 && heightCm <= 189) ||
          (elbowCm > 7.0 && elbowCm < 7.9) ||
          (heightCm >= 190 && heightCm <= 199) ||
          (elbowCm > 7.3 && elbowCm < 8.3)) {
        bodyFrameSize = 'Medium';
      } else if (heightCm > 199 && elbowCm > 83) {
        bodyFrameSize = 'Large';
      } else {
        bodyFrameSize = 'Undefined';
      }
    } else {
      if (heightCm > 146 && elbowCm < 57) {
        bodyFrameSize = 'Small';
      } else if ((heightCm >= 146 && heightCm <= 149) ||
          (elbowCm > 5.7 && elbowCm < 6.4) ||
          (heightCm >= 150 && heightCm <= 159) ||
          (elbowCm > 5.7 && elbowCm < 6.4) ||
          (heightCm >= 160 && heightCm <= 169) ||
          (elbowCm > 6.0 && elbowCm < 6.7) ||
          (heightCm >= 170 && heightCm <= 179) ||
          (elbowCm > 6.0 && elbowCm < 6.7) ||
          (heightCm >= 180 && heightCm <= 190) ||
          (elbowCm > 6.3 && elbowCm < 7.0)) {
        bodyFrameSize = 'Medium';
      } else if (heightCm > 190 && elbowCm < 70) {
        bodyFrameSize = 'Large';
      } else {
        bodyFrameSize = 'Undefined';
      }
    }

    // Ideal Weight Range (lb, logique JS)
    const u = 'lb';
    heightCm = double.parse(heightCm.toStringAsFixed(1));

    String idealWeight = 'Undefined';

    if (isMale) {
      if (heightCm == 157.5 || (heightCm > 157 && heightCm < 160)) {
        if (bodyFrameSize == 'Small') idealWeight = '128-134$u';
        if (bodyFrameSize == 'Medium') idealWeight = '131-141$u';
        if (bodyFrameSize == 'Large') idealWeight = '131-141$u';
      } else if (heightCm == 160 || (heightCm >= 160 && heightCm < 162)) {
        if (bodyFrameSize == 'Small') idealWeight = '130-136$u';
        if (bodyFrameSize == 'Medium') idealWeight = '133-143$u';
        if (bodyFrameSize == 'Large') idealWeight = '140-153$u';
      } else if (heightCm == 162.6 || (heightCm >= 162 && heightCm < 165)) {
        if (bodyFrameSize == 'Small') idealWeight = '132-138$u';
        if (bodyFrameSize == 'Medium') idealWeight = '135-145$u';
        if (bodyFrameSize == 'Large') idealWeight = '142-156$u';
      } else if (heightCm == 165.1 || (heightCm >= 165 && heightCm < 167)) {
        if (bodyFrameSize == 'Small') idealWeight = '134-140$u';
        if (bodyFrameSize == 'Medium') idealWeight = '137-148$u';
        if (bodyFrameSize == 'Large') idealWeight = '144-160$u';
      } else if (heightCm == 167.6 || (heightCm >= 167 && heightCm < 170)) {
        if (bodyFrameSize == 'Small') idealWeight = '136-142$u';
        if (bodyFrameSize == 'Medium') idealWeight = '139-151$u';
        if (bodyFrameSize == 'Large') idealWeight = '146-164$u';
      } else if (heightCm == 170.2 || (heightCm >= 170 && heightCm < 172)) {
        if (bodyFrameSize == 'Small') idealWeight = '138-145$u';
        if (bodyFrameSize == 'Medium') idealWeight = '142-154$u';
        if (bodyFrameSize == 'Large') idealWeight = '149-168$u';
      } else if (heightCm == 172.7 || (heightCm >= 172 && heightCm < 175)) {
        if (bodyFrameSize == 'Small') idealWeight = '140-148$u';
        if (bodyFrameSize == 'Medium') idealWeight = '145-157$u';
        if (bodyFrameSize == 'Large') idealWeight = '152-172$u';
      } else if (heightCm == 175.3 || (heightCm >= 175 && heightCm < 177)) {
        if (bodyFrameSize == 'Small') idealWeight = '142-151$u';
        if (bodyFrameSize == 'Medium') idealWeight = '148-160$u';
        if (bodyFrameSize == 'Large') idealWeight = '155-176$u';
      } else if (heightCm == 177.8 || (heightCm >= 177 && heightCm < 180)) {
        if (bodyFrameSize == 'Small') idealWeight = '144-154$u';
        if (bodyFrameSize == 'Medium') idealWeight = '151-163$u';
        if (bodyFrameSize == 'Large') idealWeight = '158-180$u';
      } else if (heightCm == 180.3 || (heightCm >= 180 && heightCm < 182)) {
        if (bodyFrameSize == 'Small') idealWeight = '146-157$u';
        if (bodyFrameSize == 'Medium') idealWeight = '154-166$u';
        if (bodyFrameSize == 'Large') idealWeight = '161-184$u';
      } else if (heightCm == 182.9 || (heightCm >= 182 && heightCm < 185)) {
        if (bodyFrameSize == 'Small') idealWeight = '149-160$u';
        if (bodyFrameSize == 'Medium') idealWeight = '157-170$u';
        if (bodyFrameSize == 'Large') idealWeight = '164-188$u';
      } else if (heightCm == 185.4 || (heightCm >= 185 && heightCm < 188)) {
        if (bodyFrameSize == 'Small') idealWeight = '152-164$u';
        if (bodyFrameSize == 'Medium') idealWeight = '160-174$u';
        if (bodyFrameSize == 'Large') idealWeight = '168-192$u';
      } else if (heightCm == 188 || (heightCm >= 188 && heightCm < 190)) {
        if (bodyFrameSize == 'Small') idealWeight = '155-168$u';
        if (bodyFrameSize == 'Medium') idealWeight = '164-178$u';
        if (bodyFrameSize == 'Large') idealWeight = '172-197$u';
      } else if (heightCm == 190.5 || (heightCm >= 190 && heightCm < 193)) {
        if (bodyFrameSize == 'Small') idealWeight = '158-172$u';
        if (bodyFrameSize == 'Medium') idealWeight = '167-182$u';
        if (bodyFrameSize == 'Large') idealWeight = '176-202$u';
      } else if (heightCm == 193) {
        if (bodyFrameSize == 'Small') idealWeight = '162-176$u';
        if (bodyFrameSize == 'Medium') idealWeight = '171-187$u';
        if (bodyFrameSize == 'Large') idealWeight = '181-207$u';
      }
    } else {
      if (heightCm == 147.3 || (heightCm >= 147 && heightCm < 149)) {
        if (bodyFrameSize == 'Small') idealWeight = '102-111$u';
        if (bodyFrameSize == 'Medium') idealWeight = '109-121$u';
        if (bodyFrameSize == 'Large') idealWeight = '118-131$u';
      } else if (heightCm == 149.9 || (heightCm >= 149 && heightCm < 152)) {
        if (bodyFrameSize == 'Small') idealWeight = '103-113$u';
        if (bodyFrameSize == 'Medium') idealWeight = '111-123$u';
        if (bodyFrameSize == 'Large') idealWeight = '120-134$u';
      } else if (heightCm == 152.4 || (heightCm >= 152 && heightCm < 154)) {
        if (bodyFrameSize == 'Small') idealWeight = '104-115$u';
        if (bodyFrameSize == 'Medium') idealWeight = '113-126$u';
        if (bodyFrameSize == 'Large') idealWeight = '122-137$u';
      } else if (heightCm == 154.9 || (heightCm >= 154 && heightCm < 157)) {
        if (bodyFrameSize == 'Small') idealWeight = '106-118$u';
        if (bodyFrameSize == 'Medium') idealWeight = '115-129$u';
        if (bodyFrameSize == 'Large') idealWeight = '125-140$u';
      } else if (heightCm == 157.5 || (heightCm >= 157 && heightCm < 160)) {
        if (bodyFrameSize == 'Small') idealWeight = '108-121$u';
        if (bodyFrameSize == 'Medium') idealWeight = '118-132$u';
        if (bodyFrameSize == 'Large') idealWeight = '128-143$u';
      } else if (heightCm == 160 || (heightCm >= 160 && heightCm < 162)) {
        if (bodyFrameSize == 'Small') idealWeight = '111-124$u';
        if (bodyFrameSize == 'Medium') idealWeight = '121-135$u';
        if (bodyFrameSize == 'Large') idealWeight = '131-147$u';
      } else if (heightCm == 162.6 || (heightCm >= 162 && heightCm < 165)) {
        if (bodyFrameSize == 'Small') idealWeight = '114-127$u';
        if (bodyFrameSize == 'Medium') idealWeight = '124-138$u';
        if (bodyFrameSize == 'Large') idealWeight = '134-151$u';
      } else if (heightCm == 165.1 || (heightCm >= 165 && heightCm < 167)) {
        if (bodyFrameSize == 'Small') idealWeight = '117-130$u';
        if (bodyFrameSize == 'Medium') idealWeight = '127-141$u';
        if (bodyFrameSize == 'Large') idealWeight = '137-155$u';
      } else if (heightCm == 167.6 || (heightCm >= 167 && heightCm < 170)) {
        if (bodyFrameSize == 'Small') idealWeight = '120-133$u';
        if (bodyFrameSize == 'Medium') idealWeight = '130-144$u';
        if (bodyFrameSize == 'Large') idealWeight = '140-159$u';
      } else if (heightCm == 170.2 || (heightCm >= 170 && heightCm < 172)) {
        if (bodyFrameSize == 'Small') idealWeight = '123-136$u';
        if (bodyFrameSize == 'Medium') idealWeight = '133-147$u';
        if (bodyFrameSize == 'Large') idealWeight = '143-163$u';
      } else if (heightCm == 172.7 || (heightCm >= 172 && heightCm < 175)) {
        if (bodyFrameSize == 'Small') idealWeight = '126-139$u';
        if (bodyFrameSize == 'Medium') idealWeight = '136-150$u';
        if (bodyFrameSize == 'Large') idealWeight = '146-167$u';
      } else if (heightCm == 175.3 || (heightCm >= 175 && heightCm < 177)) {
        if (bodyFrameSize == 'Small') idealWeight = '129-142$u';
        if (bodyFrameSize == 'Medium') idealWeight = '139-153$u';
        if (bodyFrameSize == 'Large') idealWeight = '149-170$u';
      } else if (heightCm == 177.8 || (heightCm >= 177 && heightCm < 180)) {
        if (bodyFrameSize == 'Small') idealWeight = '132-145$u';
        if (bodyFrameSize == 'Medium') idealWeight = '142-156$u';
        if (bodyFrameSize == 'Large') idealWeight = '152-173$u';
      } else if (heightCm == 180.3 || (heightCm >= 180 && heightCm < 182)) {
        if (bodyFrameSize == 'Small') idealWeight = '135-148$u';
        if (bodyFrameSize == 'Medium') idealWeight = '145-159$u';
        if (bodyFrameSize == 'Large') idealWeight = '155-176$u';
      } else if (heightCm == 182.9 || heightCm >= 183) {
        if (bodyFrameSize == 'Small') idealWeight = '138-151$u';
        if (bodyFrameSize == 'Medium') idealWeight = '148-162$u';
        if (bodyFrameSize == 'Large') idealWeight = '158-179$u';
      }
    }

    // Lean Mass
    double lMass;
    if (isMale) {
      lMass = weightKg * 0.3281 + heightCm * 0.33929 - 29.5336;
    } else {
      lMass = weightKg * 0.29569 + heightCm * 0.41813 - 43.2933;
    }
    final leanMass = double.parse(lMass.toStringAsFixed(2));
    final leanMassPercent = ((leanMass / weightKg) * 100).round();

    // Body fat
    final bodyFat = double.parse((weightKg - leanMass).toStringAsFixed(2));
    final bodyFatPercent = 100 - leanMassPercent;

    // Resting Metabolism
    final rmrDayTemp = 66 + 6.23 * weightKg + 12.7 * heightCm - 6.8 * age;
    final rmrDay = rmrDayTemp.round();
    final rmrHour = (rmrDay / 24).round();

    // Average Actual Metabolism
    final avgMetDay = (rmrDay * actLevelFactor).round();
    final avgMetHour = (avgMetDay / 24).round();

    // Max Heart Rate
    double mhrBpm;
    if (isMale) {
      mhrBpm = 220 - age;
    } else {
      mhrBpm = 226 - age;
    }
    final mhrBpmInt = mhrBpm.round();
    final mhrPer10s = (mhrBpmInt / 6).round();

    // Karvonen Target Heart Rate
    double goalFactor1;
    double goalFactor2;
    if (fitGoal == 1) {
      goalFactor1 = 0.50;
      goalFactor2 = 0.60;
    } else if (fitGoal == 2) {
      goalFactor1 = 0.60;
      goalFactor2 = 0.70;
    } else if (fitGoal == 3) {
      goalFactor1 = 0.70;
      goalFactor2 = 0.80;
    } else if (fitGoal == 4) {
      goalFactor1 = 0.80;
      goalFactor2 = 0.90;
    } else {
      goalFactor1 = 0.90;
      goalFactor2 = 1.00;
    }

    final thrBpmLow = ((mhrBpmInt - rhr) * goalFactor1 + rhr).round();
    final thrBpmHigh = ((mhrBpmInt - rhr) * goalFactor2 + rhr).round();
    final thr10sLow = (thrBpmLow / 6).round();
    final thr10sHigh = (thrBpmHigh / 6).round();

    setState(() {
      _bmi = bmiRounded.toString();
      _bmiClass = bmiClass;
      _waistHipRatio = wthStr;
      _bodyShape = bodyShape;
      _waistHipInterp = waistToHipInterp;
      _frameSize = bodyFrameSize;
      _idealWeight = idealWeight;
      _fatMass = '${bodyFat.toStringAsFixed(2)} kg, $bodyFatPercent %';
      _leanMass = '${leanMass.toStringAsFixed(2)} kg, $leanMassPercent %';

      _rmrDay = rmrDay.toString();
      _rmrHour = rmrHour.toString();
      _avgCalDay = avgMetDay.toString();
      _avgCalHour = avgMetHour.toString();
      _targetHrBpm = '$thrBpmLow - $thrBpmHigh';
      _targetHrPer10s = '$thr10sLow - $thr10sHigh';
      _maxHrBpm = mhrBpmInt.toString();
      _maxHrPer10s = mhrPer10s.toString();

      _showResults = true;
    });
  }

  Future<void> _scrollToResults() async {
    if (!_showResults) return;
    await _scrollCtl.animateTo(
      _scrollCtl.position.maxScrollExtent,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
    );
  }

  void _openInfo() {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      GlassyPageRoute(page: const MoreInformations()),
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

    final weightUnit = _isMetric ? 'kg' : 'lb';
    final sizeUnit = _isMetric ? 'cm' : 'in';

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _showResults
          ? FloatingActionButton.extended(
              onPressed: _scrollToResults,
              backgroundColor: Colors.white.withOpacity(0.14),
              elevation: 0,
              icon: Icon(Icons.auto_graph_rounded, color: cs.primary.withOpacity(0.95)),
              label: Text(
                'Results',
                style: t.textTheme.labelLarge?.copyWith(
                  color: Colors.white.withOpacity(0.92),
                  fontWeight: FontWeight.w900,
                ),
              ),
            )
          : null,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              _bg,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFF0B0F14)),
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
                          title: "Full Body Analysis",
                          onBack: () => Navigator.of(context).maybePop(),
                          onInfo: _openInfo,
                        ),
                        const SizedBox(height: 12),

                        _QuickActions(
                          leftText: "Units: $weightUnit / $sizeUnit",
                          onInfo: _openInfo,
                          onResults: _showResults ? _scrollToResults : null,
                        ),
                        const SizedBox(height: 12),

                        Expanded(
                          child: _Glass(
                            radius: 20,
                            padding: EdgeInsets.zero,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: CustomScrollView(
                                controller: _scrollCtl,
                                physics: const BouncingScrollPhysics(),
                                slivers: [
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                                      child: _InfoBanner(
                                        title: "Calculator",
                                        subtitle:
                                            "Fill fields, calculate, then scroll to results.",
                                      ),
                                    ),
                                  ),

                                  // Units segmented
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
                                                    Icons.straighten_rounded,
                                                    color: cs.primary.withOpacity(0.92),
                                                    size: 22,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    "Units",
                                                    style: t.textTheme.titleMedium?.copyWith(
                                                      fontWeight: FontWeight.w900,
                                                      color: Colors.white.withOpacity(0.96),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: _SegChip(
                                                    text: _unitsMetric,
                                                    selected: _selectedUnits == _unitsMetric,
                                                    onTap: () {
                                                      HapticFeedback.selectionClick();
                                                      setState(() {
                                                        _selectedUnits = _unitsMetric;
                                                        unitsController.text = _unitsMetric;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: _SegChip(
                                                    text: _unitsUS,
                                                    selected: _selectedUnits == _unitsUS,
                                                    onTap: () {
                                                      HapticFeedback.selectionClick();
                                                      setState(() {
                                                        _selectedUnits = _unitsUS;
                                                        unitsController.text = _unitsUS;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              "Inputs: Weight=$weightUnit, Sizes=$sizeUnit",
                                              textAlign: TextAlign.center,
                                              style: t.textTheme.bodySmall?.copyWith(
                                                color: Colors.white.withOpacity(0.72),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Form section
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _Glass(
                                        radius: 18,
                                        padding: const EdgeInsets.all(14),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            _SectionTitleRow(
                                              icon: Icons.tune_rounded,
                                              title: "Parameters",
                                              subtitle: "Gender, weight, height, measurements",
                                            ),
                                            const SizedBox(height: 12),

                                            Row(
                                              children: [
                                                Expanded(
                                                  child: _DropdownField(
                                                    title: "Gender",
                                                    value: _selectedGender,
                                                    items: const [_genderMale, _genderFemale],
                                                    onChanged: (v) {
                                                      setState(() {
                                                        _selectedGender = v;
                                                        genderController.text = v ?? '';
                                                      });
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: _NumberField(
                                                    title: "Weight",
                                                    hint: _isMetric ? "70" : "154",
                                                    controller: weightController,
                                                    suffix: weightUnit,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),

                                            if (_isMetric)
                                              _NumberField(
                                                title: "Height",
                                                hint: "175",
                                                controller: heightCmController,
                                                suffix: "cm",
                                              )
                                            else
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: _NumberField(
                                                      title: "Height (feet)",
                                                      hint: "5",
                                                      controller: heightFeetController,
                                                      suffix: "ft",
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: _NumberField(
                                                      title: "Height (inches)",
                                                      hint: "9",
                                                      controller: heightInchController,
                                                      suffix: "in",
                                                    ),
                                                  ),
                                                ],
                                              ),

                                            const SizedBox(height: 14),
                                            _DividerGlow(),
                                            const SizedBox(height: 14),

                                            Row(
                                              children: [
                                                Expanded(
                                                  child: _NumberField(
                                                    title: "Age",
                                                    hint: "29",
                                                    controller: ageController,
                                                    suffix: "",
                                                    isInt: true,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: _NumberField(
                                                    title: "RHR",
                                                    hint: "60",
                                                    controller: rhrController,
                                                    suffix: "bpm",
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),

                                            Row(
                                              children: [
                                                Expanded(
                                                  child: _NumberField(
                                                    title: "Waist",
                                                    hint: _isMetric ? "80" : "31.5",
                                                    controller: waistController,
                                                    suffix: sizeUnit,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: _NumberField(
                                                    title: "Elbow (in Neck field)",
                                                    hint: _isMetric ? "6.4" : "2.5",
                                                    controller: neckController,
                                                    suffix: sizeUnit,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),

                                            Row(
                                              children: [
                                                Expanded(
                                                  child: _NumberField(
                                                    title: "Hip",
                                                    hint: _isMetric ? "95" : "37.4",
                                                    controller: hipController,
                                                    suffix: sizeUnit,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: _DropdownField(
                                                    title: "Activity level",
                                                    value: _selectedActivity,
                                                    items: _activityLabels,
                                                    onChanged: (v) {
                                                      setState(() {
                                                        _selectedActivity = v;
                                                        activityLevelController.text = v ?? '';
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),

                                            _DropdownField(
                                              title: "Fitness goal",
                                              value: _selectedGoal,
                                              items: _goalLabels,
                                              onChanged: (v) {
                                                setState(() {
                                                  _selectedGoal = v;
                                                  goalController.text = v ?? '';
                                                });
                                              },
                                            ),

                                            const SizedBox(height: 14),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: InkWell(
                                                borderRadius: BorderRadius.circular(14),
                                                onTap: _canSubmit
                                                    ? () async {
                                                        HapticFeedback.selectionClick();
                                                        setState(() => _isLoading = true);
                                                        await Future.delayed(
                                                            const Duration(milliseconds: 250));
                                                        _computeFullBody(context);
                                                        if (mounted) {
                                                          setState(() => _isLoading = false);
                                                        }
                                                        if (mounted) _scrollToResults();
                                                      }
                                                    : null,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 14, vertical: 12),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(14),
                                                    color: Colors.white.withOpacity(0.12),
                                                    border: Border.all(
                                                      color: Colors.white.withOpacity(0.16),
                                                      width: 1,
                                                    ),
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
                                                      Icon(
                                                        Icons.auto_awesome_rounded,
                                                        size: 18,
                                                        color: cs.primary.withOpacity(0.92),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      _isLoading
                                                          ? const SizedBox(
                                                              height: 16,
                                                              width: 16,
                                                              child: CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                color: Colors.white,
                                                              ),
                                                            )
                                                          : Text(
                                                              "Calculate",
                                                              style: t.textTheme.labelLarge
                                                                  ?.copyWith(
                                                                fontWeight: FontWeight.w900,
                                                                color: Colors.white
                                                                    .withOpacity(0.94),
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

                                  // Results section
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
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
                                                    Icons.auto_graph_rounded,
                                                    color: cs.primary.withOpacity(0.92),
                                                    size: 22,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    "Results",
                                                    style: t.textTheme.titleMedium?.copyWith(
                                                      fontWeight: FontWeight.w900,
                                                      color: Colors.white.withOpacity(0.96),
                                                    ),
                                                  ),
                                                ),
                                                if (!_showResults)
                                                  Text(
                                                    "—",
                                                    style: t.textTheme.titleMedium?.copyWith(
                                                      fontWeight: FontWeight.w900,
                                                      color: Colors.white.withOpacity(0.70),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),

                                            _ResultRow(label: "BMI", value: _bmi),
                                            _ResultRow(label: "BMI Class", value: _bmiClass),
                                            _ResultRow(label: "Waist/Hip Ratio", value: _waistHipRatio),
                                            _ResultRow(label: "Body Shape", value: _bodyShape),
                                            _ResultRow(label: "WH Interpretation", value: _waistHipInterp),
                                            _ResultRow(label: "Frame Size", value: _frameSize),
                                            _ResultRow(label: "Ideal Weight (range)", value: _idealWeight),
                                            _ResultRow(label: "Fat Mass", value: _fatMass),
                                            _ResultRow(label: "Lean Mass", value: _leanMass),

                                            const SizedBox(height: 10),
                                            _GroupRow(
                                              title: "Resting Metabolism (RMR)",
                                              left: "$_rmrDay cal/day",
                                              right: "$_rmrHour cal/hour",
                                            ),
                                            _GroupRow(
                                              title: "Average Metabolism",
                                              left: "$_avgCalDay cal/day",
                                              right: "$_avgCalHour cal/hour",
                                            ),
                                            _GroupRow(
                                              title: "Target HR (Karvonen)",
                                              left: "$_targetHrBpm bpm",
                                              right: "$_targetHrPer10s b/10s",
                                            ),
                                            _GroupRow(
                                              title: "Max HR",
                                              left: "$_maxHrBpm bpm",
                                              right: "$_maxHrPer10s b/10s",
                                            ),

                                            const SizedBox(height: 12),
                                            InkWell(
                                              borderRadius: BorderRadius.circular(18),
                                              onTap: _openInfo,
                                              child: _Glass(
                                                radius: 18,
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 12, vertical: 10),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.info_outline_rounded,
                                                        size: 18,
                                                        color: cs.primary.withOpacity(0.92)),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        "More informations",
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: t.textTheme.bodyMedium?.copyWith(
                                                          fontWeight: FontWeight.w900,
                                                          color: Colors.white.withOpacity(0.90),
                                                        ),
                                                      ),
                                                    ),
                                                    Icon(Icons.arrow_forward_rounded,
                                                        color: Colors.white.withOpacity(0.88)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SliverToBoxAdapter(child: SizedBox(height: 6)),
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
  final VoidCallback onInfo;

  const _HeaderModern({
    required this.title,
    required this.onBack,
    required this.onInfo,
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
            icon: Icons.info_outline_rounded,
            onTap: onInfo,
            accent: cs.primary.withOpacity(0.90),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final String leftText;
  final VoidCallback onInfo;
  final VoidCallback? onResults;

  const _QuickActions({
    required this.leftText,
    required this.onInfo,
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
                Icon(Icons.stacked_line_chart_rounded,
                    size: 18, color: cs.primary.withOpacity(0.92)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    leftText,
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
            onInfo();
          },
          child: _Glass(
            radius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.help_outline_rounded,
                    size: 18, color: cs.primary.withOpacity(0.92)),
                const SizedBox(width: 8),
                Text(
                  "Info",
                  style: t.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.90),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (onResults != null) ...[
          const SizedBox(width: 10),
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              HapticFeedback.lightImpact();
              onResults?.call();
            },
            child: _Glass(
              radius: 18,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_downward_rounded,
                      size: 18, color: cs.primary.withOpacity(0.92)),
                  const SizedBox(width: 8),
                  Text(
                    "Results",
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

class _SectionTitleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionTitleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Row(
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
    );
  }
}

class _SegChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _SegChip({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: selected ? cs.primary.withOpacity(0.22) : Colors.white.withOpacity(0.08),
          border: Border.all(
            color: selected ? cs.primary.withOpacity(0.45) : Colors.white.withOpacity(0.14),
            width: 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: cs.primary.withOpacity(0.20),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            text,
            style: t.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(selected ? 0.96 : 0.84),
            ),
          ),
        ),
      ),
    );
  }
}

class _DividerGlow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.10),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final String title;
  final String hint;
  final TextEditingController controller;
  final String suffix;
  final bool isInt;

  const _NumberField({
    required this.title,
    required this.hint,
    required this.controller,
    required this.suffix,
    this.isInt = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: t.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.white.withOpacity(0.78),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: isInt
              ? TextInputType.number
              : const TextInputType.numberWithOptions(decimal: true),
          style: t.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: Colors.white.withOpacity(0.96),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.10),
            hintText: hint,
            hintStyle: t.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.38),
              fontWeight: FontWeight.w700,
            ),
            suffixText: suffix.isEmpty ? null : suffix,
            suffixStyle: t.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.78),
            ),
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

class _DropdownField extends StatelessWidget {
  final String title;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: t.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.white.withOpacity(0.78),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.expand_more_rounded, color: Colors.white.withOpacity(0.88)),
          decoration: InputDecoration(
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
          dropdownColor: const Color(0xFF0B1220),
          items: items
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(
                    e,
                    style: t.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.92),
                      fontWeight: FontWeight.w800,
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

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.10),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
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

class _GroupRow extends StatelessWidget {
  final String title;
  final String left;
  final String right;

  const _GroupRow({
    required this.title,
    required this.left,
    required this.right,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white.withOpacity(0.10), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: t.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.90),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                left,
                style: t.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withOpacity(0.82),
                ),
              ),
              Text(
                right,
                style: t.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withOpacity(0.82),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* ========================================================================== */
/* Glass kit (same spirit as BeepIntermittentTrainingView) */
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

/* ========================================================================== */
/* Glassy route (kept, but adapted to this file) */
/* ========================================================================== */

class GlassyPageRoute<T> extends PageRouteBuilder<T> {
  GlassyPageRoute({required Widget page})
      : super(
          opaque: false,
          barrierColor: Colors.transparent,
          transitionDuration: const Duration(milliseconds: 420),
          reverseTransitionDuration: const Duration(milliseconds: 360),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final curve = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.10, 1.0, curve: Curves.easeOut),
              ),
            );
            final scale = Tween<double>(begin: 0.96, end: 1.00).animate(curve);
            final slide = Tween<Offset>(begin: const Offset(0, .02), end: Offset.zero)
                .animate(curve);
            final blur = Tween<double>(begin: 0.0, end: 10.0).animate(curve);
            final tint = Tween<double>(begin: 0.0, end: isDark ? 0.10 : 0.05).animate(curve);

            return Stack(
              children: [
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: blur,
                    builder: (_, __) => BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: blur.value, sigmaY: blur.value),
                      child: Container(
                        color: Colors.black.withOpacity(tint.value),
                      ),
                    ),
                  ),
                ),
                FadeTransition(
                  opacity: fade,
                  child: ScaleTransition(
                    scale: scale,
                    child: SlideTransition(position: slide, child: child),
                  ),
                ),
              ],
            );
          },
        );
}