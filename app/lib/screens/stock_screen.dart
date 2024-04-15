import 'package:flutter/material.dart';
import 'package:app/widgets/eclipse_background.dart';
import 'package:app/screens/database.dart';
import 'package:app/medicaments.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 244, 236, 1),
      body: Stack(
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _medicamentsFuture = getMedicaments(); // Update the future to refresh the stock
                  });
                },
                child: Text('Refresh Stock'),
              ),
              SizedBox(height: 20),
              Expanded(
                child: medicamentList(),
              ),
              SizedBox(height: 150),
            ],
          ),
        ],
      ),
    );
  }

  Widget medicamentList() {
    return FutureBuilder<List<Medicament>>(
      future: _medicamentsFuture, // Use the member variable
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<Medicament>? medicaments = snapshot.data; // Get the medicaments from snapshot
          print('Stock items ${medicaments?.length ?? 0}');
          if (medicaments != null && medicaments.isNotEmpty) {
            return ListView.builder(
              itemCount: medicaments.length,
              itemBuilder: (context, index) {
                Medicament medicament = medicaments[index];
                return ListTile(
                  title: Text(medicament.name),
                  subtitle: Text('Quantity: ${medicament.quantity}'),
                );
              },
            );
          } else {
            return Center(child: Text('No medicaments in stock'));
          }
        }
      },
    );
  }

  Future<List<Medicament>> getMedicaments() async {
    return await MedicamentStock().getMedicaments();
  }
}
