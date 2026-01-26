import 'package:flutter/material.dart';

class CurrentWeatherCard extends StatefulWidget {
  const CurrentWeatherCard({super.key});

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
                Text('-12C', style: Theme.of(context).textTheme.displaySmall),
                SizedBox(height: 4),
                Text('Cloudy', style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 2),
                Text(
                  'Feels like -18°',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            Icon(Icons.cloud_rounded, size: 72, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8)),
          ],
        ),
      ),
    );
  }
}
