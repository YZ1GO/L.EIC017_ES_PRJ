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
  late Future<List<Medicament>> _medicamentsFuture; // Declare as a member variable

  @override
  void initState() {
    super.initState();
    _medicamentsFuture = getMedicaments(); // Initialize the future in initState
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
                  child: Center(
                    child: Text(
                      'MEDICINE STOCK',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DatabaseContentScreen())
                    );
                  },
                  child: Text('Add New Medicament'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _medicamentsFuture = getMedicaments();
                    });
                  },
                  child: Text('Refresh Stock'),
                ),
                SizedBox(height: 20),
                medicamentList(),
                SizedBox(height: 20),
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
            // Create a list to hold rows of medicament cards
            List<Widget> rows = [];
            // Iterate through the list of medicaments, two at a time
            for (int i = 0; i < medicaments.length; i += 2) {
              // Create a row to hold two medicament cards
              Widget row = Container(
                width: MediaQuery.of(context).size.width, // Full width of the screen
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Adjust as needed
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _buildMedicamentCard(medicaments[i]),
                      ),
                    ),
                    if (i + 1 < medicaments.length) // Check if there's another medicament to display
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: _buildMedicamentCard(medicaments[i + 1]),
                        ),
                      ),
                  ],
                ),
              );
              rows.add(row); // Add the row to the list
            }
            // Return a column with rows of medicament cards
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

  Widget _buildMedicamentCard(Medicament medicament) {
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 20, // Adjust the width as needed
      child: Card(
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
              SizedBox(height: 10),
              Center(
                child: Text(
                  medicament.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Expiry',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(medicament.expiryDate),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quantity',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${medicament.quantity} piece(s)',
                  ),
                ],
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  // Handle edit action here
                  // For example, navigate to an edit screen or show a modal bottom sheet for editing
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: EdgeInsets.all(8),
                  child: Center(
                    child: Text(
                      'Edit',
                      style: TextStyle(color: Colors.white),
                    ),
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
