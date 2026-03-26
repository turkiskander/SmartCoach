import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/widget/loading_widget.dart';

class IdealWeigthDevineView extends StatefulWidget {
  const IdealWeigthDevineView({super.key});

  @override
  State<IdealWeigthDevineView> createState() => _IdealWeigthDevineViewState();
}

List<Color> _brandBluesFrom(bool isDark) => isDark
    ? const [Color(0xFF0B2447), Color(0xFF19376D)]
    : const [Color(0xFF1D4ED8), Color(0xFF3B82F6)];

List<Color> _headlineBluesFrom(bool isDark) => isDark
    ? const [Color(0xFF93C5FD), Color(0xFF60A5FA)]
    : const [Color(0xFF1D4ED8), Color(0xFF3B82F6)];

List<Color> _brandBlues(BuildContext c) =>
    _brandBluesFrom(Theme.of(c).brightness == Brightness.dark);

List<Color> _headlineBlues(BuildContext c) =>
    _headlineBluesFrom(Theme.of(c).brightness == Brightness.dark);

Color _appBarBg(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? const Color(0xFF070D1A) : Colors.white;
}

class _IdealWeigthDevineViewState extends State<IdealWeigthDevineView> {
  final TextEditingController heightCtl = TextEditingController(text: "0");
  final TextEditingController sexCtl = TextEditingController();

  double _ideal = 0;
  bool _hasResult = false;

  double _safeDouble(String s) =>
      double.tryParse(s.trim().replaceAll(',', '.')) ?? 0.0;

  void _compute() {
    final h = _safeDouble(heightCtl.text);
    if (h <= 0) {
      setState(() {
        _ideal = 0;
        _hasResult = false;
      });
      return;
    }

    final inches = h * 0.3937008;
    final extra = inches > 60 ? (inches - 60) : 0.0;
    final isMale = (sexCtl.text == "Male");

    final ideal = isMale ? 50.0 + 2.3 * extra : 45.5 + 2.3 * extra;

    setState(() {
      _ideal = ideal;
      _hasResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBg = _appBarBg(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerScrolled) => [
            SliverAppBar(
              pinned: true,
              floating: true,
              snap: true,
              elevation: 0,
              backgroundColor: appBg,
              surfaceTintColor: Colors.transparent,
              forceElevated: innerScrolled,
              scrolledUnderElevation: 10,
              automaticallyImplyLeading: false,
              toolbarHeight: kToolbarHeight,
              collapsedHeight: kToolbarHeight + 44,
              expandedHeight: kToolbarHeight + 44,
              systemOverlayStyle: isDark
                  ? SystemUiOverlayStyle.light
                      .copyWith(statusBarColor: Colors.transparent)
                  : SystemUiOverlayStyle.dark
                      .copyWith(statusBarColor: Colors.transparent),
              leading: IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color:
                      isDark ? Colors.white.withOpacity(0.95) : Colors.black87,
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              title: Row(
                children: [
                  Text('📏', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(width: 6),
                  Expanded(
                    child:
                        _appBarGradientTitle(context, "Devine Ideal Weight"),
                  ),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(44),
                child: Container(
                  color: appBg,
                  height: 44,
                  child: const TabBar(
                    isScrollable: true,
                    tabs: [
                      Tab(text: "⚙️ Calculator"),
                      Tab(text: "📈 Results"),
                      Tab(text: "📘 Information"),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _buildCalc(context),
              _buildResults(context),
              _buildInfo(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalc(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: [
          _GlassCard(
            child: _body(
              context,
              "Enter your information to calculate your ideal weight",
              align: TextAlign.center,
              weight: FontWeight.w700,
              size: 15,
            ),
          ),
          _GlassCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _NumberField(
                        label: "Height (cm)",
                        controller: heightCtl,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DropdownField(
                        label: "Sex",
                        controller: sexCtl,
                        items: const ["Female", "Male"],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _PulseButton(
                  label: "Calculate",
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _compute();
                    DefaultTabController.of(context).animateTo(1);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    final chip = _metricChip(
      context,
      "Ideal Weight",
      _hasResult ? "${_ideal.toStringAsFixed(2)} kg" : "—",
    );

    return Center(
      child: _GlassCard(
        child: Column(
          children: [
            _sectionHeader("Your Results", context),
            const SizedBox(height: 8),
            chip,
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _GlassCard(
        child: Column(
          children: [
            const _NetImage(
              url:
                  "https://www.calculersonimc.fr/wp-content/uploads/2018/04/perte-de-poids-poids-ide%CC%81al-.jpg",
            ),
            const SizedBox(height: 10),
            _body(
              context,
              "Devine Formula Explanation",
              weight: FontWeight.w800,
              size: 14,
              align: TextAlign.center,
            ),
            const SizedBox(height: 10),
            _codeBlock(
              context,
              "Male: 50 + 2.3 × (height in inches − 60)\nFemale: 45.5 + 2.3 × (height in inches − 60)",
            ),
          ],
        ),
      ),
    );
  }
}

Widget _metricChip(BuildContext context, String label, String value) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.blue.withOpacity(0.15),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text("$label : $value",
        style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}

Widget _body(BuildContext context, String text,
    {TextAlign align = TextAlign.start,
    FontWeight? weight,
    double? size}) {
  return Text(
    text,
    textAlign: align,
    style: TextStyle(fontWeight: weight, fontSize: size),
  );
}

Widget _codeBlock(BuildContext context, String text) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey.withOpacity(0.15),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(text, textAlign: TextAlign.center),
  );
}

class _DropdownField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final List<String> items;

  const _DropdownField(
      {required this.label, required this.controller, required this.items});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (v) => controller.text = v ?? "",
    );
  }
}

class _NumberField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _NumberField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _NetImage extends StatelessWidget {
  final String url;

  const _NetImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      height: 200,
      placeholder: (_, __) => const LoadingWidget(),
      errorWidget: (_, __, ___) => const Icon(Icons.error),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.9),
        boxShadow: const [BoxShadow(blurRadius: 10)],
      ),
      child: child,
    );
  }
}

Widget _sectionHeader(String text, BuildContext context) {
  return Text(text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
}

Widget _appBarGradientTitle(BuildContext context, String text) {
  return Text(text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18));
}

class _PulseButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PulseButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onTap, child: Text(label));
  }
}