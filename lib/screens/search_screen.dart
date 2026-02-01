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
  void dispose() {
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

  // Highlights the matching part of the place name
  TextSpan _highlightMatch({
    required String text,
    required String query,
    required TextStyle normalStyle,
    required TextStyle highlightStyle,
  }) {
    final q = query.trim();
    if (q.isEmpty) {
      return TextSpan(text: text, style: normalStyle);
    }

    final queryLower = q.toLowerCase();
    final textLower = text.toLowerCase();

    final startIndex = textLower.indexOf(queryLower);
    if (startIndex < 0) {
      return TextSpan(text: text, style: normalStyle);
    }

    final endIndex = startIndex + q.length;

    return TextSpan(
      children: [
        TextSpan(text: text.substring(0, startIndex), style: normalStyle),
        TextSpan(
          text: text.substring(startIndex, endIndex),
          style: highlightStyle,
        ),
        TextSpan(text: text.substring(endIndex), style: normalStyle),
      ],
    );
  }

  Widget _buildLoadingSkeleton() {
  return ListView.builder(
    itemCount: 6,
    itemBuilder: (context, index) {
      return ListTile(
        leading: _SkeletonCircle(size: 28),
        title: _SkeletonLine(widthFactor: 0.55),
        subtitle: _SkeletonLine(widthFactor: 0.35),
      );
    },
  );
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
                            itemCount: _recent.length+1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return ListTile(
                                  title: Text('Recent searches'),
                                  trailing: TextButton(onPressed: () {
                                    setState(() {
                                      _recent.clear();
                                    });
                                    _saveRecent();
                                  }, child: Text('Clear All')),
                                );
                              }
                              final place = _recent[index-1];
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
                  ? _buildLoadingSkeleton()
                  : _errorText != null
                  ? Center(child: Text(_errorText!))
                  : _results.isEmpty
                  ? Center(child: Text('No results'))
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final place = _results[index];
                        return ListTile(
                          title: RichText(
                            text: _highlightMatch(
                              text: place.name,
                              query: _controller.text,
                              normalStyle: Theme.of(
                                context,
                              ).textTheme.titleMedium!,
                              highlightStyle: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
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

class _SkeletonLine extends StatelessWidget {
  final double widthFactor;
  const _SkeletonLine({required this.widthFactor});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: 12,
        margin: EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}

class _SkeletonCircle extends StatelessWidget {
  final double size;
  const _SkeletonCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.10),
      ),
    );
  }
}


