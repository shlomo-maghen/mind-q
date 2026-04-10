import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mind_q/providers/queue_provider.dart';

void main() {
  group('QueueNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
      await container.read(queueProvider.future);
    });

    tearDown(() => container.dispose());

    test('initial state is empty list', () {
      final items = container.read(queueProvider).valueOrNull;
      expect(items, isEmpty);
    });

    test('add() appends item at end of list', () async {
      await container.read(queueProvider.notifier).add('Buy milk');
      final items = container.read(queueProvider).valueOrNull!;
      expect(items.length, 1);
      expect(items[0].text, 'Buy milk');
    });

    test('two add() calls preserve FIFO order', () async {
      await container.read(queueProvider.notifier).add('First');
      await container.read(queueProvider.notifier).add('Second');
      final items = container.read(queueProvider).valueOrNull!;
      expect(items[0].text, 'First');
      expect(items[1].text, 'Second');
    });

    test('add() trims whitespace', () async {
      await container.read(queueProvider.notifier).add('  hello  ');
      final items = container.read(queueProvider).valueOrNull!;
      expect(items[0].text, 'hello');
    });

    test('edit() updates the matching item text', () async {
      await container.read(queueProvider.notifier).add('Old text');
      final id = container.read(queueProvider).valueOrNull![0].id;
      await container.read(queueProvider.notifier).edit(id, 'New text');
      final items = container.read(queueProvider).valueOrNull!;
      expect(items[0].text, 'New text');
    });

    test('edit() trims whitespace', () async {
      await container.read(queueProvider.notifier).add('item');
      final id = container.read(queueProvider).valueOrNull![0].id;
      await container.read(queueProvider.notifier).edit(id, '  trimmed  ');
      expect(container.read(queueProvider).valueOrNull![0].text, 'trimmed');
    });

    test('edit() with empty text is a no-op', () async {
      await container.read(queueProvider.notifier).add('Keep me');
      final id = container.read(queueProvider).valueOrNull![0].id;
      await container.read(queueProvider.notifier).edit(id, '   ');
      expect(container.read(queueProvider).valueOrNull![0].text, 'Keep me');
    });

    test('edit() leaves other items untouched', () async {
      await container.read(queueProvider.notifier).add('A');
      await container.read(queueProvider.notifier).add('B');
      final idA = container.read(queueProvider).valueOrNull![0].id;
      await container.read(queueProvider.notifier).edit(idA, 'A-edited');
      final items = container.read(queueProvider).valueOrNull!;
      expect(items[1].text, 'B');
    });

    test('remove() deletes the matching item', () async {
      await container.read(queueProvider.notifier).add('Delete me');
      final id = container.read(queueProvider).valueOrNull![0].id;
      await container.read(queueProvider.notifier).remove(id);
      expect(container.read(queueProvider).valueOrNull, isEmpty);
    });

    test('remove() leaves other items untouched', () async {
      await container.read(queueProvider.notifier).add('A');
      await container.read(queueProvider.notifier).add('B');
      final idA = container.read(queueProvider).valueOrNull![0].id;
      await container.read(queueProvider.notifier).remove(idA);
      final items = container.read(queueProvider).valueOrNull!;
      expect(items.length, 1);
      expect(items[0].text, 'B');
    });

    test('add persists across container restart', () async {
      await container.read(queueProvider.notifier).add('Persist me');
      container.dispose();

      final container2 = ProviderContainer();
      addTearDown(container2.dispose);
      await container2.read(queueProvider.future);
      final items = container2.read(queueProvider).valueOrNull!;
      expect(items.length, 1);
      expect(items[0].text, 'Persist me');
    });

    test('remove persists across container restart', () async {
      await container.read(queueProvider.notifier).add('Gone');
      final id = container.read(queueProvider).valueOrNull![0].id;
      await container.read(queueProvider.notifier).remove(id);
      container.dispose();

      final container2 = ProviderContainer();
      addTearDown(container2.dispose);
      await container2.read(queueProvider.future);
      expect(container2.read(queueProvider).valueOrNull, isEmpty);
    });
  });
}
