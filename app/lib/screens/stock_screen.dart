import 'dart:core';
import 'package:app/notifications/notification_checker.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/elipse_background.dart';
import 'package:app/database/database.dart';
import 'package:app/model/medicaments.dart';
import 'package:intl/intl.dart';
import 'package:app/widgets/edit_medicament_widgets.dart';
import 'package:app/database/local_stock.dart';

import '../model/reminders.dart';

class StockScreen extends StatefulWidget {
  final bool selectionMode;
  Future<List<Medicament>> medicamentList;
  final VoidCallback? onMedicamentListUpdated;

  StockScreen({super.key, required this.selectionMode, required this.medicamentList, required this.onMedicamentListUpdated});

  @override
  _StockScreenState createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  Medicament? selectedMedicament;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 244, 236, 1),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            const Positioned.fill(
              child: ElipseBackground(),
            ),
            Column(
              children: [
                const SizedBox(height: 60),
                Container(
                  height: kToolbarHeight,
                  color: Colors.transparent,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Visibility(
                          visible: widget.selectionMode,
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
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
                            ),
                            child: ElevatedButton(
                              onPressed: () async {
                                Medicament? selectedMedicament = getSelectedMedicament();
                                if (selectedMedicament != null) {
                                  List<Reminder> reminders = await ReminderDatabase().getReminders();
                                  bool hasReminder = reminders.any((reminder) => reminder.medicament == selectedMedicament.id);
                                  bool isExpired = selectedMedicament.checkExpired();
                                  bool isOutOfStock = selectedMedicament.quantity == 0;

                                  if (hasReminder) {
                                    showErrorDialog(context, 'You cannot select this medicament because it already has a reminder attributed.');
                                  } else if (isExpired) {
                                    showErrorDialog(context, 'You cannot select this medicament because it is expired.');
                                  } else if (isOutOfStock) {
                                    showErrorDialog(context, 'You cannot select this medicament because it is out of stock.');
                                  } else {
                                    Navigator.pop(context, selectedMedicament);
                                  }
                                } else {
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
                      key: const Key('add new medicament button'),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DatabaseContentScreen()),
                        );
                        refreshStockList();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color.fromRGBO(199, 84, 0, 1),
                        backgroundColor: const Color.fromRGBO(255, 200, 150, 1),
                        elevation: 4,
                        shadowColor: Colors.black.withOpacity(0.5),
                      ),
                      child: const Row(
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
                const SizedBox(height: 50),
                medicamentList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showErrorDialog(BuildContext context, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ERROR'),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            child: const Text(
              'OK',
              style: TextStyle(
                color: Color.fromRGBO(215, 74, 0, 1),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget medicamentList() {
    return FutureBuilder<List<Medicament>>(
      future: widget.medicamentList,
      builder: (context, snapshot) {
        List<Medicament>? medicaments = snapshot.data;
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
          rows.add(const SizedBox(height: 20));
          rows.add(const Center(
            child: Text(
              '"honk honk!"',
              style: TextStyle(
                color: Color.fromRGBO(199,54,00,1),
                fontSize: 15,
                fontWeight: FontWeight.bold,
                backgroundColor: Colors.transparent,
              ),
            ),
          ));
          rows.add(const Center(
            child: Text(
              '"It\'s the end of the list"',
              style: TextStyle(
                color: Color.fromRGBO(199,54,00,1),
                fontSize: 15,
                fontWeight: FontWeight.bold,
                backgroundColor: Colors.transparent,
              ),
            ),
          ));
          rows.add(const SizedBox(height: 160));
          return Column(
            children: rows,
          );
        } else {
          return SizedBox(
            height: 150,
            child: Card(
              color: const Color.fromRGBO(255, 218, 190, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 5,
              margin: const EdgeInsets.all(10),
              child: const Center(
                child: Text(
                  'No medicaments in stock',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(225, 95, 0, 1),
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          );
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
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 2 - 20,
            child: Card(
              color: widget.selectionMode ? (selectedMedicament == medicament ? const Color.fromRGBO(255, 200, 150, 1) : const Color.fromRGBO(255, 220, 194, 0.5)) : const Color.fromRGBO(255, 220, 194, 1),
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
                            color: selectedMedicament == medicament ? const Color.fromRGBO(243, 83, 0, 1) : Colors.grey[300],
                          ),
                          child: Icon(
                            Icons.check,
                            color: selectedMedicament == medicament ? Colors.white : Colors.transparent,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
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
                    const SizedBox(height: 6),
                    const Divider(color: Color.fromRGBO(199, 84, 0, 0.5)),
                    const SizedBox(height: 2),
                    Center(
                      child: Text(
                        medicament.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(199, 84, 0, 1),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Divider(color: Color.fromRGBO(199, 84, 0, 0.5)),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          ' Expiry',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(199, 84, 0, 1),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        expired ? const Text(
                          'Expired',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ) :
                        Text(
                          DateFormat('dd/MM/yyyy').format(medicament.expiryDate),
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Color.fromRGBO(199, 84, 0, 1),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          ' Quantity',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(199, 84, 0, 1),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        medicament.quantity > 0
                            ? Text(
                          '${medicament.quantity} piece(s)',
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Color.fromRGBO(199, 84, 0, 1),
                            fontSize: 12,
                          ),
                        ) : const Text(
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
                      child: const SizedBox(height: 12),
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
                            color: expired ? Colors.grey : const Color.fromRGBO(225, 95, 0, 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: const EdgeInsets.all(6),
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

      builder: (BuildContext context) {
        return Theme(
          data: ThemeData(
            dialogBackgroundColor: const Color.fromRGBO(255, 244, 235, 1),
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Color.fromRGBO(225, 95, 0, 1),
            ),
          ),
          child: AlertDialog(
            title: const Text('Edit Medicament'),
            backgroundColor: const Color.fromRGBO(255, 244, 235, 1),
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
                child: const Text(
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
                child: const Text(
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
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: Color.fromRGBO(100, 50, 13 ,1),
                  ),
                ),
              ),
            ],
          )
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
          title: const Text('Confirm Delete'),
          backgroundColor: Colors.white,
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Are you sure you want to delete '),
                      TextSpan(
                        text: medicament.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: '?'),
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
              child: const Text(
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
              child: const Text(
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
      await ReminderDatabase().deleteReminderByMedicamentId(medicament.id);

      int result = await MedicamentStock().deleteMedicament(medicament.id);
      if (result > 0) {
        refreshStockList();
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
      verifyMedicamentExpired(updatedMedicament);
      verifyMedicamentCloseToExpire(updatedMedicament);
      verifyMedicamentRunningLow(updatedMedicament);
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


