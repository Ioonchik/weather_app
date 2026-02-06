import 'dart:math';
import 'package:weather_app/models/forecast_day.dart';

class Weather {
  final double tempC;
  final int weatherCode;
  final double windSpeedKmh;
  final int humidityPct; 
  final List<ForecastDay> forecast;
  final double feelsLikeC;
  final String? timezone;

  Weather({
    required this.tempC,
    required this.weatherCode,
    required this.windSpeedKmh,
    required this.humidityPct,
    required this.forecast,
    required this.feelsLikeC,
    this.timezone,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;
    int minLength = min(
      (daily['time'] as List).length, min(
        (daily['temperature_2m_min'] as List).length, min(
          (daily['temperature_2m_max'] as List).length,
          (daily['weather_code'] as List).length,
        )
      )
    );

    final times = daily['time'] as List;
    final minTemps = daily['temperature_2m_min'] as List;
    final maxTemps = daily['temperature_2m_max'] as List;
    final weatherCodes = daily['weather_code'] as List;

    return Weather(
      tempC: (current['temperature_2m'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
      windSpeedKmh: (current['wind_speed_10m'] as num).toDouble(),
      humidityPct: (current['relative_humidity_2m'] as num).toInt(),
      feelsLikeC: (current['apparent_temperature'] as num).toDouble(),
      forecast: List<ForecastDay>.generate(minLength, (index) {
        return ForecastDay(
          date: DateTime.parse(times[index] as String),
          minTempC: (minTemps[index] as num).toDouble(),
          maxTempC: (maxTemps[index] as num).toDouble(),
          weatherCode: (weatherCodes[index] as num).toInt(),
        );
      }),
      
      timezone: json['timezone'] as String?,
    );
  }
}