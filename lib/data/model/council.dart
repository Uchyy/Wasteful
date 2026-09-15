// data/models/council.dart
class Council {
  final String council;
  final String city;
  final String country;
  final String url;

  const Council({required this.city, required this.url, required this.council, required this.country});

  factory Council.fromJson(Map<String, dynamic> json) {
    return Council(
      council: json['council'] as String, 
      url: json['url'] as String,
      city: json['city'] as String,
      country: json['country'] as String
    );
  }
}