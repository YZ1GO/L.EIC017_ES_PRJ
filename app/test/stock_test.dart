// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_user_is_stock_screen.dart';
import './step/the_user_presses_the_add_new_medicament_button.dart';
import './step/the_user_searches_for_paracetamol.dart';
import './step/the_user_presses_the_enter_medicament_name_search_box.dart';
import './step/the_user_sees_a_list_of_medicaments_with_respectively_information_and_paracetamol_in_name.dart';
import './step/the_user_sees_a_option_to_add_custom_medicament_paracetamol.dart';

void main() {
  group('''Medicament stock add/edit medicament''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await theUserIsStockScreen(tester);
    }
    testWidgets('''Access to the medicament database''', (tester) async {
      await bddSetUp(tester);
      await theUserPressesTheAddNewMedicamentButton(tester);
      await theUserSearchesForParacetamol(tester);
      await theUserPressesTheEnterMedicamentNameSearchBox(tester);
      await theUserSeesAListOfMedicamentsWithRespectivelyInformationAndParacetamolInName(tester);
      await theUserSeesAOptionToAddCustomMedicamentParacetamol(tester);
    });
  });
}
