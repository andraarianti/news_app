import 'articles_models.dart';

class NewsApi {
  String status;
  int totalResults;
  List<Article> articles;

  NewsApi({
    required this.status,
    required this.totalResults,
    required this.articles,
  });

  factory NewsApi.fromJson(Map<String, dynamic> json){
    return NewsApi(
        status: json['status'],
        totalResults: json['totalResults'],
        articles: json['articles']
    );
  }

}