import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class ProgressWidget extends StatefulWidget {
  final String label;
  final double value;

  /// Optionnel : permet d'utiliser le widget comme carte cliquable
  final VoidCallback? onTap;

  const ProgressWidget({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  State<ProgressWidget> createState() => _ProgressWidgetState();
}

class _ProgressWidgetState extends State<ProgressWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _valueAnimation;

  double _oldValue = 0.0;

  @override
  void initState() {
    super.initState();

    _oldValue = widget.value.clamp(0.0, 100.0).toDouble();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _valueAnimation = Tween<double>(
      begin: 0.0,
      end: _oldValue,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant ProgressWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final double newValue = widget.value.clamp(0.0, 100.0).toDouble();
    final double oldClampedValue = oldWidget.value.clamp(0.0, 100.0).toDouble();

    if (newValue != oldClampedValue) {
      _valueAnimation = Tween<double>(
        begin: _oldValue,
        end: newValue,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        ),
      );

      _oldValue = newValue;

      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Color> _tierGradient(bool isDark, double value) {
    if (value >= 90) {
      return isDark
          ? const [Color(0xFFFCA5A5), Color(0xFFF43F5E)]
          : const [Color(0xFFEF4444), Color(0xFFE11D48)];
    }
    if (value >= 75) {
      return isDark
          ? const [Color(0xFFFDE68A), Color(0xFFF59E0B)]
          : const [Color(0xFFF59E0B), Color(0xFFFB923C)];
    }
    if (value >= 55) {
      return isDark
          ? const [Color(0xFFA7F3D0), Color(0xFF10B981)]
          : const [Color(0xFF34D399), Color(0xFF10B981)];
    }
    return isDark
        ? const [Color(0xFF22D3EE), Color(0xFF818CF8)]
        : const [Color(0xFF06B6D4), Color(0xFF6366F1)];
  }

  String _tierText(double value) {
    if (value >= 90) return "Elite";
    if (value >= 75) return "Strong";
    if (value >= 55) return "Good";
    return "Progressing";
  }

  IconData _tierIcon(double value) {
    if (value >= 90) return Icons.workspace_premium_rounded;
    if (value >= 75) return Icons.local_fire_department_rounded;
    if (value >= 55) return Icons.trending_up_rounded;
    return Icons.bolt_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color trackColor =
        (isDark ? Colors.white24 : Colors.black12).withOpacity(0.22);

    return AnimatedBuilder(
      animation: _valueAnimation,
      builder: (context, _) {
        final double displayedValue =
            _valueAnimation.value.clamp(0.0, 100.0).toDouble();

        final List<Color> colors = _tierGradient(isDark, displayedValue);
        final Color accent = colors.last;

        return MouseRegion(
          cursor: widget.onTap != null
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: widget.onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 170,
                    maxWidth: 230,
                  ),
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: isDark
                        ? Colors.white.withOpacity(0.07)
                        : Colors.white.withOpacity(0.10),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.10)
                          : Colors.black.withOpacity(0.06),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.20),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: accent.withOpacity(0.18),
                        blurRadius: 24,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(colors: colors),
                            ),
                            child: Icon(
                              _tierIcon(displayedValue),
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? Colors.white.withOpacity(0.96)
                                    : Colors.black87,
                              ),
                            ),
                          ),
                          if (widget.onTap != null)
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: isDark
                                  ? Colors.white.withOpacity(0.68)
                                  : Colors.black54,
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: SfRadialGauge(
                          axes: <RadialAxis>[
                            RadialAxis(
                              minimum: 0,
                              maximum: 100,
                              startAngle: 270,
                              endAngle: 270,
                              showLabels: false,
                              showTicks: false,
                              radiusFactor: 0.92,
                              axisLineStyle: AxisLineStyle(
                                cornerStyle: CornerStyle.bothFlat,
                                color: trackColor,
                                thickness: 12,
                              ),
                              pointers: <GaugePointer>[
                                RangePointer(
                                  value: displayedValue,
                                  cornerStyle: CornerStyle.bothFlat,
                                  width: 12,
                                  sizeUnit: GaugeSizeUnit.logicalPixel,
                                  gradient: SweepGradient(
                                    colors: [...colors, colors.first],
                                    stops: const [0.0, 0.78, 1.0],
                                  ),
                                ),
                              ],
                              annotations: <GaugeAnnotation>[
                                GaugeAnnotation(
                                  angle: 90,
                                  positionFactor: 0.02,
                                  widget: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "${displayedValue.ceil()}%",
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: accent,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _tierText(displayedValue),
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: isDark
                                              ? Colors.white.withOpacity(0.72)
                                              : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: accent.withOpacity(isDark ? 0.18 : 0.12),
                          border: Border.all(
                            color: accent.withOpacity(0.35),
                          ),
                        ),
                        child: Text(
                          "${displayedValue.toStringAsFixed(0)} / 100",
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? Colors.white.withOpacity(0.92)
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}