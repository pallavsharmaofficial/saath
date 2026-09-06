import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// The page shell used by every screen: a full-bleed photo, a colour veil,
/// and a permanent gradient fade at the top and bottom so text always sits
/// on a quiet zone regardless of the photo behind it.
class Atmosphere extends StatelessWidget {
  const Atmosphere({
    super.key,
    required this.background,
    required this.child,
    this.veilOpacity,
    this.topFade = 200,
    this.bottomFade = 260,
  });

  /// Asset path, e.g. `assets/backgrounds/bg-today.jpg`.
  final String background;
  final Widget child;

  /// Overrides the theme veil opacity (0–1). Lower shows more photo.
  final double? veilOpacity;
  final double topFade;
  final double bottomFade;

  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    final veil = veilOpacity == null ? s.veil : s.bg.withOpacity(veilOpacity!);
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(background, fit: BoxFit.cover),
        ColoredBox(color: veil),
        Align(
          alignment: Alignment.topCenter,
          child: IgnorePointer(
            child: Container(
              height: topFade,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0, 0.45, 1],
                  colors: [s.bg, s.bg.withOpacity(0.7), s.bg.withOpacity(0)],
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: IgnorePointer(
            child: Container(
              height: bottomFade,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0, 0.45, 1],
                  colors: [s.bg, s.bg.withOpacity(0.75), s.bg.withOpacity(0)],
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Background assets, named by the moment they belong to.
class Backgrounds {
  Backgrounds._();
  static const welcome = 'assets/backgrounds/bg-welcome.jpg';
  static const origin = 'assets/backgrounds/bg-origin.jpg';
  static const today = 'assets/backgrounds/bg-today.jpg';
  static const aware = 'assets/backgrounds/bg-aware.jpg';
  static const working = 'assets/backgrounds/bg-working.jpg';
  static const calm = 'assets/backgrounds/bg-calm.jpg';
}
