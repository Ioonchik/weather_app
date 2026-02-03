class ForecastDay {
  final DateTime date;
  final double minTempC;
  final double maxTempC;
  final int weatherCode;

  ForecastDay({
    required this.date,
    required this.minTempC,
    required this.maxTempC,
    required this.weatherCode
  });
}