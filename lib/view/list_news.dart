import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../domain/models/articles_models.dart';
import '../domain/models/news.dart';

class ListNews extends StatefulWidget {
  final Box<News> favBox;

  const ListNews({Key? key, required this.favBox}) : super(key: key);

  @override
  _ListNewsState createState() => _ListNewsState();
}

class _ListNewsState extends State<ListNews> {
  final Dio dio = Dio();
  var NEWS_API_KEY = '4b397c0b925c48649a61b00c6ab69622';
  List<Article> _articleList = [];

  @override
  void initState() {
    super.initState();
    _getNews(); // Call the function to fetch news when the widget is initialized
  }

  void dispose() {
    var box = Hive.box<News>('boxFav');
    box.close(); // Close the box when the widget is disposed
    super.dispose();
  }

  Future<void> _getNews() async {
    final response = await dio.get(
      'https://newsapi.org/v2/everything?q=keyword&apiKey=${NEWS_API_KEY}',
    );
    final articlesJson = response.data["articles"] as List;
    setState(() {
      List<Article> newsArticle =
          articlesJson.map((index) => Article.fromJson(index)).toList();
      newsArticle = newsArticle.where((a) => a.title != "[Removed]").toList();
      _articleList = newsArticle.take(20).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('BSI News'),
          centerTitle: true,
          bottom: TabBar(
            tabs: [
              Tab(text: 'News'),
              Tab(text: 'Favorites'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(
              child: ListView.builder(
                  itemCount: _articleList.length,
                  itemBuilder: (context, index) {
                    var article = _articleList[index];
                    return Column(
                      children: [
                        ListTile(
                          onTap: () {
                            _launchUrl(
                              Uri.parse(article.url ?? ""),
                            );
                          },
                          title: Image.network(
                            article.urlToImage,
                            height: 200,
                          ),
                          subtitle: Text(
                            article.title,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          leading: IconButton(
                            onPressed: () {
                              setState(() {
                                article.isFavorite = !article.isFavorite;
                                _buttonFavorite(article);
                              });
                            },
                            icon: Icon(
                              article.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        Divider(),
                      ],
                    );
                  }),
            ),
            Center(
              child: FutureBuilder(
                future: Future.value(widget.favBox.values.toList()),
                // Retrieve all values from Hive
                builder: (context, AsyncSnapshot<List<News>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    List<News> favoriteNews = snapshot.data ?? [];

                    return ListView.builder(
                      itemCount: favoriteNews.length,
                      itemBuilder: (context, index) {
                        var news = favoriteNews[index];
                        return Column(
                          children: [
                            ListTile(
                              onTap: () {
                                _launchUrl(
                                  Uri.parse(news.url ?? ""),
                                );
                              },
                              title: Image.network(
                                news.imageUrl,
                                height: 200,
                              ),
                              subtitle: Text(
                                news.title,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Divider(),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _buttonFavorite(Article article) async {
    try {
      print('Before toggle: ${article.isFavorite}');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? favoriteArticles =
          prefs.getStringList('favorite_articles') ?? [];

      var news = News(
        imageUrl: article.urlToImage,
        title: article.title,
        description: article.description,
        isFavorite: article.isFavorite,
        url: article.url,
      );

      if (article.isFavorite) {
        if (!favoriteArticles.contains(article.title)) {
          // Add article to favorites
          favoriteArticles.add(article.title);
          widget.favBox.add(news);
          print('Added to favorites: ${news.title}');
        }
      } else {
        // Remove article from favorites
        favoriteArticles.remove(article.title);
        int index = widget.favBox.values
            .toList()
            .indexWhere((news) => news.url == article.url);
        if (index != -1) {
          widget.favBox.deleteAt(index);
          print('Removed from favorites: ${news.title}');
        }
      }

      await prefs.setStringList('favorite_articles', favoriteArticles);
    } catch (e) {
      // Handle error
      print('Error toggling favorite: $e');
    }
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
