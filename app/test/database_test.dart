// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_user_is_in_stock_screen.dart';
import './step/the_user_presses_the_button.dart';
import './step/the_user_searches_for.dart';
import './step/the_user_presses_the_search_box.dart';
import './step/the_user_sees_a_list_of_medicaments_with_respectively_information_with_in_name.dart';
import './step/the_user_sees_a_option_to.dart';

void main() {
  group('''Medicament database''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await theUserIsInStockScreen(tester);
    }
    testWidgets('''Access to the medicament database''', (tester) async {
      await bddSetUp(tester);
      await theUserPressesTheButton(tester, 'Add new medicament');
      await theUserSearchesFor(tester, 'paracetamol');
      await theUserPressesTheSearchBox(tester, 'Enter medicament name');
      await theUserSeesAListOfMedicamentsWithRespectivelyInformationWithInName(tester, 'paracetamol');
      await theUserSeesAOptionTo(tester, 'Add Custom Medicament: paracetamol');
    });
  });
}
