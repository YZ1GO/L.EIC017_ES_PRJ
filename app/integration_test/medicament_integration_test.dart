import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/widgets/edit_medicament_widgets.dart';
import 'package:app/screens/stock_screen.dart';

void main() {
  testWidgets('Name TextField Test', (WidgetTester tester) async {
    final TextEditingController nameController = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: buildNameTextField(nameController),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Test Name');
    expect(nameController.text, 'Test Name');
  });

  testWidgets('Quantity TextField Test', (WidgetTester tester) async {
    final TextEditingController quantityController = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: buildQuantityTextField(quantityController),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '123');
    expect(quantityController.text, '123');
  });

  testWidgets('Notes TextField Test', (WidgetTester tester) async {
    final TextEditingController notesController = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: buildNotesTextField(notesController),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Test Notes');
    expect(notesController.text, 'Test Notes');
  });

  testWidgets('Stock screen should display "No medicaments in stock" message when no medicaments are available',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: StockScreen(selectionMode: false, medicamentList: Future.value([]), onMedicamentListUpdated: () {})));

    expect(find.text('No medicaments in stock'), findsOneWidget);
  });
}
