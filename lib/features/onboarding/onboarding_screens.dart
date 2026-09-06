import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_state.dart';
import '../../core/strings.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../../ui/atmosphere.dart';
import '../../ui/glass.dart';

/// Step 1 — welcome + language.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context, ref);
    final t = Theme.of(context).textTheme;
    final surface = context.surface;
    return StageTheme(
      stage: ResolutionStage.aware,
      child: Scaffold(
        body: Atmosphere(
          background: Backgrounds.welcome,
          veilOpacity: context.isDark ? 0.35 : 0.30,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(Icons.favorite_border_rounded, color: context.stage.accent, size: 26),
                      const SizedBox(width: 10),
                      Text(s.appName, style: t.headlineSmall),
                      const SizedBox(width: 10),
                      Text('साथ हमेशा', style: t.bodyLarge?.copyWith(color: surface.ink2)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(s.tagline, style: t.displayLarge),
                  const SizedBox(height: 14),
                  Text(s.taglineSub,
                      style: t.bodyLarge?.copyWith(color: surface.ink2, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 28),
                  GlassButton(
                    label: s.startEnglish,
                    onPressed: () async {
                      await ref.read(appStateProvider.notifier).setLanguage(AppLanguage.en);
                      if (context.mounted) context.push('/onboarding/names');
                    },
                  ),
                  const SizedBox(height: 10),
                  GlassButton(
                    label: s.startHindi,
                    primary: false,
                    onPressed: () async {
                      await ref.read(appStateProvider.notifier).setLanguage(AppLanguage.hi);
                      if (context.mounted) context.push('/onboarding/names');
                    },
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_outline_rounded, size: 14, color: Theme.of(context).colorScheme.secondary),
                        const SizedBox(width: 8),
                        Text(s.freePrivateOffline,
                            style: t.labelSmall?.copyWith(
                                letterSpacing: 0, fontSize: 12, color: Theme.of(context).colorScheme.secondary)),
                      ],
                    ),
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

/// Step 2 — names + relationship stage.
class NamesScreen extends ConsumerStatefulWidget {
  const NamesScreen({super.key});
  @override
  ConsumerState<NamesScreen> createState() => _NamesScreenState();
}

class _NamesScreenState extends ConsumerState<NamesScreen> {
  final _me = TextEditingController();
  final _partner = TextEditingController();
  RelationshipStage? _stage;

  @override
  void dispose() {
    _me.dispose();
    _partner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context, ref);
    final t = Theme.of(context).textTheme;
    final labels = {
      RelationshipStage.dating: 'Dating',
      RelationshipStage.engaged: 'Engaged',
      RelationshipStage.married: 'Married',
      RelationshipStage.longDistance: 'Long-distance',
      RelationshipStage.roughPatch: 'Rough patch',
    };
    final ready = _me.text.trim().isNotEmpty && _partner.text.trim().isNotEmpty && _stage != null;
    return StageTheme(
      stage: ResolutionStage.working,
      child: Scaffold(
        body: Atmosphere(
          background: Backgrounds.today,
          child: Column(
            children: [
              const GlassTopBar(title: 'Step 2 of 4'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  children: [
                    Text('Who are we talking about?', style: t.headlineMedium),
                    const SizedBox(height: 20),
                    GlassPanel(
                      strong: true,
                      child: Column(
                        children: [
                          _Field(controller: _me, label: s.yourName, onChanged: (_) => setState(() {})),
                          const SizedBox(height: 12),
                          _Field(controller: _partner, label: s.partnerName, onChanged: (_) => setState(() {})),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Eyebrow('Where are you two right now?'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final e in labels.entries)
                          GlassChip(
                            label: e.value,
                            active: _stage == e.key,
                            onTap: () => setState(() => _stage = e.key),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 44),
                child: GlassButton(
                  label: s.continueLabel,
                  onPressed: ready
                      ? () async {
                          final n = ref.read(appStateProvider.notifier);
                          await n.setNames(user: _me.text.trim(), partner: _partner.text.trim());
                          await n.setRelationshipStage(_stage!);
                          if (context.mounted) context.push('/onboarding/origin');
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.controller, required this.label, required this.onChanged});
  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final surface = context.surface;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textCapitalization: TextCapitalization.words,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: surface.ink2),
        filled: true,
        fillColor: surface.glassSoft,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: surface.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: surface.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.stage.accent),
        ),
      ),
    );
  }
}

/// Step 3 — Why We Started. The anchor for everything after.
class OriginStoryScreen extends ConsumerStatefulWidget {
  const OriginStoryScreen({super.key});
  @override
  ConsumerState<OriginStoryScreen> createState() => _OriginStoryScreenState();
}

class _OriginStoryScreenState extends ConsumerState<OriginStoryScreen> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context, ref);
    final app = ref.watch(appStateProvider);
    final t = Theme.of(context).textTheme;
    final surface = context.surface;
    final words = _c.text.trim().isEmpty ? 0 : _c.text.trim().split(RegExp(r'\s+')).length;
    return StageTheme(
      stage: ResolutionStage.calm,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Atmosphere(
          background: Backgrounds.origin,
          child: Column(
            children: [
              const GlassTopBar(title: 'Step 3 of 4'),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Eyebrow(s.whyWeStarted),
                    const SizedBox(height: 12),
                    Text(s.whyChoose(app.partnerOrDefault), style: t.headlineMedium),
                    const SizedBox(height: 12),
                    Text(s.originHint, style: t.bodyMedium?.copyWith(color: surface.ink2)),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
                  child: GlassPanel(
                    strong: true,
                    child: Column(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _c,
                            maxLines: null,
                            expands: true,
                            onChanged: (_) => setState(() {}),
                            textCapitalization: TextCapitalization.sentences,
                            style: t.bodyLarge?.copyWith(fontSize: 18, fontStyle: FontStyle.italic),
                            decoration: const InputDecoration.collapsed(hintText: ''),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Typed · $words words',
                                style: t.labelSmall?.copyWith(letterSpacing: 0, fontSize: 12, color: surface.ink2)),
                            const GlassChip(label: 'Say it instead', icon: Icons.mic_none_rounded, active: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 44),
                child: Column(
                  children: [
                    GlassButton(
                      label: s.keepThis,
                      onPressed: words == 0
                          ? null
                          : () async {
                              final n = ref.read(appStateProvider.notifier);
                              await n.setOriginStory(_c.text.trim());
                              await n.completeOnboarding();
                              if (context.mounted) context.go('/');
                            },
                    ),
                    const SizedBox(height: 10),
                    Text(s.originFooter,
                        textAlign: TextAlign.center,
                        style: t.bodySmall?.copyWith(fontSize: 13, color: surface.ink2)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
