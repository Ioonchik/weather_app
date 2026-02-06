import 'package:flutter/material.dart';
import 'package:weather_app/utils/weather_condition.dart';

extension WeatherConditionUI on WeatherCondition {
  String get description {
    switch (this) {
      case WeatherCondition.clear:
        return 'Clear';
      case WeatherCondition.partlyCloudy:
        return 'Partly Cloudy';
      case WeatherCondition.cloudy:
        return 'Cloudy';
      case WeatherCondition.fog:
        return 'Fog';
      case WeatherCondition.drizzle:
        return 'Drizzle';
      case WeatherCondition.rain:
        return 'Rain';
      case WeatherCondition.freezingRain:
        return 'Freezing Rain';
      case WeatherCondition.snow:
        return 'Snow';
      case WeatherCondition.showers:
        return 'Showers';
      case WeatherCondition.thunderstorm:
        return 'Thunderstorm';
    }
  }

  IconData get icon {
    switch (this) {
      case WeatherCondition.clear:
        return Icons.wb_sunny_rounded;
      case WeatherCondition.partlyCloudy:
        return Icons.wb_cloudy_rounded;
      case WeatherCondition.cloudy:
        return Icons.cloud_rounded;
      case WeatherCondition.fog:
        return Icons.blur_on_rounded;
      case WeatherCondition.drizzle:
        return Icons.grain_rounded;
      case WeatherCondition.rain:
        return Icons.beach_access_rounded;
      case WeatherCondition.freezingRain:
        return Icons.ac_unit_rounded;
      case WeatherCondition.snow:
        return Icons.ac_unit_rounded;
      case WeatherCondition.showers:
        return Icons.umbrella_rounded;
      case WeatherCondition.thunderstorm:
        return Icons.flash_on_rounded;
    }
  }
}