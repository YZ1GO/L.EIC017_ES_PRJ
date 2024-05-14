import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/model/medicaments.dart';
import 'package:app/database/local_stock.dart';

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

      const initialQuantity = 10;
      const updatedQuantity = 9;

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
    setUp(() async {
      final mockSharedPreferences = MockSharedPreferences();
      when(mockSharedPreferences.getInt('lowQuantity')).thenReturn(3);
      when(mockSharedPreferences.getInt('daysBeforeExpiry')).thenReturn(5);
      SharedPreferences.setMockInitialValues({
        'lowQuantity': 3,
        'daysBeforeExpiry': 5,
      });
    });

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

    test('check medicament is close to expire', () async {
      final now = DateTime.now();

      final medicamentCloseToExpire4 = Medicament(
        id: 4,
        name: 'Med4',
        expiryDate: now.add(Duration(days: 4)),
        quantity: 0,
        notes: '',
      );
      expect(await medicamentCloseToExpire4.checkCloseToExpire(), true);

      final medicamentCloseToExpire5 = Medicament(
        id: 5,
        name: 'Med5',
        expiryDate: now.add(Duration(days: 5)),
        quantity: 0,
        notes: '',
      );
      expect(await medicamentCloseToExpire5.checkCloseToExpire(), true);

      final medicamentCloseToExpire6 = Medicament(
        id: 6,
        name: 'Med6',
        expiryDate: now.add(Duration(days: 6)),
        quantity: 0,
        notes: '',
      );
      expect(await medicamentCloseToExpire6.checkCloseToExpire(), false);
    });

    test('check medicament is running low', () async {
      final medicamentRunningLow1 = Medicament(
        id: 1,
        name: 'Med1',
        expiryDate: DateTime.now(),
        quantity: 4,
        notes: '',
      );
      expect(await medicamentRunningLow1.verifyStockRunningLow(), false);

      final medicamentRunningLow2 = Medicament(
        id: 2,
        name: 'Med2',
        expiryDate: DateTime.now(),
        quantity: 3,
        notes: '',
      );
      expect(await medicamentRunningLow2.verifyStockRunningLow(), true);

      final medicamentRunningLow3 = Medicament(
        id: 3,
        name: 'Med3',
        expiryDate: DateTime.now(),
        quantity: 2,
        notes: '',
      );
      expect(await medicamentRunningLow3.verifyStockRunningLow(), true);

      final medicamentRunningLow4 = Medicament(
        id: 4,
        name: 'Med4',
        expiryDate: DateTime.now(),
        quantity: 0,
        notes: '',
      );
      expect(await medicamentRunningLow4.verifyStockRunningLow(), true);
    });
  });
}
