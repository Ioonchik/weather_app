import 'package:flutter/material.dart';
import 'package:weather_app/screens/search_screen.dart';
import 'package:weather_app/widgets/weather_stat.dart';

class City {
  final int id;
  final String name;
  final String country;

  City({required this.id, required this.name, required this.country});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  City? selectedCity = City(id: 1, name: 'Astana', country: 'Kazakhstan');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weather App')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              SearchBar(
                hintText: 'Search city',
                leading: Icon(Icons.search_rounded),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchScreen()),
                  );
                },
              ),
              selectedCity != null
                  ? Column(
                      children: [
                        Text(selectedCity!.name),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Text('-12C'),
                                Text('Cloudy'),
                                Text('Feels like'),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                WeatherStat(icon: Icons.air, value: '4 km/h'),
                                WeatherStat(icon: Icons.water_drop, value: '72%'),
                                WeatherStat(icon: Icons.speed, value: '1016 hPa'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Text('No city'),
            ],
          ),
        ),
      ),
    );
  }
}
