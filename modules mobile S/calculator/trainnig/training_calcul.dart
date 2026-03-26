import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// PDF + Printing
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TrainingCalcul extends StatefulWidget {
  const TrainingCalcul({super.key});

  @override
  State<TrainingCalcul> createState() => _TrainingCalculState();
}

class _TXT {
  static const String screenTitle = "Training Load";
  static const String heroTitle = "Session Load Calculator";
  static const String heroSubtitle =
      "Calcule la charge de séance sur 15 blocs avec un système de pondération par intensité.";

  static const String maximum = "Maximum";
  static const String veryDifficult = "Très difficile";
  static const String difficult = "Difficile";
  static const String quiteDifficult = "Assez difficile";
  static const String mean = "Moyenne";
  static const String easy = "Facile";
  static const String total = "Total";

  static const String calculate = "Calculer";
  static const String print = "Imprimer";
  static const String back = "Retour";
  static const String next = "Suivant";

  static const String page1 = "1–5";
  static const String page2 = "6–10";
  static const String page3 = "11–15";

  static const String summaryTitle = "Résumé global";
  static const String summaryHint =
      "Norme indicative : < 7000 faible, 7000–17000 moyenne, 17001–30000 élevée, > 30000 très élevée.";

  static const String weak = "Faible";
  static const String medium = "Moyenne";
  static const String high = "Élevée";
  static const String veryHigh = "Très élevée";

  static const String pdfTitle = "Résumé de charge d'entraînement";
  static const String pdfNote =
      "Note : le total de chaque bloc est calculé selon la pondération des niveaux d'intensité.";
}

class _TrainingCalculState extends State<TrainingCalcul>
    with TickerProviderStateMixin {
  static const String _bg = "assets/images/BgS.jfif";

  late final AnimationController _enterCtrl;

  int _segment = 0;
  static const int _pageSize = 5;

  final List<Map<String, dynamic>> blocks = [
    {
      'maximum': 0,
      'veryDifficult': 0,
      'difficult': 0,
      'quiteDifficult': 0,
      'mean': 0,
      'easy': 0,
      'total': 0,
    }
  ];

  void addBlock() {
    blocks.add({
      'maximum': 0,
      'veryDifficult': 0,
      'difficult': 0,
      'quiteDifficult': 0,
      'mean': 0,
      'easy': 0,
      'total': 0,
    });
  }

  @override
  void initState() {
    super.initState();

    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    )..forward();

    for (int i = 0; i < 14; i++) {
      addBlock();
    }
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  int get _startIndex => _segment * _pageSize;
  int get _visibleCount => math.min(_pageSize, blocks.length - _startIndex);
  int get _sliverItemCount => _visibleCount > 0 ? _visibleCount * 2 - 1 : 0;

  void _goPrev() {
    if (_segment > 0) {
      setState(() => _segment--);
    }
  }

  void _goNext() {
    if (_segment < 2) {
      setState(() => _segment++);
    }
  }

  void _goTo(int index) {
    setState(() => _segment = index.clamp(0, 2));
  }

  Color _groupColorFor(int n) {
    if (n <= 5) return const Color(0xFF22C55E);
    if (n <= 10) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String _groupEmojiFor(int n) {
    if (n <= 5) return '🟢';
    if (n <= 10) return '🟠';
    return '🔴';
  }

  int get _globalTotal => blocks.fold<int>(
        0,
        (sum, b) => sum + ((b['total'] ?? 0) as int),
      );

  String get _globalCategoryLabel {
    final total = _globalTotal;
    if (total < 7000) return _TXT.weak;
    if (total <= 17000) return _TXT.medium;
    if (total <= 30000) return _TXT.high;
    return _TXT.veryHigh;
  }

  Color _globalCategoryColor() {
    final t = _globalTotal;
    if (t < 7000) return const Color(0xFF22C55E);
    if (t <= 17000) return const Color(0xFF3B82F6);
    if (t <= 30000) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String _sanitize(String s) => s.replaceAll('–', '-').replaceAll('—', '-');

  Future<void> _printAll() async {
    try {
      final pdf = await _buildPdfDocument();
      final bytes = await pdf.save();

      await Printing.layoutPdf(
        name: "training_load_summary",
        onLayout: (PdfPageFormat format) async => bytes,
      );
    } catch (e) {
      try {
        final pdf = await _buildPdfDocument();
        final bytes = await pdf.save();

        await Printing.sharePdf(
          bytes: bytes,
          filename: "training_load_summary.pdf",
        );
      } catch (_) {}

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur impression : $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<pw.Document> _buildPdfDocument() async {
    final doc = pw.Document();

    final isArabic = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('ar');

    pw.TextDirection dir() =>
        isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr;

    final regularData =
        await rootBundle.load('assets/fonts/Tajawal-Regular.ttf');
    final boldData = await rootBundle.load('assets/fonts/Tajawal-Bold.ttf');
    final regularFont = pw.Font.ttf(regularData);
    final boldFont = pw.Font.ttf(boldData);

    final theme = pw.ThemeData.withFont(
      base: regularFont,
      bold: boldFont,
    );

    final accent = PdfColor.fromInt(const Color(0xFF3B82F6).value);

    final headers = <String>[
      '#',
      _TXT.maximum,
      _TXT.veryDifficult,
      _TXT.difficult,
      _TXT.quiteDifficult,
      _TXT.mean,
      _TXT.easy,
      _TXT.total,
    ];

    pw.Widget cell(
      String text, {
      bool isHeader = false,
    }) {
      final align =
          isArabic ? pw.Alignment.centerRight : pw.Alignment.centerLeft;

      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        alignment: align,
        decoration: isHeader
            ? pw.BoxDecoration(
                color: accent,
                borderRadius: pw.BorderRadius.circular(4),
              )
            : null,
        child: pw.Text(
          _sanitize(text),
          textDirection: dir(),
          style: pw.TextStyle(
            font: isHeader ? boldFont : regularFont,
            fontSize: isHeader ? 9.5 : 9,
            color: isHeader ? PdfColors.white : PdfColors.black,
          ),
        ),
      );
    }

    final rows = <pw.TableRow>[
      pw.TableRow(
        children: headers.map((h) => cell(h, isHeader: true)).toList(),
      ),
      for (int i = 0; i < blocks.length; i++)
        pw.TableRow(
          children: [
            cell((i + 1).toString()),
            cell(blocks[i]['maximum'].toString()),
            cell(blocks[i]['veryDifficult'].toString()),
            cell(blocks[i]['difficult'].toString()),
            cell(blocks[i]['quiteDifficult'].toString()),
            cell(blocks[i]['mean'].toString()),
            cell(blocks[i]['easy'].toString()),
            cell(blocks[i]['total'].toString()),
          ],
        ),
    ];

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        theme: theme,
        build: (_) => [
          pw.Directionality(
            textDirection: dir(),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: accent,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    _TXT.pdfTitle,
                    textDirection: dir(),
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 18,
                      color: PdfColors.white,
                    ),
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  "Total global : $_globalTotal",
                  textDirection: dir(),
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  "Catégorie : $_globalCategoryLabel",
                  textDirection: dir(),
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(height: 14),
                pw.Table(
                  border: pw.TableBorder.symmetric(
                    inside:
                        pw.BorderSide(color: PdfColors.grey300, width: 0.6),
                    outside:
                        pw.BorderSide(color: PdfColors.grey300, width: 0.8),
                  ),
                  defaultVerticalAlignment:
                      pw.TableCellVerticalAlignment.middle,
                  children: rows,
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  _TXT.pdfNote,
                  textDirection: dir(),
                  style: pw.TextStyle(
                    font: regularFont,
                    fontSize: 9,
                    color: PdfColors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return doc;
  }

  void _computeBlock(Map<String, dynamic> block) {
    setState(() {
      block['total'] = block['maximum'] * 64 +
          block['veryDifficult'] * 48 +
          block['difficult'] * 32 +
          block['quiteDifficult'] * 16 +
          block['mean'] * 8 +
          block['easy'] * 4;
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
                          onPrint: () {
                            HapticFeedback.selectionClick();
                            _printAll();
                          },
                        ),
                        const SizedBox(height: 12),
                        _QuickActions(
                          pageLabel: [_TXT.page1, _TXT.page2, _TXT.page3][_segment],
                          onPrint: () {
                            HapticFeedback.lightImpact();
                            _printAll();
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
                                      padding: const EdgeInsets.fromLTRB(
                                          12, 12, 12, 8),
                                      child: _InfoBanner(
                                        title: _TXT.heroTitle,
                                        subtitle: _TXT.heroSubtitle,
                                        icon: Icons.insights_rounded,
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          12, 0, 12, 8),
                                      child: _SegmentedPills(
                                        segments: const [
                                          _TXT.page1,
                                          _TXT.page2,
                                          _TXT.page3
                                        ],
                                        index: _segment,
                                        onChanged: (i) {
                                          HapticFeedback.selectionClick();
                                          _goTo(i);
                                        },
                                      ),
                                    ),
                                  ),
                                  SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, i) {
                                        if (_visibleCount <= 0) return null;
                                        if (i.isOdd) {
                                          return const SizedBox(height: 10);
                                        }

                                        final localIndex = i ~/ 2;
                                        final index = _startIndex + localIndex;
                                        final n = index + 1;
                                        final block = blocks[index];

                                        final groupColor = _groupColorFor(n);
                                        final groupEmoji = _groupEmojiFor(n);

                                        final anim = CurvedAnimation(
                                          parent: _enterCtrl,
                                          curve: Interval(
                                            0.08 + (localIndex * 0.08),
                                            1.0,
                                            curve: Curves.easeOutCubic,
                                          ),
                                        );

                                        return Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              12, 0, 12, 0),
                                          child: FadeTransition(
                                            opacity: anim,
                                            child: SlideTransition(
                                              position: Tween<Offset>(
                                                begin: const Offset(0, 0.06),
                                                end: Offset.zero,
                                              ).animate(anim),
                                              child: _TrainingBlockCard(
                                                number: n,
                                                emoji: groupEmoji,
                                                accent: groupColor,
                                                block: block,
                                                onChangedMaximum: (v) =>
                                                    setState(() {
                                                  block['maximum'] =
                                                      v.isEmpty ? 0 : int.parse(v);
                                                }),
                                                onChangedVeryDifficult: (v) =>
                                                    setState(() {
                                                  block['veryDifficult'] =
                                                      v.isEmpty ? 0 : int.parse(v);
                                                }),
                                                onChangedDifficult: (v) =>
                                                    setState(() {
                                                  block['difficult'] =
                                                      v.isEmpty ? 0 : int.parse(v);
                                                }),
                                                onChangedQuiteDifficult: (v) =>
                                                    setState(() {
                                                  block['quiteDifficult'] =
                                                      v.isEmpty ? 0 : int.parse(v);
                                                }),
                                                onChangedMean: (v) =>
                                                    setState(() {
                                                  block['mean'] =
                                                      v.isEmpty ? 0 : int.parse(v);
                                                }),
                                                onChangedEasy: (v) =>
                                                    setState(() {
                                                  block['easy'] =
                                                      v.isEmpty ? 0 : int.parse(v);
                                                }),
                                                onCalculate: () {
                                                  HapticFeedback.selectionClick();
                                                  _computeBlock(block);
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      childCount: _sliverItemCount,
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(12, 14, 12, 0),
                                      child: _SummaryCard(
                                        total: _globalTotal,
                                        category: _globalCategoryLabel,
                                        categoryColor: _globalCategoryColor(),
                                        hint: _TXT.summaryHint,
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(12, 14, 12, 14),
                                      child: _BottomPagerCard(
                                        index: _segment,
                                        total: 3,
                                        canPrev: _segment > 0,
                                        canNext: _segment < 2,
                                        onPrev: _goPrev,
                                        onNext: _goNext,
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
/* Header / banners */
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
          const SizedBox(width: 10),
          _PillIconButton(
            icon: Icons.print_rounded,
            onTap: onPrint,
            accent:
                Theme.of(context).colorScheme.primary.withOpacity(0.90),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final String pageLabel;
  final VoidCallback onPrint;

  const _QuickActions({
    required this.pageLabel,
    required this.onPrint,
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
                  Icons.layers_rounded,
                  size: 18,
                  color: cs.primary.withOpacity(0.92),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Blocs • $pageLabel",
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
          onTap: onPrint,
          child: _Glass(
            radius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.picture_as_pdf_rounded,
                  size: 18,
                  color: cs.primary.withOpacity(0.92),
                ),
                const SizedBox(width: 8),
                Text(
                  _TXT.print,
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

class _SegmentedPills extends StatelessWidget {
  final List<String> segments;
  final int index;
  final ValueChanged<int> onChanged;

  const _SegmentedPills({
    required this.segments,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(segments.length, (i) {
        final selected = index == i;

        return GestureDetector(
          onTap: () => onChanged(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: selected
                  ? cs.primary.withOpacity(0.90)
                  : Colors.white.withOpacity(0.08),
              border: Border.all(
                color: Colors.white.withOpacity(selected ? 0.20 : 0.12),
                width: 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        blurRadius: 18,
                        color: cs.primary.withOpacity(0.20),
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              segments[i],
              style: t.textTheme.labelLarge?.copyWith(
                color: Colors.white.withOpacity(selected ? 0.98 : 0.82),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        );
      }),
    );
  }
}

/* ========================================================================== */
/* Cards */
/* ========================================================================== */

class _TrainingBlockCard extends StatelessWidget {
  final int number;
  final String emoji;
  final Color accent;
  final Map<String, dynamic> block;

  final ValueChanged<String> onChangedMaximum;
  final ValueChanged<String> onChangedVeryDifficult;
  final ValueChanged<String> onChangedDifficult;
  final ValueChanged<String> onChangedQuiteDifficult;
  final ValueChanged<String> onChangedMean;
  final ValueChanged<String> onChangedEasy;
  final VoidCallback onCalculate;

  const _TrainingBlockCard({
    required this.number,
    required this.emoji,
    required this.accent,
    required this.block,
    required this.onChangedMaximum,
    required this.onChangedVeryDifficult,
    required this.onChangedDifficult,
    required this.onChangedQuiteDifficult,
    required this.onChangedMean,
    required this.onChangedEasy,
    required this.onCalculate,
  });

  @override
  Widget build(BuildContext context) {
    return _Glass(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardAccentBar(color: accent),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: _IndexChip(
              index: number,
              emoji: emoji,
              color: accent,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _NumberField(
                  key: ValueKey('max_$number'),
                  label: _TXT.maximum,
                  value: block['maximum'] as int,
                  onChanged: onChangedMaximum,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NumberField(
                  key: ValueKey('veryDiff_$number'),
                  label: _TXT.veryDifficult,
                  value: block['veryDifficult'] as int,
                  onChanged: onChangedVeryDifficult,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _NumberField(
                  key: ValueKey('diff_$number'),
                  label: _TXT.difficult,
                  value: block['difficult'] as int,
                  onChanged: onChangedDifficult,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NumberField(
                  key: ValueKey('quiteDiff_$number'),
                  label: _TXT.quiteDifficult,
                  value: block['quiteDifficult'] as int,
                  onChanged: onChangedQuiteDifficult,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _NumberField(
                  key: ValueKey('mean_$number'),
                  label: _TXT.mean,
                  value: block['mean'] as int,
                  onChanged: onChangedMean,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NumberField(
                  key: ValueKey('easy_$number'),
                  label: _TXT.easy,
                  value: block['easy'] as int,
                  onChanged: onChangedEasy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _PrimaryActionButton(
            label: _TXT.calculate,
            icon: Icons.auto_awesome_rounded,
            onTap: onCalculate,
          ),
          const SizedBox(height: 12),
          _ResultBadge(
            label: _TXT.total,
            value: (block['total'] ?? 0).toString(),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int total;
  final String category;
  final Color categoryColor;
  final String hint;

  const _SummaryCard({
    required this.total,
    required this.category,
    required this.categoryColor,
    required this.hint,
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
          Row(
            children: [
              Text('📊', style: t.textTheme.titleLarge),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _TXT.summaryTitle,
                  style: t.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.96),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Total global : $total",
            style: t.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.96),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: categoryColor.withOpacity(0.18),
                border: Border.all(
                  color: categoryColor.withOpacity(0.70),
                  width: 1,
                ),
              ),
              child: Text(
                category,
                style: t.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withOpacity(0.96),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            hint,
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

class _BottomPagerCard extends StatelessWidget {
  final int index;
  final int total;
  final bool canPrev;
  final bool canNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _BottomPagerCard({
    required this.index,
    required this.total,
    required this.canPrev,
    required this.canNext,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return _Glass(
      radius: 18,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: _NavButton(
              label: _TXT.back,
              icon: Icons.arrow_back_rounded,
              enabled: canPrev,
              onTap: onPrev,
            ),
          ),
          const SizedBox(width: 12),
          _Dots(index: index, total: total),
          const SizedBox(width: 12),
          Expanded(
            child: _NavButton(
              label: _TXT.next,
              icon: Icons.arrow_forward_rounded,
              enabled: canNext,
              onTap: onNext,
              iconAtEnd: true,
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

class _CardAccentBar extends StatelessWidget {
  final Color color;

  const _CardAccentBar({required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          colors: [color, cs.primary.withOpacity(0.90)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }
}

class _IndexChip extends StatelessWidget {
  final int index;
  final String emoji;
  final Color color;

  const _IndexChip({
    required this.index,
    required this.emoji,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          colors: [color, Theme.of(context).colorScheme.primary],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
          const SizedBox(width: 6),
          Text(
            '$index',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final String label;
  final ValueChanged<String> onChanged;
  final int value;

  const _NumberField({
    super.key,
    required this.label,
    required this.onChanged,
    required this.value,
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
        TextFormField(
          key: key,
          initialValue: value == 0 ? '' : value.toString(),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: t.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: Colors.white.withOpacity(0.96),
          ),
          decoration: InputDecoration(
            hintText: "0",
            hintStyle: t.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.40),
              fontWeight: FontWeight.w700,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.10),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: Colors.white.withOpacity(0.14)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: Colors.white.withOpacity(0.14)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color:
                    Theme.of(context).colorScheme.primary.withOpacity(0.85),
                width: 1.2,
              ),
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: cs.primary.withOpacity(0.92),
            ),
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

class _ResultBadge extends StatelessWidget {
  final String label;
  final String value;

  const _ResultBadge({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

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
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: t.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white.withOpacity(0.78),
              ),
            ),
          ),
          Text(
            value,
            style: t.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.96),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool enabled;
  final bool iconAtEnd;
  final VoidCallback onTap;

  const _NavButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onTap,
    this.iconAtEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: enabled
            ? () {
                HapticFeedback.selectionClick();
                onTap();
              }
            : null,
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
                    Icon(
                      icon,
                      size: 18,
                      color: cs.primary.withOpacity(0.92),
                    ),
                  ]
                : [
                    Icon(
                      icon,
                      size: 18,
                      color: cs.primary.withOpacity(0.92),
                    ),
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
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int index;
  final int total;

  const _Dots({
    required this.index,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: active ? 18 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: active
                ? cs.primary.withOpacity(0.92)
                : Colors.white.withOpacity(0.22),
          ),
        );
      }),
    );
  }
}