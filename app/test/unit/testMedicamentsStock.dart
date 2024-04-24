import 'package:flutter_test/flutter_test.dart';
import 'package:app/medicaments.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  group('MedicamentStock', () {
    late MedicamentStock medicamentStock;
    DateTime myDateTime = DateTime(2022, 4, 25, 12, 30, 0);
    int myMedicamentId = 99900099900;  //to avoid conflict with already exit content

    setUp(() async {
      databaseFactory = databaseFactoryFfi;
      medicamentStock = MedicamentStock();
      await medicamentStock.initDatabase();

      await medicamentStock.deleteMedicament(myMedicamentId); //delete at beginning to avoid conflict
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
  });
}
