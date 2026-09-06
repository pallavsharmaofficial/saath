import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
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
    final me = app.userOrDefault;
    final p = app.partnerOrDefault;

    void notYet() => ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(s.needsPairing)));

    return StageTheme(
      stage: ResolutionStage.calm,
      child: Atmosphere(
        background: Backgrounds.calm,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
              24, MediaQuery.paddingOf(context).top + 12, 24, 140),
          children: [
            Eyebrow(s.usLabel, color: surface.ink2),
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
                      Flexible(child: Eyebrow(s.whyWeStarted)),
                      Icon(Icons.lock_outline_rounded,
                          size: 16, color: context.stage.accent),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    app.originStory.isEmpty
                        ? s.originRevealHintUnwritten(p)
                        : s.originRevealHintWritten(p),
                    style: t.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  if (app.originStory.isEmpty)
                    GlassButton(
                      label: s.editOriginStory,
                      primary: false,
                      icon: Icons.edit_outlined,
                      onPressed: () => context.push(Routes.editOrigin),
                    )
                  else
                    GlassButton(
                      label: s.planTheReveal,
                      primary: false,
                      onPressed: notYet,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Eyebrow(s.loveMap),
                  const SizedBox(height: 10),
                  _Row(k: s.currentStress(p), v: s.tapToAdd, onTap: notYet),
                  Divider(color: surface.hairline, height: 16),
                  _Row(k: s.smallJoy(p), v: s.tapToAdd, onTap: notYet),
                  Divider(color: surface.hairline, height: 16),
                  // Was "You still don't know · Vikram's dream trip →", which
                  // read like an insight the app had derived. It had derived
                  // nothing; it is a prompt.
                  _Row(
                      k: s.askAbout(p),
                      v: s.dreamTripPrompt,
                      accent: true,
                      onTap: notYet),
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
                      label: s.nextDate,
                      color: surface.gold,
                      child: Text(s.noDatePlanned),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TintPanel(
                      label: s.sharedGoal,
                      color: context.stage.accent,
                      // Was a hardcoded goal presented as though the couple
                      // had set it.
                      child: Text(s.noSharedGoal),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GlassButton(
              label: s.openRepairRoom,
              primary: false,
              icon: Icons.meeting_room_outlined,
              onPressed: () => context.push(Routes.repair),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(
      {required this.k, required this.v, this.accent = false, this.onTap});

  final String k;
  final String v;
  final bool accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 15);
    return Semantics(
      button: onTap != null,
      label: '$k, $v',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  child:
                      Text(k, style: t?.copyWith(color: context.surface.ink2))),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  v,
                  textAlign: TextAlign.right,
                  style:
                      t?.copyWith(color: accent ? context.stage.accent : null),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
