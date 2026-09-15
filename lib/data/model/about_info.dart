// data/model/about_info.dart
class AboutInfo {
  final String appName;
  final String tagline;
  final String version;
  final String description;

  const AboutInfo({
    required this.appName,
    required this.tagline,
    required this.version,
    required this.description,
  });

  factory AboutInfo.fromJson(Map<String, dynamic> json) => AboutInfo(
        appName: json['appName'] as String,
        tagline: json['tagline'] as String,
        version: json['version'] as String,
        description: json['description'] as String,
      );
}