import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:app/preferences.dart';
import 'package:app/model/medicaments.dart';
import 'package:app/notifications/system_notification.dart';

class MedicamentStock {
  static final MedicamentStock _instance = MedicamentStock._internal();
  late Database _database;

  factory MedicamentStock() => _instance;

  MedicamentStock._internal();

  Future<void> initDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    final String path = join(await getDatabasesPath(), 'medicaments_database.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
            '''
          CREATE TABLE medicaments(
            id INTEGER PRIMARY KEY,
            name TEXT,
            quantity INTEGER,
            expiryDate INTEGER,
            notes TEXT,
            brandId INTEGER
          )
          '''
        );
      },
    );
  }

  Future<int> insertMedicament(Medicament medicament) async {
    try {
      final int id = await _database.insert('medicaments', medicament.toMap());
      print('Inserted medicament ${medicament.name}');
      return id;
    } catch (e) {
      print('Error inserting medicament: $e');
      return -1;
    }
  }

  Future<Medicament?> getMedicamentById(int id) async {
    try {
      List<Map<String, dynamic>> maps = await _database.query(
        'medicaments',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return Medicament.fromMap(maps.first);
      } else {
        print('Medicament not found with ID: $id');
        return null;
      }
    } catch (e) {
      print('Error fetching medicament: $e');
      return null;
    }
  }

  Future<List<Medicament>> getMedicaments() async {
    try {
      final List<Map<String, dynamic>> maps = await _database.query('medicaments');
      print('Getting medicaments list');
      return List.generate(maps.length, (i) {
        return Medicament.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error fetching medicaments: $e');
      return [];
    }
  }

  Future<int> deleteMedicament(int id) async {
    try {
      int rowsDeleted = await _database.delete(
        'medicaments',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsDeleted > 0) {
        print('Deleted medicament with ID: $id');
      } else {
        print('No medicament found with ID: $id');
      }

      return rowsDeleted;
    } catch (e) {
      print('Error deleting medicament: $e');
      return -1;
    }
  }

  Future<void> updateMedicament(Medicament updatedMedicament) async {
    try {
      await _database.update(
        'medicaments',
        updatedMedicament.toMap(),
        where: 'id = ?',
        whereArgs: [updatedMedicament.id],
      );
      print('Updated medicament ${updatedMedicament.name}');
      verifyStockRunningLow(updatedMedicament);
    } catch (e) {
      print('Error updating medicament: $e');
    }
  }

  Future<void> changeMedicamentQuantity(Medicament medicament, int newQuantity) async {
    if (newQuantity < 0) {
      print('Quantity cannot be negative integer');
      return;
    }
    try {
      Medicament? currentMedicament = await getMedicamentById(medicament.id);

      if (currentMedicament != null) {
        currentMedicament.quantity = newQuantity;
        await updateMedicament(currentMedicament);
        print('Updated quantity for medicament ${medicament.name} to $newQuantity');
        verifyStockRunningLow(currentMedicament);
      } else {
        print('Medicament not found in the database');
      }
    } catch (e) {
      print('Error changing medicament quantity: $e');
    }
  }

  Future<List<Medicament>> getMedicamentsCloseToExpire() async {
    int daysBeforeExpiredValue = await Preferences().getDaysBeforeExpiry();
    List<Medicament> closeToExpiryMedicaments = [];
    List<Medicament> currentMedicamentsStock = await getMedicaments();

    DateTime now = DateTime.now();
    for (Medicament medicament in currentMedicamentsStock) {
      if (now.difference(medicament.expiryDate).inDays == daysBeforeExpiredValue) {
        closeToExpiryMedicaments.add(medicament);
      }
    }
    return closeToExpiryMedicaments;
  }

  Future<List<Medicament>> getExpiredMedicaments() async {
    List<Medicament> expiredMedicaments = [];
    List<Medicament> currentMedicamentsStock = await getMedicaments();
    DateTime now = DateTime.now();
    for (Medicament medicament in currentMedicamentsStock) {
      if (medicament.expiryDate.isAtSameMomentAs(now)) {
        expiredMedicaments.add(medicament);
      }
    }
    return expiredMedicaments;
  }
}