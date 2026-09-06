import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../../ui/atmosphere.dart';
import '../../ui/glass.dart';

class _Card {
  const _Card(this.title, this.body, this.exercise);
  final String title;
  final String body;
  final String exercise;
}

const _cards = [
  _Card(
    'The four horsemen',
    'Criticism, contempt, defensiveness and stonewalling predict a breakup better than how often a couple fights. Contempt — eye-rolling, mocking — is the worst of the four.',
    'Two minutes: name the horseman you reach for first. Just name it.',
  ),
  _Card(
    'Repair attempts',
    'Happy couples fight too. The difference is a small move — a joke, a hand on the arm, “can we start over?” — that stops the escalation. Repair attempts fail when the other person doesn’t notice them.',
    'Agree on one signal you will both recognise as “I’m trying to fix this.”',
  ),
  _Card(
    'Bids for connection',
    '“Look at that bird.” It’s never about the bird. Turning toward small bids — even with a grunt — is what keeps a relationship alive between the big talks.',
    'Tonight, count the bids. Turn toward three of them on purpose.',
  ),
  _Card(
    'Family boundaries, Indian edition',
    'In a joint family “my parents” and “our marriage” overlap by design. The couple has to be a team first, then negotiate with everyone else — not the other way round.',
    'Write one sentence you would both say to a parent, together.',
  ),
  _Card(
    'The flooded brain',
    'Above ~100 bpm you can’t hear anyone. This is biology, not stubbornness. Twenty minutes apart, doing something boring, resets it.',
    'Agree on a time-out word neither of you will argue with.',
  ),
];

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final surface = context.surface;
    return StageTheme(
      stage: ResolutionStage.calm,
      child: Atmosphere(
        background: Backgrounds.origin,
        child: ListView(
          padding: EdgeInsets.fromLTRB(24, MediaQuery.paddingOf(context).top + 12, 24, 140),
          children: [
            Eyebrow('Learn · 5 of 15 cards', color: surface.ink2),
            const SizedBox(height: 4),
            Text('Small ideas, big fights', style: t.headlineMedium),
            const SizedBox(height: 18),
            for (final c in _cards) ...[
              GlassPanel(
                strong: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.title, style: t.titleMedium),
                    const SizedBox(height: 8),
                    Text(c.body, style: t.bodySmall?.copyWith(fontSize: 15)),
                    const SizedBox(height: 12),
                    TintPanel(label: '2-minute exercise', color: context.stage.accent, child: Text(c.exercise)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
