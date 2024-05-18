import 'package:flutter/material.dart';
import 'package:app/model/medicaments.dart';
import 'package:app/database/local_stock.dart';

class AddMedicamentPage extends StatefulWidget {
  final Map<dynamic, dynamic>? brand;
  final String? customMedicamentName;

  const AddMedicamentPage({super.key, this.brand, this.customMedicamentName});

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
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color.fromRGBO(243, 83, 0, 1),
            colorScheme: const ColorScheme.light(primary: Color.fromRGBO(243, 83, 0, 1),),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 244, 236, 1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
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
              const Text(
                'Medicament',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color.fromRGBO(158, 66, 0, 1),
                ),
              ),
              const SizedBox(height: 6.0),
              if (widget.brand != null)
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 198, 157, 1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      if (widget.brand!['brand_id'] != null)
                        _loadMedicamentImage(int.parse(widget.brand!['brand_id'])),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Text(
                          widget.brand!['brand_name'],
                          style: const TextStyle(
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
                    color: const Color.fromRGBO(255, 198, 157, 1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      _loadMedicamentImage(null),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Text(
                          widget.customMedicamentName!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16.0),
              const Text(
                'Quantity',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color.fromRGBO(158, 66, 0, 1),
                ),
              ),
              const SizedBox(height: 6.0),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(225, 95, 0, 1),
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(
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
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
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
              const SizedBox(height: 16.0),
              const Text(
                'Expiry Date',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color.fromRGBO(158, 66, 0, 1),
                ),
              ),
              const SizedBox(height: 6.0),
              Container(
                padding: const EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(225, 95, 0, 1),
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${_expiryDate.year}-${_expiryDate.month}-${_expiryDate.day}',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  onTap: () => _selectExpiryDate(context),
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Notes',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color.fromRGBO(158, 66, 0, 1),
                ),
              ),
              const SizedBox(height: 6.0),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 198, 157, 1),
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
                  decoration: const InputDecoration(
                    hintText: 'Enter notes (if any)',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 165.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                      _saveMedicament();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(225, 95, 0, 1),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  child: const Text(
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
      Medicament newMedicament = Medicament(
        id: DateTime.now().millisecondsSinceEpoch,
        name: widget.brand != null ? widget.brand!['brand_name'] : widget.customMedicamentName!,
        quantity: _quantity,
        expiryDate: _expiryDate,
        notes: _notes,
        brandId: widget.brand != null ? int.tryParse(widget.brand!['brand_id']) : null,
      );

      int result = await _medicamentStock.insertMedicament(newMedicament);
      if (result != -1) {
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
      } else {
      }
    } catch (e) {}
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
