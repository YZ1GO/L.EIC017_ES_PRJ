import 'package:flutter/material.dart';

class Database extends StatelessWidget {
  const Database({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 450,
      left: (MediaQuery.of(context).size.width - 150) / 2,
      child: ElevatedButton(
        onPressed: () {

        },
        child: const Text('Test Firebase database'),
        style: ElevatedButton.styleFrom(
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.5),
          backgroundColor: Color.fromRGBO(255, 131, 41, 1),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
