import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One message in a counsellor conversation.
class ChatMessage {
  const ChatMessage({required this.fromUser, required this.text});
  final bool fromUser;
  final String text;
}

/// Result of the Untangle feature: a vent sorted into four columns plus one
/// sentence the user could actually say.
class Untangled {
  const Untangled({
    required this.happened,
    required this.assumed,
    required this.felt,
    required this.need,
    required this.sentence,
  });
  final String happened;
  final String assumed;
  final String felt;
  final String need;
  final String sentence;
}

/// Neutral merge of two private accounts of the same incident.
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
  final String sideA;
  final String sideB;
  final String split;
  final String firstTurn;
}

/// Context the engine gets on every call. The origin story is what keeps
/// advice anchored to why the couple started.
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
}

/// The AI layer sits behind this one interface so the on-device Gemma
/// engine (and later an optional cloud engine) are implementations, not
/// rewrites. The UI never knows which one is answering.
abstract class CounsellorEngine {
  /// Streams the reply token by token.
  Stream<String> reply(List<ChatMessage> history, CounsellorContext ctx);

  Future<Untangled> untangle(String vent, CounsellorContext ctx);

  Future<RepairMerge> mergeRepair(String sideA, String sideB, CounsellorContext ctx);

  /// Returns true when the input suggests coercion, abuse or self-harm and
  /// the safety interrupt should show instead of a normal reply.
  bool needsSafetyInterrupt(String input);
}

/// Scripted engine for simulator testing. Replies are deliberately in the
/// counsellor's voice so the UI can be judged on feel, not just layout.
class MockCounsellorEngine implements CounsellorEngine {
  static const _safetyWords = [
    'hit me', 'hits me', 'afraid of him', 'afraid of her', 'scared of him', 'scared of her',
    'won\'t let me', 'wont let me', 'not allowed to', 'threatens', 'threatened me',
    'hurt myself', 'kill myself', 'end it all', 'मारता है', 'डर लगता है', 'जान दे',
  ];

  @override
  bool needsSafetyInterrupt(String input) {
    final t = input.toLowerCase();
    return _safetyWords.any(t.contains);
  }

  @override
  Stream<String> reply(List<ChatMessage> history, CounsellorContext ctx) async* {
    final turn = history.where((m) => m.fromUser).length;
    final p = ctx.partnerName.isEmpty ? 'your partner' : ctx.partnerName;
    final text = switch (turn) {
      1 => ctx.hindi
          ? '"जो करना है करो" शायद ही कभी इजाज़त होती है। इसका मतलब अक्सर होता है — मैंने सुने जाने की कोशिश छोड़ दी। और अगर यह कल भी हुआ था, तो यह झगड़ा नहीं, एक पैटर्न है।'
          : '“Do whatever you want” is rarely permission. It usually means *I gave up trying to be heard*. And if it happened yesterday too, that is a pattern, not a fight.',
      2 => ctx.hindi
          ? 'आगे बढ़ने से पहले: जब $p कमरे में चली गईं, पहले दो मिनट में आपने क्या किया?'
          : 'Before we go further: when $p walked away, what did you do in the first two minutes?',
      3 => ctx.hindi
          ? 'यह पूरी तरह समझ में आता है। यह दो लोग हैं जो दोनों "मुझे देखो" कह रहे हैं, ऐसे तरीकों से जो दूसरे को अनदेखा महसूस कराते हैं। चाहें तो मैं इसे सुलझा दूँ?'
          : 'That makes complete sense. That is two people both saying “notice me” in ways that make the other feel unnoticed. Want me to untangle this into what happened versus what you each assumed?',
      _ => ctx.hindi
          ? 'याद रखिए आपने शुरुआत क्यों की थी — ${ctx.originStory.isEmpty ? 'वह वजह अभी भी वहीं है।' : '"${ctx.originStory}"'} इसी से आज की बात को जोड़ते हैं।'
          : 'Remember why you started — ${ctx.originStory.isEmpty ? 'that reason is still there.' : '“${ctx.originStory}”'} Let us connect tonight back to that.',
    };
    final words = text.split(' ');
    for (final w in words) {
      await Future<void>.delayed(const Duration(milliseconds: 45));
      yield '$w ';
    }
  }

  @override
  Future<Untangled> untangle(String vent, CounsellorContext ctx) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final p = ctx.partnerName.isEmpty ? 'your partner' : ctx.partnerName;
    return Untangled(
      happened: 'You raised something while $p was busy. $p said “do whatever you want” and left the room.',
      assumed: 'That $p does not care about your time together.',
      felt: 'Dismissed. Then angry, to cover the dismissed part.',
      need: 'To know it matters to $p too.',
      sentence: '“I asked at a bad moment. I wasn’t trying to push — I just want this to be ours. Can we pick a time tonight?”',
    );
  }

  @override
  Future<RepairMerge> mergeRepair(String sideA, String sideB, CounsellorContext ctx) async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    final me = ctx.userName.isEmpty ? 'You' : ctx.userName;
    final p = ctx.partnerName.isEmpty ? 'Partner' : ctx.partnerName;
    return RepairMerge(
      title: 'Thursday night, the dishes',
      agreed: 'It was late. You were both tired. The dishes were not really about the dishes.',
      sideA: '$me heard: “You never help.”',
      sideB: '$p said: “I’m exhausted and I feel alone in this.”',
      split: 'One of you was talking about tonight. The other was talking about the last three months.',
      firstTurn: '$me, your only job for two minutes: repeat back what you heard, without defending. Start with “What I’m hearing is…”',
    );
  }
}

/// Swap this provider's value for the Gemma engine once the model spike is
/// done: `counsellorEngineProvider.overrideWithValue(GemmaCounsellorEngine())`.
final counsellorEngineProvider = Provider<CounsellorEngine>((_) => MockCounsellorEngine());
