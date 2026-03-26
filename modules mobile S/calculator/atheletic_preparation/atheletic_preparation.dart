// lib/feature/ppCalculator/preparation/athletic_preparation.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ✅ PDF + Printing
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class _TXT {
  static const String screenTitle = "Athletic Preparation";
  static const String introTitle = "Préparation prête";
  static const String introSubtitle =
      "Saisis les paramètres, les groupes se recalculent automatiquement, puis imprime en PDF si besoin.";

  static const String chipPrint = "Imprimer PDF";
  static const String chipAuto = "Calcul auto";
  static const String chipGroups = "5 Groupes";

  static const String sectionInputs = "Paramètres";
  static const String sectionResults = "Résultats par groupe";

  static const String lastLevelReached = "Last level reached";
  static const String differenceBetweenGrp = "Difference between group";
  static const String workingTime = "Working time";
  static const String intensity = "Intensity (%)";
  static const String percentage = "Percentage (%)";

  static const String group = "Group";
  static const String bearing = "Bearing";
  static const String vma = "VMA";
  static const String distanceWithout = "Distance without";
  static const String distanceWith = "Distance with";

  static const String unitKmH = "km/h";
  static const String unitM = "m";

  static const String printError = "Erreur impression";
  static const String pdfName = "Athletic Preparation";
}

class AthleticPreparation extends StatefulWidget {
  const AthleticPreparation({super.key});

  @override
  State<AthleticPreparation> createState() => _AthleticPreparationState();
}

class _AthleticPreparationState extends State<AthleticPreparation>
    with SingleTickerProviderStateMixin {
  static const String _bg = "assets/images/BgS.jfif";

  late final AnimationController _enterCtrl;

  // Contrôleurs (init 0)
  final TextEditingController _controller1 =
      TextEditingController(text: '0'); // last level reached
  final TextEditingController _controller2 =
      TextEditingController(text: '0'); // diff between grp
  final TextEditingController _controller3 =
      TextEditingController(text: '0'); // working time
  final TextEditingController _controller4 =
      TextEditingController(text: '0'); // intensity %
  final TextEditingController _controller5 =
      TextEditingController(text: '0'); // percentage %

  // Résultats
  double vma1 = 0, vma2 = 0, vma3 = 0, vma4 = 0, vma5 = 0;
  double dwith1 = 0, dwith2 = 0, dwith3 = 0, dwith4 = 0, dwith5 = 0;
  double dwithout1 = 0,
      dwithout2 = 0,
      dwithout3 = 0,
      dwithout4 = 0,
      dwithout5 = 0;

  @override
  void initState() {
    super.initState();

    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    )..forward();

    // Recalc à chaque modif
    for (final c in [
      _controller1,
      _controller2,
      _controller3,
      _controller4,
      _controller5,
    ]) {
      c.addListener(_recompute);
    }
    _recompute();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    _controller5.dispose();
    super.dispose();
  }

  int _toInt(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

  void _capAll() {
    // Limites cohérentes
    int v1 = _toInt(_controller1).clamp(0, 21); // last level
    int v2 = _toInt(_controller2).clamp(0, 9); // diff
    int v3 = _toInt(_controller3).clamp(0, 149); // working time (s)
    int v4 = _toInt(_controller4).clamp(0, 59); // intensity %
    int v5 = _toInt(_controller5).clamp(0, 100); // percentage %

    if (v1.toString() != _controller1.text) _controller1.text = '$v1';
    if (v2.toString() != _controller2.text) _controller2.text = '$v2';
    if (v3.toString() != _controller3.text) _controller3.text = '$v3';
    if (v4.toString() != _controller4.text) _controller4.text = '$v4';
    if (v5.toString() != _controller5.text) _controller5.text = '$v5';
  }

  void _recompute() {
    _capAll();
    final l = _toInt(_controller1);
    final d = _toInt(_controller2);
    final w = _toInt(_controller3);
    final i = _toInt(_controller4);
    final p = _toInt(_controller5);

    // VMA
    vma1 = 0.1 * d + 0.5 * l;
    vma2 = 0.5 * d + 0.5 * l;
    vma3 = 1.0 * d + 0.5 * l;
    vma4 = 1.5 * d + 0.5 * l;
    vma5 = 2.0 * d + 0.5 * l;

    // Distances
    dwith1 = 2.81 * l + 0.01 * d + 0.5 * w + 0.01 * i + 0.11 * p;
    dwith2 = 2.81 * l + 0.08 * d + 0.5 * w + 0.01 * i + 0.11 * p;
    dwith3 = 2.81 * l + 0.18 * d + 0.5 * w + 0.01 * i + 0.11 * p;
    dwith4 = 2.81 * l + 0.28 * d + 0.5 * w + 0.01 * i + 0.11 * p;
    dwith5 = 2.81 * l + 0.37 * d + 0.5 * w + 0.01 * i + 0.11 * p;

    dwithout1 = 3.2 * l + 0.03 * d + 4.54 * w + 0.13 * i;
    dwithout2 = 3.2 * l + 0.13 * d + 4.54 * w + 0.13 * i;
    dwithout3 = 3.2 * l + 0.25 * d + 4.54 * w + 0.13 * i;
    dwithout4 = 3.2 * l + 0.38 * d + 4.54 * w + 0.13 * i;
    dwithout5 = 3.2 * l + 0.51 * d + 4.54 * w + 0.13 * i;

    if (mounted) setState(() {});
  }

  void _inc(TextEditingController c) {
    HapticFeedback.selectionClick();
    c.text = (_toInt(c) + 1).toString();
  }

  void _dec(TextEditingController c) {
    HapticFeedback.selectionClick();
    c.text = (_toInt(c) - 1).clamp(0, 9999).toString();
  }

  // 🔧 Normaliser les “–/—” pour éviter des soucis dans certains PDF/fonts
  String _sanitize(String s) => s.replaceAll('–', '-').replaceAll('—', '-');

  // ✅ PRINT FLOW (logic unchanged)
  Future<void> _onPrint() async {
    print("🖨️ [AthleticPreparation] Print button tapped.");
    try {
      print("🧾 [AthleticPreparation] Construction du document PDF...");
      final pdf = await _buildPdfDocument();
      final bytes = await pdf.save();

      await Printing.layoutPdf(
        name: _TXT.pdfName,
        onLayout: (PdfPageFormat format) async => bytes,
      );
    } catch (e) {
      print(
          "! [AthleticPreparation] Erreur layoutPdf -> tentative sharePdf. Erreur: $e");
      try {
        final pdf = await _buildPdfDocument();
        final bytes = await pdf.save();
        await Printing.sharePdf(
          bytes: bytes,
          filename: "athletic_preparation.pdf",
        );
      } catch (e2) {
        print(
            "❌ [AthleticPreparation] Erreur sharePdf: $e2 (erreur initiale: $e)");
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${_TXT.printError}: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // ✅ Build PDF (same logic, texts localized removed)
  Future<pw.Document> _buildPdfDocument() async {
    print("🧾 [AthleticPreparation] Construction du document PDF...");

    final doc = pw.Document();

    // Tajawal pour compatibilité unicode
    print("🔤 [AthleticPreparation] Chargement des polices PDF Unicode...");
    final regularData =
        await rootBundle.load('assets/fonts/Tajawal-Regular.ttf');
    final boldData = await rootBundle.load('assets/fonts/Tajawal-Bold.ttf');
    final regularFont = pw.Font.ttf(regularData);
    final boldFont = pw.Font.ttf(boldData);
    print("✅ [AthleticPreparation] Polices PDF chargées (Tajawal).");

    final theme = pw.ThemeData.withFont(
      base: regularFont,
      bold: boldFont,
    );

    final accent = PdfColor.fromInt(const Color(0xFF06B6D4).value);

    final headerStyle = pw.TextStyle(
      font: boldFont,
      fontSize: 18,
      color: PdfColors.white,
    );

    final titleStyle = pw.TextStyle(
      font: boldFont,
      fontSize: 14,
      color: accent,
    );

    final baseStyle = pw.TextStyle(
      font: regularFont,
      fontSize: 12,
      color: PdfColors.black,
    );

    pw.Widget kv(String k, String v) {
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: PdfColors.grey300),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Text(
                _sanitize(k),
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 11,
                  color: PdfColors.black,
                ),
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Text(
              _sanitize(v),
              style: baseStyle,
            ),
          ],
        ),
      );
    }

    pw.Widget groupCard({
      required String title,
      required String bearing,
      required double vma,
      required double distanceWithout,
      required double distanceWith,
    }) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          borderRadius: pw.BorderRadius.circular(10),
          border: pw.Border.all(color: PdfColors.grey300),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: pw.BoxDecoration(
                color: accent,
                borderRadius: pw.BorderRadius.circular(999),
              ),
              child: pw.Text(
                _sanitize(title),
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 12,
                  color: PdfColors.white,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            kv(_TXT.bearing, bearing),
            pw.SizedBox(height: 6),
            kv(_TXT.vma, "${vma.toStringAsFixed(2)} ${_TXT.unitKmH}"),
            pw.SizedBox(height: 6),
            kv(_TXT.distanceWithout,
                "${distanceWithout.toStringAsFixed(2)} ${_TXT.unitM}"),
            pw.SizedBox(height: 6),
            kv(_TXT.distanceWith,
                "${distanceWith.toStringAsFixed(2)} ${_TXT.unitM}"),
          ],
        ),
      );
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        theme: theme,
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: accent,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(
              _sanitize(_TXT.screenTitle),
              style: headerStyle,
            ),
          ),
          pw.SizedBox(height: 14),

          pw.Text(
            _sanitize(_TXT.sectionInputs),
            style: titleStyle,
          ),
          pw.SizedBox(height: 8),
          kv(_TXT.lastLevelReached, _controller1.text),
          pw.SizedBox(height: 6),
          kv(_TXT.differenceBetweenGrp, _controller2.text),
          pw.SizedBox(height: 6),
          kv(_TXT.workingTime, _controller3.text),
          pw.SizedBox(height: 6),
          kv(_TXT.intensity, _controller4.text),
          pw.SizedBox(height: 6),
          kv(_TXT.percentage, _controller5.text),

          pw.SizedBox(height: 14),

          groupCard(
            title: "${_TXT.group} 1",
            bearing: _controller1.text,
            vma: vma1,
            distanceWithout: dwith1,
            distanceWith: dwithout1,
          ),
          pw.SizedBox(height: 10),
          groupCard(
            title: "${_TXT.group} 2",
            bearing: "5",
            vma: vma2,
            distanceWithout: dwith2,
            distanceWith: dwithout2,
          ),
          pw.SizedBox(height: 10),
          groupCard(
            title: "${_TXT.group} 3",
            bearing: "5",
            vma: vma3,
            distanceWithout: dwith3,
            distanceWith: dwithout3,
          ),
          pw.SizedBox(height: 10),
          groupCard(
            title: "${_TXT.group} 4",
            bearing: "5",
            vma: vma4,
            distanceWithout: dwith4,
            distanceWith: dwithout4,
          ),
          pw.SizedBox(height: 10),
          groupCard(
            title: "${_TXT.group} 5",
            bearing: "5",
            vma: vma5,
            distanceWithout: dwith5,
            distanceWith: dwithout5,
          ),
        ],
      ),
    );

    print("✅ [AthleticPreparation] Document PDF construit.");
    return doc;
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
                          onPrint: _onPrint,
                        ),
                        const SizedBox(height: 12),
                        _QuickActions(onPrint: _onPrint),
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
                                        title: _TXT.introTitle,
                                        subtitle: _TXT.introSubtitle,
                                      ),
                                    ),
                                  ),

                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(12, 4, 12, 8),
                                      child: _InputsCard(
                                        controller1: _controller1,
                                        controller2: _controller2,
                                        controller3: _controller3,
                                        controller4: _controller4,
                                        controller5: _controller5,
                                        onMinus1: () => _dec(_controller1),
                                        onPlus1: () => _inc(_controller1),
                                        onMinus2: () => _dec(_controller2),
                                        onPlus2: () => _inc(_controller2),
                                        onMinus3: () => _dec(_controller3),
                                        onPlus3: () => _inc(_controller3),
                                        onMinus4: () => _dec(_controller4),
                                        onPlus4: () => _inc(_controller4),
                                        onMinus5: () => _dec(_controller5),
                                        onPlus5: () => _inc(_controller5),
                                      ),
                                    ),
                                  ),

                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(12, 2, 12, 10),
                                      child: _SectionChip(
                                        icon: Icons.analytics_rounded,
                                        title: _TXT.sectionResults,
                                      ),
                                    ),
                                  ),

                                  SliverList.separated(
                                    itemCount: 5,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 10),
                                    itemBuilder: (context, index) {
                                      final anim = CurvedAnimation(
                                        parent: _enterCtrl,
                                        curve: Interval(
                                          0.08 + (index * 0.08),
                                          1.0,
                                          curve: Curves.easeOutCubic,
                                        ),
                                      );

                                      final title = "${_TXT.group} ${index + 1}";
                                      final bearing =
                                          index == 0 ? _controller1.text : "5";
                                      final vma = [
                                        vma1,
                                        vma2,
                                        vma3,
                                        vma4,
                                        vma5,
                                      ][index];
                                      final distanceWithout = [
                                        dwith1,
                                        dwith2,
                                        dwith3,
                                        dwith4,
                                        dwith5,
                                      ][index];
                                      final distanceWith = [
                                        dwithout1,
                                        dwithout2,
                                        dwithout3,
                                        dwithout4,
                                        dwithout5,
                                      ][index];

                                      return Padding(
                                        padding:
                                            const EdgeInsets.fromLTRB(12, 0, 12, 0),
                                        child: FadeTransition(
                                          opacity: anim,
                                          child: SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(0, 0.06),
                                              end: Offset.zero,
                                            ).animate(anim),
                                            child: _GroupResultCard(
                                              title: title,
                                              bearing: bearing,
                                              vma: vma,
                                              distanceWithout: distanceWithout,
                                              distanceWith: distanceWith,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                  const SliverToBoxAdapter(
                                    child: SizedBox(height: 14),
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
/* Header / Top widgets */
/* ========================================================================== */

class _HeaderModern extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onPrint;

  const _HeaderModern({
    required this.title,
    required this.onBack,
    required this.onPrint,
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
            icon: Icons.print_rounded,
            onTap: () {
              HapticFeedback.lightImpact();
              onPrint();
            },
            accent: cs.primary.withOpacity(0.90),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onPrint;

  const _QuickActions({required this.onPrint});

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
                  Icons.auto_graph_rounded,
                  size: 18,
                  color: cs.primary.withOpacity(0.92),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "${_TXT.chipAuto} • ${_TXT.chipGroups}",
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
            onPrint();
          },
          child: _Glass(
            radius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.print_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.92),
                ),
                const SizedBox(width: 8),
                Text(
                  _TXT.chipPrint,
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
              Icons.fitness_center_rounded,
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

class _SectionChip extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionChip({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return _Glass(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.primary.withOpacity(0.92)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: t.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(0.92),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ========================================================================== */
/* Inputs */
/* ========================================================================== */

class _InputsCard extends StatelessWidget {
  final TextEditingController controller1;
  final TextEditingController controller2;
  final TextEditingController controller3;
  final TextEditingController controller4;
  final TextEditingController controller5;

  final VoidCallback onMinus1;
  final VoidCallback onPlus1;
  final VoidCallback onMinus2;
  final VoidCallback onPlus2;
  final VoidCallback onMinus3;
  final VoidCallback onPlus3;
  final VoidCallback onMinus4;
  final VoidCallback onPlus4;
  final VoidCallback onMinus5;
  final VoidCallback onPlus5;

  const _InputsCard({
    required this.controller1,
    required this.controller2,
    required this.controller3,
    required this.controller4,
    required this.controller5,
    required this.onMinus1,
    required this.onPlus1,
    required this.onMinus2,
    required this.onPlus2,
    required this.onMinus3,
    required this.onPlus3,
    required this.onMinus4,
    required this.onPlus4,
    required this.onMinus5,
    required this.onPlus5,
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
                  border:
                      Border.all(color: Colors.white.withOpacity(0.14), width: 1),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: cs.primary.withOpacity(0.92),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _TXT.sectionInputs,
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
                child: _StepperNumberField(
                  label: _TXT.lastLevelReached,
                  controller: controller1,
                  onMinus: onMinus1,
                  onPlus: onPlus1,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StepperNumberField(
                  label: _TXT.differenceBetweenGrp,
                  controller: controller2,
                  onMinus: onMinus2,
                  onPlus: onPlus2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StepperNumberField(
                  label: _TXT.workingTime,
                  controller: controller3,
                  onMinus: onMinus3,
                  onPlus: onPlus3,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StepperNumberField(
                  label: _TXT.intensity,
                  controller: controller4,
                  onMinus: onMinus4,
                  onPlus: onPlus4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _StepperNumberField(
            label: _TXT.percentage,
            controller: controller5,
            onMinus: onMinus5,
            onPlus: onPlus5,
          ),
        ],
      ),
    );
  }
}

class _StepperNumberField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _StepperNumberField({
    required this.label,
    required this.controller,
    required this.onMinus,
    required this.onPlus,
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white.withOpacity(0.10),
            border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
          ),
          child: Row(
            children: [
              _MiniPillButton(
                icon: Icons.remove_rounded,
                onTap: onMinus,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: t.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.96),
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _MiniPillButton(
                icon: Icons.add_rounded,
                onTap: onPlus,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniPillButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MiniPillButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: Colors.white.withOpacity(0.10),
          border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
        ),
        child: Icon(
          icon,
          size: 18,
          color: Colors.white.withOpacity(0.92),
        ),
      ),
    );
  }
}

/* ========================================================================== */
/* Group cards */
/* ========================================================================== */

class _GroupResultCard extends StatelessWidget {
  final String title;
  final String bearing;
  final double vma;
  final double distanceWithout;
  final double distanceWith;

  const _GroupResultCard({
    required this.title,
    required this.bearing,
    required this.vma,
    required this.distanceWithout,
    required this.distanceWith,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.white.withOpacity(0.10),
                  border:
                      Border.all(color: Colors.white.withOpacity(0.14), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.flag_rounded,
                      size: 16,
                      color: cs.primary.withOpacity(0.92),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: t.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white.withOpacity(0.96),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MetricRow(label: _TXT.bearing, value: bearing),
          _MetricRow(
            label: _TXT.vma,
            value: "${vma.toStringAsFixed(2)} ${_TXT.unitKmH}",
          ),
          _MetricRow(
            label: _TXT.distanceWithout,
            value: "${distanceWithout.toStringAsFixed(2)} ${_TXT.unitM}",
          ),
          _MetricRow(
            label: _TXT.distanceWith,
            value: "${distanceWith.toStringAsFixed(2)} ${_TXT.unitM}",
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetricRow({
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
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
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

/* ========================================================================== */
/* UI Kit */
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