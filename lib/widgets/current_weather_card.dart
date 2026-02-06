import 'package:flutter/material.dart';
import 'package:weather_app/models/weather.dart';

class CurrentWeatherCard extends StatefulWidget {
  final Weather weather;

  const CurrentWeatherCard({
    super.key,
    required this.weather
  });

  @override
  State<CurrentWeatherCard> createState() => _CurrentWeatherCardState();
}

class _CurrentWeatherCardState extends State<CurrentWeatherCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${widget.weather.tempC}°C', style: Theme.of(context).textTheme.displaySmall),
                SizedBox(height: 4),
                Text('${widget.weather.weatherCode}', style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 2),
                Text(
                  '${widget.weather.feelsLikeC}°C feels like',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            Icon(
              Icons.cloud_rounded,
              size: 72,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ],
        ),
      ),
    );
  }
}
