import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mind_q/models/queue_item.dart';
import 'package:mind_q/services/queue_repository.dart';

void main() {
  group('QueueRepository', () {
    late QueueRepository repo;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      repo = QueueRepository();
    });

    QueueItem makeItem(String id, String text) => QueueItem(
          id: id,
          text: text,
          createdAt: DateTime.utc(2024, 1, 1),
        );

    test('loadAll returns empty list when nothing stored', () async {
      final items = await repo.loadAll();
      expect(items, isEmpty);
    });

    test('saveAll then loadAll round-trips a list of items', () async {
      final items = [makeItem('1', 'Alpha'), makeItem('2', 'Beta')];
      await repo.saveAll(items);
      final loaded = await repo.loadAll();
      expect(loaded.length, 2);
      expect(loaded[0].id, '1');
      expect(loaded[0].text, 'Alpha');
      expect(loaded[1].id, '2');
      expect(loaded[1].text, 'Beta');
    });

    test('saveAll with empty list clears stored items', () async {
      await repo.saveAll([makeItem('1', 'Ghost')]);
      await repo.saveAll([]);
      final loaded = await repo.loadAll();
      expect(loaded, isEmpty);
    });

    test('saveAll twice overwrites, does not append', () async {
      await repo.saveAll([makeItem('1', 'First')]);
      await repo.saveAll([makeItem('2', 'Second')]);
      final loaded = await repo.loadAll();
      expect(loaded.length, 1);
      expect(loaded[0].id, '2');
    });

    test('loadAll with malformed JSON propagates an exception', () async {
      SharedPreferences.setMockInitialValues({'queue_items': 'not-json'});
      expect(() async => await repo.loadAll(), throwsA(anything));
    });
  });
}
