# Releasing Saath

Everything here is reproducible from a clean checkout. Nothing in this file
assumes a machine that has built the app before.

## Identity

| | |
|---|---|
| iOS bundle ID | `in.saathhamesha.app` |
| Android application ID | `in.saathhamesha.app` |
| Store name | Saath |
| Minimum iOS | 16.0 |
| Minimum Android | API 29 (Android 10) |
| Orientation | Portrait only, both platforms |

The version lives in exactly two places and a test enforces that they agree:
`pubspec.yaml` (`version: x.y.z+n`) and `lib/core/app_info.dart`. Bump both, or
`test/app_info_test.dart` fails.

## Before every release

```bash
flutter pub get
flutter analyze          # must be clean, not "only infos"
flutter test             # 171 tests
```

Then re-verify the helpline numbers against the operators' own published pages
and bump `Helplines.verifiedOn` in `lib/core/helplines.dart`. Settings → About
shows that date to the user, so a stale value is visible in the product.

## Android

Release signing reads `android/key.properties`, which is **not** in version
control. Create it on the release machine:

```properties
storePassword=…
keyPassword=…
keyAlias=upload
storeFile=/absolute/path/to/upload-keystore.jks
```

Without that file the release build falls back to the debug keystore so
`flutter run --release` still works locally — it just cannot be uploaded.

```bash
flutter build appbundle --release     # → build/app/outputs/bundle/release/app-release.aab
```

R8 (`isMinifyEnabled`) and resource shrinking are on. Rules live in
`android/app/proguard-rules.pro`.

## iOS

```bash
flutter build ipa --release
```

Signing is configured in Xcode against the team that owns
`in.saathhamesha.app`. `ios/Runner/PrivacyInfo.xcprivacy` is registered in the
Runner target's Resources phase — confirm it is present in the built
`Runner.app` before uploading, because App Store Connect rejects the archive
silently late if it is missing.

## Store answers already decided in code

- **Encryption** — `ITSAppUsesNonExemptEncryption = false` in `Info.plist`.
  True today: the app makes no network calls at all. This changes the day
  pairing ships.
- **Data Safety / Privacy Nutrition Label** — no data collected, no data
  shared, no tracking. `PrivacyInfo.xcprivacy` declares one required-reason
  API: `UserDefaults` (CA92.1), used by `shared_preferences`.
- **Backups** — Android cloud backup and device transfer are both disabled
  (`android/app/src/main/res/xml/data_extraction_rules.xml`). The journal and
  origin story are meant to exist on one phone.
- **Age rating** — 17+ on iOS / Mature on Play, for the relationship and
  self-harm subject matter.
- **Not medical advice** — Settings → About carries the "not a licensed
  therapist" line, and the store listing must repeat it.

## Still open before a public launch

See `docs/LAUNCH-READINESS.md`. In short: the counsellor is a scripted preview
engine, there is no pairing, and 20 of the 28 planned screens do not exist yet.
