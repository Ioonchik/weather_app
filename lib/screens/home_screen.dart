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

class Day {
  final String dayLabel;
  final IconData icon;
  final String condition;
  final int minTemp;
  final int maxTemp;

  Day({
    required this.dayLabel,
    required this.icon,
    required this.condition,
    required this.minTemp,
    required this.maxTemp,
  });
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                          children: [
                            Expanded(
                              child: WeatherStat(
                                icon: Icons.air,
                                label: 'Wind',
                                value: '4 km/h',
                              ),
                            ),
                            Container(
                              height: 36,
                              width: 1,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.12),
                            ),
                            Expanded(
                              child: WeatherStat(
                                icon: Icons.water_drop,
                                label: 'Humidity',
                                value: '72%',
                              ),
                            ),
                            Container(
                              height: 36,
                              width: 1,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.12),
                            ),
                            Expanded(
                              child: WeatherStat(
                                icon: Icons.speed,
                                label: 'Pressure',
                                value: '1016 hPa',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        '7-Day Forecast',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Details(),
                  ],
                ),
              ),
            )
          : Padding(
              // if no city is selected
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

class ForecastCard extends StatelessWidget {
  const ForecastCard({super.key, required this.day});

  final Day day;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        children: [
          Text(day.dayLabel),
          SizedBox(height: 8),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        TextSpan(text: '${day.maxTemp}°'),
                        TextSpan(
                          text: ' / ${day.minTemp}°',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Text(
                  //   '${day.maxTemp} / ${day.minTemp}°',
                  //   style: Theme.of(context).textTheme.bodyMedium,
                  // ),
                  // Text(
                  //   day.condition,
                  //   style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  //     color: Theme.of(
                  //       context,
                  //     ).colorScheme.onSurface.withValues(alpha: 0.6),
                  //   ),
                  // ),
                ],
              ),
              SizedBox(width: 10),
              Icon(day.icon),
            ],
          ),

          // SizedBox(height: 8),
        ],
      ),
    );
  }
}

class Details extends StatelessWidget {
  Details({super.key});

  final List<Day> forecast = [
    Day(
      dayLabel: 'Mon',
      icon: Icons.cloudy_snowing,
      condition: 'Snow',
      minTemp: -18,
      maxTemp: -10,
    ),
    Day(
      dayLabel: 'Tue',
      icon: Icons.cloud,
      condition: 'Cloudy',
      minTemp: -17,
      maxTemp: -9,
    ),
    Day(
      dayLabel: 'Wed',
      icon: Icons.wb_sunny_outlined,
      condition: 'Sunny',
      minTemp: -15,
      maxTemp: -6,
    ),
    Day(
      dayLabel: 'Thu',
      icon: Icons.wb_cloudy_outlined,
      condition: 'Partly cloudy',
      minTemp: -14,
      maxTemp: -5,
    ),
    Day(
      dayLabel: 'Fri',
      icon: Icons.cloud,
      condition: 'Overcast',
      minTemp: -16,
      maxTemp: -8,
    ),
    Day(
      dayLabel: 'Sat',
      icon: Icons.ac_unit,
      condition: 'Cold',
      minTemp: -19,
      maxTemp: -11,
    ),
    Day(
      dayLabel: 'Sun',
      icon: Icons.cloudy_snowing,
      condition: 'Snow',
      minTemp: -20,
      maxTemp: -12,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Card(
        child: Row(
          children: forecast.map((item) {
            final isLast = item == forecast.last;
            return Row(
              children: [
                SizedBox(
                  width: 134,
                  child: Center(child: ForecastCard(day: item)),
                ),
                if (!isLast)
                  Container(
                    height: 36,
                    width: 1,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.12),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
