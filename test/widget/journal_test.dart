import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saath_hamesha/core/journal.dart';

import '../support/harness.dart';

void main() {
  testWidgets(
      'an empty journal explains itself instead of showing a blank list',
      (tester) async {
    usePhoneSurface(tester);
    final app = await pumpApp(tester, seed: onboardedSeed());

    app.push('/journal');
    await tester.pumpAndSettle();

    expect(find.textContaining('Nothing saved yet'), findsOneWidget);
  });

  testWidgets('shows saved entries with their ask and themes', (tester) async {
    usePhoneSurface(tester);
    final app = await pumpApp(tester, seed: onboardedSeed());
    await app.container.read(journalProvider.notifier).add(
      kind: JournalKind.untangle,
      title: 'He walked out of the room',
      body: 'What I need: to know it matters',
      ask: 'Can we pick a time tonight?',
      themes: [JournalTheme.time, JournalTheme.trust],
    );

    app.push('/journal');
    await tester.pumpAndSettle();

    expect(find.text('He walked out of the room'), findsOneWidget);
    expect(find.text('Can we pick a time tonight?'), findsOneWidget);
    expect(find.text('Time · 1'), findsOneWidget);
    expect(find.text('Trust · 1'), findsOneWidget);
  });

  testWidgets('deleting an entry removes it from screen and from disk',
      (tester) async {
    usePhoneSurface(tester);
    final app = await pumpApp(tester, seed: onboardedSeed());
    await app.container
        .read(journalProvider.notifier)
        .add(kind: JournalKind.untangle, title: 'the dishes', body: '');

    app.push('/journal');
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(app.container.read(journalProvider), isEmpty);
    expect(JournalStore.load(app.store), isEmpty);
    expect(find.textContaining('Nothing saved yet'), findsOneWidget);
  });

  testWidgets('themes can be corrected by the person who lived it',
      (tester) async {
    usePhoneSurface(tester);
    final app = await pumpApp(tester, seed: onboardedSeed());
    await app.container.read(journalProvider.notifier).add(
      kind: JournalKind.untangle,
      title: 'the dishes',
      body: 'b',
      // What the keyword pass guessed.
      themes: [JournalTheme.time],
    );

    app.push('/journal');
    await tester.pumpAndSettle();

    await tapVisible(tester, find.text('Trust'));

    final themes = app.container.read(journalProvider).single.themes;
    expect(themes, containsAll([JournalTheme.time, JournalTheme.trust]));
    expect(JournalStore.load(app.store).single.themes, hasLength(2));
  });

  testWidgets('a reflection is generated on request and kept', (tester) async {
    usePhoneSurface(tester);
    final app = await pumpApp(tester, seed: onboardedSeed());
    await app.container.read(journalProvider.notifier).add(
          kind: JournalKind.untangle,
          title: 'the dishes',
          body: 'What I need: to know it matters',
          ask: 'Can we pick a time tonight?',
          at: DateTime.now().subtract(const Duration(days: 9)),
        );

    app.push('/journal');
    await tester.pumpAndSettle();

    // Not generated at save time: the value is in the distance.
    await tapVisible(tester, find.text('What does this look like now?'));

    final entry = app.container.read(journalProvider).single;
    expect(entry.reflection, isNotEmpty);
    expect(entry.reflection, contains('A week ago'));
    expect(JournalStore.load(app.store).single.reflection, isNotEmpty);
  });

  testWidgets('reachable from Today once something is saved', (tester) async {
    usePhoneSurface(tester);
    final app = await pumpApp(tester, seed: onboardedSeed());

    await tapVisible(tester, find.byIcon(Icons.auto_stories_outlined));
    expect(app.location, '/journal');
  });
}
