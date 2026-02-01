import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_app/models/place.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  void _testGeocodingApi() async {
    final uri = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=Almaty&count=5&language=en',
    );
    final response = await http.get(uri);
  }

  Future<List<Place>> searchPlaces(String query) async {
    final uri = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=$query&count=5&language=en',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Geocoding failed: ${response.statusCode}');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    final List<dynamic>? results = data['results'] as List<dynamic>?;

    if (results == null) return [];

    return results
        .map((item) => Place.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  final _controller = TextEditingController();

  List<Place> _results = [];
  bool _isLoading = false;
  String? _errorText;

  Timer? _debounce;

  void _onQueryChanged(String value) {
    setState(() {}); //just for updating the clear button
    final query = value.trim();

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      if (query.length < 2) {
        setState(() {
          _results = [];
          _isLoading = false;
          _errorText = null;
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorText = null;
      });

      try {
        final places = await searchPlaces(query);
        if (!mounted) return;

        setState(() {
          _results = places;
          _isLoading = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _errorText = 'Couldn\'t load results. Check your connection.';
          _isLoading = false;
          _results = [];
        });
      }
    });

    dispose() {
      _controller.dispose();
      _debounce?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search city')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SearchBar(
              hintText: 'Search city',
              leading: Icon(Icons.search_rounded),
              controller: _controller,
              onChanged: _onQueryChanged,
              trailing: [if(_controller.text.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.close_rounded),
                  onPressed: () {
                    _controller.clear();
                    setState(() {
                      _results = [];
                      _isLoading = false;
                      _errorText = null;
                    });
                  },
                ),
              ],
            ),
            Expanded(child: 
              _isLoading
                ? Center(child: CircularProgressIndicator())
                : _errorText != null
                  ? Center(child: Text(_errorText!))
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final place = _results[index];
                        return ListTile(
                          title: Text(place.name),
                          leading: Icon(Icons.location_city),
                          subtitle: Text('${place.country} ${place.admin1 != null ? '• ${place.admin1}' : ''}'),
                          trailing: Icon(Icons.north_east),
                          onTap: () {
                            Navigator.pop(context, place);
                          },
                        );
                      },
                    ),
            ),
            // ListTile(
            //   title: Text('Almaty'),
            //   leading: Icon(Icons.location_city),
            //   subtitle: Text('Kazakhstan • Almaty oblysy'),
            //   trailing: Icon(Icons.north_east),
            //   onTap: () {
            //     Navigator.pop(
            //       context,
            //       Place(
            //         name: 'Almaty',
            //         country: 'Kazakhstan',
            //         latitude: 43.25,
            //         longitude: 76.92,
            //         region: 'Almaty oblysy',
            //       ),
            //     );
            //   },
            // ),
            // ElevatedButton(
            //   onPressed: () async {
            //     final places = await searchPlaces('Almaty');
            //     print('Found: ${places.length} places');
            //     if (places.isNotEmpty) {
            //       print('First place: ${places[0].name}, ${places[0].country}');
            //     }
            //   },
            //   child: Text('Test API'),
            // ),
          ],
        ),
      ),
    );
  }
}
