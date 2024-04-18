import 'package:flutter/material.dart';
import 'package:app/widgets/eclipse_background.dart';
import 'package:app/database/database.dart';
import 'package:app/medicaments.dart';
import 'package:intl/intl.dart';
import 'package:app/widgets/system_notification_test_widget.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({Key? key});

  @override
  _StockScreenState createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  late Future<List<Medicament>> _medicamentsFuture;
  late Medicament _lastDeletedMedicament;

  static int quantityLimit = 0;

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
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DatabaseContentScreen()),
                    );
                    print(Text('Add new medicament button pressed'));
                    refreshStockList();
                    print(Text('Refreshed medicaments list'));
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
                SizedBox(height: 50),
                medicamentList(),
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
            rows.add(SizedBox(height: 20));
            rows.add(Center(
              child: Text(
                '\"honk honk!\"',
                style: TextStyle(
                  color: Color.fromRGBO(199,54,00,1),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ));
            rows.add(Center(
              child: Text(
                'It\'s the end of the list\"',
                style: TextStyle(
                  color: Color.fromRGBO(199,54,00,1),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ));
            rows.add(SizedBox(height: 160));
            return Column(
              children: rows,
            );
          } else {
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 125),
                child: Text('No medicaments in stock'),
              ),
            );
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
                  _showEditPopUp(medicament);
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

  Future<void> _showEditPopUp(Medicament medicament) async {
    TextEditingController nameController = TextEditingController(text: medicament.name);
    TextEditingController quantityController = TextEditingController(text: medicament.quantity.toString());
    TextEditingController expiryDateController = TextEditingController(text: DateFormat('dd/MM/yyyy').format(medicament.expiryDate));
    TextEditingController notesController = TextEditingController(text: medicament.notes);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Medicament'),
          backgroundColor: Colors.white,
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: quantityController,
                  decoration: InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: expiryDateController,
                  decoration: InputDecoration(labelText: 'Expiry Date (dd/MM/yyyy)'),
                ),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(labelText: 'Notes'),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Color.fromRGBO(100, 50, 13 ,1),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showDeleteConfirmationPopUp(medicament);
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                _updateMedicament(
                  medicament,
                  nameController.text,
                  int.parse(quantityController.text),
                  DateFormat('dd/MM/yyyy').parse(expiryDateController.text),
                  notesController.text,
                );
                Navigator.of(context).pop();
              },
              child: Text(
                'Save',
                style: TextStyle(
                  color: Color.fromRGBO(100, 50, 13 ,1),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationPopUp(Medicament medicament) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          backgroundColor: Colors.white,
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'Are you sure you want to delete '),
                      TextSpan(
                        text: medicament.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: '?'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _deleteMedicament(medicament);
                Navigator.pop(context);
              },
              child: Text(
                'Yes',
                style: TextStyle(
                  color: Color.fromRGBO(100, 50, 13 ,1),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showEditPopUp(medicament);
              },
              child: Text(
                'No',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteMedicament(Medicament medicament) async {
    try {
      int result = await MedicamentStock().deleteMedicament(medicament.id);
      if (result > 0) {
        print('Medicament deleted successfully');
        setState(() {
          // Add the deleted medicament to the list of deleted items
          _lastDeletedMedicament = medicament;
        });
        refreshStockList();
        _showUndoSnackbar(medicament);
      } else {
        print('Failed to delete medicament');
      }
    } catch (e) {
      print('Error deleting medicament: $e');
    }
  }

  void _undoDeleteMedicament(Medicament medicament) async {
    try {
      int result = await MedicamentStock().insertMedicament(medicament);
      if (result != -1) {
        print('Medicament restored successfully');
        refreshStockList();
      } else {
        print('Failed to restore medicament');
      }
    } catch (e) {
      print('Error restoring medicament: $e');
    }
  }

  void _showUndoSnackbar(Medicament medicament) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Medicament ${medicament.name} deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            _undoDeleteMedicament(medicament);
          },
        ),
      ),
    );
  }

  void _updateMedicament(
      Medicament medicament,
      String newName,
      int newQuantity,
      DateTime newExpiryDate,
      String newNotes,
      ) async {
    Medicament updatedMedicament = Medicament(
      id: medicament.id,
      name: newName,
      quantity: newQuantity,
      expiryDate: newExpiryDate,
      notes: newNotes,
      brandId: medicament.brandId,
    );

    try {
      await MedicamentStock().updateMedicament(updatedMedicament);
      print('Medicament updated successfully');
      refreshStockList();
    } catch (e) {
      print('Error updating medicament: $e');
    }
  }

  Future<List<Medicament>> getMedicaments() async {
    return await MedicamentStock().getMedicaments();
  }

  void refreshStockList() async {
    setState(() {
      _medicamentsFuture = getMedicaments();
    });
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
            width: 90,
            height: 90,
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}
