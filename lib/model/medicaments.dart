import 'package:app/preferences.dart';

class Medicament {
  final int id;
  String name;
  int quantity;
  DateTime expiryDate;
  String notes;
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

  Future<bool> checkCloseToExpire() async {
    int daysBeforeExpiredValue = await Preferences().getDaysBeforeExpiry();
    DateTime now = DateTime.now();
    int differenceInDays = expiryDate.difference(now).inDays;
    return differenceInDays <= daysBeforeExpiredValue - 1;
  }


  bool checkExpired() {
    DateTime currentDate = DateTime.now();
    int differenceInDays = expiryDate.difference(currentDate).inDays;
    return differenceInDays < 0;
  }

  Future<bool> verifyStockRunningLow() async {
    int lowQuantity = await Preferences().getLowQuantity();

    if (quantity <= lowQuantity) {
      return true;
    }
    return false;
  }
}
