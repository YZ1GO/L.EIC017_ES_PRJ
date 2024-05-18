import 'dart:async';
import 'package:app/model/medicaments.dart';
import 'package:app/database/local_stock.dart';
import 'package:app/notifications/system_notification.dart';

/** DAILY CHECKER **/
DateTime _lastCalledDay = DateTime.now();

void checkDayChangeInit() {
  checkDayChange();
  final now = DateTime.now();
  final midnight = DateTime(now.year, now.month, now.day + 1);
  final durationUntilMidnight = midnight.difference(now);

  Timer(durationUntilMidnight, () {
    checkDayChangeInit();
  });
}

void checkDayChange() {
  print('Check days called');
  final now = DateTime.now();
  if (_lastCalledDay.day != now.day) {
    verifyAllMedicamentCloseToExpire();
    verifyAllMedicamentExpired();

    _lastCalledDay = now;
  }
}

/// VERIFY ALL MEDICAMENTS *
void verifyAllMedicamentCloseToExpire() async {
  List<Medicament>? medicamentsToNotify = await MedicamentStock().getMedicamentsCloseToExpire();

  if (medicamentsToNotify.isEmpty) {
    return;
  }

  for (Medicament medicament in medicamentsToNotify) {
    notifyMedicamentCloseToExpire(medicament);
  }
}

void verifyAllMedicamentExpired() async {
  List<Medicament>? medicamentsToNotify = await MedicamentStock().getExpiredMedicaments();

  if (medicamentsToNotify.isEmpty) {
    return;
  }

  for (Medicament medicament in medicamentsToNotify) {
    notifyMedicamentExpired(medicament);
  }
}

/// VERIFY SINGLE MEDICAMENT *
void verifyMedicamentRunningLow(Medicament medicament) async {
  bool isRunningLow = await medicament.verifyStockRunningLow();
  if (isRunningLow) {
    notifyMedicamentRunningLow(medicament);
  }
}

void verifyMedicamentCloseToExpire(Medicament medicament) async {
  bool isCloseToExpire = await medicament.checkCloseToExpire();
  if (isCloseToExpire) {
    notifyMedicamentCloseToExpire(medicament);
  }
}

void verifyMedicamentExpired(Medicament medicament) async {
  if (medicament.checkExpired()) {
    notifyMedicamentExpired(medicament);
  }
}
