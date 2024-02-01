import 'package:news_app/domain/models/source_models.dart';
import 'package:uuid/uuid.dart';

class Article {
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  late bool isFavorite = false;

  Article({
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    print('DEBUG: Parsing Article JSON - $json');

    final article = Article(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'] ?? '',
    );
    print('DEBUG: Parsed Article - ${article.title}');
    return article;
  }
}
