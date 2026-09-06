import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/strings.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../../ui/atmosphere.dart';
import '../../ui/glass.dart';

/// One evidence-based idea and the two-minute thing to do about it.
///
/// The full deck is 15 cards; these five are the ones written so far. The
/// header used to claim "5 of 15" as though ten more were behind a scroll —
/// it now counts what is actually here.
class LearnCard {
  const LearnCard({
    required this.title,
    required this.titleHi,
    required this.body,
    required this.bodyHi,
    required this.exercise,
    required this.exerciseHi,
  });

  final String title;
  final String titleHi;
  final String body;
  final String bodyHi;
  final String exercise;
  final String exerciseHi;

  String t(bool hindi) => hindi ? titleHi : title;
  String b(bool hindi) => hindi ? bodyHi : body;
  String e(bool hindi) => hindi ? exerciseHi : exercise;
}

const learnCards = <LearnCard>[
  LearnCard(
    title: 'The four horsemen',
    titleHi: 'चार घुड़सवार',
    body:
        'Criticism, contempt, defensiveness and stonewalling predict a breakup better than how often a couple fights. Contempt — eye-rolling, mocking — is the worst of the four.',
    bodyHi:
        'आलोचना, तिरस्कार, सफ़ाई देना और चुप्पी — ये चार चीज़ें रिश्ते के टूटने का अंदाज़ा इससे बेहतर देती हैं कि झगड़े कितने होते हैं। तिरस्कार — आँखें घुमाना, मज़ाक़ उड़ाना — सबसे ख़तरनाक है।',
    exercise:
        'Two minutes: name the horseman you reach for first. Just name it.',
    exerciseHi:
        'दो मिनट: सोचिए आप सबसे पहले किसका सहारा लेते हैं। बस नाम दे दीजिए।',
  ),
  LearnCard(
    title: 'Repair attempts',
    titleHi: 'सुलह की कोशिशें',
    body:
        'Happy couples fight too. The difference is a small move — a joke, a hand on the arm, “can we start over?” — that stops the escalation. Repair attempts fail when the other person doesn’t notice them.',
    bodyHi:
        'ख़ुश जोड़े भी झगड़ते हैं। फ़र्क़ एक छोटी-सी बात का होता है — एक मज़ाक़, कंधे पर हाथ, "फिर से शुरू करें?" — जो बात बढ़ने से रोक देती है। ये कोशिशें तब नाकाम होती हैं जब सामने वाला उन्हें पहचानता ही नहीं।',
    exercise:
        'Agree on one signal you will both recognise as “I’m trying to fix this.”',
    exerciseHi:
        'एक इशारा तय कीजिए जिसे आप दोनों समझें — "मैं इसे ठीक करना चाहता/चाहती हूँ।"',
  ),
  LearnCard(
    title: 'Bids for connection',
    titleHi: 'जुड़ाव की पुकार',
    body:
        '“Look at that bird.” It’s never about the bird. Turning toward small bids — even with a grunt — is what keeps a relationship alive between the big talks.',
    bodyHi:
        '"वो चिड़िया देखो।" बात कभी चिड़िया की नहीं होती। ऐसी छोटी पुकारों की तरफ़ मुड़ना — चाहे बस "हूँ" कहकर — यही रिश्ते को बड़ी बातचीतों के बीच ज़िंदा रखता है।',
    exercise: 'Tonight, count the bids. Turn toward three of them on purpose.',
    exerciseHi: 'आज रात ऐसी पुकारें गिनिए। तीन की तरफ़ जान-बूझकर मुड़िए।',
  ),
  LearnCard(
    title: 'Family boundaries, Indian edition',
    titleHi: 'परिवार की सीमाएँ, भारतीय संदर्भ',
    body:
        'In a joint family “my parents” and “our marriage” overlap by design. The couple has to be a team first, then negotiate with everyone else — not the other way round.',
    bodyHi:
        'संयुक्त परिवार में "मेरे माता-पिता" और "हमारी शादी" का घुलना-मिलना स्वाभाविक है। जोड़े को पहले एक टीम बनना होता है, फिर बाक़ी सबसे बात — उल्टा नहीं।',
    exercise: 'Write one sentence you would both say to a parent, together.',
    exerciseHi: 'एक वाक्य लिखिए जो आप दोनों मिलकर किसी बड़े से कहेंगे।',
  ),
  LearnCard(
    title: 'The flooded brain',
    titleHi: 'उबला हुआ दिमाग़',
    body:
        'Above ~100 bpm you can’t hear anyone. This is biology, not stubbornness. Twenty minutes apart, doing something boring, resets it.',
    bodyHi:
        'दिल की धड़कन 100 से ऊपर जाते ही आप किसी की सुन नहीं सकते। यह ज़िद नहीं, शरीर विज्ञान है। बीस मिनट अलग रहकर कोई नीरस काम करना इसे वापस सामान्य कर देता है।',
    exercise: 'Agree on a time-out word neither of you will argue with.',
    exerciseHi: 'एक ऐसा शब्द तय कीजिए जिस पर आप दोनों में से कोई बहस न करे।',
  ),
];

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context, ref);
    final hindi = s.isHindi;
    final t = Theme.of(context).textTheme;
    final surface = context.surface;

    return StageTheme(
      stage: ResolutionStage.calm,
      child: Atmosphere(
        background: Backgrounds.origin,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
              24, MediaQuery.paddingOf(context).top + 12, 24, 140),
          children: [
            Eyebrow(s.learnCount(learnCards.length, learnCards.length),
                color: surface.ink2),
            const SizedBox(height: 4),
            Text(s.learnTitle, style: t.headlineMedium),
            const SizedBox(height: 18),
            for (final c in learnCards) ...[
              GlassPanel(
                strong: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.t(hindi), style: t.titleMedium),
                    const SizedBox(height: 8),
                    Text(c.b(hindi),
                        style: t.bodySmall?.copyWith(fontSize: 15)),
                    const SizedBox(height: 12),
                    TintPanel(
                      label: s.twoMinuteExercise,
                      color: context.stage.accent,
                      child: Text(c.e(hindi)),
                    ),
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
