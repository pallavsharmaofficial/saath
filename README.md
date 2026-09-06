# Saath Hamesha

On-device AI relationship counsellor. Flutter, iOS + Android.

## First run (Apple Silicon Mac)

The repo ships only `lib/`, `assets/` and `pubspec.yaml`. Generate the platform folders once, then run:

```bash
cd ~/Workspace/saath_hamesha
flutter create . --org in.saathhamesha --project-name saath_hamesha --platforms ios,android
flutter pub get
flutter run            # pick the iOS simulator or Android emulator when prompted
```

`flutter create .` will not overwrite `lib/main.dart` or `pubspec.yaml`. If it asks, keep ours.

Android emulator: use an **arm64** system image (the default on Apple Silicon). The on-device model, when it lands, will not run on x86 images.

## Layout

```
lib/
  app/        router, tab shell, MaterialApp
  theme/      tokens (palette, SurfaceTokens, StageTokens = resolution arc), ThemeData
  ui/         Atmosphere (photo + veil + fades), glass components, tab bar
  core/       AppState (SharedPreferences), EN/HI strings
  features/   onboarding, home, counsellor (engine + chat), untangle, repair, couple, learn, safety, settings
assets/backgrounds/   placeholder colour fields — swap for real photos, same filenames
```

## The resolution arc

Every screen is wrapped in `StageTheme(stage: …)`. Three stages move accent, radius and blur together:

| stage   | accent | radius | blur | used on |
|---------|--------|--------|------|---------|
| aware   | rose   | 12     | 14   | welcome, counsellor chat |
| working | plum   | 18     | 18   | today, names, untangle, repair room |
| calm    | sage   | 26     | 24   | origin story, cool-down, repair close, us, learn, settings |

## AI engine

`features/counsellor/engine.dart` defines `CounsellorEngine`. The app runs on `MockCounsellorEngine` (scripted) so every screen is testable on simulators today. The Gemma engine replaces it via `counsellorEngineProvider` after the model spike — no UI changes.

## Dev shortcuts

- Settings → *Delete everything* resets onboarding.
- Repair Room merged view has a "Skip to closing (dev)" link.
- Type "afraid of him" in the counsellor to see the safety interrupt.
