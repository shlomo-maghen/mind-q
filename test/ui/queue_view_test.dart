import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mind_q/models/queue_item.dart';
import 'package:mind_q/providers/queue_provider.dart';
import 'package:mind_q/ui/empty_state.dart';
import 'package:mind_q/ui/queue_view.dart';

// ---------------------------------------------------------------------------
// Fake notifier — captures calls without touching SharedPreferences
// ---------------------------------------------------------------------------
class FakeQueueNotifier extends AsyncNotifier<List<QueueItem>>
    implements QueueNotifier {
  FakeQueueNotifier(this._items);
  final List<QueueItem> _items;
  final addedTexts = <String>[];
  final removedIds = <String>[];

  @override
  Future<List<QueueItem>> build() async => _items;

  @override
  Future<void> add(String text) async {
    addedTexts.add(text.trim());
    state = AsyncData([
      ...state.valueOrNull ?? [],
      QueueItem(id: 'fake-${addedTexts.length}', text: text.trim(), createdAt: DateTime.now()),
    ]);
  }

  @override
  Future<void> remove(String id) async => removedIds.add(id);

  @override
  Future<void> edit(String id, String text) async {}
}

// ---------------------------------------------------------------------------
// Helper to build QueueView inside a minimal router + ProviderScope
// ---------------------------------------------------------------------------
Widget buildSubject(List<QueueItem> items, {FakeQueueNotifier? captureNotifier}) {
  final notifier = captureNotifier ?? FakeQueueNotifier(items);
  final router = GoRouter(routes: [
    GoRoute(path: '/', builder: (_, __) => const QueueView()),
    GoRoute(path: '/settings', builder: (_, __) => const Scaffold(body: Text('Settings'))),
  ]);
  return ProviderScope(
    overrides: [
      queueProvider.overrideWith(() => notifier),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  testWidgets('shows EmptyState when queue is empty', (tester) async {
    await tester.pumpWidget(buildSubject([]));
    await tester.pump();
    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text("Queue is clear. You're focused."), findsOneWidget);
  });

  testWidgets('shows list items when queue has data', (tester) async {
    final items = [
      QueueItem(id: '1', text: 'Alpha', createdAt: DateTime.now()),
      QueueItem(id: '2', text: 'Beta', createdAt: DateTime.now()),
    ];
    await tester.pumpWidget(buildSubject(items));
    await tester.pump();
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);
    expect(find.byType(EmptyState), findsNothing);
  });

  testWidgets('text field has hint text', (tester) async {
    await tester.pumpWidget(buildSubject([]));
    await tester.pump();
    expect(find.text('Tap to add...'), findsOneWidget);
  });

  testWidgets('Add button is disabled when text field is empty', (tester) async {
    await tester.pumpWidget(buildSubject([]));
    await tester.pump();
    // Focus the field to reveal the action buttons
    await tester.tap(find.byType(TextField).first);
    await tester.pump();
    final button = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Add'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('Add button enables after entering text', (tester) async {
    await tester.pumpWidget(buildSubject([]));
    await tester.pump();
    await tester.tap(find.byType(TextField).first);
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, 'hello');
    await tester.pump();
    final button = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Add'),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('tapping Add calls notifier.add with trimmed text and clears field',
      (tester) async {
    final notifier = FakeQueueNotifier([]);
    await tester.pumpWidget(buildSubject([], captureNotifier: notifier));
    await tester.pump();
    await tester.tap(find.byType(TextField).first);
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, '  task one  ');
    await tester.pump();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Add'));
    await tester.pump();
    expect(notifier.addedTexts, ['task one']);
    // Field should be cleared
    final tf = tester.widget<TextField>(find.byType(TextField).first);
    expect(tf.controller?.text ?? '', isEmpty);
  });

  testWidgets('tapping Quick Add calls notifier.add', (tester) async {
    final notifier = FakeQueueNotifier([]);
    await tester.pumpWidget(buildSubject([], captureNotifier: notifier));
    await tester.pump();
    await tester.tap(find.byType(TextField).first);
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, 'quick task');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Quick Add'));
    await tester.pump();
    expect(notifier.addedTexts, ['quick task']);
  });

  testWidgets('settings icon button is present and tappable', (tester) async {
    await tester.pumpWidget(buildSubject([]));
    await tester.pump();
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
  });
}
