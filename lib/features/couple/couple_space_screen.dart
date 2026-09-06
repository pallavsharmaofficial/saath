import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_state.dart';
import '../../core/strings.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../../ui/atmosphere.dart';
import '../../ui/glass.dart';

class CoupleSpaceScreen extends ConsumerWidget {
  const CoupleSpaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context, ref);
    final app = ref.watch(appStateProvider);
    final t = Theme.of(context).textTheme;
    final surface = context.surface;
    final me = app.userName.isEmpty ? 'You' : app.userName;
    final p = app.partnerOrDefault;

    return StageTheme(
      stage: ResolutionStage.calm,
      child: Atmosphere(
        background: Backgrounds.calm,
        child: ListView(
          padding: EdgeInsets.fromLTRB(24, MediaQuery.paddingOf(context).top + 12, 24, 140),
          children: [
            Eyebrow('Us', color: surface.ink2),
            const SizedBox(height: 4),
            Text('$me & $p', style: t.headlineMedium),
            const SizedBox(height: 18),
            GlassPanel(
              strong: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Eyebrow(s.whyWeStarted),
                      Icon(Icons.lock_outline_rounded, size: 16, color: context.stage.accent),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    app.originStory.isEmpty
                        ? 'Write yours in onboarding. When $p writes theirs, you reveal them together.'
                        : 'Yours is written. When $p writes theirs, reveal them together on the same evening, when you are both ready.',
                    style: t.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  GlassButton(
                    label: 'Plan the reveal',
                    primary: false,
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reveal needs pairing — couple-layer build.')),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('Love map'),
                  const SizedBox(height: 10),
                  _Row(k: '$p’s current stress', v: 'Tap to add'),
                  Divider(color: surface.hairline, height: 16),
                  _Row(k: '$p’s small joy', v: 'Tap to add'),
                  Divider(color: surface.hairline, height: 16),
                  _Row(k: 'You still don’t know', v: '$p’s dream trip →', accent: true),
                ],
              ),
            ),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: TintPanel(
                      label: 'Next date',
                      color: surface.gold,
                      child: const Text('Nothing planned · ask Saath for one that fits you both'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TintPanel(
                      label: 'Shared goal',
                      color: context.stage.accent,
                      child: const Text('One tech-free dinner a week · start this week'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GlassButton(
              label: 'Open a Repair Room',
              primary: false,
              icon: Icons.meeting_room_outlined,
              onPressed: () => context.push('/repair'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.k, required this.v, this.accent = false});
  final String k;
  final String v;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 15);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(k, style: t?.copyWith(color: context.surface.ink2))),
        const SizedBox(width: 12),
        Flexible(
          child: Text(v, textAlign: TextAlign.right, style: t?.copyWith(color: accent ? context.stage.accent : null)),
        ),
      ],
    );
  }
}
