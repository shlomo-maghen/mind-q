import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_q/models/queue_item.dart';
import 'package:mind_q/ui/queue_item_card.dart';

void main() {
  QueueItem makeItem({String text = 'Test item', DateTime? createdAt}) =>
      QueueItem(id: 'id-1', text: text, createdAt: createdAt ?? DateTime.now());

  Widget buildCard({
    required QueueItem item,
    VoidCallback? onComplete,
    void Function(String)? onEdit,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: QueueItemCard(
          item: item,
          onComplete: onComplete ?? () {},
          onEdit: onEdit ?? (_) {},
        ),
      ),
    );
  }

  testWidgets('displays the item text', (tester) async {
    await tester.pumpWidget(buildCard(item: makeItem(text: 'Buy eggs')));
    expect(find.text('Buy eggs'), findsOneWidget);
  });

  testWidgets('displays "just now" for a freshly created item', (tester) async {
    await tester.pumpWidget(buildCard(item: makeItem()));
    expect(find.text('just now'), findsOneWidget);
  });

  testWidgets('complete button calls onComplete callback', (tester) async {
    bool called = false;
    await tester.pumpWidget(buildCard(
      item: makeItem(),
      onComplete: () => called = true,
    ));
    await tester.tap(find.byIcon(Icons.check_circle_outline_rounded));
    expect(called, isTrue);
  });

  testWidgets('tapping item text starts editing mode (shows TextField)', (tester) async {
    await tester.pumpWidget(buildCard(item: makeItem(text: 'Editable')));
    await tester.tap(find.text('Editable'));
    await tester.pump();
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('submitting new text calls onEdit with trimmed value', (tester) async {
    String? editedText;
    await tester.pumpWidget(buildCard(
      item: makeItem(text: 'Original'),
      onEdit: (t) => editedText = t,
    ));
    await tester.tap(find.text('Original'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), '  Updated  ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(editedText, 'Updated');
  });

  testWidgets('submitting unchanged text does NOT call onEdit', (tester) async {
    bool called = false;
    await tester.pumpWidget(buildCard(
      item: makeItem(text: 'Same'),
      onEdit: (_) => called = true,
    ));
    await tester.tap(find.text('Same'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Same');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(called, isFalse);
  });

  testWidgets('clearing the field and submitting does NOT call onEdit and reverts text', (tester) async {
    bool called = false;
    await tester.pumpWidget(buildCard(
      item: makeItem(text: 'Keep me'),
      onEdit: (_) => called = true,
    ));
    await tester.tap(find.text('Keep me'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), '');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(called, isFalse);
    expect(find.text('Keep me'), findsOneWidget);
  });

  testWidgets('card shows primary border color while editing', (tester) async {
    await tester.pumpWidget(buildCard(item: makeItem(text: 'Edit me')));
    await tester.tap(find.text('Edit me'));
    await tester.pump();

    final card = tester.widget<Card>(find.byType(Card));
    final shape = card.shape as RoundedRectangleBorder;
    final context = tester.element(find.byType(Card));
    final primary = Theme.of(context).colorScheme.primary;
    expect(shape.side.color, primary);
  });
}
