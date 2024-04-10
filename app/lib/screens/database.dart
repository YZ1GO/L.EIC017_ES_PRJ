import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseContentScreen extends StatefulWidget {
  @override
  _DatabaseContentScreenState createState() => _DatabaseContentScreenState();
}

class _DatabaseContentScreenState extends State<DatabaseContentScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Map<dynamic, dynamic>> _filteredBrandList = [];

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
                delegate: BrandSearchDelegate(brandList: _filteredBrandList),
              );
            },
          ),
        ],
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

          // Set filteredBrandList initially to the full brand list
          _filteredBrandList = brandList;

          // Build UI from _filteredBrandList
          return ListView.builder(
            itemCount: _filteredBrandList.length,
            itemBuilder: (BuildContext context, int index) {
              var brand = _filteredBrandList[index];
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

    return ListView.builder(
      itemCount: filteredBrands.length,
      itemBuilder: (BuildContext context, int index) {
        var brand = filteredBrands[index];
        return ListTile(
          title: Text(brand['brand_name'] ?? ''),
          subtitle: Text(
            'Form: ${brand['form'] ?? ''}, Strength: ${brand['strength'] ?? ''}, Price: ${brand['price'] ?? ''}',
          ),
        );
      },
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

