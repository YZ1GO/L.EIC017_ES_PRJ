import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final List<String> medications = [
    'Aspirin',
    'Paracetamol',
    'Ibuprofen',
    'Amoxicillin',
    'Loratadine',
  ];

  List<String> suggestions = [];

  void onTextChanged(String searchMedication) {
    setState(() {
      if (searchMedication.isEmpty) {
        suggestions = []; // Clear suggestions if the search box is empty
      } else {
        suggestions = medications
            .where((medication) =>
            medication.toLowerCase().contains(searchMedication.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Medications'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (searchMedication) {
                onTextChanged(searchMedication);
              },
              decoration: const InputDecoration(
                labelText: 'Search',
                hintText: 'Type medication name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
              child: ListView.builder(
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(suggestions[index]),
                    onTap: () {
                      // action when selected medication
                      print('Selected medication: ${suggestions[index]}');
                    },
                  );
                },
              )
          )
        ],
      ),
    );
  }
}