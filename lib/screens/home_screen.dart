import 'package:flutter/material.dart';
import 'package:weather_app/screens/search_screen.dart';
import 'package:weather_app/widgets/current_weather_card.dart';
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
  City? selectedCity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: selectedCity != null
            ? Text(selectedCity!.name)
            : Text('Weather'),
        actions: [
          selectedCity != null
              ? IconButton(onPressed: () {}, icon: Icon(Icons.refresh_rounded))
              : SizedBox.shrink(),
        ],
      ),
      body: selectedCity != null
          ? Padding(
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  spacing: 12,
                  children: [
                    SearchBar(
                      hintText: 'Search city',
                      leading: Icon(Icons.search_rounded),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchScreen(),
                          ),
                        );
                      },
                    ),
                    CurrentWeatherCard(),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
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
                ),
              ),
            )
          : Padding(
              padding: EdgeInsets.all(12),
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
                  Expanded(
                    // if no city is selected, take up remaining space
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 10,
                        children: [
                          Icon(Icons.cloud_off_rounded, size: 64),
                          Text('Pick a city or use location'),
                          FilledButton(
                            onPressed: () {
                              setState(() {
                                selectedCity = City(
                                  id: 1,
                                  name: 'Astana',
                                  country: 'Kazakhstan',
                                );
                              });
                            },
                            child: Text('Pick a city'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
