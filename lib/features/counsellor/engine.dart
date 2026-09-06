import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/journal.dart';
import 'safety.dart';

/// One message in a counsellor conversation.
@immutable
class ChatMessage {
  const ChatMessage(
      {required this.fromUser, required this.text, this.failed = false});

  final bool fromUser;
  final String text;

  /// True when generation stopped before the reply was finished, so the UI can
  /// offer a retry instead of leaving a half-sentence on screen.
  final bool failed;

  ChatMessage copyWith({String? text, bool? failed}) => ChatMessage(
      fromUser: fromUser,
      text: text ?? this.text,
      failed: failed ?? this.failed);
}

/// Result of the Untangle feature: a vent sorted into four columns plus one
/// sentence the user could actually say.
@immutable
class Untangled {
  const Untangled({
    required this.happened,
    required this.assumed,
    required this.felt,
    required this.need,
    required this.sentence,
    this.themes = const [],
  });

  final String happened;
  final String assumed;
  final String felt;
  final String need;
  final String sentence;

  /// What the vent was about, for the journal's 30-day trends.
  final List<JournalTheme> themes;
}

/// The two private accounts that go into a Repair Room merge.
@immutable
class RepairSides {
  const RepairSides(this.a, this.b);
  final String a;
  final String b;

  bool get isComplete => a.trim().length >= 10 && b.trim().length >= 10;

  @override
  bool operator ==(Object other) =>
      other is RepairSides && other.a == a && other.b == b;

  @override
  int get hashCode => Object.hash(a, b);
}

/// Neutral merge of two private accounts of the same incident.
@immutable
class RepairMerge {
  const RepairMerge({
    required this.title,
    required this.agreed,
    required this.sideA,
    required this.sideB,
    required this.split,
    required this.firstTurn,
  });

  final String title;
  final String agreed;

  /// What each side heard/said, already neutralised. Neither contains the
  /// other person's raw words — that is the whole promise of the room.
  final String sideA;
  final String sideB;
  final String split;
  final String firstTurn;
}

/// Context the engine gets on every call. The origin story is what keeps
/// advice anchored to why the couple started.
@immutable
class CounsellorContext {
  const CounsellorContext({
    required this.userName,
    required this.partnerName,
    required this.originStory,
    required this.hindi,
  });

  final String userName;
  final String partnerName;
  final String originStory;
  final bool hindi;

  String get partnerOrDefault => partnerName.trim().isEmpty
      ? (hindi ? 'आपका साथी' : 'your partner')
      : partnerName.trim();

  String get userOrDefault =>
      userName.trim().isEmpty ? (hindi ? 'आप' : 'You') : userName.trim();
}

/// Thrown when the engine cannot produce a result. The UI turns this into a
/// retry, never into a stack trace.
class CounsellorException implements Exception {
  const CounsellorException(this.message);
  final String message;

  @override
  String toString() => 'CounsellorException: $message';
}

/// The AI layer sits behind this one interface so the on-device Gemma
/// engine (and later an optional cloud engine) are implementations, not
/// rewrites. The UI never knows which one is answering.
abstract class CounsellorEngine {
  /// Streams the reply token by token. Cancelling the subscription must stop
  /// generation — the Gemma implementation has to honour that too, or "Stop"
  /// will keep burning battery after the user has moved on.
  Stream<String> reply(List<ChatMessage> history, CounsellorContext ctx);

  Future<Untangled> untangle(String vent, CounsellorContext ctx);

  Future<RepairMerge> mergeRepair(RepairSides sides, CounsellorContext ctx);

  /// True when the input suggests coercion, abuse or self-harm and the safety
  /// interrupt should show instead of a normal reply.
  ///
  /// This runs *before* any generation, on every entry point. It is not the
  /// model's judgement — a guardrail the model cannot talk its way past.
  bool needsSafetyInterrupt(String input) => safetyClassifier.fires(input);

  /// Whether a real model is loaded. False for the preview engine, which
  /// Settings surfaces rather than implying an AI is answering.
  bool get isPreview => false;
}

/// Scripted engine for simulator and device testing. Replies are deliberately
/// in the counsellor's voice so the UI can be judged on feel, not just layout.
///
/// Replaced wholesale by the Gemma engine after the model spike; nothing above
/// this line changes when that happens.
class MockCounsellorEngine implements CounsellorEngine {
  const MockCounsellorEngine(
      {this.tokenDelay = const Duration(milliseconds: 45)});

  /// Zero in tests, so a widget test does not spend four seconds streaming.
  final Duration tokenDelay;

  @override
  bool get isPreview => true;

  @override
  bool needsSafetyInterrupt(String input) => safetyClassifier.fires(input);

  @override
  Stream<String> reply(
      List<ChatMessage> history, CounsellorContext ctx) async* {
    final turn = history.where((m) => m.fromUser).length;
    final p = ctx.partnerOrDefault;
    final text = switch (turn) {
      0 || 1 => ctx.hindi
          ? '"जो करना है करो" शायद ही कभी इजाज़त होती है। इसका मतलब अक्सर होता है — मैंने सुने जाने की कोशिश छोड़ दी। और अगर यह कल भी हुआ था, तो यह झगड़ा नहीं, एक पैटर्न है।'
          : '“Do whatever you want” is rarely permission. It usually means I gave up trying to be heard. And if it happened yesterday too, that is a pattern, not a fight.',
      2 => ctx.hindi
          ? 'आगे बढ़ने से पहले: जब $p कमरे से चले गए, पहले दो मिनट में आपने क्या किया?'
          : 'Before we go further: when $p walked away, what did you do in the first two minutes?',
      3 => ctx.hindi
          ? 'यह पूरी तरह समझ में आता है। यह दो लोग हैं जो दोनों "मुझे देखो" कह रहे हैं, ऐसे तरीकों से जो दूसरे को अनदेखा महसूस कराते हैं। चाहें तो मैं इसे सुलझा दूँ?'
          : 'That makes complete sense. That is two people both saying “notice me” in ways that make the other feel unnoticed. Want me to untangle this into what happened versus what you each assumed?',
      _ => ctx.hindi
          ? 'याद रखिए आपने शुरुआत क्यों की थी — ${ctx.originStory.isEmpty ? 'वह वजह अभी भी वहीं है।' : '"${ctx.originStory}"'} इसी से आज की बात को जोड़ते हैं।'
          : 'Remember why you started — ${ctx.originStory.isEmpty ? 'that reason is still there.' : '“${ctx.originStory}”'} Let us connect tonight back to that.',
    };

    for (final word in text.split(' ')) {
      if (tokenDelay > Duration.zero) await Future<void>.delayed(tokenDelay);
      yield '$word ';
    }
  }

  @override
  Future<Untangled> untangle(String vent, CounsellorContext ctx) async {
    if (vent.trim().isEmpty) {
      throw const CounsellorException('nothing to untangle');
    }
    await Future<void>.delayed(tokenDelay * 20);
    final p = ctx.partnerOrDefault;
    // Scripted in both languages. A Hindi tester seeing Hindi chrome wrapped
    // around English content is not testing the Hindi experience.
    if (ctx.hindi) {
      return Untangled(
        happened:
            'आपने कुछ कहना चाहा जब $p व्यस्त थे। $p ने कहा "जो करना है करो" और कमरे से चले गए।',
        assumed: 'कि $p को आपके साथ बिताए वक़्त की परवाह नहीं।',
        felt: 'अनदेखा। फिर गुस्सा — उस अनदेखेपन को ढँकने के लिए।',
        need: 'यह जानना कि $p के लिए भी यह मायने रखता है।',
        sentence:
            '"मैंने ग़लत वक़्त पर कहा। मैं ज़बरदस्ती नहीं कर रहा था — बस चाहता हूँ कि यह हम दोनों का हो। आज रात कोई वक़्त तय कर लें?"',
        themes: inferThemes(vent),
      );
    }
    return Untangled(
      happened:
          'You raised something while $p was busy. $p said “do whatever you want” and left the room.',
      assumed: 'That $p does not care about your time together.',
      felt: 'Dismissed. Then angry, to cover the dismissed part.',
      need: 'To know it matters to $p too.',
      sentence:
          '“I asked at a bad moment. I wasn’t trying to push — I just want this to be ours. Can we pick a time tonight?”',
      themes: inferThemes(vent),
    );
  }

  @override
  Future<RepairMerge> mergeRepair(
      RepairSides sides, CounsellorContext ctx) async {
    if (!sides.isComplete) {
      throw const CounsellorException('both sides are needed');
    }
    await Future<void>.delayed(tokenDelay * 26);
    final me = ctx.userOrDefault;
    final p = ctx.partnerOrDefault;
    if (ctx.hindi) {
      return RepairMerge(
        title: 'गुरुवार की रात, बर्तन',
        agreed:
            'देर हो चुकी थी। आप दोनों थके हुए थे। बात असल में बर्तनों की थी ही नहीं।',
        sideA: 'तुम कभी मदद नहीं करते।',
        sideB: 'मैं थक चुका हूँ और इसमें ख़ुद को अकेला महसूस करता हूँ।',
        split: 'एक आज रात की बात कर रहा था। दूसरा पिछले तीन महीनों की।',
        firstTurn:
            '$me, दो मिनट के लिए बस इतना: जो सुना वही दोहराइए, सफ़ाई दिए बिना। शुरू कीजिए — "मैं जो सुन रहा/रही हूँ वह यह है…" — फिर $p की बारी।',
      );
    }
    return RepairMerge(
      title: 'Thursday night, the dishes',
      agreed:
          'It was late. You were both tired. The dishes were not really about the dishes.',
      sideA: 'You never help.',
      sideB: 'I’m exhausted and I feel alone in this.',
      split:
          'One of you was talking about tonight. The other was talking about the last three months.',
      firstTurn:
          '$me, your only job for two minutes: repeat back what you heard, without defending. Start with “What I’m hearing is…” — $p goes second.',
    );
  }

  /// Cheap keyword pass so saved entries carry themes for the 30-day trend.
  /// The Gemma engine returns these in its JSON instead.
  @visibleForTesting
  static List<JournalTheme> inferThemes(String vent) {
    final t = vent.toLowerCase();
    bool any(List<String> words) => words.any(t.contains);
    return [
      if (any([
        'money',
        'salary',
        'kharcha',
        'खर्च',
        'पैसे',
        'paise',
        'rent',
        'emi'
      ]))
        JournalTheme.money,
      if (any([
        'mother',
        'father',
        'in-law',
        'inlaw',
        'saas',
        'sasural',
        'family',
        'माँ',
        'पिता',
        'सास',
        'ससुराल',
        'परिवार',
      ]))
        JournalTheme.family,
      if (any(['intimacy', 'sex', 'touch', 'affection', 'नज़दीक', 'प्यार']))
        JournalTheme.intimacy,
      if (any(
          ['time', 'busy', 'late', 'work', 'office', 'वक्त', 'व्यस्त', 'देर']))
        JournalTheme.time,
      if (any(
          ['lie', 'lied', 'trust', 'phone', 'secret', 'झूठ', 'भरोसा', 'छुपा']))
        JournalTheme.trust,
    ];
  }
}

/// Swap this provider's value for the Gemma engine once the model spike is
/// done: `counsellorEngineProvider.overrideWithValue(GemmaCounsellorEngine())`.
final counsellorEngineProvider =
    Provider<CounsellorEngine>((_) => const MockCounsellorEngine());
