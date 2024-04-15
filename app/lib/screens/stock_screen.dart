import 'package:flutter/material.dart';
import 'package:app/widgets/eclipse_background.dart';
import 'package:app/screens/database.dart';
import 'package:app/medicaments.dart';
import 'package:intl/intl.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({Key? key});

  @override
  _StockScreenState createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  late Future<List<Medicament>> _medicamentsFuture;

  @override
  void initState() {
    super.initState();
    _medicamentsFuture = getMedicaments();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 244, 236, 1),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Positioned.fill(
              child: eclipse_background(),
            ),
            Column(
              children: [
                SizedBox(height: 60),
                Container(
                  height: kToolbarHeight,
                  color: Colors.transparent,
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          'MEDICINE STOCK',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            backgroundColor: Colors.transparent,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DatabaseContentScreen()),
                    );
                    print(Text('Add new medicament button pressed'));
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color.fromRGBO(199, 84, 0, 1),
                    backgroundColor: Color.fromRGBO(255, 200, 150, 1),
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add,
                        color: Color.fromRGBO(199, 84, 0, 1),
                        size: 14,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Add new medicament',
                        style: TextStyle(
                          color: Color.fromRGBO(199, 84, 0, 1),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _medicamentsFuture = getMedicaments();
                    });
                    print(Text('refresh button pressed'));
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color.fromRGBO(199, 84, 0, 1),
                    backgroundColor: Color.fromRGBO(255, 200, 150, 1),
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh,
                        color: Color.fromRGBO(199, 84, 0, 1),
                        size: 14,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Refresh',
                        style: TextStyle(
                          color: Color.fromRGBO(199, 84, 0, 1),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                medicamentList(),
                SizedBox(height: 20),
                Center(
                  child: Text(
                    '\"honk honk! It\'s the end!\"',
                    style: TextStyle(
                      color: Color.fromRGBO(199,54,00,1),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
                SizedBox(height: 160),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget medicamentList() {
    return FutureBuilder<List<Medicament>>(
      future: _medicamentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<Medicament>? medicaments = snapshot.data;
          print('Stock items ${medicaments?.length ?? 0}');
          if (medicaments != null && medicaments.isNotEmpty) {
            medicaments.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
            List<Widget> rows = [];
            for (int i = 0; i < medicaments.length; i += 2) {
              bool isLastItem = i + 1 == medicaments.length;
              bool isSingleItem = !isLastItem && i + 2 == medicaments.length;
              Widget row = Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      flex: isSingleItem ? 1 : 0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _buildMedicamentCard(medicaments[i], isLastItem, isSingleItem),
                      ),
                    ),
                    if (!isLastItem)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _buildMedicamentCard(medicaments[i + 1], false, false),
                        ),
                      ),
                  ],
                ),
              );
              rows.add(row);
            }
            return Column(
              children: rows,
            );
          } else {
            return Center(child: Text('No medicaments in stock'));
          }
        }
      },
    );
  }

  Widget _buildMedicamentCard(Medicament medicament, bool isLastItem, bool isSingleItem) {
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 20,
      child: Card(
        color: Color.fromRGBO(255, 220, 194, 1),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Container(
                child: Align(
                  alignment: Alignment.center,
                  child: _loadMedicamentImage(medicament.brandId),
                ),
              ),
              SizedBox(height: 6),
              Divider(color: Color.fromRGBO(199, 84, 0, 0.5)),
              SizedBox(height: 2),
              Center(
                child: Text(
                  medicament.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(199, 84, 0, 1),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 2),
              Divider(color: Color.fromRGBO(199, 84, 0, 0.5)),
              SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ' Expiry',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(199, 84, 0, 1),
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(medicament.expiryDate),
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(199, 84, 0, 1),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ' Quantity',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(199, 84, 0, 1),
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                      '${medicament.quantity} piece(s)',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(199, 84, 0, 1),
                        fontSize: 12,
                      )
                  ),
                ],
              ),
              SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  print(Text('TO BE DONE'));
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(225, 95, 0, 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: EdgeInsets.all(6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit,
                        color: Color.fromRGBO(255, 220, 194, 1),
                        size: 14,
                      ),
                      SizedBox(width: 9),
                      Text(
                        'Edit',
                        style: TextStyle(
                          color: Color.fromRGBO(255, 220, 194, 1),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Medicament>> getMedicaments() async {
    return await MedicamentStock().getMedicaments();
  }

  Widget _loadMedicamentImage(int? brandId) {
    String imagePath = brandId != null ? 'assets/database/$brandId.jpg' : 'assets/database/default.jpg';
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.asset(
        imagePath,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/database/default.jpg',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}
