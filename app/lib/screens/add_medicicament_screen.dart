import 'package:flutter/material.dart';

class AddMedicamentPage extends StatefulWidget {
  final Map<dynamic, dynamic>? brand;
  final String? customMedicamentName;

  const AddMedicamentPage({Key? key, this.brand, this.customMedicamentName}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 244, 236, 1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Add Medicament'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Medicament Name:'),
              SizedBox(height: 8.0),
              if (widget.brand != null)
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 198, 157, 1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    widget.brand!['brand_name'],
                    textAlign: TextAlign.center,
                  ),
                ),
              if (widget.customMedicamentName != null)
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 198, 157, 1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    widget.customMedicamentName!,
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(height: 32.0),
              Text('Quantity'),
              SizedBox(height: 8.0),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 95, 0, 1),
                  borderRadius: BorderRadius.circular(18.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.remove,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_quantity > 1) _quantity--;
                        });
                      },
                    ),
                    Text(
                      '$_quantity',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _quantity++;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.0),
              Text('Expiry Date'),
              SizedBox(height: 8.0),
              Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 95, 0, 1),
                  borderRadius: BorderRadius.circular(18.0),
                ),
                padding: EdgeInsets.all(2.0),
                child: ListTile(
                  title: Text(
                    '${_expiryDate.year}-${_expiryDate.month}-${_expiryDate.day}',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  onTap: () => _selectExpiryDate(context),
                ),
              ),
              SizedBox(height: 32.0),
              Text('Notes'),
              SizedBox(height: 8.0),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 198, 157, 1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _notes = value;
                    });
                  },
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter notes (if any)',
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 64.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // to be add
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(255, 95, 0, 1),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
