enum WeatherCondition {
  clear,
  partlyCloudy,
  cloudy,
  fog,
  drizzle,
  rain,
  freezingRain,
  snow,
  showers,
  thunderstorm,
}

extension WeatherCodeExtension on int {
  WeatherCondition get condition => fromWeatherCode(this);
}

WeatherCondition fromWeatherCode(int code) {
  if (code == 0) return WeatherCondition.clear;
  if (code == 1 || code == 2) return WeatherCondition.partlyCloudy;
  if (code == 3) return WeatherCondition.cloudy;
  if (code == 45 || code == 48) return WeatherCondition.fog;
  if (51 <= code && code <= 55) return WeatherCondition.drizzle;
  if (61 <= code && code <= 65) return WeatherCondition.rain;
  if (66 <= code && code <= 67) return WeatherCondition.freezingRain;
  if (71 <= code && code <= 77) return WeatherCondition.snow;
  if (80 <= code && code <= 82) return WeatherCondition.showers;
  if (85 <= code && code <= 86) return WeatherCondition.snow;
  if (95 <= code && code <= 99) return WeatherCondition.thunderstorm;

  // if the code is unknown, we can return a cloudy weather as a default value
  return WeatherCondition.cloudy;
}
