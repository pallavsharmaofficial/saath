import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:saath_hamesha/core/app_state.dart';
import 'package:saath_hamesha/core/journal.dart';
import 'package:saath_hamesha/features/settings/export.dart';

void main() {
  test('the export is valid JSON containing everything the app holds', () {
    const app = AppState(
      language: AppLanguage.hi,
      onboarded: true,
      userName: 'Asha',
      partnerName: 'Vikram',
      relationshipStage: RelationshipStage.married,
      originStory: 'he stayed',
      pulses: [DailyPulse(day: '2026-09-01', connection: 4, word: 'warm')],
    );
    final journal = [
      JournalEntry(
        id: '1',
        createdAt: DateTime(2026, 9, 1, 21, 30),
        kind: JournalKind.untangle,
        title: 'the dishes',
        body: 'body',
        ask: 'can we pick a time?',
        themes: const [JournalTheme.time],
      ),
    ];

    final decoded = jsonDecode(buildExportJson(app: app, journal: journal))
        as Map<String, Object?>;

    expect(decoded['app'], 'Saath');
    expect(decoded['version'], isNotEmpty);
    expect(DateTime.tryParse(decoded['exportedAt']! as String), isNotNull);

    final profile = decoded['profile']! as Map<String, Object?>;
    expect(profile['userName'], 'Asha');
    expect(profile['partnerName'], 'Vikram');
    expect(profile['originStory'], 'he stayed');
    expect(profile['language'], 'hi');
    expect(profile['relationshipStage'], 'married');
    expect((profile['pulses']! as List).single,
        {'day': '2026-09-01', 'connection': 4, 'word': 'warm'});

    final entries = decoded['journal']! as List;
    expect(entries, hasLength(1));
    expect((entries.single as Map)['ask'], 'can we pick a time?');
    expect((entries.single as Map)['themes'], ['time']);
  });

  test('an empty install still produces valid, readable JSON', () {
    final decoded =
        jsonDecode(buildExportJson(app: const AppState(), journal: const []))
            as Map<String, Object?>;
    expect(decoded['journal'], isEmpty);
    expect((decoded['profile']! as Map)['userName'], '');
  });

  test('is indented, because a user is meant to be able to read it', () {
    expect(buildExportJson(app: const AppState(), journal: const []),
        contains('\n  '));
  });
}
