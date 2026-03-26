import 'dart:ui';
import 'package:flutter/material.dart';

// ✅ TES IMPORTS EXISTANTS (inchangés)
import 'package:flutter_1/features/calculator/ideal_weigth_creff/ideal_weight_creff.dart';
import 'package:flutter_1/features/calculator/index_mass_adipose/index_mass_adipose_view.dart';
import 'package:flutter_1/features/calculator/nick_trefethen_imc/nick_trefethen_imc.dart';

import 'Img_calculation/img_clacuator.dart';
import 'atheletic_preparation/atheletic_preparation.dart';
import 'basal_metabolism/basal_metabolism_view.dart';
import 'biological_age/biological_age_view.dart';
import 'calories/calories_view.dart';
import 'ideal_measurements_rth/ideal_measurment_view.dart';
import 'ideal_weight_bornhardt/ideal_weight_bornhardt.dart';
import 'ideal_weight_lorentz/ideal_weigth_lorentz.dart';
import 'ideal_weigth_broca/ideal_weigth_broca.dart';
import 'ideal_weigth_monerot/ideal_weigth_monerot.dart';
import 'ideal_weigth_peck/ideal_weigth_peck.dart';
import 'imc_child/imc_child_view.dart';
import 'index_mass_corporal/index_mass_corporal_view.dart';
import 'macro_calculator/macro_calculator_view.dart';
import 'microcycles/microcycle_view.dart';
import 'one_rep_mac_tool/one_rep_max_tool_view.dart';
import 'trainnig/trainnig_view.dart';

class CalculatorMAin extends StatefulWidget {
  const CalculatorMAin({super.key});

  @override
  State<CalculatorMAin> createState() => _CalculatorMAinState();
}

class _CalculatorMAinState extends State<CalculatorMAin> {
  static const String _bgHome = 'assets/images/BgHome.jfif';

  late final PageController _pageCtl;
  double _page = 0;

  late final List<_CalcItem> _items;

  @override
  void initState() {
    super.initState();

    _pageCtl = PageController(viewportFraction: 0.78);
    _pageCtl.addListener(() {
      setState(() => _page = _pageCtl.page ?? 0);
    });

    _items = [
      _CalcItem(
        "Athletic Preparation",
        () => const AthleticPreparation(),
        "assets/calculator/Athletic_prep.jfif",
      ),
      _CalcItem(
        "Training",
        () => const TrainingView(),
        "assets/calculator/training.jfif",
      ),
      _CalcItem(
        "Microcycles",
        () => const MicrocycleView(),
        "assets/calculator/microcycles.jfif",
      ),
      _CalcItem(
        "Calories",
        () => const CaloriesCalculatorView(),
        "assets/calculator/calories.jfif",
      ),
      _CalcItem(
        "Macro Calculator",
        () => const MacroCalculatorView(),
        "assets/calculator/macro_calculator.jfif",
      ),
      _CalcItem(
        "One Rep Max Tool",
        () => const OneRepMAxToolView(),
        "assets/calculator/one_rep.jfif",
      ),
      _CalcItem(
        "Body Mass Index",
        () => const ImcCalculator(),
        "assets/calculator/body_mass.jfif",
      ),
      _CalcItem(
        "Body Fat Index",
        () => const CalculatingIMG(),
        "assets/calculator/body_fat.jfif",
      ),
      _CalcItem(
        "Ideal Measurements",
        () => const IdealMeasurementsView(),
        "assets/calculator/ideal_mesure.jfif",
      ),
      _CalcItem(
        "Basal Metabolism",
        () => const BasalMetabolismView(),
        "assets/calculator/basal_metabolism.jfif",
      ),
      _CalcItem(
        "Adipose Mass Index",
        () => const IndexMassAdiposeView(),
        "assets/calculator/adipose_mass.jfif",
      ),
      _CalcItem(
        "Ideal Weight Lorentz",
        () => const IdealWeigthLorentzView(),
        "assets/calculator/ideal_weight_L.jfif",
      ),
      _CalcItem(
        "Ideal Weight Monnerot",
        () => const IdealWeigthMonnerotView(),
        "assets/calculator/ideal_weight_M.jfif",
      ),
      _CalcItem(
        "Ideal Weight Creff",
        () => const IdealWeigthDevineView(),
        "assets/calculator/ideal_weight_D.jfif",
      ),
      _CalcItem(
        "Ideal Weight Broca",
        () => const IdealWeigthBrocaView(),
        "assets/calculator/ideal_weight_B.jfif",
      ),
      _CalcItem(
        "Ideal Weight Peck",
        () => const IdealWeigthPeckView(),
        "assets/calculator/ideal_weight_P.jfif",
      ),
      _CalcItem(
        "Ideal Weight Bornhardt",
        () => const IdealWeightBornhardtView(),
        "assets/calculator/ideal_weight_Bornhardt.jfif",
      ),
      _CalcItem(
        "Nick Trefethen BMI",
        () => const NickTrefethenImcView(),
        "assets/calculator/nick_BMI.jfif",
      ),
      _CalcItem(
        "Child BMI",
        () => const ImcChildView(),
        "assets/calculator/child_BMI.jfif",
      ),
      _CalcItem(
        "Biological Age",
        () => const BiologicalAgeView(),
        "assets/calculator/Biological_age.jfif",
      ),
    ];
  }

  @override
  void dispose() {
    _pageCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final isDark = t.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Calculator",
          style: t.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          /// ✅ BACKGROUND IDENTIQUE BEEPER
          Positioned.fill(child: Image.asset(_bgHome, fit: BoxFit.cover)),

          /// overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                /// ✅ CAROUSEL
                Expanded(
                  child: PageView.builder(
                    controller: _pageCtl,
                    itemCount: _items.length,
                    itemBuilder: (_, index) {
                      final item = _items[index];

                      final distance = (_page - index).abs().clamp(0.0, 1.0);
                      final scale = 1 - (0.1 * distance);
                      final tilt = (index - _page) * 0.1;

                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(tilt)
                          ..scale(scale),
                        child: _Card(
                          title: item.title,
                          image: item.image,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => item.builder()),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                _Indicator(count: _items.length, page: _page),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// MODEL
class _CalcItem {
  final String title;
  final Widget Function() builder;
  final String image;

  _CalcItem(this.title, this.builder, this.image);
}

/// CARD STYLE BEEPER
class _Card extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback onTap;

  const _Card({required this.title, required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Image.asset(image, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: t.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// INDICATOR
class _Indicator extends StatelessWidget {
  final int count;
  final double page;

  const _Indicator({required this.count, required this.page});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final d = (page - i).abs().clamp(0.0, 1.0);
        final w = 10 + (1 - d) * 18;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: w,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(1 - d),
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }
}
