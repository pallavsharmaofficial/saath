# Saath (साथ)

An AI relationship counsellor that runs entirely on the phone. Free, private,
offline. Flutter, iOS 16+ and Android 10+.

> **What this build is:** the complete front end, running on a *scripted
> preview engine*. No AI model runs on the device yet. See
> [docs/LAUNCH-READINESS.md](docs/LAUNCH-READINESS.md) for the honest gap
> between this and v1.

## Run it

```bash
flutter pub get
flutter run          # pick a simulator or an arm64 Android emulator
```

Both platform folders are checked in. There is no `flutter create` step.

```bash
flutter analyze --fatal-infos --fatal-warnings   # must be clean
flutter test                                     # 171 tests
```

## Layout

```
lib/
  app/        router (one stable GoRouter), tab shell, MaterialApp
  theme/      tokens (palette, SurfaceTokens, StageTokens), typography, ThemeData
  ui/         Atmosphere (photo + veil + fades), Frost/glass components
  core/       app state, journal, key-value store, strings (EN/HI), helplines
  features/   onboarding, home, counsellor, untangle, repair, couple,
              journal, learn, safety, settings
assets/
  backgrounds/  placeholder colour fields — swap for real photos, same filenames
  fonts/        Sora, Source Serif 4, Noto Serif Devanagari (subset, variable)
docs/         RELEASE.md, LAUNCH-READINESS.md, ACCESSIBILITY.md
test/         unit + widget tests; test/support/harness.dart boots the real app
```

## The resolution arc

Every screen is wrapped in `StageTheme(stage: …)`. Three stages move accent,
radius and blur together:

| stage   | accent | radius | blur | used on |
|---------|--------|--------|------|---------|
| aware   | rose   | 12     | 14   | welcome, counsellor chat |
| working | plum   | 18     | 18   | today, names, untangle, repair room |
| calm    | sage   | 26     | 24   | origin story, cool-down, repair close, us, journal, learn, settings |

## Typography

The three faces are **bundled**, not fetched. `google_fonts` downloads from
`fonts.gstatic.com` on first run, which breaks the offline promise the welcome
screen makes and is the one network call an otherwise on-device app would have.

All three are variable fonts. Flutter does not map `fontWeight` onto a `wght`
axis by itself, so build styles with `AppFonts.sora` / `AppFonts.sourceSerif`
and change weight with `AppFonts.at` — a bare `copyWith(fontWeight: …)` silently
does nothing. Noto Serif Devanagari is attached as a fallback on every style, so
Hindi resolves even inside an English paragraph.

## AI engine

`features/counsellor/engine.dart` defines `CounsellorEngine`. The app runs
`MockCounsellorEngine` (scripted) so every screen is testable today. The Gemma
engine replaces it via `counsellorEngineProvider` after the model spike — no UI
changes.

The safety guardrail (`features/counsellor/safety.dart`) is deliberately *not*
part of the model. It runs on every text the user writes — chat, Untangle vents,
both Repair Room sides — before any generation, and the model gets no vote.

## Strings

Every user-visible string lives in `lib/core/strings.dart`. A literal in a
widget is a string that will ship in English to a Hindi user, which is what half
this app used to do. `test/strings_test.dart` reads the table as source and
fails if any `_t()` pair is empty, identical, or missing Devanagari.

## Dev shortcuts

- `flutter run --route=/safety` (or `/learn`, `/settings`, `/journal`) opens
  straight onto a screen. go_router honours the platform's initial route.
- Settings → *Delete everything* resets to onboarding (with a confirmation).
- Repair Room's merged view has a "Skip to closing" link **in debug builds
  only**.
- Type "afraid of him" in the counsellor to see the safety interrupt.

## Releasing

See [docs/RELEASE.md](docs/RELEASE.md).
