import 'package:flutter/material.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/utils/weather_condition.dart';
import 'package:weather_app/utils/weather_condition_mapper.dart';

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
    final condition = widget.weather.weatherCode.condition;
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
                Text(condition.description, style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 2),
                Text(
                  'Feels like ${widget.weather.feelsLikeC}°C ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            Icon(
              condition.icon,
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
