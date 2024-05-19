import 'dart:async';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:app/model/medicaments.dart';

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
      return id;
    } catch (e) {
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
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<List<Medicament>> getMedicaments() async {
    try {
      final List<Map<String, dynamic>> maps = await _database.query('medicaments');
      return List.generate(maps.length, (i) {
        return Medicament.fromMap(maps[i]);
      });
    } catch (e) {
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
      }

      return rowsDeleted;
    } catch (e) {
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
    } catch (e) {
    }
  }

  Future<int> getMedicamentQuantity(Medicament medicament) async {
    try {
      Medicament? currentMedicament = await getMedicamentById(medicament.id);

      if (currentMedicament != null) {
        return currentMedicament.quantity;
      } else {
        print('Medicament not found in the database');
        return -1;
      }
    } catch (e) {
      print('Error fetching medicament quantity: $e');
      return -1;
    }
  }

  Future<Medicament?> changeMedicamentQuantity(Medicament medicament, int newQuantity) async {
    if (newQuantity < 0) {
      return null;
    }
    try {
      Medicament? currentMedicament = await getMedicamentById(medicament.id);

      if (currentMedicament != null) {
        currentMedicament.quantity = newQuantity;
        await updateMedicament(currentMedicament);
      }

      return currentMedicament;
    } catch (e) {
      print('Error changing medicament quantity: $e');
    }
    return null;
  }

  Future<List<Medicament>> getMedicamentsCloseToExpire() async {
    List<Medicament> closeToExpiryMedicaments = [];
    List<Medicament> currentMedicamentsStock = await getMedicaments();


    for (Medicament medicament in currentMedicamentsStock) {
      if (medicament.checkCloseToExpire() == true) {
        closeToExpiryMedicaments.add(medicament);
      }
    }
    return closeToExpiryMedicaments;
  }

  Future<List<Medicament>> getExpiredMedicaments() async {
    List<Medicament> expiredMedicaments = [];
    List<Medicament> currentMedicamentsStock = await getMedicaments();
    for (Medicament medicament in currentMedicamentsStock) {
      if (medicament.checkExpired()) {
        expiredMedicaments.add(medicament);
      }
    }
    return expiredMedicaments;
  }
}