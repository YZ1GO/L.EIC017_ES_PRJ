import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget buildNameTextField(TextEditingController nameController) {
  return TextField(
    controller: nameController,
    decoration: const InputDecoration(
      labelText: 'Name',
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color.fromRGBO(243, 83, 0, 1)),
      ),
    ),
  );
}

Widget buildQuantityTextField(TextEditingController quantityController) {
  return TextField(
    controller: quantityController,
    decoration: const InputDecoration(
      labelText: 'Quantity',
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color.fromRGBO(243, 83, 0, 1)),
      ),
    ),
    keyboardType: TextInputType.number,
    inputFormatters: <TextInputFormatter>[
      FilteringTextInputFormatter.digitsOnly,
      FilteringTextInputFormatter.allow(RegExp(r'^[0-9]\d*')),
    ],
  );
}

Widget buildExpiryDateRow(BuildContext context, TextEditingController expiryDateController, DateTime initialDate, Function(DateTime) onDateSelected) {
  return Row(
    children: <Widget>[
      Expanded(
        child: GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: DateTime(DateTime.now().year, 1, 1),
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
            if (picked != null) {
              onDateSelected(picked);
            }
          },
          child: AbsorbPointer(
            child: TextField(
              controller: expiryDateController,
              decoration: const InputDecoration(
                labelText: 'Expiry Date (dd/mm/yyyy)',
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color.fromRGBO(243, 83, 0, 1)),
                ),
              ),
              readOnly: true,
            ),
          ),
        ),
      ),
    ],
  );
}


Widget buildNotesTextField(TextEditingController notesController) {
  return TextField(
    controller: notesController,
    decoration: const InputDecoration(
      labelText: 'Notes',
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color.fromRGBO(243, 83, 0, 1)),
      ),
    ),
  );
}


