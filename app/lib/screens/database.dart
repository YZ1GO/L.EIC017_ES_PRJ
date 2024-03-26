import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseContentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Database Content'),
      ),
      body: StreamBuilder(
        stream: FirebaseDatabase.instance.reference().child('brands').onValue,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Extract data from snapshot
          var brandsData = snapshot.data?.snapshot.value;

          // Check if data is null or not in the expected format
          if (brandsData == null || brandsData is! List) {
            return Center(child: Text('No data available'));
          }

          // Convert List<dynamic> to List<Map<dynamic, dynamic>>
          List<Map<dynamic, dynamic>> brandList = List<Map<dynamic, dynamic>>.from(brandsData);

          // Build UI from brandList
          return ListView.builder(
            itemCount: brandList.length,
            itemBuilder: (BuildContext context, int index) {
              var brand = brandList[index];
              return ListTile(
                title: Text(brand['brand_name'] ?? ''),
                subtitle: Text(
                  'Form: ${brand['form'] ?? ''}, Strength: ${brand['strength'] ?? ''}, Price: ${brand['price'] ?? ''}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
