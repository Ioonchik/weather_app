import 'package:flutter/material.dart';

class WeatherStat extends StatelessWidget {
  final IconData icon;
  final String value;

  const WeatherStat({super.key, required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey,),
        SizedBox(width: 6),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
