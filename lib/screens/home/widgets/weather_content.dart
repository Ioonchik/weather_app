import 'package:flutter/material.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/screens/home/widgets/forecast_strip.dart';
import 'package:weather_app/widgets/current_weather_card.dart';
import 'package:weather_app/widgets/weather_stat.dart';

class WeatherContent extends StatelessWidget {
  final Weather weather;
  final DateTime? lastUpdated;

  const WeatherContent({
    super.key,
    required this.weather,
    required this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        CurrentWeatherCard(weather: weather),
        Text(
          lastUpdated != null
              ? 'Last updated: ${lastUpdated!.hour.toString().padLeft(2, '0')}:${lastUpdated!.minute.toString().padLeft(2, '0')}'
              : 'Last updated: -',
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
        ForecastStrip(),
      ],
    );
  }
}
