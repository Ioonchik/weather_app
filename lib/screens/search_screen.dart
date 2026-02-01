import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/models/place.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  @override
  dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
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
  }


  List<Place> _recent = [];
  static const _recentKey = 'recent_places';

  void _addToRecent(Place place) {
    _recent.removeWhere(
      (p) => p.latitude == place.latitude && p.longitude == place.longitude,
    );

    _recent.insert(0, place);

    if (_recent.length > 5) {
      _recent = _recent.sublist(0, 5);
    }
    print(_recent.map((e) => e.name).toList());
  }

  Future<void> _saveRecent() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> storedPlaces = _recent
        .map((place) => jsonEncode(place.toJson()))
        .toList();

    await prefs.setStringList(_recentKey, storedPlaces);
  }

  Future<void> _loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> storedPlaces = prefs.getStringList(_recentKey) ?? [];
    final List<Place> places = <Place>[];

    for (final placeJson in storedPlaces) {
      final Map<String, dynamic> jsonMap = jsonDecode(placeJson);
      places.add(Place.fromStoredJson(jsonMap));
    }

    if (!mounted) return;
    setState(() {
      _recent = places;
    });
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
              trailing: [
                if (_controller.text.isNotEmpty)
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
            Expanded(
              child: _controller.text.length < 2
                  ? _recent.isEmpty
                        ? Center(child: Text('Type to search'))
                        : ListView.builder(
                          itemCount: _recent.length,
                          itemBuilder: (context, index) {
                            final place = _recent[index];
                            return ListTile(
                              title: Text(place.name),
                              leading: Icon(Icons.history_rounded),
                              subtitle: Text(
                                '${place.country} ${place.admin1 != null ? '• ${place.admin1}' : ''}',
                              ),
                              trailing: Icon(Icons.north_east),
                              onTap: () {
                                Navigator.pop(context, place);
                              },
                            );
                          },
                        )
                  : _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _errorText != null
                  ? Center(child: Text(_errorText!))
                  : _results.isEmpty
                  ? Center(child: Text('No results'))
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final place = _results[index];
                        return ListTile(
                          title: Text(place.name),
                          leading: Icon(Icons.location_city),
                          subtitle: Text(
                            '${place.country} ${place.admin1 != null ? '• ${place.admin1}' : ''}',
                          ),
                          trailing: Icon(Icons.north_east),
                          onTap: () async {
                            setState(() => _addToRecent(place));
                            await _saveRecent();
                            Navigator.pop(context, place);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
