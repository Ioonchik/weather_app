import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/screens/search_screen.dart';
import 'package:weather_app/services/location_service.dart';
import 'package:weather_app/services/weather_api.dart';
import 'package:weather_app/widgets/current_weather_card.dart';
import 'package:weather_app/widgets/weather_stat.dart';

import '../models/place.dart';

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
  Place? selectedPlace;

  final LocationService _locationService = LocationService();
  bool _isLocating = false;
  Position? _currentPosition;

  final weatherApi = WeatherApi();

  Weather? _weather;
  bool _isLoadingWeather = false;
  String? _error;

  Future<void> _loadWeatherFor(Place place) async {
    if (_isLoadingWeather) return;

    setState(() {
      _isLoadingWeather = true;
      _error = null;
    });

    try {
      final weather = await weatherApi.fetchWeather(place.latitude, place.longitude);
      if (mounted) {
        setState(() {
          _weather = weather;
        });
        print(weather.tempC);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not load weather data: $e';
        });
        print('Error loading weather: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingWeather = false;
        });
      }
    }
  }

  Future<void> _useMyLocation() async {
    if (_isLocating) return;

    setState(() {
      _isLocating = true;
    });

    try {
      final position = await _locationService.getCurrentPositionOrThrow();
      
      if (!mounted) return;

      setState(() {
        _currentPosition = position;
        selectedPlace = Place(
          name: 'My Location',
          country: '',
          latitude: position.latitude,
          longitude: position.longitude,
        );
      });
      print(_currentPosition);
    } on PermissionDenied {
      await _showPermissionDeniedDialog();
    } on PermissionDeniedForever {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Enable location permission?'),
          content: Text(
            'Location permissions are permanently denied. Please enable them in settings to use this feature.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openAppSettings();
              },
              child: Text('Open settings'),
            ),
          ],
        ),
      );
    } on LocationServiceDisabled {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Location services disabled'),
          content: Text(
            'Please enable location services in your device settings to use this feature.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openLocationSettings();
              },
              child: Text('Open location settings'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: $e'),
        )
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
      }
    }
  }

  Future<void> _showPermissionDeniedDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Allow location access?'),
        content: Text(
          'We use your location to show local weather. Allow access to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Future.microtask(_useMyLocation);
            },
            child: Text('Try again'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Not now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather'),
        actions: [
          selectedPlace != null
              ? IconButton(onPressed: () => _loadWeatherFor(selectedPlace!), icon: Icon(Icons.refresh_rounded))
              : SizedBox.shrink(),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          spacing: 16,
          children: [
            InkWell(
              child: IgnorePointer(
                child: SearchBar(
                  hintText: selectedPlace?.name ?? 'Search city',
                  leading: Icon(Icons.search_rounded),
                  readOnly: true,
                ),
              ),
              onTap: () async {
                final Place? place = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchScreen()),
                );
                if (place != null) {
                  setState(() {
                    selectedPlace = place;
                  });
                  _loadWeatherFor(place);
                }
              },
            ),
            TextButton.icon(
              onPressed: _isLocating ? null : () => _useMyLocation(),
              icon: Icon(Icons.my_location_rounded),
              label: Text(_isLocating ? 'Getting location...' : 'Use current location'),
            ),
            selectedPlace != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      CurrentWeatherCard(
                        weather: _weather ?? Weather(
                          tempC: 0,
                          weatherCode: 0,
                          windSpeedKmh: 0,
                          humidityPct: 0,
                          feelsLikeC: 0,
                          forecast: [],
                        ),
                      ),
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
                      TextButton(onPressed: () async {
                        final weather = await weatherApi.fetchWeather(selectedPlace!.latitude, selectedPlace!.longitude);
                        print(weather.tempC);
                        print(weather.forecast.length);
                      }, child: Text('Test API'))
                    ],
                  )
                : Expanded(
                    child: Center(
                      child: Opacity(
                        opacity: 0.8,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 10,
                          children: [
                            Icon(Icons.cloud_off_rounded, size: 64),
                            Text('Pick a city or use location'),
                          ],
                        ),
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
                ],
              ),
              SizedBox(width: 10),
              Icon(day.icon),
            ],
          ),
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
