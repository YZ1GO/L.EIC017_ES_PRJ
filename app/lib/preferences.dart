import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  int lowQuantity = 0;
  int daysBeforeExpiry = 1;

  void setLowQuantity(int newQuantity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lowQuantity', newQuantity);
    lowQuantity = newQuantity;
  }

  Future<int> getLowQuantity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    lowQuantity = prefs.getInt('lowQuantity') ?? 0;
    return lowQuantity;
  }

  void setDaysBeforeExpiry(int newValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daysBeforeExpiry', newValue);
    daysBeforeExpiry = newValue;
  }

  Future<int> getDaysBeforeExpiry() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    daysBeforeExpiry = prefs.getInt('daysBeforeExpiry') ?? 1;
    return daysBeforeExpiry;
  }

}
