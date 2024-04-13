import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:app/screens/add_medicicament_screen.dart';

class DatabaseContentScreen extends StatefulWidget {
  @override
  _DatabaseContentScreenState createState() => _DatabaseContentScreenState();
}

class _DatabaseContentScreenState extends State<DatabaseContentScreen> {
  List<Map<dynamic, dynamic>>? _brandList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 244, 236, 1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'SEARCH MEDICAMENT',
          style: TextStyle(
            color: Color.fromRGBO(158, 66, 0, 1),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_brandList == null) {
      return Center(child: CircularProgressIndicator());
    } else {
      return SizedBox.shrink();
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
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
          _brandList = [];
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

    return Container(
      color: Color.fromRGBO(255, 244, 236, 1),
      child: Column(
        children: [
          if (query.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 222, 199, 1),
                borderRadius: BorderRadius.circular(5.0),
              ),
              margin: EdgeInsets.all(10.0),
              child: ListTile(
                title: Text(
                    'Add Custom Medicament: $query',
                    style: TextStyle(
                      color: Color.fromRGBO(158, 66, 0, 1),
                    ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddMedicamentPage(customMedicamentName: query),
                    ),
                  );
                },
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredBrands.length,
              itemBuilder: (BuildContext context, int index) {
                var brand = filteredBrands[index];
                var imageUrl = 'assets/database/${brand['brand_id']}.jpg';
                return ListTile(
                  title: Text(brand['brand_name'] ?? ''),
                  subtitle: Text(
                    'Form: ${brand['form'] ?? ''}, Strength: ${brand['strength'] ?? ''}',
                  ),
                  leading: Image.asset(
                    imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/database/default.jpg',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      );
                    },
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
      ),
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
