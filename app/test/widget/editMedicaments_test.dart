import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/widgets/edit_medicament_widgets.dart';

void main() {
  testWidgets('buildNameTextField - edit medicament name', (WidgetTester tester) async {
    TextEditingController controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: buildNameTextField(controller),
        ),
      ),
    );
    expect(find.text('Name'), findsOneWidget);
    expect((tester.widget(find.byType(TextField)) as TextField).controller, controller);
  });

  testWidgets('buildQuantityTextField - edit medicament quantity', (WidgetTester tester) async {
    TextEditingController controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: buildQuantityTextField(controller),
        ),
      ),
    );
    expect(find.text('Quantity'), findsOneWidget);
    expect((tester.widget(find.byType(TextField)) as TextField).controller, controller);
    expect((tester.widget(find.byType(TextField)) as TextField).keyboardType, TextInputType.number);
  });

  testWidgets('buildExpiryDateRow - edit medicament expiry date', (WidgetTester tester) async {
    DateTime? selectedDate;
    void onDateSelected(DateTime date) {
      selectedDate = date;
    }
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return buildExpiryDateRow(
                context,
                TextEditingController(),
                DateTime.now(),
                onDateSelected,
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.byType(GestureDetector));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(selectedDate, isNotNull);
  });

  testWidgets('buildNotesTextField - edit medicament notes', (WidgetTester tester) async {
    TextEditingController controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: buildNotesTextField(controller),
        ),
      ),
    );
    expect(find.text('Notes'), findsOneWidget);
    expect((tester.widget(find.byType(TextField)) as TextField).controller, controller);
  });
}
