import 'dart:async';

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

/// Repair Room, single-device rehearsal mode: until pairing ships, the
/// partner's side is typed on the same phone (handed over), which is also
/// how the feature will demo in the beta.
class RepairIntroScreen extends ConsumerStatefulWidget {
  const RepairIntroScreen({super.key});
  @override
  ConsumerState<RepairIntroScreen> createState() => _RepairIntroScreenState();
}

class _RepairIntroScreenState extends ConsumerState<RepairIntroScreen> {
  final _mine = TextEditingController();
  final _theirs = TextEditingController();
  int _step = 0; // 0 = my side, 1 = hand over, 2 = their side

  @override
  void dispose() {
    _mine.dispose();
    _theirs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context, ref);
    final app = ref.watch(appStateProvider);
    final t = Theme.of(context).textTheme;
    final surface = context.surface;
    final who = _step == 2 ? app.partnerOrDefault : (app.userName.isEmpty ? 'you' : app.userName);
    final ctrl = _step == 2 ? _theirs : _mine;

    return StageTheme(
      stage: ResolutionStage.working,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Atmosphere(
          background: Backgrounds.working,
          child: Column(
            children: [
              GlassTopBar(title: s.repairRoom),
              Expanded(
                child: _step == 1
                    ? _Handover(partner: app.partnerOrDefault, onReady: () => setState(() => _step = 2))
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(24, 6, 24, 24),
                        children: [
                          Eyebrow(_step == 2 ? '${app.partnerOrDefault}’s side · private' : 'Your side · private'),
                          const SizedBox(height: 8),
                          Text('What happened, as $who saw it?', style: t.headlineMedium?.copyWith(fontSize: 26)),
                          const SizedBox(height: 8),
                          Text('Only Saath reads this. Your partner sees the neutral version, never your words.',
                              style: t.bodySmall?.copyWith(fontSize: 15, color: surface.ink2)),
                          const SizedBox(height: 18),
                          GlassPanel(
                            strong: true,
                            child: TextField(
                              controller: ctrl,
                              minLines: 6,
                              maxLines: 12,
                              textCapitalization: TextCapitalization.sentences,
                              style: t.bodyLarge,
                              decoration: const InputDecoration.collapsed(hintText: 'Start anywhere…'),
                            ),
                          ),
                        ],
                      ),
              ),
              if (_step != 1)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 44),
                  child: GlassButton(
                    label: _step == 0 ? 'Submit my side' : 'Both sides in — merge',
                    onPressed: () {
                      if (_step == 0) {
                        setState(() => _step = 1);
                      } else {
                        context.pushReplacement('/repair/merged',
                            extra: (a: _mine.text.trim(), b: _theirs.text.trim()));
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Handover extends StatelessWidget {
  const _Handover({required this.partner, required this.onReady});
  final String partner;
  final VoidCallback onReady;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 44),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline_rounded, size: 36, color: context.stage.accent),
          const SizedBox(height: 18),
          Text('Your side is sealed.', style: t.headlineMedium),
          const SizedBox(height: 10),
          Text('Hand the phone to $partner. They will not see what you wrote.',
              style: t.bodyLarge?.copyWith(color: context.surface.ink2)),
          const Spacer(),
          GlassButton(label: 'I am $partner', onPressed: onReady),
        ],
      ),
    );
  }
}

final _mergeProvider = FutureProvider.autoDispose.family<RepairMerge, ({String a, String b})>((ref, sides) {
  final a = ref.read(appStateProvider);
  return ref.read(counsellorEngineProvider).mergeRepair(
        sides.a,
        sides.b,
        CounsellorContext(
          userName: a.userName,
          partnerName: a.partnerName,
          originStory: a.originStory,
          hindi: a.language == AppLanguage.hi,
        ),
      );
});

class RepairMergedScreen extends ConsumerStatefulWidget {
  const RepairMergedScreen({super.key, required this.sides});
  final ({String a, String b}) sides;
  @override
  ConsumerState<RepairMergedScreen> createState() => _RepairMergedScreenState();
}

class _RepairMergedScreenState extends ConsumerState<RepairMergedScreen> {
  static const _turnLength = Duration(minutes: 2);
  int _turn = 0;
  Duration _left = _turnLength;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTurn() {
    _timer?.cancel();
    setState(() => _left = _turnLength);
    _timer = Timer.periodic(const Duration(seconds: 1), (tm) {
      if (_left.inSeconds <= 1) {
        tm.cancel();
        setState(() {
          _left = Duration.zero;
          _turn = _turn + 1 > 4 ? 4 : _turn + 1;
        });
        if (_turn >= 4 && mounted) context.pushReplacement('/repair/close');
      } else {
        setState(() => _left -= const Duration(seconds: 1));
      }
    });
  }

  String _mmss(Duration d) =>
      '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final s = S.of(context, ref);
    final app = ref.watch(appStateProvider);
    final merge = ref.watch(_mergeProvider(widget.sides));
    final t = Theme.of(context).textTheme;
    final surface = context.surface;
    final dark = context.isDark;
    final me = app.userName.isEmpty ? 'You' : app.userName;
    final p = app.partnerOrDefault;
    final speakers = [(p, me), (me, p), (p, me), (me, p)];
    final ti = _turn > 3 ? 3 : _turn;

    return StageTheme(
      stage: ResolutionStage.working,
      child: Scaffold(
        body: Atmosphere(
          background: Backgrounds.working,
          child: Column(
            children: [
              GlassTopBar(
                title: s.repairRoom,
                trailing: Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 18, color: surface.ink2),
                    const SizedBox(width: 6),
                    Text(_mmss(_left), style: t.labelLarge?.copyWith(fontSize: 13, color: surface.ink2)),
                  ],
                ),
              ),
              Expanded(
                child: merge.when(
                  loading: () => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: context.stage.accent, strokeWidth: 2),
                        const SizedBox(height: 16),
                        Text('Finding the shared facts…', style: t.bodyMedium?.copyWith(color: surface.ink2)),
                      ],
                    ),
                  ),
                  error: (e, _) => Center(child: Text('Could not merge: $e')),
                  data: (m) => ListView(
                    padding: const EdgeInsets.fromLTRB(24, 6, 24, 40),
                    children: [
                      Eyebrow(s.bothSidesIn),
                      const SizedBox(height: 6),
                      Text(m.title, style: t.headlineMedium?.copyWith(fontSize: 26)),
                      const SizedBox(height: 16),
                      TintPanel(label: s.youBothAgree, color: dark ? Palette.sageDark : Palette.sage, child: Text(m.agreed)),
                      const SizedBox(height: 10),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: TintPanel(label: '$me heard', color: surface.ink2, child: Text(m.sideA.replaceFirst('$me heard: ', '')))),
                            const SizedBox(width: 10),
                            Expanded(child: TintPanel(label: '$p said', color: surface.ink2, child: Text(m.sideB.replaceFirst('$p said: ', '')))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      TintPanel(label: s.storiesSplit, color: surface.gold, child: Text(m.split)),
                      const SizedBox(height: 16),
                      GlassPanel(
                        strong: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Eyebrow('Turn ${_turn + 1} of 4 · ${speakers[ti].$1} speaks, ${speakers[ti].$2} listens'),
                            const SizedBox(height: 8),
                            Text(_turn == 0 ? m.firstTurn
                                : '${speakers[ti].$2}, repeat back what you heard, without defending. Then say one thing you need.',
                                style: t.bodyMedium),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(flex: 6, child: GlassButton(label: _timer?.isActive == true ? 'Turn running' : s.startTurn, onPressed: _timer?.isActive == true ? null : _startTurn)),
                          const SizedBox(width: 10),
                          Expanded(flex: 4, child: GlassButton(label: s.coolDown, primary: false, icon: Icons.timer_outlined, onPressed: () => context.push('/repair/cooldown'))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () => context.pushReplacement('/repair/close'),
                          child: Text('Skip to closing (dev)', style: t.bodySmall?.copyWith(color: surface.ink2)),
                        ),
                      ),
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

class CoolDownScreen extends StatefulWidget {
  const CoolDownScreen({super.key});
  @override
  State<CoolDownScreen> createState() => _CoolDownScreenState();
}

class _CoolDownScreenState extends State<CoolDownScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _breath =
      AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat(reverse: true);
  Duration _left = const Duration(minutes: 20);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_left.inSeconds > 0) setState(() => _left -= const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final mm = _left.inMinutes.toString().padLeft(2, '0');
    final ss = (_left.inSeconds % 60).toString().padLeft(2, '0');
    return StageTheme(
      stage: ResolutionStage.calm,
      child: Scaffold(
        body: Atmosphere(
          background: Backgrounds.calm,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
              child: Column(
                children: [
                  const Spacer(),
                  AnimatedBuilder(
                    animation: _breath,
                    builder: (context, _) {
                      final v = Curves.easeInOut.transform(_breath.value);
                      return Container(
                        width: 160 + 80 * v,
                        height: 160 + 80 * v,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.stage.accent.withOpacity(0.10 + 0.10 * v),
                          border: Border.all(color: context.stage.accent.withOpacity(0.4)),
                        ),
                        alignment: Alignment.center,
                        child: Text(v < 0.5 ? 'breathe in' : 'breathe out',
                            style: t.labelLarge?.copyWith(color: context.stage.accent)),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Text('$mm:$ss', style: t.displayLarge?.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
                  const SizedBox(height: 8),
                  Text('Twenty minutes is how long a flooded nervous system takes to settle. The room will still be here.',
                      textAlign: TextAlign.center, style: t.bodyMedium?.copyWith(color: context.surface.ink2)),
                  const Spacer(),
                  GlassButton(label: 'Back to the room', primary: false, onPressed: () => context.pop()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RepairCloseScreen extends ConsumerWidget {
  const RepairCloseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context, ref);
    final app = ref.watch(appStateProvider);
    final t = Theme.of(context).textTheme;
    final surface = context.surface;
    return StageTheme(
      stage: ResolutionStage.calm,
      child: Scaffold(
        body: Atmosphere(
          background: Backgrounds.calm,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.stage.accentSoft,
                      border: Border.all(color: context.stage.accent.withOpacity(0.35)),
                    ),
                    child: Icon(Icons.check_rounded, color: context.stage.accent, size: 26),
                  ),
                  const SizedBox(height: 18),
                  const Eyebrow('Repaired'),
                  const SizedBox(height: 10),
                  Text('You both stayed. That is the whole thing.', style: t.headlineMedium?.copyWith(fontSize: 30)),
                  const SizedBox(height: 12),
                  Text('The fight was never the point. Feeling alone in it was. You said that out loud tonight — and you were heard.',
                      style: t.bodyLarge?.copyWith(color: surface.ink2)),
                  const SizedBox(height: 18),
                  GlassPanel(
                    strong: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Eyebrow('${s.whyWeStarted} · in your words'),
                        const SizedBox(height: 8),
                        Text(
                          app.originStory.isEmpty ? 'You have not written yours yet.' : '“${app.originStory}”',
                          style: t.bodyLarge?.copyWith(fontSize: 18, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GlassButton(label: s.closeRoom, onPressed: () => context.go('/')),
                  const SizedBox(height: 10),
                  GlassButton(label: s.planSmallThing, primary: false, onPressed: () => context.go('/us')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
