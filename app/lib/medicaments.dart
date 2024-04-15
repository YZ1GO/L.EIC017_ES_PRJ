import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Medicament {
  final int id;
  final String name;
  final int quantity;
  final DateTime expiryDate;
  final String notes;
  final int? brandId;

  Medicament({
    required this.id,
    required this.name,
    required this.quantity,
    required this.expiryDate,
    required this.notes,
    this.brandId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'expiryDate': expiryDate.millisecondsSinceEpoch,
      'notes': notes,
      'brandId': brandId,
    };
  }

  factory Medicament.fromMap(Map<String, dynamic> map) {
    return Medicament(
      id: map['id'],
      name: map['name'],
      quantity: map['quantity'],
      expiryDate: DateTime.fromMillisecondsSinceEpoch(map['expiryDate']),
      notes: map['notes'],
      brandId: map['brandId'],
    );
  }
}

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
}
