import 'package:flutter/foundation.dart';

/// A model Saath can run on the device.
///
/// Two, not ten. The choice is made for the user from their phone's RAM,
/// because "which quantisation would you like" is not a question to put to
/// someone who opened a relationship app at eleven at night.
enum SaathModel {
  /// Gemma 3n E2B, int4. Multilingual, noticeably better Hindi.
  gemma3nE2B(
    id: 'gemma-3n-e2b-int4',
    fileName: 'gemma-3n-E2B-it-int4.litertlm',
    repo: 'google/gemma-3n-E2B-it-litert-lm',
    bytes: 3655827456,
    minRamMb: 6144,
    maxTokens: 2048,
  ),

  /// Gemma 3 1B, int4. The fallback that makes the app usable on a 4 GB phone
  /// — which is most of the market this is aimed at.
  gemma31B(
    id: 'gemma-3-1b-int4',
    fileName: 'gemma3-1b-it-int4.litertlm',
    repo: 'litert-community/Gemma3-1B-IT',
    bytes: 584417280,
    minRamMb: 0,
    maxTokens: 1280,
  );

  const SaathModel({
    required this.id,
    required this.fileName,
    required this.repo,
    required this.bytes,
    required this.minRamMb,
    required this.maxTokens,
  });

  final String id;
  final String fileName;

  /// Hugging Face repo, used to build the default download URL.
  final String repo;

  /// Exact download size. Shown to the user before anything is downloaded,
  /// because a 3.7 GB surprise on a metered connection is a betrayal.
  final int bytes;

  /// Physical RAM at or above which this model is the recommended default.
  final int minRamMb;

  /// Context window. The 1B model gets a smaller one so a long conversation
  /// does not push it into swap on the phones it exists for.
  final int maxTokens;

  double get gigabytes => bytes / (1000 * 1000 * 1000);

  String get sizeLabel => bytes >= 1000000000
      ? '${gigabytes.toStringAsFixed(1)} GB'
      : '${(bytes / (1000 * 1000)).round()} MB';

  /// Where the file comes from.
  ///
  /// Both upstream repos are gated, so a first run against Hugging Face needs
  /// a token. The launch plan calls for our own mirror instead — that is what
  /// [ModelHosting.baseUrl] is for, and it is also what stops a model rename
  /// upstream from breaking first-run for everyone at once.
  String get downloadUrl {
    const base = ModelHosting.baseUrl;
    if (base.isEmpty) {
      return 'https://huggingface.co/$repo/resolve/main/$fileName';
    }
    return '${base.endsWith('/') ? base.substring(0, base.length - 1) : base}/$fileName';
  }

  /// The model recommended for a device with [ramMb] of physical RAM.
  ///
  /// Falls back to the small model when RAM is unknown: shipping a 3.7 GB
  /// download to a phone that cannot hold it is the worse failure.
  static SaathModel recommendedFor(int? ramMb) {
    if (ramMb == null) return SaathModel.gemma31B;
    for (final m in values) {
      if (ramMb >= m.minRamMb) return m;
    }
    return SaathModel.gemma31B;
  }

  static SaathModel? byId(String? id) {
    if (id == null) return null;
    for (final m in values) {
      if (m.id == id) return m;
    }
    return null;
  }
}

/// Where model files are served from.
///
/// Set at build time:
/// `flutter build --dart-define=SAATH_MODEL_BASE_URL=https://models.saathhamesha.in`
///
/// Left empty, Saath falls back to Hugging Face, which needs
/// `--dart-define=HUGGINGFACE_TOKEN=...` because both repos are gated. That is
/// fine for development and is **not** how this should ship: see
/// docs/LAUNCH-READINESS.md.
class ModelHosting {
  ModelHosting._();

  static const baseUrl = String.fromEnvironment('SAATH_MODEL_BASE_URL');
  static const huggingFaceToken = String.fromEnvironment('HUGGINGFACE_TOKEN');

  /// True when the build is pointed at a host that can actually serve the
  /// files without a per-user token.
  static bool get isConfigured =>
      baseUrl.isNotEmpty || huggingFaceToken.isNotEmpty;
}

/// Progress of an in-flight download.
@immutable
class ModelDownload {
  const ModelDownload({
    required this.model,
    required this.receivedBytes,
    required this.startedAt,
  });

  final SaathModel model;
  final int receivedBytes;
  final DateTime startedAt;

  double get fraction =>
      model.bytes == 0 ? 0 : (receivedBytes / model.bytes).clamp(0.0, 1.0);

  int get percent => (fraction * 100).round();

  /// Bytes per second so far, or null before there is enough to be meaningful.
  double? get bytesPerSecond {
    final seconds = DateTime.now().difference(startedAt).inMilliseconds / 1000;
    if (seconds < 2 || receivedBytes <= 0) return null;
    return receivedBytes / seconds;
  }

  Duration? get remaining {
    final rate = bytesPerSecond;
    if (rate == null || rate <= 0) return null;
    final left = model.bytes - receivedBytes;
    if (left <= 0) return Duration.zero;
    return Duration(seconds: (left / rate).round());
  }

  ModelDownload copyWith({int? receivedBytes}) => ModelDownload(
        model: model,
        receivedBytes: receivedBytes ?? this.receivedBytes,
        startedAt: startedAt,
      );
}
