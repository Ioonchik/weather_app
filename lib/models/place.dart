class Place {
  final String name;
  final String country;
  final double latitude;
  final double longitude;
  final String? admin1;

  Place({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.admin1,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'admin1': admin1,
    };
  }

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      name: json['name'] as String,
      country: json['country'] as String,
      latitude: (json['latitude'] as double).toDouble(),
      longitude: (json['longitude'] as double).toDouble(),
      admin1: json['admin1'] as String?,
    );
  }

  factory Place.fromStoredJson(Map<String, dynamic> json) {
    return Place(
      name: json['name'] as String,
      country: json['country'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      admin1: json['admin1'] as String?,
    );
  }

}
