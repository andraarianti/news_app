import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:news_app/view/list_news.dart';

import 'domain/models/news.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(NewsAdapter());
  await Hive.openBox<News>('boxFav');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  var favBox = Hive.box<News>('boxFav');
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ListNews(favBox: favBox,),
    );
    // return GetMaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   title: 'Flutter Demo',
    //   initialRoute: AppRoutes.initial,
    //   getPages: AppRoutes.routes,
    // );
  }
}
