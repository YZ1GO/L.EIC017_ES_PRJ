import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/medicaments.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  sqfliteFfiInit();

  group('MedicamentStock', () {
    late MedicamentStock medicamentStock;
    DateTime myDateTime = DateTime(2022, 4, 25, 12, 30, 0);
    int myMedicamentId = 99900099900;  //to avoid conflict with already existing content

    setUp(() async {
      databaseFactory = databaseFactoryFfi;
      medicamentStock = MedicamentStock();
      SharedPreferences.setMockInitialValues({});
      final mockSharedPreferences = MockSharedPreferences();
      when(mockSharedPreferences.getInt('lowQuantity')).thenReturn(0);
      when(mockSharedPreferences.getInt('daysBeforeExpiry')).thenReturn(1);
      SharedPreferences.setMockInitialValues({});
      await medicamentStock.initDatabase();
      await medicamentStock.deleteMedicament(myMedicamentId); //delete at the beginning to avoid conflict
    });

    test('Insert and remove medicament', () async {
      final medicament = Medicament(
        id: myMedicamentId,
        name: 'Test Medicament',
        quantity: 10,
        expiryDate: myDateTime,
        notes: 'Test notes',
        brandId: 123,
      );

      final insertedId = await medicamentStock.insertMedicament(medicament);
      expect(insertedId, myMedicamentId);

      final rowsDeleted = await medicamentStock.deleteMedicament(myMedicamentId);
      expect(rowsDeleted, 1);
    });

    test('Insert and retrieve medicament', () async {
      final medicament = Medicament(
        id: myMedicamentId,
        name: 'Test Medicament',
        quantity: 10,
        expiryDate: myDateTime,
        notes: 'Test notes',
        brandId: 123,
      );

      final insertedId = await medicamentStock.insertMedicament(medicament);
      expect(insertedId, myMedicamentId);

      final retrievedMedicament = await medicamentStock.getMedicamentById(myMedicamentId);
      expect(retrievedMedicament?.id, myMedicamentId);
      expect(retrievedMedicament?.name, 'Test Medicament');
      expect(retrievedMedicament?.quantity, 10);
    });

    test('Insert and update medicament quantity', () async {
      await medicamentStock.deleteMedicament(myMedicamentId);

      final initialQuantity = 10;
      final updatedQuantity = 9;

      final medicament = Medicament(
        id: myMedicamentId,
        name: 'Test Medicament',
        quantity: initialQuantity,
        expiryDate: myDateTime,
        notes: 'Test notes',
        brandId: 123,
      );

      await medicamentStock.insertMedicament(medicament);
      final retrievedMedicament = await medicamentStock.getMedicamentById(myMedicamentId);
      expect(retrievedMedicament?.quantity, initialQuantity);

      await medicamentStock.changeMedicamentQuantity(medicament, updatedQuantity);
      final retrievedMedicament2 = await medicamentStock.getMedicamentById(myMedicamentId);
      expect(retrievedMedicament2?.quantity, updatedQuantity);
    });

    test('Insert and update medicament information', () async {
      await medicamentStock.deleteMedicament(myMedicamentId);

      final medicament = Medicament(
        id: myMedicamentId,
        name: 'Test Medicament 1',
        quantity: 10000000000,
        expiryDate: myDateTime,
        notes: 'Test notes 1',
        brandId: 123,
      );

      DateTime newDateTime = DateTime(1234, 4, 25, 12, 30, 0);
      final updatedMedicament = Medicament(
        id: myMedicamentId,
        name: 'Test Medicament 2',
        quantity: 10000000001,
        expiryDate: newDateTime,
        notes: 'Test notes 2',
        brandId: 124,
      );

      await medicamentStock.insertMedicament(medicament);
      await medicamentStock.updateMedicament(updatedMedicament);
      final retrievedMedicament = await medicamentStock.getMedicamentById(myMedicamentId);
      expect(retrievedMedicament?.name, 'Test Medicament 2');
      expect(retrievedMedicament?.quantity, 10000000001);
      expect(retrievedMedicament?.expiryDate, newDateTime);
      expect(retrievedMedicament?.notes, 'Test notes 2');
      expect(retrievedMedicament?.brandId, 124);
    });
  });

  group('Medicaments related to Notification', () {
    test('check medicament is expired', () {
      final now = DateTime.now();
      final medicamentNotExpired = Medicament(id: 1, name: 'Med1', expiryDate: now.subtract(Duration(days: 1)), quantity: 0, notes: '');
      expect(medicamentNotExpired.checkExpired(), true);
    });

    test('check medicament is not expired', () {
      final now = DateTime.now();
      final medicamentNotExpired1 = Medicament(id: 1, name: 'Med1', expiryDate: now, quantity: 0, notes: '');
      final medicamentNotExpired2 = Medicament(id: 2, name: 'Med2', expiryDate: now.add(Duration(days: 10)), quantity: 0, notes: '');
      expect(medicamentNotExpired1.checkExpired(), false);
      expect(medicamentNotExpired2.checkExpired(), false);
    });
  });

}
