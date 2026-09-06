import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

/// Builds the app theme for a brightness. The [ResolutionStage] is applied
/// per screen with [StageTheme], so the app-level default is `working`.
ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final surface = dark ? SurfaceTokens.dark : SurfaceTokens.light;
  final stage = StageTokens.of(ResolutionStage.working, brightness);

  final display = GoogleFonts.soraTextTheme();
  final body = GoogleFonts.sourceSerif4TextTheme();

  final textTheme = TextTheme(
    displayLarge: display.displayLarge?.copyWith(
        fontSize: 36, fontWeight: FontWeight.w700, height: 1.1, letterSpacing: -0.7),
    headlineMedium: display.headlineMedium?.copyWith(
        fontSize: 28, fontWeight: FontWeight.w700, height: 1.15, letterSpacing: -0.3),
    headlineSmall: display.headlineSmall?.copyWith(
        fontSize: 22, fontWeight: FontWeight.w600, height: 1.2),
    titleMedium: display.titleMedium?.copyWith(
        fontSize: 17, fontWeight: FontWeight.w600, height: 1.3),
    labelLarge: display.labelLarge?.copyWith(
        fontSize: 16, fontWeight: FontWeight.w600),
    labelSmall: display.labelSmall?.copyWith(
        fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5),
    bodyLarge: body.bodyLarge?.copyWith(fontSize: 17, height: 1.5),
    bodyMedium: body.bodyMedium?.copyWith(fontSize: 16, height: 1.5),
    bodySmall: body.bodySmall?.copyWith(fontSize: 14, height: 1.45),
  ).apply(bodyColor: surface.ink, displayColor: surface.ink);

  final scheme = ColorScheme(
    brightness: brightness,
    primary: stage.accent,
    onPrimary: Colors.white,
    secondary: dark ? Palette.sageDark : Palette.sage,
    onSecondary: Colors.white,
    error: dark ? Palette.roseDark : Palette.rose,
    onError: Colors.white,
    surface: surface.bg,
    onSurface: surface.ink,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: surface.bg,
    textTheme: textTheme,
    splashFactory: InkSparkle.splashFactory,
    extensions: [surface, stage],
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
  );
}

/// Re-themes a subtree for a resolution stage. Wrap a screen in this to
/// move its accent, radii and blur along the arc.
class StageTheme extends StatelessWidget {
  const StageTheme({super.key, required this.stage, required this.child});

  final ResolutionStage stage;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = StageTokens.of(stage, theme.brightness);
    final surface = theme.extension<SurfaceTokens>()!;
    return AnimatedTheme(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(primary: tokens.accent),
        extensions: [surface, tokens],
      ),
      child: child,
    );
  }
}
