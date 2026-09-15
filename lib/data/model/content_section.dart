// data/model/content_section.dart
class ContentSection {
  final String heading;
  final String body;

  const ContentSection({required this.heading, required this.body});

  factory ContentSection.fromJson(Map<String, dynamic> json) =>
      ContentSection(heading: json['heading'] as String, body: json['body'] as String);
}