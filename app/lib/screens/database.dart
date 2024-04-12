import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:app/screens/add_medicicament_screen.dart';

class DatabaseContentScreen extends StatefulWidget {
  @override
  _DatabaseContentScreenState createState() => _DatabaseContentScreenState();
}

class _DatabaseContentScreenState extends State<DatabaseContentScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Map<dynamic, dynamic>>? _brandList; // Initialize as null

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Database Content'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: BrandSearchDelegate(brandList: _brandList ?? []),
              );
            },
          ),
        ],
      ),
      body: _buildBrandList(),
    );
  }

  Widget _buildBrandList() {
    if (_brandList == null) {
      return Center(child: CircularProgressIndicator()); // Show a loading indicator while fetching data
    } else if (_brandList!.isEmpty) {
      return Center(child: Text('No data available')); // Show message if data is fetched but empty
    } else {
      return ListView.builder(
        itemCount: _brandList!.length,
        itemBuilder: (BuildContext context, int index) {
          var brand = _brandList![index];
          return ListTile(
            title: Text(brand['brand_name'] ?? ''),
            subtitle: Text(
              'Form: ${brand['form'] ?? ''}, Strength: ${brand['strength'] ?? ''}, Price: ${brand['price'] ?? ''}',
            ),
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData(); // Call function to fetch data when screen initializes
  }

  void _fetchData() {
    FirebaseDatabase.instance.reference().child('brands').onValue.listen((event) {
      var brandsData = event.snapshot.value;

      if (brandsData != null && brandsData is List) {
        setState(() {
          _brandList = List<Map<dynamic, dynamic>>.from(brandsData);
        });
      } else {
        setState(() {
          _brandList = []; // Set _brandList to empty list if no data is fetched
        });
      }
    });
  }
}


class BrandSearchDelegate extends SearchDelegate<String> {
  final List<Map<dynamic, dynamic>> brandList;

  BrandSearchDelegate({required this.brandList});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final List<Map<dynamic, dynamic>> filteredBrands = _filterBrands();

    return Column(
      children: [
        if (query.isNotEmpty)
          ListTile(
            title: Text('Add Custom Medicament: $query'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddMedicamentPage(customMedicamentName: query),
                ),
              );
            },
          ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredBrands.length,
            itemBuilder: (BuildContext context, int index) {
              var brand = filteredBrands[index];
              return ListTile(
                title: Text(brand['brand_name'] ?? ''),
                subtitle: Text(
                  'Form: ${brand['form'] ?? ''}, Strength: ${brand['strength'] ?? ''}, Price: ${brand['price'] ?? ''}',
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddMedicamentPage(brand: brand),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  List<Map<dynamic, dynamic>> _filterBrands() {
    return query.isEmpty
        ? brandList
        : brandList
        .where((brand) => brand['brand_name'].toString().toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
