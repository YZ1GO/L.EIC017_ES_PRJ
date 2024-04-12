import 'package:app/screens/add_medicicament_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/eclipse_background.dart';
import 'database.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 244, 236, 1),
      body: Stack(
        children: [
          Positioned.fill(
            child: eclipse_background(),
          ),
          SingleChildScrollView(
            physics: ScrollPhysics(),
            child: Column(
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
                SizedBox(height: 70),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 155,
                          height: 240,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Container(
                              width: 77,
                              height: 77,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Color.fromRGBO(58, 44, 0, 1),
                                  width: 1.5,
                                )
                              ),
                              child: Center(
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(255, 220, 194, 1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => DatabaseContentScreen()),
                                      );
                                    },
                                    icon: Icon(Icons.add),
                                    iconSize: 25,
                                    color: Color.fromRGBO(58, 44, 0, 1),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 15),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 155,
                          height: 240,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(255, 220, 194, 1),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 4,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => AddMedicamentPage()),
                              );
                            },
                            icon: Icon(Icons.medical_services_outlined),
                            iconSize: 40,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 155,
                          height: 240,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(255, 220, 194, 1),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 4,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
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
                    SizedBox(width: 15),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 155,
                          height: 240,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(255, 220, 194, 1),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 4,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () {
                            },
                            icon: Icon(Icons.medical_services_outlined),
                            iconSize: 40,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 155,
                          height: 240,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(255, 220, 194, 1),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 4,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
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
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  height: kToolbarHeight,
                  color: Colors.transparent,
                  child: Center(
                    child: Text(
                      '\"honk honk! It\'s the end!\"',
                      style: TextStyle(
                        color: Color.fromRGBO(199,54,00,1),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 150),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your action here
        },
        child: Icon(Icons.add),
        backgroundColor: Color.fromRGBO(255, 220, 194, 1),
      ),
    );
  }
}
