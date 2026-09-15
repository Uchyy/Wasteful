// data/model/faq_item.dart
class FaqItem {
  final String question;
  final String answer;

  const FaqItem({required this.question, required this.answer});

  factory FaqItem.fromJson(Map<String, dynamic> json) =>
      FaqItem(question: json['question'] as String, answer: json['answer'] as String);
}