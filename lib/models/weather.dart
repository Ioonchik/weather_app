import 'package:weather_app/models/forecast_day.dart';

class Weather {
  final double tempC;
  final int weatherCode;
  final double windSpeedKph;
  final int humidityPct; 
  final List<ForecastDay> forecast;
  final String timezone;

  Weather({
    required this.tempC,
    required this.weatherCode,
    required this.windSpeedKph,
    required this.humidityPct,
    required this.forecast,
    required this.timezone,
  });
}