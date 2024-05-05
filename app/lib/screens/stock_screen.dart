import 'dart:core';
import 'package:flutter/material.dart';
import 'package:app/widgets/eclipse_background.dart';
import 'package:app/database/database.dart';
import 'package:app/medicaments.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:app/widgets/edit_medicament.dart';

class StockScreen extends StatefulWidget {
  final bool selectionMode;
  Future<List<Medicament>> medicamentList;
  final VoidCallback? onMedicamentListUpdated;

  StockScreen({Key? key, required this.selectionMode, required this.medicamentList, required this.onMedicamentListUpdated});

  @override
  _StockScreenState createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  Medicament? selectedMedicament;

  static int quantityLimit = 0;

  void toggleSelection(Medicament medicament) {
    setState(() {
      if (selectedMedicament == medicament) {
        selectedMedicament = null;
      } else {
        selectedMedicament = medicament;
      }
    });
  }

  Medicament? getSelectedMedicament() {
    return selectedMedicament;
  }

  @override
  void initState() {
    super.initState();

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
                      Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Visibility(
                          visible: widget.selectionMode,
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ), // Back button
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          widget.selectionMode ?
                          (selectedMedicament == null ? 'SELECT MEDICAMENT' : '')
                              : 'MEDICINE STOCK',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            backgroundColor: Colors.transparent,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Visibility(
                        visible: selectedMedicament != null,
                        child: Center(
                          child: Container(
                            width: 120,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 4,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Medicament? selectedMedicament = getSelectedMedicament();
                                if (selectedMedicament != null) {
                                  print('Selected Medicament Details:');
                                  print('ID: ${selectedMedicament.id}');
                                  print('Name: ${selectedMedicament.name}');
                                  print('Quantity: ${selectedMedicament.quantity}');
                                  print('Expiry Date: ${selectedMedicament.expiryDate}');
                                  print('Notes: ${selectedMedicament.notes}');
                                  print('Brand ID: ${selectedMedicament.brandId}');
                                  Navigator.pop(context, selectedMedicament);
                                } else {
                                  print('Error selecting medicament (stock_screen)');
                                  Navigator.pop(context);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: const Color.fromRGBO(215, 74, 0, 1),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Done',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: !widget.selectionMode,
                  child: const SizedBox(height: 20),
                ),
                Visibility(
                  visible: !widget.selectionMode,
                    child: ElevatedButton(
                      key: Key('add new medicament button'),
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
      future: widget.medicamentList,
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
                        child: widget.selectionMode ? _buildMedicamentCard(medicaments[i], isLastItem, isSingleItem, true) : _buildMedicamentCard(medicaments[i], isLastItem, isSingleItem, false),
                      ),
                    ),
                    if (!isLastItem)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: widget.selectionMode ? _buildMedicamentCard(medicaments[i + 1], false, false, true) : _buildMedicamentCard(medicaments[i + 1], false, false, false),
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
                '\"It\'s the end of the list\"',
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

  Widget _buildMedicamentCard(Medicament medicament, bool isLastItem, bool isSingleItem, bool selectionMode) {
    bool expired = medicament.checkExpired();

    return Stack(
      children: [
        GestureDetector(
          onTap: selectionMode ? () => toggleSelection(medicament) : null,
          child: Container(
            width: MediaQuery.of(context).size.width / 2 - 20,
            child: Card(
              color: widget.selectionMode ? (selectedMedicament == medicament ? Color.fromRGBO(255, 200, 150, 1) : Color.fromRGBO(255, 220, 194, 0.5)) : Color.fromRGBO(255, 220, 194, 1),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                      visible: widget.selectionMode,
                      child: GestureDetector(
                        onTap: () {
                          toggleSelection(medicament);
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selectedMedicament == medicament ? Color.fromRGBO(243, 83, 0, 1) : Colors.grey[300],
                          ),
                          child: Icon(
                            Icons.check,
                            color: selectedMedicament == medicament ? Colors.white : Colors.transparent,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      child: Align(
                        alignment: Alignment.center,
                        child: widget.selectionMode
                            ? ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            selectedMedicament == medicament ? Colors.white.withOpacity(0) : Colors.white.withOpacity(0.5),
                            BlendMode.srcATop,
                          ),
                          child: _loadMedicamentImage(medicament.brandId),
                        ) : _loadMedicamentImage(medicament.brandId),
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
                        expired ? Text(
                          'Expired',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ) :
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
                        medicament.quantity > 0
                            ? Text(
                          '${medicament.quantity} piece(s)',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Color.fromRGBO(199, 84, 0, 1),
                            fontSize: 12,
                          ),
                        ) : Text(
                          'Out of stock',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: !widget.selectionMode,
                      child: SizedBox(height: 12),
                    ),
                    Visibility(
                      visible: !widget.selectionMode,
                      child: GestureDetector(
                        onTap: () {
                          _showEditPopUp(medicament);
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: expired ? Colors.grey : Color.fromRGBO(225, 95, 0, 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: EdgeInsets.all(6),
                          child: const Row(
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
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
                buildNameTextField(nameController),
                buildQuantityTextField(quantityController),
                buildExpiryDateRow(context, expiryDateController, medicament.expiryDate, (DateTime pickedDate) {
                  setState(() {
                    expiryDateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                  });
                }),

                buildNotesTextField(notesController),
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
                  color: Colors.red,
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
                  color: Color.fromRGBO(100, 50, 13 ,1),
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
        refreshStockList();
      } else {
        print('Failed to delete medicament');
      }
    } catch (e) {
      print('Error deleting medicament: $e');
    }
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

  void refreshStockList() {
    setState(() {
      widget.medicamentList = getMedicaments();
      widget.onMedicamentListUpdated!();
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


