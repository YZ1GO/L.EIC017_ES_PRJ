import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:app/screens/add_medicament_screen.dart';

class DatabaseContentScreen extends StatefulWidget {
  const DatabaseContentScreen({super.key});

  @override
  _DatabaseContentScreenState createState() => _DatabaseContentScreenState();
}

class _DatabaseContentScreenState extends State<DatabaseContentScreen> {
  List<Map<dynamic, dynamic>>? _brandList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 244, 236, 1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'SEARCH MEDICAMENT',
          style: TextStyle(
            color: Color.fromRGBO(158, 66, 0, 1),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8.0),
          customSearchBox(),
          _buildBody(),
        ],
      ),
    );
  }

  Widget customSearchBox() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      color: Colors.transparent,
      width: double.infinity,
      child: InkWell(
        onTap: () {
          showSearch(
            context: context,
            delegate: BrandSearchDelegate(brandList: _brandList ?? []),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: const Color.fromRGBO(255, 198, 157, 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: const Row(
            children: [
              Icon(Icons.search, color: Color.fromRGBO(158, 66, 0, 1)),
              SizedBox(width: 12.0),
              Text(
                'Enter medicament name',
                style: TextStyle(color: Color.fromRGBO(158, 66, 0, 1)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_brandList == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return const SizedBox.shrink();
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
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
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
      color: const Color.fromRGBO(255, 244, 236, 1),
      child: Column(
        children: [
          if (query.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 222, 199, 1),
                borderRadius: BorderRadius.circular(5.0),
              ),
              margin: const EdgeInsets.all(10.0),
              child: ListTile(
                title: Text(
                    'Add Custom Medicament: $query',
                    style: const TextStyle(
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
                //var imageUrl = 'assets/database/${brand['brand_id']}.jpg';
                return ListTile(
                  title: Text(brand['brand_name'] ?? ''),
                  subtitle: Text(
                    '${brand['form'] ?? ''}${brand['strength'] != ' ' ? ', ${brand['strength']}' : ''}',
                  ),
                  leading: loadBrandImage(int.tryParse(brand['brand_id'])),
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

  Widget loadBrandImage(int? brandId) {
    String imagePath = 'assets/database/$brandId.jpg';
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.asset(
        imagePath,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/database/default.jpg',
            width: 48,
            height:48,
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }

}
