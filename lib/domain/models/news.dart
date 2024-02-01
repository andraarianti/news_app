import 'package:hive/hive.dart';

part 'news.g.dart';

@HiveType(typeId: 0)
class News {
  @HiveField(0)
  final String imageUrl;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String description;
  @HiveField(3)
  bool isFavorite;
  @HiveField(4)
  final String url;

  News({
    required this.imageUrl,
    required this.title,
    required this.description,
    this.isFavorite = false,
    required this.url,
  });
}
