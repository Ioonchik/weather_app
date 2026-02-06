import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_app/models/weather.dart';

class WeatherApi {
  final http.Client httpClient;

  WeatherApi({http.Client? httpClient})
    : httpClient = httpClient ?? http.Client();

  Future<Weather> fetchWeather(double latitude, double longitude) async {
    final queryParameters = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current':
          'temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,weather_code',
      'daily': 'temperature_2m_min,temperature_2m_max,weather_code',
      'forecast_days': '7',
      'temperature_unit': 'celsius',
      'wind_speed_unit': 'kmh',
      'timezone': 'auto',
    };

    final Uri uri = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      queryParameters,
    );

    final response = await httpClient.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load weather data');
    }

    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    return Weather.fromJson(jsonResponse);
  }
}
