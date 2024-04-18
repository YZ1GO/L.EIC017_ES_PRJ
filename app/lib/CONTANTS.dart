import 'package:shared_preferences/shared_preferences.dart';

class CONSTANTS {
  int lowQuantity = 0;

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

}
