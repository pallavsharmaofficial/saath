import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../../ui/atmosphere.dart';
import '../../ui/glass.dart';

/// Shown instead of a reply when the safety classifier fires. Always the
/// dark, quiet screen regardless of theme mode.
class SafetyScreen extends StatelessWidget {
  const SafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: buildTheme(Brightness.dark),
      child: StageTheme(
        stage: ResolutionStage.calm,
        child: Builder(builder: (context) {
          final t = Theme.of(context).textTheme;
          final surface = context.surface;
          return Scaffold(
            body: Atmosphere(
              background: Backgrounds.welcome,
              veilOpacity: 0.72,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Palette.sageDark.withOpacity(0.16),
                          border: Border.all(color: Palette.sageDark.withOpacity(0.35)),
                        ),
                        child: const Icon(Icons.shield_outlined, color: Palette.sageDark, size: 26),
                      ),
                      const SizedBox(height: 18),
                      Text('I want to pause and check on you.', style: t.headlineMedium?.copyWith(fontSize: 30, color: Colors.white)),
                      const SizedBox(height: 14),
                      Text(
                        'Some of what you described sounds like more than a rough patch. You deserve to be safe, and that comes before fixing anything.',
                        style: t.bodyLarge?.copyWith(color: surface.ink2),
                      ),
                      const SizedBox(height: 10),
                      Text('I am not a counsellor you can call. These people are, and they are free.',
                          style: t.bodyLarge?.copyWith(color: surface.ink2)),
                      const SizedBox(height: 18),
                      const _Helpline(name: 'iCall', sub: 'Mon–Sat, 10am–8pm · 9152987821'),
                      const SizedBox(height: 8),
                      const _Helpline(name: 'National Commission for Women', sub: '7827-170-170 · 24×7'),
                      const SizedBox(height: 8),
                      const _Helpline(name: 'Emergency', sub: '112'),
                      const Spacer(),
                      GlassButton(label: 'I’m okay, keep talking', primary: false, onPressed: () => context.pop()),
                      const SizedBox(height: 12),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.visibility_off_outlined, size: 16, color: surface.ink2),
                            const SizedBox(width: 8),
                            Text('Hide Saath behind a calculator icon',
                                style: t.labelSmall?.copyWith(letterSpacing: 0, fontSize: 13, color: surface.ink2)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _Helpline extends StatelessWidget {
  const _Helpline({required this.name, required this.sub});
  final String name;
  final String sub;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return GlassPanel(
      strong: true,
      radius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: t.labelLarge?.copyWith(fontSize: 15, color: Colors.white)),
                Text(sub, style: t.bodySmall?.copyWith(fontSize: 13, color: context.surface.ink2)),
              ],
            ),
          ),
          const Icon(Icons.call_outlined, color: Palette.sageDark, size: 20),
        ],
      ),
    );
  }
}
