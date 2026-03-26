import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// UI Kit commun pour tous les outils Training Calculation
/// - Background BgS.jfif + overlay
/// - Orbs glow
/// - Glass containers
/// - Header moderne (back + titre)
///
/// ✅ But: Harmoniser le design sans toucher la logique métier des fichiers outils.
class TrainingUiKit {
  static const String bgAsset = "assets/images/BgS.jfif";
}

/// Scaffold glass “Beep style”
/// Utilise-le dans chaque tool:
/// return TrainingGlassScaffold(title: "Cooper", child: ... ton UI existante ...);
class TrainingGlassScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final VoidCallback? onBack;

  const TrainingGlassScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.onBack,
  });

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
          // Background
          Positioned.fill(
            child: Image.asset(
              TrainingUiKit.bgAsset,
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

          // Orbs
          Positioned(
            top: -160,
            left: -160,
            child: GlowOrb(
              size: 360,
              color: cs.primary.withOpacity(isDark ? 0.10 : 0.08),
            ),
          ),
          Positioned(
            bottom: -170,
            right: -170,
            child: GlowOrb(
              size: 390,
              color: (cs.tertiary == cs.primary ? cs.secondary : cs.tertiary)
                  .withOpacity(isDark ? 0.12 : 0.10),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Column(
                children: [
                  HeaderModern(
                    title: title,
                    onBack: () {
                      HapticFeedback.selectionClick();
                      if (onBack != null) return onBack!();
                      Navigator.of(context).maybePop();
                    },
                    actions: actions,
                  ),
                  const SizedBox(height: 12),

                  // Content
                  Expanded(
                    child: Glass(
                      radius: 20,
                      padding: EdgeInsets.zero,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ========================================================================== */
/* Widgets communs */
/* ========================================================================== */

class HeaderModern extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final List<Widget>? actions;

  const HeaderModern({
    super.key,
    required this.title,
    required this.onBack,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Glass(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          PillIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: onBack,
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
          if (actions != null) ...[
            const SizedBox(width: 8),
            ...actions!,
          ],
        ],
      ),
    );
  }
}

class Glass extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsets padding;

  const Glass({
    super.key,
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
    final border =
        isDark ? Colors.white.withOpacity(0.10) : Colors.white.withOpacity(0.14);

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

class PillIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? accent;

  const PillIconButton({
    super.key,
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
          color: (accent ?? Colors.white.withOpacity(0.92)),
          size: 20,
        ),
      ),
    );
  }
}

class GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const GlowOrb({super.key, required this.size, required this.color});

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

/// Champ input “glass” optionnel (si tu veux uniformiser les TextField)
class GlassField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  const GlassField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.10),
        border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: t.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: Colors.white.withOpacity(0.92),
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: t.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white.withOpacity(0.55),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

/// Bouton “glass”
class GlassButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  const GlassButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: cs.primary.withOpacity(0.22),
          border: Border.all(color: cs.primary.withOpacity(0.45), width: 1),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withOpacity(0.22),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: Colors.white.withOpacity(0.92)),
              const SizedBox(width: 10),
            ],
            Text(
              label,
              style: t.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(0.96),
              ),
            ),
          ],
        ),
      ),
    );
  }
}