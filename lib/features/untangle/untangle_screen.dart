import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_state.dart';
import '../../core/strings.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../../ui/atmosphere.dart';
import '../../ui/glass.dart';
import '../counsellor/engine.dart';

final _untangleProvider = FutureProvider.autoDispose.family<Untangled, String>((ref, vent) {
  final a = ref.read(appStateProvider);
  return ref.read(counsellorEngineProvider).untangle(
        vent,
        CounsellorContext(
          userName: a.userName,
          partnerName: a.partnerName,
          originStory: a.originStory,
          hindi: a.language == AppLanguage.hi,
        ),
      );
});

class UntangleScreen extends ConsumerWidget {
  const UntangleScreen({super.key, required this.vent});
  final String vent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context, ref);
    final app = ref.watch(appStateProvider);
    final result = ref.watch(_untangleProvider(vent));
    final t = Theme.of(context).textTheme;
    final surface = context.surface;
    final dark = context.isDark;

    return StageTheme(
      stage: ResolutionStage.working,
      child: Scaffold(
        body: Atmosphere(
          background: Backgrounds.working,
          child: Column(
            children: [
              GlassTopBar(
                title: s.untangled,
                trailing: const StatusPill(label: 'Working', icon: Icons.auto_awesome_rounded),
              ),
              Expanded(
                child: result.when(
                  loading: () => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: context.stage.accent, strokeWidth: 2),
                        const SizedBox(height: 16),
                        Text('Sorting the story from the facts…', style: t.bodyMedium?.copyWith(color: surface.ink2)),
                      ],
                    ),
                  ),
                  error: (e, _) => Center(child: Text('Could not untangle: $e')),
                  data: (u) => ListView(
                    padding: const EdgeInsets.fromLTRB(24, 6, 24, 40),
                    children: [
                      Text(s.simpleVersion, style: t.headlineMedium?.copyWith(fontSize: 26)),
                      const SizedBox(height: 6),
                      Text(s.untangleSub, style: t.bodySmall?.copyWith(fontSize: 15, color: surface.ink2)),
                      const SizedBox(height: 16),
                      _Grid(children: [
                        TintPanel(label: s.whatHappened, color: surface.ink2, child: Text(u.happened)),
                        TintPanel(label: s.whatIAssumed, color: surface.gold, child: Text(u.assumed)),
                        TintPanel(label: s.whatIFelt, color: dark ? Palette.roseDark : Palette.rose, child: Text(u.felt)),
                        TintPanel(label: s.whatINeed, color: dark ? Palette.sageDark : Palette.sage, child: Text(u.need)),
                      ]),
                      const SizedBox(height: 16),
                      GlassPanel(
                        strong: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Eyebrow(s.oneSentence),
                            const SizedBox(height: 8),
                            Text(u.sentence, style: t.bodyLarge?.copyWith(fontSize: 18, fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: GlassButton(
                              label: s.sendTo(app.partnerOrDefault),
                              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Pairing arrives in the couple-layer build.')),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 4,
                            child: GlassButton(label: s.save, primary: false, onPressed: () => context.pop()),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Center(child: Text(s.notRight, style: t.bodySmall?.copyWith(fontSize: 13, color: surface.ink2))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Two-column grid where each row's cells share a height.
class _Grid extends StatelessWidget {
  const _Grid({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += 2) {
      rows.add(IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: children[i]),
            const SizedBox(width: 10),
            Expanded(child: i + 1 < children.length ? children[i + 1] : const SizedBox()),
          ],
        ),
      ));
      if (i + 2 < children.length) rows.add(const SizedBox(height: 10));
    }
    return Column(children: rows);
  }
}
