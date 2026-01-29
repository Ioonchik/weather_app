import 'package:flutter/material.dart';
import 'package:weather_app/screens/home_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
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
            ),
            ListTile(
              title: Text('Almaty'),
              leading: Icon(Icons.location_city),
              subtitle: Text('Kazakhstan • Almaty oblysy'),
              trailing: Icon(Icons.north_east),
              onTap: () {
                Navigator.pop(
                  context,
                  Place(
                    name: 'Almaty',
                    country: 'Kazakhstan',
                    latitude: 43.25,
                    longitude: 76.92,
                    region: 'Almaty oblysy',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
