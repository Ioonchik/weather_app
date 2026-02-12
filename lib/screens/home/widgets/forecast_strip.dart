import 'package:flutter/material.dart';

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

class ForecastStrip extends StatelessWidget {
  ForecastStrip({super.key});

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