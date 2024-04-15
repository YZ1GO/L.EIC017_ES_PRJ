import 'package:flutter/material.dart';
import 'package:app/medicaments.dart';

class AddMedicamentPage extends StatefulWidget {
  final Map<dynamic, dynamic>? brand;
  final String? customMedicamentName;

  const AddMedicamentPage({Key? key, this.brand, this.customMedicamentName}) : super(key: key);

  @override
  _AddMedicamentPageState createState() => _AddMedicamentPageState();
}

class _AddMedicamentPageState extends State<AddMedicamentPage> {
  final MedicamentStock _medicamentStock = MedicamentStock();

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
        title: Text(
          'ADD MEDICAMENT',
          style: TextStyle(
            color: Color.fromRGBO(158, 66, 0, 1),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Medicament',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color.fromRGBO(158, 66, 0, 1),
                ),
              ),
              SizedBox(height: 6.0),
              if (widget.brand != null)
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 198, 157, 1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      if (widget.brand!['brand_id'] != null)
                        _loadMedicamentImage(int.parse(widget.brand!['brand_id'])),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: Text(
                          widget.brand!['brand_name'],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,

                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (widget.customMedicamentName != null)
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 198, 157, 1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      _loadMedicamentImage(null), // Use default image
                      SizedBox(width: 16.0),
                      Expanded(
                        child: Text(
                          widget.customMedicamentName!,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 16.0),
              Text(
                'Quantity',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color.fromRGBO(158, 66, 0, 1),
                ),
              ),
              SizedBox(height: 6.0),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(225, 95, 0, 1),
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.25),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
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
              SizedBox(height: 16.0),
              Text(
                'Expiry Date',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color.fromRGBO(158, 66, 0, 1),
                ),
              ),
              SizedBox(height: 6.0),
              Container(
                padding: EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(225, 95, 0, 1),
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.25),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Text(
                        '${_expiryDate.year}-${_expiryDate.month}-${_expiryDate.day}',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  onTap: () => _selectExpiryDate(context),
                ),
              ),

              SizedBox(height: 16.0),
              Text(
                'Notes',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color.fromRGBO(158, 66, 0, 1),
                ),
              ),
              SizedBox(height: 6.0),
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
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Enter notes (if any)',
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 165.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                      _saveMedicament();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(225, 95, 0, 1),
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

  void _saveMedicament() async {
    try {
      // Prepare Medicament object
      Medicament newMedicament = Medicament(
        id: DateTime.now().millisecondsSinceEpoch, // Unique ID
        name: widget.brand != null ? widget.brand!['brand_name'] : widget.customMedicamentName!,
        quantity: _quantity,
        expiryDate: _expiryDate,
        notes: _notes,
        brandId: widget.brand != null ? widget.brand!['brand_id'] : null,
      );

      int result = await _medicamentStock.insertMedicament(newMedicament);
      if (result != -1) {
        print('Medicament added successfully');
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
      } else {
        print('Failed to add medicament');
      }
    } catch (e) {
      // Handle any exceptions
      print('Error saving medicament: $e');
    }
  }


  Widget _loadMedicamentImage(int? brandId) {
    String imagePath = brandId != null ? 'assets/database/$brandId.jpg' : 'assets/database/default.jpg';
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.asset(
        imagePath,
        width: 50,
        height: 50,
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
