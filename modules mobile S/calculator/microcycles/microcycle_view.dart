// ignore_for_file: unused_local_variable

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// ---------------------------------------------------------------------------
/// Brand colors
/// ---------------------------------------------------------------------------

List<Color> _brandBluesFrom(bool isDark) => isDark
    ? const [Color(0xFF0B2447), Color(0xFF19376D)]
    : const [Color(0xFF1D4ED8), Color(0xFF3B82F6)];

List<Color> _brandBlues(BuildContext ctx) =>
    _brandBluesFrom(Theme.of(ctx).brightness == Brightness.dark);

List<Color> _headlineBluesFrom(bool isDark) => isDark
    ? const [Color(0xFF93C5FD), Color(0xFF60A5FA)]
    : const [Color(0xFF1D4ED8), Color(0xFF3B82F6)];

List<Color> _headlineBlues(BuildContext ctx) =>
    _headlineBluesFrom(Theme.of(ctx).brightness == Brightness.dark);

class _TXT {
  static const String screenTitle = "Microcycle Planner";
  static const String heroTitle = "Microcycle Builder";
  static const String heroSubtitle =
      "Configure your TG, G, M and F lines, calculate the total, then export the summary to PDF.";

  static const String navLegend1 = "Legend 1";
  static const String navLegend2 = "Legend 2";
  static const String navInfo = "Info";
  static const String navLines = "Lines";
  static const String navResult = "Result";

  static const String legendTitle1 = "Legend - Volume / Load";
  static const String legendTitle2 = "Legend - Density / Intensity";
  static const String infoTitle = "Information";
  static const String linesTitle = "Microcycle Lines";
  static const String resultTitle = "Final Total";

  static const String low1 = "Low";
  static const String average1 = "Average";
  static const String large1 = "Large";
  static const String veryLarge1 = "Very Large";

  static const String low2 = "Low";
  static const String average2 = "Average";
  static const String large2 = "Large";
  static const String veryLarge2 = "Very Large";

  static const String informationBody =
      "Each line is calculated as A × B. The global result is the sum of TG + G + M + F. Use this screen to structure your microcycle workload and export the result.";

  static const String lineFieldA = "A";
  static const String lineFieldB = "B";

  static const String calculate = "Calculate";
  static const String print = "Print PDF";

  static const String pdfTitle = "Microcycle Summary";
  static const String pdfSubtitle = "Detail of lines (A x B = Product)";
  static const String pdfLine = "Line";
  static const String pdfProduct = "Product";
  static const String pdfTotal = "Total";
  static const String pdfNote =
      "Note: Total = sum of (TG + G + M + F).";
}

class MicrocycleView extends StatefulWidget {
  const MicrocycleView({super.key});

  @override
  State<MicrocycleView> createState() => _MicrocycleViewState();
}

class _MicrocycleViewState extends State<MicrocycleView>
    with TickerProviderStateMixin {
  static const String _bg = "assets/images/BgS.jfif";

  final ScrollController _scrollController = ScrollController();

  final GlobalKey _legend1Key = GlobalKey();
  final GlobalKey _legend2Key = GlobalKey();
  final GlobalKey _infoKey = GlobalKey();
  final GlobalKey _linesKey = GlobalKey();
  final GlobalKey _resultKey = GlobalKey();

  final TextEditingController _Tg1 = TextEditingController(text: '0');
  final TextEditingController _Tg2 = TextEditingController(text: '0');
  int _Tg3 = 0;

  final TextEditingController _g1 = TextEditingController(text: '0');
  final TextEditingController _g2 = TextEditingController(text: '0');
  int _g3 = 0;

  final TextEditingController _m1 = TextEditingController(text: '0');
  final TextEditingController _m2 = TextEditingController(text: '0');
  int _m3 = 0;

  final TextEditingController _f1 = TextEditingController(text: '0');
  final TextEditingController _f2 = TextEditingController(text: '0');
  int _f3 = 0;

  int result = 0;

  late final AnimationController _enterCtrl;

  int _safeParse(String v) =>
      int.tryParse(v.trim().isEmpty ? '0' : v.trim()) ?? 0;

  void _recalcTg() =>
      setState(() => _Tg3 = _safeParse(_Tg1.text) * _safeParse(_Tg2.text));

  void _recalcG() =>
      setState(() => _g3 = _safeParse(_g1.text) * _safeParse(_g2.text));

  void _recalcM() =>
      setState(() => _m3 = _safeParse(_m1.text) * _safeParse(_m2.text));

  void _recalcF() =>
      setState(() => _f3 = _safeParse(_f1.text) * _safeParse(_f2.text));

  String _sanitize(String s) => s.replaceAll('–', '-').replaceAll('—', '-');

  int get _total => _Tg3 + _g3 + _m3 + _f3;

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
    _scrollController.dispose();
    _enterCtrl.dispose();

    _Tg1.dispose();
    _Tg2.dispose();
    _g1.dispose();
    _g2.dispose();
    _m1.dispose();
    _m2.dispose();
    _f1.dispose();
    _f2.dispose();

    super.dispose();
  }

  Future<void> _jumpTo(GlobalKey key) async {
    final ctx = key.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: 0.06,
    );
  }

  Future<void> _printMicrocycle() async {
    try {
      final pdf = await _buildPdfDocument();
      final bytes = await pdf.save();

      await Printing.layoutPdf(
        name: "Microcycle",
        onLayout: (PdfPageFormat format) async => bytes,
      );
    } catch (e) {
      try {
        final pdf = await _buildPdfDocument();
        final bytes = await pdf.save();
        await Printing.sharePdf(
          bytes: bytes,
          filename: "microcycle_summary.pdf",
        );
      } catch (_) {}

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Print error: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<pw.Document> _buildPdfDocument() async {
    final doc = pw.Document();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = _brandBluesFrom(isDark).first;
    final accent = PdfColor.fromInt(accentColor.value);

    final tgA = _safeParse(_Tg1.text);
    final tgB = _safeParse(_Tg2.text);
    final gA = _safeParse(_g1.text);
    final gB = _safeParse(_g2.text);
    final mA = _safeParse(_m1.text);
    final mB = _safeParse(_m2.text);
    final fA = _safeParse(_f1.text);
    final fB = _safeParse(_f2.text);

    final total = _total;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (ctx) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: accent,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  _sanitize(_TXT.pdfTitle),
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.Text(
                  "TG / G / M / F",
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.white,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 14),
          pw.Text(
            _sanitize(_TXT.pdfSubtitle),
            style: const pw.TextStyle(fontSize: 11, color: PdfColors.black),
          ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            border: null,
            headers: const [
              _TXT.pdfLine,
              "A",
              "B",
              _TXT.pdfProduct,
            ],
            data: [
              ["TG", tgA.toString(), tgB.toString(), _Tg3.toString()],
              ["G", gA.toString(), gB.toString(), _g3.toString()],
              ["M", mA.toString(), mB.toString(), _m3.toString()],
              ["F", fA.toString(), fB.toString(), _f3.toString()],
            ],
            headerStyle: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
            cellStyle: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.black,
            ),
            cellAlignment: pw.Alignment.center,
            headerDecoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(6),
            ),
          ),
          pw.SizedBox(height: 14),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Text(
              "${_TXT.pdfTotal}: $total",
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: accent,
              ),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            _TXT.pdfNote,
            style: const pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );

    return doc;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isDark = t.brightness == Brightness.dark;
    final cs = t.colorScheme;

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
                          onLegend1: () => _jumpTo(_legend1Key),
                          onLegend2: () => _jumpTo(_legend2Key),
                          onInfo: () => _jumpTo(_infoKey),
                          onLines: () => _jumpTo(_linesKey),
                          onResult: () => _jumpTo(_resultKey),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: _Glass(
                            radius: 20,
                            padding: EdgeInsets.zero,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: CustomScrollView(
                                controller: _scrollController,
                                physics: const BouncingScrollPhysics(),
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                slivers: [
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(12, 12, 12, 8),
                                      child: _HeroBanner(
                                        title: _TXT.heroTitle,
                                        subtitle: _TXT.heroSubtitle,
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    key: _legend1Key,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _LegendCard(
                                        title: _TXT.legendTitle1,
                                        emoji: "🧭",
                                        rows: const [
                                          [_TXT.low1, _TXT.average1],
                                          [_TXT.large1, _TXT.veryLarge1],
                                        ],
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    key: _legend2Key,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _LegendCard(
                                        title: _TXT.legendTitle2,
                                        emoji: "📏",
                                        rows: const [
                                          [_TXT.low2, _TXT.average2],
                                          [_TXT.large2, _TXT.veryLarge2],
                                        ],
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    key: _infoKey,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _InfoCard(
                                        title: _TXT.infoTitle,
                                        body: _TXT.informationBody,
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    key: _linesKey,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(12, 0, 12, 10),
                                      child: _LinesCard(
                                        tg1: _Tg1,
                                        tg2: _Tg2,
                                        tg3: _Tg3,
                                        g1: _g1,
                                        g2: _g2,
                                        g3: _g3,
                                        m1: _m1,
                                        m2: _m2,
                                        m3: _m3,
                                        f1: _f1,
                                        f2: _f2,
                                        f3: _f3,
                                        onTg: _recalcTg,
                                        onG: _recalcG,
                                        onM: _recalcM,
                                        onF: _recalcF,
                                      ),
                                    ),
                                  ),
                                  SliverToBoxAdapter(
                                    key: _resultKey,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(12, 0, 12, 14),
                                      child: _ResultCard(
                                        result: result,
                                        totalLive: _total,
                                        onCalculate: () {
                                          HapticFeedback.selectionClick();
                                          setState(() => result = _total);
                                        },
                                        onPrint: () {
                                          HapticFeedback.selectionClick();
                                          _printMicrocycle();
                                        },
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

/// ---------------------------------------------------------------------------
/// Header + nav
/// ---------------------------------------------------------------------------

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
                color: Colors.white.withOpacity(0.96),
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const _PillIconStatic(icon: Icons.view_timeline_rounded),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onLegend1;
  final VoidCallback onLegend2;
  final VoidCallback onInfo;
  final VoidCallback onLines;
  final VoidCallback onResult;

  const _QuickActions({
    required this.onLegend1,
    required this.onLegend2,
    required this.onInfo,
    required this.onLines,
    required this.onResult,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _NavChip(
            icon: Icons.layers_rounded,
            label: _TXT.navLegend1,
            onTap: onLegend1,
          ),
          const SizedBox(width: 10),
          _NavChip(
            icon: Icons.straighten_rounded,
            label: _TXT.navLegend2,
            onTap: onLegend2,
          ),
          const SizedBox(width: 10),
          _NavChip(
            icon: Icons.info_outline_rounded,
            label: _TXT.navInfo,
            onTap: onInfo,
          ),
          const SizedBox(width: 10),
          _NavChip(
            icon: Icons.segment_rounded,
            label: _TXT.navLines,
            onTap: onLines,
          ),
          const SizedBox(width: 10),
          _NavChip(
            icon: Icons.analytics_rounded,
            label: _TXT.navResult,
            onTap: onResult,
          ),
        ],
      ),
    );
  }
}

class _NavChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: _Glass(
        radius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: cs.primary.withOpacity(0.92)),
            const SizedBox(width: 8),
            Text(
              label,
              style: t.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white.withOpacity(0.88),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Cards
/// ---------------------------------------------------------------------------

class _HeroBanner extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HeroBanner({
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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withOpacity(0.10),
              border: Border.all(color: Colors.white.withOpacity(0.14)),
            ),
            child: Icon(
              Icons.route_rounded,
              size: 24,
              color: cs.primary.withOpacity(0.92),
            ),
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
                  style: t.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    color: Colors.white.withOpacity(0.74),
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

class _LegendCard extends StatelessWidget {
  final String title;
  final String emoji;
  final List<List<String>> rows;

  const _LegendCard({
    required this.title,
    required this.emoji,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return _Glass(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardTitle(title: title, emoji: emoji),
          const SizedBox(height: 12),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _LegendPill(text: row[0], color: const Color(0xFF6366F1)),
                  _LegendPill(text: row[1], color: const Color(0xFF22C55E)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String body;

  const _InfoCard({
    required this.title,
    required this.body,
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
          _CardTitle(title: title, emoji: "ℹ️"),
          const SizedBox(height: 12),
          Text(
            body,
            textAlign: TextAlign.center,
            style: t.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.82),
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LinesCard extends StatelessWidget {
  final TextEditingController tg1;
  final TextEditingController tg2;
  final int tg3;
  final TextEditingController g1;
  final TextEditingController g2;
  final int g3;
  final TextEditingController m1;
  final TextEditingController m2;
  final int m3;
  final TextEditingController f1;
  final TextEditingController f2;
  final int f3;

  final VoidCallback onTg;
  final VoidCallback onG;
  final VoidCallback onM;
  final VoidCallback onF;

  const _LinesCard({
    required this.tg1,
    required this.tg2,
    required this.tg3,
    required this.g1,
    required this.g2,
    required this.g3,
    required this.m1,
    required this.m2,
    required this.m3,
    required this.f1,
    required this.f2,
    required this.f3,
    required this.onTg,
    required this.onG,
    required this.onM,
    required this.onF,
  });

  @override
  Widget build(BuildContext context) {
    return _Glass(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _CardTitle(title: _TXT.linesTitle, emoji: "🧮"),
          const SizedBox(height: 14),
          _LineRow(
            tag: 'TG',
            emoji: '🚀',
            color: const Color(0xFF0EA5E9),
            leftCtl: tg1,
            rightCtl: tg2,
            product: tg3,
            onChanged: onTg,
          ),
          const SizedBox(height: 12),
          _LineRow(
            tag: 'G',
            emoji: '🏋️',
            color: const Color(0xFFF59E0B),
            leftCtl: g1,
            rightCtl: g2,
            product: g3,
            onChanged: onG,
          ),
          const SizedBox(height: 12),
          _LineRow(
            tag: 'M',
            emoji: '⚡',
            color: const Color(0xFF22C55E),
            leftCtl: m1,
            rightCtl: m2,
            product: m3,
            onChanged: onM,
          ),
          const SizedBox(height: 12),
          _LineRow(
            tag: 'F',
            emoji: '🔥',
            color: const Color(0xFFEF4444),
            leftCtl: f1,
            rightCtl: f2,
            product: f3,
            onChanged: onF,
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final int result;
  final int totalLive;
  final VoidCallback onCalculate;
  final VoidCallback onPrint;

  const _ResultCard({
    required this.result,
    required this.totalLive,
    required this.onCalculate,
    required this.onPrint,
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
          const _CardTitle(title: _TXT.resultTitle, emoji: "📊"),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withOpacity(0.10),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ResultStat(
                    label: "Live Total",
                    value: totalLive.toString(),
                  ),
                ),
                Container(
                  width: 1,
                  height: 44,
                  color: Colors.white.withOpacity(0.10),
                ),
                Expanded(
                  child: _ResultStat(
                    label: "Saved Result",
                    value: result.toString(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _PulseButton(
                  label: _TXT.calculate,
                  onTap: onCalculate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PulseButton(
                  label: _TXT.print,
                  onTap: onPrint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  final String title;
  final String emoji;

  const _CardTitle({
    required this.title,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          emoji,
          style: t.textTheme.titleLarge?.copyWith(
            color: Colors.white.withOpacity(0.92),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: _gradientTitle(
            context,
            title,
            headline: true,
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// Small widgets
/// ---------------------------------------------------------------------------

class _LegendPill extends StatelessWidget {
  final String text;
  final Color color;

  const _LegendPill({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withOpacity(isDark ? 0.22 : 0.18),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white.withOpacity(0.92) : null,
            ),
      ),
    );
  }
}

class _LineRow extends StatelessWidget {
  final String tag;
  final String emoji;
  final Color color;
  final TextEditingController leftCtl;
  final TextEditingController rightCtl;
  final int product;
  final VoidCallback onChanged;

  const _LineRow({
    required this.tag,
    required this.emoji,
    required this.color,
    required this.leftCtl,
    required this.rightCtl,
    required this.product,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isDark = t.brightness == Brightness.dark;
    final tailBlue = _brandBlues(context)[1];

    return Column(
      children: [
        Container(
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              colors: [color, tailBlue],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(colors: [color, tailBlue]),
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
                    style: t.textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    tag,
                    style: t.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _NumberField(
                label: _TXT.lineFieldA,
                controller: leftCtl,
                onChanged: (_) => onChanged(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _NumberField(
                label: _TXT.lineFieldB,
                controller: rightCtl,
                onChanged: (_) => onChanged(),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              constraints: const BoxConstraints(minWidth: 42),
              alignment: Alignment.centerRight,
              child: Text(
                product.toString(),
                style: t.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white.withOpacity(0.95) : null,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label;
  final String value;

  const _ResultStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Column(
      children: [
        Text(
          label,
          style: t.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white.withOpacity(0.72),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: t.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: Colors.white.withOpacity(0.96),
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// Inputs
/// ---------------------------------------------------------------------------

class _NumberField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _NumberField({
    required this.label,
    required this.controller,
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
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: t.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: Colors.white.withOpacity(0.96),
          ),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: "0",
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

/// ---------------------------------------------------------------------------
/// Base UI
/// ---------------------------------------------------------------------------

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
      child: Icon(icon, color: Colors.white.withOpacity(0.92), size: 20),
    );
  }
}

Text _gradientTitle(BuildContext context, String text, {bool headline = false}) {
  final colors = headline ? _headlineBlues(context) : _brandBlues(context);
  final shader = LinearGradient(
    colors: colors,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ).createShader(const Rect.fromLTWH(0, 0, 360, 44));

  return Text(
    text,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w900,
          foreground: Paint()..shader = shader,
        ),
  );
}

class _PulseButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _PulseButton({
    required this.label,
    required this.onTap,
  });

  @override
  State<_PulseButton> createState() => _PulseButtonState();
}

class _PulseButtonState extends State<_PulseButton>
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
    final blues = _brandBlues(context);

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
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: blues,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: blues[1].withOpacity(0.50 * (0.3 + 0.7 * v)),
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