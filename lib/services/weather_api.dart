import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:weather_app/models/weather.dart';

class WeatherFetchResult {
  final Weather weather;
  final Map<String, dynamic> rawJson;
  WeatherFetchResult({required this.weather, required this.rawJson});
}

class WeatherApi {
  final http.Client httpClient;

  WeatherApi({http.Client? httpClient})
    : httpClient = httpClient ?? http.Client();

  Future<Weather> fetchWeather(double latitude, double longitude) async {
    final queryParameters = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current':
          'temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,weather_code,surface_pressure',
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

    try {
      final response = await httpClient.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Failed to load weather data');
      }
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return Weather.fromJson(jsonResponse);
    } on SocketException {
      throw Exception('No Internet connection');
    } on FormatException {
      throw Exception('Invalid server response');
    } catch (e) {
      throw Exception('Failed to load weather data: $e');
    }
  }

  Future<WeatherFetchResult> fetchWeatherWithRawJson(
    double lat,
    double lon,
  ) async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,surface_pressure,weather_code&daily=temperature_2m_min,temperature_2m_max,weather_code&forecast_days=7&temperature_unit=celsius&wind_speed_unit=kmh&timezone=auto',
    );

    final resp = await httpClient.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Weather fetch failed: ${resp.statusCode}');
    }

    final Map<String, dynamic> jsonMap = jsonDecode(resp.body);
    final weather = Weather.fromJson(jsonMap);

    return WeatherFetchResult(weather: weather, rawJson: jsonMap);
  }
}
