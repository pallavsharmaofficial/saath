import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/router.dart';
import '../../core/app_state.dart';
import '../../core/journal.dart';
import '../../core/strings.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../../ui/atmosphere.dart';
import '../../ui/glass.dart';

/// Everything the user chose to keep. Local only — this screen exists because
/// Untangle's "Save" button had nowhere to save to.
class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context, ref);
    final app = ref.watch(appStateProvider);
    final entries = ref.watch(journalProvider);
    final counts = ref.read(journalProvider.notifier).themeCounts();
    final t = Theme.of(context).textTheme;
    final surface = context.surface;
    final format = DateFormat('d MMM, h:mm a', app.language.code);

    return StageTheme(
      stage: ResolutionStage.calm,
      child: Scaffold(
        body: Atmosphere(
          background: Backgrounds.origin,
          child: Column(
            children: [
              GlassTopBar(
                title: s.journal,
                onBack: () => context.pop(),
                trailing: StatusPill(
                    label: s.onThisPhoneOnly, icon: Icons.lock_outline_rounded),
              ),
              Expanded(
                child: entries.isEmpty
                    ? _Empty(s: s)
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(24, 6, 24, 40),
                        children: [
                          Text(s.journalSub,
                              style: t.bodySmall?.copyWith(
                                  fontSize: 15, color: surface.ink2)),
                          if (counts.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final e in counts.entries)
                                  GlassChip(
                                      label:
                                          '${themeLabel(s, e.key)} · ${e.value}'),
                              ],
                            ),
                          ],
                          const SizedBox(height: 16),
                          for (final entry in entries) ...[
                            _EntryCard(
                                entry: entry,
                                s: s,
                                when: format.format(entry.createdAt)),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String themeLabel(S s, JournalTheme theme) => switch (theme) {
        JournalTheme.money => s.isHindi ? 'पैसा' : 'Money',
        JournalTheme.family => s.isHindi ? 'परिवार' : 'Family',
        JournalTheme.intimacy => s.isHindi ? 'नज़दीकी' : 'Intimacy',
        JournalTheme.time => s.isHindi ? 'वक़्त' : 'Time',
        JournalTheme.trust => s.isHindi ? 'भरोसा' : 'Trust',
      };
}

class _Empty extends StatelessWidget {
  const _Empty({required this.s});

  final S s;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_stories_outlined,
                size: 36, color: context.surface.ink2),
            const SizedBox(height: 16),
            Text(s.journalEmpty,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 20),
            GlassButton(
              label: s.talkToSaath,
              expand: false,
              onPressed: () => context.go(Routes.counsellor),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryCard extends ConsumerWidget {
  const _EntryCard({required this.entry, required this.s, required this.when});

  final JournalEntry entry;
  final S s;
  final String when;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final surface = context.surface;

    return GlassPanel(
      strong: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Eyebrow(when, color: surface.ink2)),
              IconButton(
                tooltip: s.deleteEntry,
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.close_rounded, size: 18, color: surface.ink2),
                onPressed: () async {
                  await ref.read(journalProvider.notifier).remove(entry.id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(s.entryDeleted)));
                },
              ),
            ],
          ),
          Text(entry.title, style: t.titleMedium),
          if (entry.body.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(entry.body, style: t.bodySmall?.copyWith(fontSize: 15)),
          ],
          if (entry.ask.isNotEmpty) ...[
            const SizedBox(height: 12),
            TintPanel(
              label: s.oneSentence,
              color: context.stage.accent,
              child: Text(entry.ask),
            ),
          ],
          if (entry.themes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final theme in entry.themes)
                  GlassChip(label: JournalScreen.themeLabel(s, theme)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
