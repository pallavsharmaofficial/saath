import 'package:flutter_test/flutter_test.dart';
import 'package:saath_hamesha/features/counsellor/model/model_catalogue.dart';

void main() {
  group('recommendedFor', () {
    test('picks the big model only on 6 GB or more', () {
      expect(SaathModel.recommendedFor(8192), SaathModel.gemma3nE2B);
      expect(SaathModel.recommendedFor(6144), SaathModel.gemma3nE2B);
    });

    test('falls back to the small model on a 4 GB phone', () {
      // The phone this app exists for. Shipping 3.7 GB here is an OOM.
      expect(SaathModel.recommendedFor(4096), SaathModel.gemma31B);
      expect(SaathModel.recommendedFor(3072), SaathModel.gemma31B);
    });

    test('falls back to the small model when RAM is unknown', () {
      expect(SaathModel.recommendedFor(null), SaathModel.gemma31B);
    });
  });

  group('sizes', () {
    test('are the real file sizes, shown before anything downloads', () {
      expect(SaathModel.gemma31B.sizeLabel, '584 MB');
      expect(SaathModel.gemma3nE2B.sizeLabel, '3.7 GB');
    });
  });

  group('ids', () {
    test('round-trip, and are stable strings rather than ordinals', () {
      for (final m in SaathModel.values) {
        expect(SaathModel.byId(m.id), m);
      }
      expect(SaathModel.byId('something-else'), isNull);
      expect(SaathModel.byId(null), isNull);
    });
  });

  group('download URLs', () {
    test('point at Hugging Face when no mirror is configured', () {
      // Both repos are gated, which is exactly why the launch plan calls for
      // our own mirror; this default is for development.
      expect(
        SaathModel.gemma31B.downloadUrl,
        'https://huggingface.co/litert-community/Gemma3-1B-IT/resolve/main/gemma3-1b-it-int4.litertlm',
      );
    });

    test('carry the real upstream filenames', () {
      expect(SaathModel.gemma31B.fileName, 'gemma3-1b-it-int4.litertlm');
      expect(SaathModel.gemma3nE2B.fileName, 'gemma-3n-E2B-it-int4.litertlm');
    });
  });

  group('ModelDownload', () {
    final started = DateTime.now().subtract(const Duration(seconds: 10));

    test('reports a clamped fraction and a percentage', () {
      final d = ModelDownload(
        model: SaathModel.gemma31B,
        receivedBytes: SaathModel.gemma31B.bytes ~/ 4,
        startedAt: started,
      );
      expect(d.percent, 25);
      expect(d.fraction, closeTo(0.25, 0.001));
    });

    test('never exceeds 100% even if the runtime overshoots', () {
      final d = ModelDownload(
        model: SaathModel.gemma31B,
        receivedBytes: SaathModel.gemma31B.bytes * 2,
        startedAt: started,
      );
      expect(d.percent, 100);
    });

    test('estimates a remaining time once there is enough to go on', () {
      final d = ModelDownload(
        model: SaathModel.gemma31B,
        receivedBytes: SaathModel.gemma31B.bytes ~/ 2,
        startedAt: started,
      );
      expect(d.remaining, isNotNull);
      expect(d.remaining!.inSeconds, greaterThan(0));
    });

    test('gives no estimate in the first seconds, rather than a wild one', () {
      final d = ModelDownload(
        model: SaathModel.gemma31B,
        receivedBytes: 1000,
        startedAt: DateTime.now(),
      );
      expect(d.bytesPerSecond, isNull);
      expect(d.remaining, isNull);
    });
  });
}
