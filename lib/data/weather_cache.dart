import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/models/place.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/utils/cache_keys.dart';

class CachedWeather {
  final Place place;
  final Weather weather;
  final DateTime? updatedAt;

  CachedWeather({
    required this.place,
    required this.weather,

    required this.updatedAt,
  });
}

class WeatherCache {
  Future<CachedWeather?> load() async {
    final prefs = await SharedPreferences.getInstance();

    final cachedJson = prefs.getString(CacheKeys.cachedWeatherJson);
    final lastLat = prefs.getDouble(CacheKeys.cachedLat);
    final lastLon = prefs.getDouble(CacheKeys.cachedLon);
    final lastName = prefs.getString(CacheKeys.cachedPlaceName);
    final updatedIso = prefs.getString(CacheKeys.cachedUpdatedAtIso);

    if (cachedJson == null ||
        lastLat == null ||
        lastLon == null ||
        lastName == null) {
      return null;
    }

    try {
      final Map<String, dynamic> map =
          jsonDecode(cachedJson) as Map<String, dynamic>;
      final weather = Weather.fromJson(map);
      final place = Place(
        name: lastName,
        country: '',
        latitude: lastLat,
        longitude: lastLon,
      );

      return CachedWeather(
        place: place,
        weather: weather,
        updatedAt: updatedIso != null ? DateTime.parse(updatedIso) : null,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> save({
    required Place place,
    required Map<String, dynamic> fullResponseJson,
    required DateTime updatedAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      CacheKeys.cachedWeatherJson,
      jsonEncode(fullResponseJson),
    );
    await prefs.setString(CacheKeys.cachedPlaceName, place.name);
    await prefs.setDouble(CacheKeys.cachedLat, place.latitude);
    await prefs.setDouble(CacheKeys.cachedLon, place.longitude);
    await prefs.setString(
      CacheKeys.cachedUpdatedAtIso,
      updatedAt.toIso8601String(),
    );
  }
}
