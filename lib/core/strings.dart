import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_state.dart';

/// Minimal EN/HI string table. Kept as a map until copy settles; moves to
/// ARB + gen-l10n before beta.
class S {
  S._(this._lang);
  final AppLanguage _lang;

  static S of(BuildContext context, WidgetRef ref) => S._(ref.watch(appStateProvider).language);

  String _t(String en, String hi) => _lang == AppLanguage.hi ? hi : en;

  String get appName => 'Saath Hamesha';
  String get tagline => _t(
      'Most problems are simple. Your brain makes them big.',
      'ज़्यादातर मसले आसान होते हैं। दिमाग़ उन्हें बड़ा बना देता है।');
  String get taglineSub => _t(
      'A counsellor that lives on your phone, never leaves it, and remembers why you two started.',
      'एक काउंसलर जो आपके फ़ोन में रहता है, कहीं नहीं जाता, और याद रखता है कि आप दोनों ने शुरुआत क्यों की थी।');
  String get freePrivateOffline => _t('Free. Private. Works offline.', 'मुफ़्त। निजी। बिना इंटरनेट भी।');
  String get startEnglish => 'Start in English';
  String get startHindi => 'हिंदी में शुरू करें';

  String get tabToday => _t('Today', 'आज');
  String get tabCounsellor => _t('Counsellor', 'काउंसलर');
  String get tabUs => _t('Us', 'हम');
  String get tabLearn => _t('Learn', 'सीखें');

  String greeting(String name) {
    final h = DateTime.now().hour;
    final en = h < 12 ? 'Morning' : (h < 17 ? 'Afternoon' : 'Evening');
    final hi = h < 12 ? 'सुप्रभात' : (h < 17 ? 'नमस्ते' : 'शुभ संध्या');
    return _t('$en, $name', '$hi, $name');
  }

  String get checkinLabel => _t('30-second check-in', '30 सेकंड का चेक-इन');
  String get checkinQ => _t('How connected do you feel today?', 'आज आप कितना जुड़ा हुआ महसूस कर रहे हैं?');
  String get oneWord => _t('One word for today?', 'आज के लिए एक शब्द?');
  String get talkToSaath => _t('Talk to Saath', 'साथ से बात करें');
  String talkPrompt(String partner) => _t(
      'Something on your mind about $partner? Say it messy — I will untangle it.',
      '$partner को लेकर कुछ मन में है? जैसे भी हो, कह दीजिए — मैं सुलझा दूँगा।');
  String get promptSameFight => _t('Same fight again', 'फिर वही झगड़ा');
  String get promptRegret => _t('About to say something I’ll regret', 'कुछ ऐसा कहने वाला हूँ जिसका पछतावा होगा');
  String get sayItMessy => _t('Say it messy…', 'जैसे भी हो, कह दीजिए…');
  String get onThisPhoneOnly => _t('On this phone only', 'सिर्फ़ इसी फ़ोन पर');
  String get untangleIt => _t('Untangle it', 'सुलझाओ');
  String get helpMeSaySorry => _t('Help me say sorry', 'माफ़ी माँगने में मदद करो');

  String get untangled => _t('Untangled', 'सुलझा हुआ');
  String get simpleVersion => _t('The simple version', 'आसान रूप');
  String get untangleSub => _t('Your vent, sorted. Nothing here is a verdict — check what feels true.',
      'आपकी बात, छाँटी हुई। यह कोई फ़ैसला नहीं है — देखिए क्या सच लगता है।');
  String get whatHappened => _t('What happened', 'क्या हुआ');
  String get whatIAssumed => _t('What I assumed', 'मैंने क्या मान लिया');
  String get whatIFelt => _t('What I felt', 'मुझे क्या महसूस हुआ');
  String get whatINeed => _t('What I need', 'मुझे क्या चाहिए');
  String get oneSentence => _t('One sentence you could say', 'एक वाक्य जो आप कह सकते हैं');
  String sendTo(String p) => _t('Send to $p', '$p को भेजें');
  String get save => _t('Save', 'सहेजें');
  String get notRight => _t('Not quite right? Tap any box to fix it.', 'ठीक नहीं लगा? किसी भी बॉक्स पर टैप करके बदलें।');

  String get whyWeStarted => _t('Why we started', 'हमने शुरुआत क्यों की');
  String whyChoose(String p) => _t('Why did you choose $p?', 'आपने $p को क्यों चुना?');
  String get originHint => _t(
      'Say it the way you would tell a friend. Only you can see this — until you both choose to share it.',
      'वैसे ही कहिए जैसे किसी दोस्त को बताते। इसे सिर्फ़ आप देख सकते हैं — जब तक आप दोनों साझा न करना चाहें।');
  String get keepThis => _t('Keep this', 'इसे रखें');
  String get originFooter => _t('Saath brings this back to you at the end of every hard conversation.',
      'हर मुश्किल बातचीत के अंत में साथ इसे आपके सामने लाता है।');

  String get repairRoom => _t('Repair Room', 'रिपेयर रूम');
  String get bothSidesIn => _t('Both sides are in', 'दोनों पक्ष आ गए');
  String get youBothAgree => _t('You both agree', 'आप दोनों सहमत हैं');
  String get storiesSplit => _t('Where the stories split', 'जहाँ कहानियाँ अलग होती हैं');
  String get startTurn => _t('Start turn', 'बारी शुरू करें');
  String get coolDown => _t('Cool down', 'शांत हों');
  String get closeRoom => _t('Close the room', 'रूम बंद करें');
  String get planSmallThing => _t('Plan a small thing this week', 'इस हफ़्ते कुछ छोटा-सा प्लान करें');

  String get settings => _t('Settings', 'सेटिंग्स');
  String get language => _t('Language', 'भाषा');
  String get theme => _t('Appearance', 'रूप');
  String get partnerName => _t('Partner’s name', 'साथी का नाम');
  String get yourName => _t('Your name', 'आपका नाम');
  String get continueLabel => _t('Continue', 'आगे');
}
