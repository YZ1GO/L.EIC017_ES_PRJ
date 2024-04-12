import 'package:flutter/material.dart';

class AddMedicamentPage extends StatefulWidget {
  @override
  _AddMedicamentPageState createState() => _AddMedicamentPageState();
}

class _AddMedicamentPageState extends State<AddMedicamentPage> {
  int _quantity = 1;
  DateTime _expiryDate = DateTime.now();
  String _notes = '';

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _expiryDate)
      setState(() {
        _expiryDate = picked;
      });
  }

  void _openMedicamentDetailsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicamentDetailsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Medicament'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Quantity'),
            SizedBox(height: 8.0),
            Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      if (_quantity > 1) _quantity--;
                    });
                  },
                ),
                Text('$_quantity'),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Text('Expiry Date'),
            SizedBox(height: 8.0),
            ListTile(
              title: Text('${_expiryDate.year}-${_expiryDate.month}-${_expiryDate.day}'),
              onTap: () => _selectExpiryDate(context),
            ),
            SizedBox(height: 16.0),
            Text('Notes'),
            SizedBox(height: 8.0),
            TextField(
              onChanged: (value) {
                setState(() {
                  _notes = value;
                });
              },
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter notes (if any)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            GestureDetector(
              onTap: () => _openMedicamentDetailsPage(context),
              child: IconButton(
                onPressed: () {
                  // Add your action here
                },
                icon: Icon(Icons.medical_services_outlined),
                iconSize: 40,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MedicamentDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicament Details'),
      ),
      body: Center(
        child: Text('This is the medicament details page.'),
      ),
    );
  }
}