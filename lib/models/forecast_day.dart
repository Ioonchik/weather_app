class ForecastDay {
  final DateTime date;
  final int minTempC;
  final int maxTempC;
  final int weatherCode;

  ForecastDay({
    required this.date,
    required this.minTempC,
    required this.maxTempC,
    required this.weatherCode
  });
}