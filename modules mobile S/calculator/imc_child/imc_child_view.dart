// lib/features/.../imc_child_view.dart
//
// ✅ Logique IMC enfant inchangée
// ✅ Suppression de intl/localization
// ✅ Suppression de TabBar / TabBarView
// ✅ Design identique à BeepIntermittentTrainingView
// ✅ Même fond premium + overlay + glass cards + animations

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/widget/loading_widget.dart';

class _TXT {
  static const String screenTitle = "IMC Enfant";

  static const String introTitle = "IMC enfant";
  static const String introSubtitle =
      "Calcule l’indice de masse corporelle selon la taille, le poids, l’âge et le sexe.";

  static const String calcTitle = "Calculateur";
  static const String calcDesc =
      "Saisis la taille, le poids, l’âge et le sexe, puis lance le calcul.";

  static const String height = "Taille";
  static const String weight = "Poids";
  static const String age = "Âge";
  static const String sex = "Sexe";

  static const String sexGirl = "Fille";
  static const String sexBoy = "Garçon";

  static const String cm = "cm";
  static const String kg = "kg";
  static const String calculate = "Calculer";

  static const String yourResults = "Résultats";
  static const String bmi = "IMC";
  static const String status = "Évaluation";
  static const String noResult = "—";

  static const String chipMethod = "IMC enfant";
  static const String chipEstimate = "Évaluation pédiatrique";

  static const String severeUnderweight = "Maigreur importante";
  static const String mildUnderweight = "Maigreur";
  static const String normal = "Corpulence normale";
  static const String overweight = "Surpoids";
  static const String obesity = "Obésité";

  static const String infoTitle1 = "Comprendre l’IMC enfant";
  static const String infoBody1 =
      "L’IMC enfant ne s’interprète pas comme chez l’adulte. Il dépend de la taille, du poids, de l’âge et du sexe.";
  static const String infoBody2 =
      "Le calcul utilise l’IMC classique puis compare le résultat à des seuils spécifiques selon l’âge et le sexe.";
  static const String infoBody3 =
      "L’évaluation finale permet de distinguer la maigreur importante, la maigreur, la corpulence normale, le surpoids et l’obésité.";

  static const String infoTitle2 = "Interprétation";
  static const String infoBody4 =
      "Le résultat affiché doit être interprété comme un repère général. En cas de doute, un professionnel de santé reste la meilleure référence.";
  static const String infoBody5 =
      "Les seuils évoluent avec la croissance. Deux enfants ayant le même IMC peuvent donc avoir une interprétation différente selon l’âge et le sexe.";

  static const String infoTitle3 = "Courbes garçon";
  static const String infoTitle4 = "Courbes fille";

  static String inputControl(String label) => "Veuillez saisir $label.";
  static String inputControlInvalid(String label) => "$label invalide.";
}

class ImcChildView extends StatefulWidget {
  const ImcChildView({super.key});

  @override
  State<ImcChildView> createState() => _ImcChildViewState();
}

class _ImcChildViewState extends State<ImcChildView>
    with TickerProviderStateMixin {
  static const String _bg = "assets/images/BgS.jfif";

  final TextEditingController height = TextEditingController(text: "0");
  final TextEditingController weight = TextEditingController(text: "0");
  final TextEditingController age = TextEditingController(text: "0");
  final TextEditingController sexe = TextEditingController();

  late final AnimationController _enterCtrl;

  double? _imc;
  String? _tagKey;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    )..forward();
  }

  @override
  void dispose() {
    height.dispose();
    weight.dispose();
    age.dispose();
    sexe.dispose();
    _enterCtrl.dispose();
    super.dispose();
  }

  double _safeDouble(String s) =>
      double.tryParse(s.trim().replaceAll(',', '.')) ?? double.nan;

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// ✅ Logique IMC enfant inchangée
  void _computeChildImc(BuildContext context) {
    final h = _safeDouble(height.text);
    final p = _safeDouble(weight.text);
    final a = _safeDouble(age.text);
    final sexText = sexe.text;

    if (height.text.trim().isEmpty) {
      _showError(context, _TXT.inputControl(_TXT.height));
      return;
    } else if (weight.text.trim().isEmpty) {
      _showError(context, _TXT.inputControl(_TXT.weight));
      return;
    } else if (age.text.trim().isEmpty) {
      _showError(context, _TXT.inputControl(_TXT.age));
      return;
    } else if (sexText.isEmpty) {
      _showError(context, _TXT.inputControl(_TXT.sex));
      return;
    } else if (h.isNaN || h <= 0) {
      _showError(context, _TXT.inputControlInvalid(_TXT.height));
      return;
    } else if (p.isNaN || p <= 0) {
      _showError(context, _TXT.inputControlInvalid(_TXT.weight));
      return;
    } else if (a.isNaN || a < 0 || a > 18) {
      _showError(context, _TXT.inputControlInvalid(_TXT.age));
      return;
    }

    final imcValue = p / ((h / 100.0) * (h / 100.0));
    final isGirl = sexText == _TXT.sexGirl;

    double imcmin3 = 0, imcmin25 = 0, imcmin75 = 0, imcmin97 = 0;

    if (isGirl) {
      if (a >= 0 && a < 0.25) {
        imcmin3 = 11;
        imcmin25 = 11.5;
        imcmin75 = 13.5;
        imcmin97 = 15;
      } else if (a >= 0.25 && a < 0.50) {
        imcmin3 = 13;
        imcmin25 = 14.5;
        imcmin75 = 16;
        imcmin97 = 18;
      } else if (a >= 0.50 && a < 0.75) {
        imcmin3 = 14.2;
        imcmin25 = 15.5;
        imcmin75 = 17.5;
        imcmin97 = 19;
      } else if (a >= 0.75 && a < 1) {
        imcmin3 = 14.7;
        imcmin25 = 16.1;
        imcmin75 = 18;
        imcmin97 = 19.8;
      } else if (a >= 1 && a < 1.5) {
        imcmin3 = 14.8;
        imcmin25 = 16.25;
        imcmin75 = 18.15;
        imcmin97 = 20;
      } else if (a >= 1.5 && a < 2) {
        imcmin3 = 14.5;
        imcmin25 = 16;
        imcmin75 = 17.8;
        imcmin97 = 19.6;
      } else if (a >= 2 && a < 2.5) {
        imcmin3 = 14.2;
        imcmin25 = 15.55;
        imcmin75 = 17.35;
        imcmin97 = 19.1;
      } else if (a >= 2.5 && a < 3) {
        imcmin3 = 13.9;
        imcmin25 = 15.25;
        imcmin75 = 17;
        imcmin97 = 18.75;
      } else if (a >= 3 && a < 3.5) {
        imcmin3 = 13.75;
        imcmin25 = 15;
        imcmin75 = 16.75;
        imcmin97 = 18.4;
      } else if (a >= 3.5 && a < 4) {
        imcmin3 = 13.5;
        imcmin25 = 14.8;
        imcmin75 = 16.5;
        imcmin97 = 18.2;
      } else if (a >= 4 && a < 4.5) {
        imcmin3 = 13.4;
        imcmin25 = 14.7;
        imcmin75 = 16.25;
        imcmin97 = 17.9;
      } else if (a >= 4.5 && a < 5) {
        imcmin3 = 13.25;
        imcmin25 = 14.5;
        imcmin75 = 16.2;
        imcmin97 = 17.8;
      } else if (a >= 5 && a < 5.5) {
        imcmin3 = 13.15;
        imcmin25 = 14.4;
        imcmin75 = 16;
        imcmin97 = 17.75;
      } else if (a >= 5.5 && a < 6) {
        imcmin3 = 13;
        imcmin25 = 14.3;
        imcmin75 = 16;
        imcmin97 = 17.75;
      } else if (a >= 6 && a < 6.5) {
        imcmin3 = 13;
        imcmin25 = 14.3;
        imcmin75 = 16;
        imcmin97 = 17.8;
      } else if (a >= 6.5 && a < 7) {
        imcmin3 = 13;
        imcmin25 = 14.3;
        imcmin75 = 16;
        imcmin97 = 17.85;
      } else if (a >= 7 && a < 7.5) {
        imcmin3 = 13;
        imcmin25 = 14.4;
        imcmin75 = 16.1;
        imcmin97 = 18;
      } else if (a >= 7.5 && a < 8) {
        imcmin3 = 13.05;
        imcmin25 = 14.5;
        imcmin75 = 16.25;
        imcmin97 = 18.2;
      } else if (a >= 8 && a < 8.5) {
        imcmin3 = 13.15;
        imcmin25 = 14.5;
        imcmin75 = 16.4;
        imcmin97 = 18.5;
      } else if (a >= 8.5 && a < 9) {
        imcmin3 = 13.2;
        imcmin25 = 14.6;
        imcmin75 = 16.6;
        imcmin97 = 18.75;
      } else if (a >= 9 && a < 9.5) {
        imcmin3 = 13.25;
        imcmin25 = 14.7;
        imcmin75 = 16.8;
        imcmin97 = 19.1;
      } else if (a >= 9.5 && a < 10) {
        imcmin3 = 13.4;
        imcmin25 = 15;
        imcmin75 = 17.1;
        imcmin97 = 19.5;
      } else if (a >= 10 && a < 10.5) {
        imcmin3 = 13.5;
        imcmin25 = 15.1;
        imcmin75 = 17.4;
        imcmin97 = 19.9;
      } else if (a >= 10.5 && a < 11) {
        imcmin3 = 13.6;
        imcmin25 = 15.3;
        imcmin75 = 17.75;
        imcmin97 = 20.4;
      } else if (a >= 11 && a < 11.5) {
        imcmin3 = 13.8;
        imcmin25 = 15.5;
        imcmin75 = 18;
        imcmin97 = 20.9;
      } else if (a >= 11.5 && a < 12) {
        imcmin3 = 14;
        imcmin25 = 15.75;
        imcmin75 = 18.4;
        imcmin97 = 21.4;
      } else if (a >= 12 && a < 12.5) {
        imcmin3 = 14.25;
        imcmin25 = 16.1;
        imcmin75 = 18.8;
        imcmin97 = 22;
      } else if (a >= 12.5 && a < 13) {
        imcmin3 = 14.5;
        imcmin25 = 16.5;
        imcmin75 = 19.2;
        imcmin97 = 22.5;
      } else if (a >= 13 && a < 13.5) {
        imcmin3 = 14.8;
        imcmin25 = 16.75;
        imcmin75 = 19.6;
        imcmin97 = 23.1;
      } else if (a >= 13.5 && a < 14) {
        imcmin3 = 15;
        imcmin25 = 17.1;
        imcmin75 = 20.1;
        imcmin97 = 23.6;
      } else if (a >= 14 && a < 14.5) {
        imcmin3 = 15.3;
        imcmin25 = 17.45;
        imcmin75 = 20.5;
        imcmin97 = 24.2;
      } else if (a >= 14.5 && a < 15) {
        imcmin3 = 15.6;
        imcmin25 = 17.75;
        imcmin75 = 20.85;
        imcmin97 = 24.7;
      } else if (a >= 15 && a < 15.5) {
        imcmin3 = 15.8;
        imcmin25 = 18;
        imcmin75 = 21.2;
        imcmin97 = 25.1;
      } else if (a >= 15.5 && a < 16) {
        imcmin3 = 16;
        imcmin25 = 18.2;
        imcmin75 = 21.5;
        imcmin97 = 25.4;
      } else if (a >= 16 && a < 16.5) {
        imcmin3 = 16.25;
        imcmin25 = 18.5;
        imcmin75 = 21.75;
        imcmin97 = 25.65;
      } else if (a >= 16.5 && a < 17) {
        imcmin3 = 16.4;
        imcmin25 = 18.6;
        imcmin75 = 21.8;
        imcmin97 = 25.8;
      } else if (a >= 17 && a < 17.5) {
        imcmin3 = 16.5;
        imcmin25 = 18.7;
        imcmin75 = 22;
        imcmin97 = 26.1;
      } else if (a >= 17.5 && a < 18) {
        imcmin3 = 16.6;
        imcmin25 = 18.8;
        imcmin75 = 22.15;
        imcmin97 = 26.2;
      } else if (a == 18) {
        imcmin3 = 16.7;
        imcmin25 = 18.9;
        imcmin75 = 22.3;
        imcmin97 = 26.3;
      }
    } else {
      if (a >= 0 && a < 0.25) {
        imcmin3 = 11;
        imcmin25 = 11.5;
        imcmin75 = 14.5;
        imcmin97 = 15.5;
      } else if (a >= 0.25 && a < 0.50) {
        imcmin3 = 13.5;
        imcmin25 = 14.2;
        imcmin75 = 16.5;
        imcmin97 = 18.5;
      } else if (a >= 0.50 && a < 0.75) {
        imcmin3 = 14.5;
        imcmin25 = 16;
        imcmin75 = 17.8;
        imcmin97 = 19.8;
      } else if (a >= 0.75 && a < 1) {
        imcmin3 = 15;
        imcmin25 = 16.4;
        imcmin75 = 18.25;
        imcmin97 = 20.3;
      } else if (a >= 1 && a < 1.5) {
        imcmin3 = 15.1;
        imcmin25 = 16.5;
        imcmin75 = 18.4;
        imcmin97 = 20.3;
      } else if (a >= 1.5 && a < 2) {
        imcmin3 = 14.8;
        imcmin25 = 16.25;
        imcmin75 = 17.9;
        imcmin97 = 19.8;
      } else if (a >= 2 && a < 2.5) {
        imcmin3 = 14.5;
        imcmin25 = 15.75;
        imcmin75 = 17.4;
        imcmin97 = 19.1;
      } else if (a >= 2.5 && a < 3) {
        imcmin3 = 14.25;
        imcmin25 = 15.45;
        imcmin75 = 17;
        imcmin97 = 18.7;
      } else if (a >= 3 && a < 3.5) {
        imcmin3 = 14;
        imcmin25 = 15.25;
        imcmin75 = 16.8;
        imcmin97 = 18.35;
      } else if (a >= 3.5 && a < 4) {
        imcmin3 = 13.85;
        imcmin25 = 15.1;
        imcmin75 = 16.55;
        imcmin97 = 18.15;
      } else if (a >= 4 && a < 4.5) {
        imcmin3 = 13.8;
        imcmin25 = 14.95;
        imcmin75 = 16.48;
        imcmin97 = 18;
      } else if (a >= 4.5 && a < 5) {
        imcmin3 = 13.7;
        imcmin25 = 14.85;
        imcmin75 = 16.35;
        imcmin97 = 17.9;
      } else if (a >= 5 && a < 5.5) {
        imcmin3 = 13.5;
        imcmin25 = 14.75;
        imcmin75 = 16.3;
        imcmin97 = 17.9;
      } else if (a >= 5.5 && a < 6) {
        imcmin3 = 13.47;
        imcmin25 = 14.7;
        imcmin75 = 16.25;
        imcmin97 = 17.9;
      } else if (a >= 6 && a < 6.5) {
        imcmin3 = 13.45;
        imcmin25 = 14.65;
        imcmin75 = 16.28;
        imcmin97 = 17.95;
      } else if (a >= 6.5 && a < 7) {
        imcmin3 = 13.45;
        imcmin25 = 14.65;
        imcmin75 = 16.35;
        imcmin97 = 18.1;
      } else if (a >= 7 && a < 7.5) {
        imcmin3 = 13.45;
        imcmin25 = 14.7;
        imcmin75 = 16.42;
        imcmin97 = 18.25;
      } else if (a >= 7.5 && a < 8) {
        imcmin3 = 13.48;
        imcmin25 = 14.8;
        imcmin75 = 16.55;
        imcmin97 = 18.5;
      } else if (a >= 8 && a < 8.5) {
        imcmin3 = 13.5;
        imcmin25 = 14.85;
        imcmin75 = 16.7;
        imcmin97 = 18.75;
      } else if (a >= 8.5 && a < 9) {
        imcmin3 = 13.53;
        imcmin25 = 15;
        imcmin75 = 16.85;
        imcmin97 = 19;
      } else if (a >= 9 && a < 9.5) {
        imcmin3 = 13.6;
        imcmin25 = 15.1;
        imcmin75 = 17.1;
        imcmin97 = 19.2;
      } else if (a >= 9.5 && a < 10) {
        imcmin3 = 13.7;
        imcmin25 = 15.2;
        imcmin75 = 17.25;
        imcmin97 = 19.65;
      } else if (a >= 10 && a < 10.5) {
        imcmin3 = 13.8;
        imcmin25 = 15.37;
        imcmin75 = 17.5;
        imcmin97 = 20;
      } else if (a >= 10.5 && a < 11) {
        imcmin3 = 13.85;
        imcmin25 = 15.5;
        imcmin75 = 17.75;
        imcmin97 = 20.25;
      } else if (a >= 11 && a < 11.5) {
        imcmin3 = 14;
        imcmin25 = 15.62;
        imcmin75 = 18;
        imcmin97 = 20.6;
      } else if (a >= 11.5 && a < 12) {
        imcmin3 = 14.19;
        imcmin25 = 15.8;
        imcmin75 = 18.1;
        imcmin97 = 21;
      } else if (a >= 12 && a < 12.5) {
        imcmin3 = 14.2;
        imcmin25 = 16;
        imcmin75 = 18.5;
        imcmin97 = 21.4;
      } else if (a >= 12.5 && a < 13) {
        imcmin3 = 14.5;
        imcmin25 = 16.25;
        imcmin75 = 18.8;
        imcmin97 = 21.75;
      } else if (a >= 13 && a < 13.5) {
        imcmin3 = 14.75;
        imcmin25 = 16.6;
        imcmin75 = 19.1;
        imcmin97 = 22.25;
      } else if (a >= 13.5 && a < 14) {
        imcmin3 = 15;
        imcmin25 = 16.8;
        imcmin75 = 19.5;
        imcmin97 = 22.75;
      } else if (a >= 14 && a < 14.5) {
        imcmin3 = 15.3;
        imcmin25 = 17.2;
        imcmin75 = 19.9;
        imcmin97 = 23.2;
      } else if (a >= 14.5 && a < 15) {
        imcmin3 = 15.55;
        imcmin25 = 17.5;
        imcmin75 = 20.3;
        imcmin97 = 23.6;
      } else if (a >= 15 && a < 15.5) {
        imcmin3 = 15.85;
        imcmin25 = 17.9;
        imcmin75 = 20.65;
        imcmin97 = 24.1;
      } else if (a >= 15.5 && a < 16) {
        imcmin3 = 16.1;
        imcmin25 = 18.1;
        imcmin75 = 21;
        imcmin97 = 24.5;
      } else if (a >= 16 && a < 16.5) {
        imcmin3 = 16.4;
        imcmin25 = 18.4;
        imcmin75 = 21.35;
        imcmin97 = 24.9;
      } else if (a >= 16.5 && a < 17) {
        imcmin3 = 16.6;
        imcmin25 = 18.7;
        imcmin75 = 21.68;
        imcmin97 = 25.2;
      } else if (a >= 17 && a < 17.5) {
        imcmin3 = 16.8;
        imcmin25 = 18.9;
        imcmin75 = 21.95;
        imcmin97 = 26;
      } else if (a >= 17.5 && a < 18) {
        imcmin3 = 16.9;
        imcmin25 = 19.1;
        imcmin75 = 22.2;
        imcmin97 = 25.75;
      } else if (a == 18) {
        imcmin3 = 17;
        imcmin25 = 19.25;
        imcmin75 = 22.4;
        imcmin97 = 26;
      }
    }

    String evaluationKey;
    if (imcValue <= imcmin3) {
      evaluationKey = "severe_underweight";
    } else if (imcValue > imcmin3 && imcValue <= imcmin25) {
      evaluationKey = "mild_underweight";
    } else if (imcValue > imcmin25 && imcValue <= imcmin75) {
      evaluationKey = "normal";
    } else if (imcValue > imcmin75 && imcValue < imcmin97) {
      evaluationKey = "overweight";
    } else {
      evaluationKey = "obesity";
    }

    setState(() {
      _imc = imcValue;
      _tagKey = evaluationKey;
    });
  }

  String _statusLabel(String key) {
    switch (key) {
      case "severe_underweight":
        return _TXT.severeUnderweight;
      case "mild_underweight":
        return _TXT.mildUnderweight;
      case "normal":
        return _TXT.normal;
      case "overweight":
        return _TXT.overweight;
      case "obesity":
        return _TXT.obesity;
      default:
        return "—";
    }
  }

  Color _chipColorForIMC(BuildContext context, String key) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (key) {
      case "severe_underweight":
      case "mild_underweight":
        return isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6);
      case "normal":
        return isDark ? const Color(0xFF34D399) : const Color(0xFF10B981);
      case "overweight":
        return isDark ? const Color(0xFFF59E0B) : const Color(0xFFFB923C);
      case "obesity":
        return isDark ? const Color(0xFFF472B6) : const Color(0xFFEF4444);
      default:
        return isDark ? Colors.white24 : Colors.black12;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final isDark = t.brightness == Brightness.dark;
    final hasResult = _imc != null && _tagKey != null;

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
                        ),
                        const SizedBox(height: 12),
                        _QuickActions(
                          resultText: hasResult
                              ? _imc!.toStringAsFixed(2)
                              : _TXT.noResult,
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
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                slivers: [
                                  const SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(12, 12, 12, 8),
                                      child: _InfoBanner(
                                        title: _TXT.introTitle,
                                        subtitle: _TXT.introSubtitle,
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _CalcCard(
                                        heightCtl: height,
                                        weightCtl: weight,
                                        ageCtl: age,
                                        sexCtl: sexe,
                                        onCompute: () {
                                          HapticFeedback.selectionClick();
                                          _computeChildImc(context);
                                        },
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _ResultCard(
                                        imc: _imc,
                                        tagKey: _tagKey,
                                        statusLabelBuilder: _statusLabel,
                                        chipColorBuilder: (key) =>
                                            _chipColorForIMC(context, key),
                                      ),
                                    ),
                                  ),
                                  const SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _TextInfoCard(),
                                    ),
                                  ),
                                  const SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _ImageInfoCard(
                                        title: "Repères généraux",
                                        body:
                                            "L’interprétation de l’IMC enfant repose sur des courbes et des seuils qui évoluent avec la croissance.",
                                        url:
                                            "https://www.calculersonimc.fr/wp-content/uploads/2018/04/ximc-enfant-a-table.jpg.pagespeed.ic.7RoKZII81e.jpg",
                                      ),
                                    ),
                                  ),
                                  const SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _ImageInfoCard(
                                        title: "Suivi médical",
                                        body:
                                            "Le suivi de l’IMC enfant s’interprète dans la durée avec l’âge, la taille et le sexe.",
                                        url:
                                            "https://www.calculersonimc.fr/wp-content/uploads/2018/04/xdocteur-avec-enfant-mesurant-poids.jpg.pagespeed.ic.Evsvydhdqz.jpg",
                                      ),
                                    ),
                                  ),
                                  const SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _ImageInfoCard(
                                        title: _TXT.infoTitle3,
                                        body:
                                            "Courbe de référence garçon pour l’interprétation de l’IMC selon l’âge.",
                                        url:
                                            "https://www.calculersonimc.fr/images/ximc-enfant-garcon.jpg.pagespeed.ic.jdCaPQSAOE.jpg",
                                      ),
                                    ),
                                  ),
                                  const SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(12, 0, 12, 14),
                                      child: _ImageInfoCard(
                                        title: _TXT.infoTitle4,
                                        body:
                                            "Courbe de référence fille pour l’interprétation de l’IMC selon l’âge.",
                                        url:
                                            "https://www.calculersonimc.fr/images/ximc-enfant-fille.jpg.pagespeed.ic.0L5sZOdQPV.jpg",
                                      ),
                                    ),
                                  ),
                                  const SliverToBoxAdapter(
                                    child: SizedBox(height: 8),
                                  ),
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
/* Header + top actions */
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
          const SizedBox(width: 10),
          const _PillIconStatic(icon: Icons.child_care_rounded),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final String resultText;

  const _QuickActions({required this.resultText});

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
                  Icons.monitor_heart_rounded,
                  size: 18,
                  color: cs.primary.withOpacity(0.92),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "${_TXT.chipMethod} • ${_TXT.chipEstimate}",
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
        _Glass(
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
                resultText,
                style: t.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withOpacity(0.90),
                ),
              ),
            ],
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
            child: Icon(
              Icons.health_and_safety_rounded,
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
/* Content cards */
/* ========================================================================== */

class _CalcCard extends StatelessWidget {
  final TextEditingController heightCtl;
  final TextEditingController weightCtl;
  final TextEditingController ageCtl;
  final TextEditingController sexCtl;
  final VoidCallback onCompute;

  const _CalcCard({
    required this.heightCtl,
    required this.weightCtl,
    required this.ageCtl,
    required this.sexCtl,
    required this.onCompute,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return _Glass(
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
                  Icons.calculate_rounded,
                  color: cs.primary.withOpacity(0.92),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _TXT.calcTitle,
                  style: t.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.96),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _TXT.calcDesc,
            style: t.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.72),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          _NumberField(
            label: "${_TXT.height} (${_TXT.cm})",
            hint: "0",
            controller: heightCtl,
          ),
          const SizedBox(height: 12),
          _NumberField(
            label: "${_TXT.weight} (${_TXT.kg})",
            hint: "0",
            controller: weightCtl,
          ),
          const SizedBox(height: 12),
          _NumberField(
            label: _TXT.age,
            hint: "0",
            controller: ageCtl,
          ),
          const SizedBox(height: 12),
          _DropdownField(
            label: _TXT.sex,
            controller: sexCtl,
            items: const [_TXT.sexGirl, _TXT.sexBoy],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                HapticFeedback.lightImpact();
                onCompute();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                    Text(
                      _TXT.calculate,
                      style: t.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white.withOpacity(0.94),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final double? imc;
  final String? tagKey;
  final String Function(String key) statusLabelBuilder;
  final Color Function(String key) chipColorBuilder;

  const _ResultCard({
    required this.imc,
    required this.tagKey,
    required this.statusLabelBuilder,
    required this.chipColorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final hasResult = imc != null && tagKey != null;
    final chipColor = hasResult ? chipColorBuilder(tagKey!) : Colors.white24;
    final status = hasResult ? statusLabelBuilder(tagKey!) : _TXT.noResult;

    return _Glass(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _TXT.yourResults,
            style: t.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.96),
            ),
          ),
          const SizedBox(height: 10),
          if (hasResult) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: chipColor.withOpacity(0.12),
                border: Border.all(color: chipColor.withOpacity(0.55)),
              ),
              child: Column(
                children: [
                  Text(
                    status,
                    textAlign: TextAlign.center,
                    style: t.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withOpacity(0.96),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    imc!.toStringAsFixed(2),
                    style: t.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withOpacity(0.96),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            _ResultRow(label: _TXT.status, value: _TXT.noResult),
            _ResultRow(label: _TXT.bmi, value: _TXT.noResult),
          ],
          const SizedBox(height: 8),
          Text(
            hasResult
                ? "L’IMC affiché a été comparé aux seuils adaptés à l’âge et au sexe."
                : "Aucun résultat pour le moment. Saisis les données puis lance le calcul.",
            style: t.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.72),
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _TextInfoCard extends StatelessWidget {
  const _TextInfoCard();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return _Glass(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _TXT.infoTitle1,
            style: t.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.96),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _TXT.infoBody1,
            style: t.textTheme.bodyMedium?.copyWith(
              height: 1.25,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.82),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _TXT.infoBody2,
            style: t.textTheme.bodyMedium?.copyWith(
              height: 1.25,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.82),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _TXT.infoBody3,
            style: t.textTheme.bodyMedium?.copyWith(
              height: 1.25,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.82),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _TXT.infoTitle2,
            style: t.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.96),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _TXT.infoBody4,
            style: t.textTheme.bodySmall?.copyWith(
              height: 1.25,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.72),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _TXT.infoBody5,
            style: t.textTheme.bodySmall?.copyWith(
              height: 1.25,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageInfoCard extends StatelessWidget {
  final String title;
  final String body;
  final String url;

  const _ImageInfoCard({
    required this.title,
    required this.body,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return _Glass(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _NetImage(url: url),
          const SizedBox(height: 12),
          Text(
            title,
            style: t.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.96),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: t.textTheme.bodyMedium?.copyWith(
              height: 1.25,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.82),
            ),
          ),
        ],
      ),
    );
  }
}

/* ========================================================================== */
/* UI kit */
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
        child: Icon(
          icon,
          color: Colors.white.withOpacity(0.92),
          size: 20,
        ),
      ),
    );
  }
}

class _PillIconStatic extends StatelessWidget {
  final IconData icon;

  const _PillIconStatic({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withOpacity(0.10),
        border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
      ),
      child: Icon(
        icon,
        color: Colors.white.withOpacity(0.92),
        size: 20,
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

class _DropdownField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final List<String> items;

  const _DropdownField({
    required this.label,
    required this.controller,
    required this.items,
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
        DropdownButtonFormField<String>(
          value: controller.text.isEmpty ? null : controller.text,
          isExpanded: true,
          items: items
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(e, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (v) => controller.text = v ?? "",
          dropdownColor: const Color(0xFF11161D),
          iconEnabledColor: Colors.white.withOpacity(0.86),
          style: t.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: Colors.white.withOpacity(0.96),
          ),
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
                color: cs.primary.withOpacity(0.85),
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;

  const _NumberField({
    required this.label,
    required this.hint,
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
            hintText: hint,
            hintStyle: t.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.45),
              fontWeight: FontWeight.w700,
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

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow({
    required this.label,
    required this.value,
  });

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

class _NetImage extends StatelessWidget {
  final String url;

  const _NetImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      height: MediaQuery.of(context).size.height * 0.22,
      width: double.infinity,
      imageUrl: url,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ),
      ),
      placeholder: (context, url) => const SizedBox(
        height: 220,
        child: Center(child: LoadingWidget()),
      ),
      errorWidget: (context, url, error) => Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withOpacity(0.06),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: const Center(
          child: Icon(Icons.broken_image_rounded, color: Colors.white70),
        ),
      ),
    );
  }
}