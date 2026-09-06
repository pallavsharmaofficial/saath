import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/app_state.dart';
import '../../core/strings.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../../ui/atmosphere.dart';
import '../../ui/glass.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context, ref);
    final app = ref.watch(appStateProvider);
    final t = Theme.of(context).textTheme;
    final surface = context.surface;
    final dark = context.isDark;
    final name = app.userName.isEmpty ? 'there' : app.userName;

    return StageTheme(
      stage: ResolutionStage.working,
      child: Atmosphere(
        background: Backgrounds.today,
        child: ListView(
          padding: EdgeInsets.fromLTRB(24, MediaQuery.paddingOf(context).top + 12, 24, 140),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Eyebrow(DateFormat('EEEE, d MMM').format(DateTime.now()), color: surface.ink2),
                      const SizedBox(height: 4),
                      Text(s.greeting(name), style: t.headlineMedium?.copyWith(fontSize: 26)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => context.push('/settings'),
                  icon: Icon(Icons.tune_rounded, color: surface.ink2),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _CheckIn(s: s, app: app),
            const SizedBox(height: 12),
            _TalkCard(s: s, partner: app.partnerOrDefault),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: TintPanel(
                    label: 'From ${app.partnerOrDefault}',
                    color: dark ? Palette.roseDark : Palette.rose,
                    child: const Text('Not paired yet · invite from any Untangle'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TintPanel(
                    label: 'This week',
                    color: surface.gold,
                    child: Text(app.todayConnection == null
                        ? 'Pulse report ready Sunday · 0 of 7 check-ins'
                        : 'Pulse report ready Sunday · 1 of 7 check-ins'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckIn extends ConsumerWidget {
  const _CheckIn({required this.s, required this.app});
  final S s;
  final AppState app;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final surface = context.surface;
    final st = context.stage;
    final sage = Theme.of(context).colorScheme.secondary;
    return GlassPanel(
      strong: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(s.checkinLabel, color: sage),
          const SizedBox(height: 8),
          Text(s.checkinQ, style: t.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 1; i <= 5; i++) ...[
                Expanded(
                  child: InkWell(
                    onTap: () => ref.read(appStateProvider.notifier).checkIn(connection: i),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 46,
                      decoration: BoxDecoration(
                        color: app.todayConnection == i ? st.accentSoft : surface.glassSoft,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: app.todayConnection == i ? st.accent : surface.glassBorder,
                          width: app.todayConnection == i ? 1.5 : 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text('$i',
                          style: t.labelLarge?.copyWith(
                              fontSize: 15,
                              color: app.todayConnection == i ? st.accent : surface.ink2)),
                    ),
                  ),
                ),
                if (i < 5) const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(app.todayConnection == null ? s.oneWord : 'Saved for today. ${s.oneWord}',
              style: t.bodySmall?.copyWith(color: surface.ink2)),
        ],
      ),
    );
  }
}

class _TalkCard extends StatelessWidget {
  const _TalkCard({required this.s, required this.partner});
  final S s;
  final String partner;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final r = BorderRadius.circular(context.stage.radius);
    return ClipRRect(
      borderRadius: r,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Material(
          color: Palette.bgDark.withOpacity(context.isDark ? 0.55 : 0.72),
          shape: RoundedRectangleBorder(borderRadius: r, side: BorderSide(color: Colors.white.withOpacity(0.18))),
          child: InkWell(
            onTap: () => context.go('/counsellor'),
            borderRadius: r,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, size: 18, color: Palette.roseDark),
                      const SizedBox(width: 8),
                      Eyebrow(s.talkToSaath, color: Palette.roseDark),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(s.talkPrompt(partner), style: t.bodyLarge?.copyWith(color: Colors.white)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _DarkChip(s.promptSameFight, onTap: () => context.push('/talk', extra: s.promptSameFight)),
                      _DarkChip(s.promptRegret, onTap: () => context.push('/talk', extra: s.promptRegret)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DarkChip extends StatelessWidget {
  const _DarkChip(this.label, {required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.08),
      shape: StadiumBorder(side: BorderSide(color: Colors.white.withOpacity(0.3))),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 0, fontSize: 12, fontWeight: FontWeight.w500, color: Palette.inkDark)),
        ),
      ),
    );
  }
}
