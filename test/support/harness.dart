import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saath_hamesha/app/router.dart';
import 'package:saath_hamesha/core/app_state.dart';
import 'package:saath_hamesha/core/key_value_store.dart';
import 'package:saath_hamesha/features/counsellor/engine.dart';
import 'package:saath_hamesha/theme/theme.dart';

/// Engine with no artificial latency, so a widget test does not spend four
/// seconds watching a scripted reply stream one word at a time.
const instantEngine = MockCounsellorEngine(tokenDelay: Duration.zero);

/// Boots the real app — real router, real redirect, real providers — on top of
/// an in-memory store. Widget tests exercise the same navigation the user does.
class TestApp {
  TestApp({Map<String, Object>? seed, CounsellorEngine engine = instantEngine})
      : store = InMemoryStore(seed) {
    container = ProviderContainer(
      overrides: [
        keyValueStoreProvider.overrideWithValue(store),
        counsellorEngineProvider.overrideWithValue(engine),
      ],
    );
  }

  final InMemoryStore store;
  late final ProviderContainer container;

  Widget widget() {
    return UncontrolledProviderScope(
      container: container,
      child: Consumer(
        builder: (context, ref, _) => MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          routerConfig: ref.watch(routerProvider),
          locale: ref.watch(appStateProvider.select((s) => s.language)).locale,
          supportedLocales: const [Locale('en'), Locale('hi')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );
  }

  /// The route actually on top.
  ///
  /// `currentConfiguration.uri` only tracks the last `go()` — an imperative
  /// `push()` leaves it pointing at the previous location, which makes it
  /// useless for asserting on a flow built out of pushes.
  String get location => container
      .read(routerProvider)
      .routerDelegate
      .currentConfiguration
      .last
      .matchedLocation;

  void go(String location, {Object? extra}) =>
      container.read(routerProvider).go(location, extra: extra);

  void push(String location, {Object? extra}) =>
      container.read(routerProvider).push(location, extra: extra);

  void dispose() => container.dispose();
}

/// Preference values for a user who has already finished onboarding.
Map<String, Object> onboardedSeed({
  String user = 'Asha',
  String partner = 'Vikram',
  String origin = 'He made me laugh on the worst day of my year.',
  String language = 'en',
}) =>
    {
      'saath.onboarded': true,
      'saath.userName': user,
      'saath.partnerName': partner,
      'saath.originStory': origin,
      'saath.relationshipStage': 'married',
      'saath.language': language,
    };

/// Builds the app and pumps until idle.
Future<TestApp> pumpApp(
  WidgetTester tester, {
  Map<String, Object>? seed,
  CounsellorEngine engine = instantEngine,
}) async {
  final app = TestApp(seed: seed, engine: engine);
  addTearDown(app.dispose);
  await tester.pumpWidget(app.widget());
  await tester.pumpAndSettle();
  return app;
}

/// Phone-sized surface. The layouts are portrait-only by design, and the
/// default 800×600 test window is neither.
void usePhoneSurface(WidgetTester tester, {Size size = const Size(390, 844)}) {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

final _devanagari = RegExp(r'[ऀ-ॿ]');

/// Finds an [Eyebrow] by the label as written in the string table.
///
/// The widget uppercases Latin labels for the tracked small-caps look and
/// leaves Devanagari alone (it has no case, and wide tracking wrecks
/// conjuncts). Tests say what the copy says; this applies the same rule.
Finder findEyebrow(String label) =>
    find.text(_devanagari.hasMatch(label) ? label : label.toUpperCase());

/// Scrolls [finder] into the viewport and taps it.
///
/// `scrollUntilVisible` alone is not enough: a ListView builds a little beyond
/// the viewport, so the finder succeeds while the widget is still below the
/// fold and `tap()` lands on empty space with only a warning. `ensureVisible`
/// is what actually scrolls it into view.
Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(finder, 240,
        scrollable: find.byType(Scrollable).last);
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
