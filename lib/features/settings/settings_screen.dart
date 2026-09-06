import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_state.dart';
import '../../core/strings.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../../ui/atmosphere.dart';
import '../../ui/glass.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context, ref);
    final app = ref.watch(appStateProvider);
    final n = ref.read(appStateProvider.notifier);
    final t = Theme.of(context).textTheme;
    final surface = context.surface;

    return StageTheme(
      stage: ResolutionStage.calm,
      child: Scaffold(
        body: Atmosphere(
          background: Backgrounds.today,
          child: Column(
            children: [
              GlassTopBar(title: s.settings),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 6, 24, 40),
                  children: [
                    GlassPanel(
                      strong: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Eyebrow(s.language),
                          const SizedBox(height: 10),
                          Wrap(spacing: 8, children: [
                            GlassChip(label: 'English', active: app.language == AppLanguage.en, onTap: () => n.setLanguage(AppLanguage.en)),
                            GlassChip(label: 'हिंदी', active: app.language == AppLanguage.hi, onTap: () => n.setLanguage(AppLanguage.hi)),
                          ]),
                          const SizedBox(height: 18),
                          Eyebrow(s.theme),
                          const SizedBox(height: 10),
                          Wrap(spacing: 8, children: [
                            GlassChip(label: 'System', active: app.themeMode == ThemeMode.system, onTap: () => n.setThemeMode(ThemeMode.system)),
                            GlassChip(label: 'Light', active: app.themeMode == ThemeMode.light, onTap: () => n.setThemeMode(ThemeMode.light)),
                            GlassChip(label: 'Dark', active: app.themeMode == ThemeMode.dark, onTap: () => n.setThemeMode(ThemeMode.dark)),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    GlassPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Eyebrow('Privacy'),
                          const SizedBox(height: 8),
                          Text('Everything — the counsellor, your journal, your origin story — stays on this phone. Nothing is sent anywhere unless you pair with a partner, and even then only encrypted.',
                              style: t.bodySmall?.copyWith(fontSize: 15)),
                          const SizedBox(height: 12),
                          Row(children: [
                            Expanded(child: GlassButton(label: 'Export data', primary: false, onPressed: () {})),
                            const SizedBox(width: 10),
                            Expanded(child: GlassButton(label: 'Delete everything', primary: false, onPressed: () async {
                              await n.reset();
                              if (context.mounted) context.go('/onboarding');
                            })),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    GlassPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Eyebrow('Counsellor model'),
                          const SizedBox(height: 8),
                          Text('Scripted preview engine (simulator build). Gemma 3n runs here once the on-device spike lands.',
                              style: t.bodySmall?.copyWith(fontSize: 15, color: surface.ink2)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(child: Text('Saath Hamesha 0.1.0 · not a substitute for a licensed therapist',
                        textAlign: TextAlign.center, style: t.bodySmall?.copyWith(fontSize: 12, color: surface.ink2))),
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
