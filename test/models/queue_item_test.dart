import 'package:flutter_test/flutter_test.dart';
import 'package:mind_q/models/queue_item.dart';

void main() {
  group('QueueItem', () {
    final baseTime = DateTime.utc(2024, 6, 1, 12, 0, 0);
    final item = QueueItem(id: 'abc-123', text: 'Buy milk', createdAt: baseTime);

    group('toJson / fromJson', () {
      test('round-trips all fields', () {
        final json = item.toJson();
        final restored = QueueItem.fromJson(json);
        expect(restored.id, item.id);
        expect(restored.text, item.text);
        expect(restored.createdAt.toIso8601String(), item.createdAt.toIso8601String());
      });

      test('toJson produces expected keys with ISO 8601 createdAt', () {
        final json = item.toJson();
        expect(json.keys.toSet(), {'id', 'text', 'createdAt'});
        expect(json['createdAt'], isA<String>());
        expect(json['createdAt'], item.createdAt.toIso8601String());
      });

      test('fromJson preserves UTC DateTime', () {
        final json = item.toJson(); // createdAt stored as UTC ISO string
        final restored = QueueItem.fromJson(json);
        expect(restored.createdAt.isUtc, isTrue);
      });
    });

    group('copyWith', () {
      test('copyWith(text:) updates text and preserves other fields', () {
        final copy = item.copyWith(text: 'Buy eggs');
        expect(copy.text, 'Buy eggs');
        expect(copy.id, item.id);
        expect(copy.createdAt, item.createdAt);
      });

      test('copyWith() with no args returns equivalent object', () {
        final copy = item.copyWith();
        expect(copy.id, item.id);
        expect(copy.text, item.text);
        expect(copy.createdAt, item.createdAt);
      });
    });
  });
}
