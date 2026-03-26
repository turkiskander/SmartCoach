// audio_widget.dart
// ✅ UI redesign only — logic unchanged
// ✅ Style sombre/glass comme BeepIntermittentTrainingView (HomePage vibe)
// ✅ Pas de couleurs flashy / gradients agressifs
// ✅ brandGradient conservé pour compat (mais UI = accent Theme.primary)

import 'dart:async';
import 'dart:io';
import 'dart:ui' show FontFeature, ImageFilter;

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException, HapticFeedback;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class _TXT {
  static const String loading = "Chargement…";

  static const String audioTimeoutShort = "Délai audio dépassé.";
  static const String audioTimeoutLong =
      "Impossible de charger l’audio (timeout). Vérifie ta connexion.";

  static const String audioAndroidErrorShort = "Erreur audio Android.";
  static const String audioAndroidErrorLong = "Erreur audio Android détectée";

  static const String audioGenericErrorShort = "Erreur audio.";
  static const String audioGenericErrorLong =
      "Une erreur est survenue pendant le chargement audio";

  static const String audioPlaybackImpossible = "Lecture impossible";

  static const String storagePermissionDenied = "Permission de stockage refusée.";
  static const String storageFolderNotFound = "Dossier de stockage introuvable.";

  static const String fileSaved = "Fichier enregistré";
  static const String downloadImpossible = "Téléchargement impossible";

  static const String nowPlaying = "Audio";
  static const String stateReady = "Prêt";
  static const String stateLoading = "Chargement";
  static const String stateError = "Erreur";
}

class AudioWidget extends StatefulWidget {
  final String source;

  /// ✅ kept for compatibility (logic unchanged)
  final List<Color>? brandGradient;

  const AudioWidget({
    super.key,
    required this.source,
    this.brandGradient,
  });

  @override
  State<AudioWidget> createState() => _AudioWidgetState();
}

class _AudioWidgetState extends State<AudioWidget> {
  final AudioPlayer _player = AudioPlayer();

  Duration _dur = Duration.zero;
  Duration _pos = Duration.zero;
  bool _isPlaying = false;
  bool _isMuted = false;
  bool _isReady = false;
  String? _lastError;

  StreamSubscription<Duration>? _subDur;
  StreamSubscription<Duration>? _subPos;
  StreamSubscription<void>? _subComplete;

  bool get _isLoading => !_isReady && _lastError == null;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  @override
  void dispose() {
    _subDur?.cancel();
    _subPos?.cancel();
    _subComplete?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _initAudio() async {
    _subDur?.cancel();
    _subPos?.cancel();
    _subComplete?.cancel();

    if (mounted) {
      setState(() {
        _isReady = false;
        _lastError = null;
        _dur = Duration.zero;
        _pos = Duration.zero;
        _isPlaying = false;
      });
    }

    _subDur = _player.onDurationChanged.listen((d) {
      if (!mounted) return;
      setState(() => _dur = d);
    });

    _subPos = _player.onPositionChanged.listen((p) {
      if (!mounted) return;
      setState(() => _pos = p);
    });

    _subComplete = _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _pos = Duration.zero;
        _isPlaying = false;
      });
    });

    try {
      _lastError = null;

      await _player
          .setSource(UrlSource(widget.source))
          .timeout(const Duration(seconds: 12));

      if (!mounted) return;
      setState(() => _isReady = true);
    } on TimeoutException catch (_) {
      if (!mounted) return;
      setState(() {
        _isReady = false;
        _lastError = _TXT.audioTimeoutLong;
      });
      _showSnack(_TXT.audioTimeoutShort);
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() {
        _isReady = false;
        _lastError = "${_TXT.audioAndroidErrorLong}: ${e.message}";
      });
      _showSnack(_TXT.audioAndroidErrorShort);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isReady = false;
        _lastError = "${_TXT.audioGenericErrorLong}: $e";
      });
      _showSnack("${_TXT.audioGenericErrorShort}: $e");
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _mmss(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  Future<void> _togglePlayPause() async {
    if (!_isReady) {
      await _initAudio();
      if (!_isReady) return;
    }

    if (_isPlaying) {
      await _player.pause();
      if (!mounted) return;
      setState(() => _isPlaying = false);
    } else {
      if (_dur > Duration.zero && _pos >= _dur) {
        await _player.seek(Duration.zero);
      }

      try {
        await _player.resume();
        if (!mounted) return;
        setState(() => _isPlaying = true);
      } catch (e) {
        _showSnack("${_TXT.audioPlaybackImpossible}: $e");
      }
    }
  }

  Future<void> _toggleMute() async {
    setState(() => _isMuted = !_isMuted);
    await _player.setVolume(_isMuted ? 0.0 : 1.0);
  }

  Future<void> _seekTo(double seconds) async {
    final max = _dur.inSeconds;
    final clamped = seconds.clamp(0, (max > 0 ? max : 1)).toInt();
    final target = Duration(seconds: clamped);
    await _player.seek(target);
    if (!mounted) return;
    setState(() => _pos = target);
  }

  Future<void> _downloadWithDio() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          _showSnack(_TXT.storagePermissionDenied);
          return;
        }
      }

      final dir = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();

      if (dir == null) {
        _showSnack(_TXT.storageFolderNotFound);
        return;
      }

      final fileName = Uri.parse(widget.source).pathSegments.last;
      final filePath = '${dir.path}/$fileName';

      final dio = Dio();
      await dio.download(widget.source, filePath);

      _showSnack("${_TXT.fileSaved}: $fileName");
    } catch (e) {
      _showSnack("${_TXT.downloadImpossible}: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final dark = t.brightness == Brightness.dark;

    // ✅ accent sobre, aligné au thème (HomePage vibe)
    final accent = cs.primary;

    final maxSeconds = _dur.inSeconds > 0 ? _dur.inSeconds.toDouble() : 1.0;
    final valueSeconds =
        _isLoading ? 0.0 : _pos.inSeconds.clamp(0, maxSeconds.toInt()).toDouble();

    String timeLabel;
    if (_isLoading) {
      timeLabel = _TXT.loading;
    } else if (_lastError != null) {
      timeLabel = "⚠️";
    } else {
      timeLabel = "${_mmss(_pos)} / ${_mmss(_dur)}";
    }

    final stateText = _lastError != null
        ? _TXT.stateError
        : (_isLoading ? _TXT.stateLoading : _TXT.stateReady);

    final fileLabel = Uri.tryParse(widget.source)?.pathSegments.last ?? "";

    return Stack(
      children: [
        // ✅ Orbs discrets
        Positioned(
          top: -70,
          left: -70,
          child: _Orb(color: accent.withOpacity(dark ? 0.16 : 0.10)),
        ),
        Positioned(
          bottom: -85,
          right: -85,
          child: _Orb(color: accent.withOpacity(dark ? 0.12 : 0.08)),
        ),

        _GlassCard(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            children: [
              Row(
                children: [
                  _LeadingBadge(icon: Icons.graphic_eq_rounded),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _TXT.nowPlaying,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            height: 1.0,
                            color: Colors.white.withOpacity(0.96),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _StateChip(
                              text: stateText,
                              isError: _lastError != null,
                              isLoading: _isLoading,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                fileLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: t.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withOpacity(0.74),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    timeLabel,
                    style: t.textTheme.labelLarge?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withOpacity(0.94),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  overlayShape: SliderComponentShape.noOverlay,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  activeTrackColor: accent.withOpacity(0.92),
                  thumbColor: accent.withOpacity(0.95),
                  inactiveTrackColor: Colors.white.withOpacity(0.18),
                ),
                child: Slider(
                  value: valueSeconds,
                  min: 0.0,
                  max: maxSeconds,
                  onChanged: (!_isLoading && _isReady) ? (v) => _seekTo(v) : null,
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _PrimaryPlayButton(
                      isPlaying: _isPlaying,
                      enabled: !_isLoading,
                      onTap: _isLoading
                          ? null
                          : (_isReady ? _togglePlayPause : _initAudio),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _IconPillButton(
                    icon: _isMuted
                        ? Icons.volume_off_rounded
                        : Icons.volume_up_rounded,
                    onTap: (_isLoading || !_isReady) ? null : () async {
                      HapticFeedback.lightImpact();
                      await _toggleMute();
                    },
                  ),
                  const SizedBox(width: 10),
                  _IconPillButton(
                    icon: Icons.download_rounded,
                    onTap: _isLoading
                        ? null
                        : () async {
                            HapticFeedback.lightImpact();
                            await _downloadWithDio();
                          },
                  ),
                ],
              ),

              if (_isLoading) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white70),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _TXT.loading,
                        style: t.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withOpacity(0.76),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              if (_lastError != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: const Color(0xFFE11D48).withOpacity(0.16),
                    border: Border.all(
                      color: const Color(0xFFE11D48).withOpacity(0.35),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Color(0xFFE11D48), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _lastError!,
                          style: t.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withOpacity(0.80),
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// ---------------- UI helpers (style identique) ----------------

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;

  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 18,
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

class _LeadingBadge extends StatelessWidget {
  final IconData icon;
  const _LeadingBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.10),
        border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            color: Colors.black.withOpacity(0.22),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: cs.primary.withOpacity(0.92), size: 22),
    );
  }
}

class _StateChip extends StatelessWidget {
  final String text;
  final bool isError;
  final bool isLoading;

  const _StateChip({
    required this.text,
    required this.isError,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isError
        ? const Color(0xFFE11D48).withOpacity(0.18)
        : Colors.white.withOpacity(0.10);

    final border = isError
        ? const Color(0xFFE11D48).withOpacity(0.35)
        : Colors.white.withOpacity(0.14);

    final icon = isError
        ? Icons.error_outline_rounded
        : (isLoading
            ? Icons.hourglass_top_rounded
            : Icons.check_circle_outline_rounded);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: bg,
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color:
                isError ? const Color(0xFFE11D48) : Colors.white.withOpacity(0.72),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withOpacity(0.84),
                ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryPlayButton extends StatelessWidget {
  final bool isPlaying;
  final bool enabled;
  final VoidCallback? onTap;

  const _PrimaryPlayButton({
    required this.isPlaying,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    final label = isPlaying ? "Pause" : "Play";
    final icon = isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: enabled
          ? () {
              HapticFeedback.lightImpact();
              onTap?.call();
            }
          : null,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(enabled ? 0.12 : 0.08),
          border: Border.all(
            color: Colors.white.withOpacity(enabled ? 0.16 : 0.12),
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    blurRadius: 18,
                    color: Colors.black.withOpacity(0.25),
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: cs.primary.withOpacity(enabled ? 0.92 : 0.55)),
            const SizedBox(width: 8),
            Text(
              label,
              style: t.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(enabled ? 0.94 : 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconPillButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _IconPillButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.10),
          border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 20,
          color: enabled ? Colors.white.withOpacity(0.92) : Colors.white54,
        ),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  final Color color;
  const _Orb({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 70, spreadRadius: 18)],
      ),
    );
  }
}
