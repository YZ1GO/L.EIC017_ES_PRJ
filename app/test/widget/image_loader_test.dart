import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/widgets/image_loader.dart';

void main() {
  testWidgets('loadBrandImage displays correct image when brandId is not null', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: loadBrandImage(1),
      ),
    ));

    expect(find.byType(Image), findsOneWidget);

    expect(find.byType(ClipRRect), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('loadBrandImage displays default image when brandId is null', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: loadBrandImage(null),
      ),
    ));

    expect(find.byType(Image), findsOneWidget);

    expect(find.byType(ClipRRect), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });
}
