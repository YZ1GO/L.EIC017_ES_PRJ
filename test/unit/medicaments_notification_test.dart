import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/model/medicaments.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
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
      final medicamentNotExpired = Medicament(id: 1, name: 'Med1', expiryDate: now.subtract(const Duration(days: 1)), quantity: 0, notes: '');
      expect(medicamentNotExpired.checkExpired(), true);
    });

    test('check medicament is not expired', () {
      final now = DateTime.now();
      final medicamentNotExpired1 = Medicament(id: 1, name: 'Med1', expiryDate: now, quantity: 0, notes: '');
      final medicamentNotExpired2 = Medicament(id: 2, name: 'Med2', expiryDate: now.add(const Duration(days: 10)), quantity: 0, notes: '');
      expect(medicamentNotExpired1.checkExpired(), false);
      expect(medicamentNotExpired2.checkExpired(), false);
    });

    test('check medicament is close to expire', () async {
      final now = DateTime.now();

      final medicamentCloseToExpire4 = Medicament(
        id: 4,
        name: 'Med4',
        expiryDate: now.add(const Duration(days: 4)),
        quantity: 0,
        notes: '',
      );
      expect(await medicamentCloseToExpire4.checkCloseToExpire(), true);

      final medicamentCloseToExpire5 = Medicament(
        id: 5,
        name: 'Med5',
        expiryDate: now.add(const Duration(days: 5)),
        quantity: 0,
        notes: '',
      );
      expect(await medicamentCloseToExpire5.checkCloseToExpire(), true);

      final medicamentCloseToExpire6 = Medicament(
        id: 6,
        name: 'Med6',
        expiryDate: now.add(const Duration(days: 6)),
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