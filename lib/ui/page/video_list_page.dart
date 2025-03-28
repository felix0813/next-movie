import 'dart:math';

import 'package:flutter/material.dart';
import 'package:next_movie/service/movie_service/movie_service.dart';
import 'package:next_movie/ui/global_navigation_bar.dart';
import 'package:next_movie/ui/video_card.dart';

class VideoListPage extends StatefulWidget {
  const VideoListPage({super.key});

  @override
  VideoListPageState createState() => VideoListPageState();
}

class VideoListPageState extends State<VideoListPage> {
  int page = 0;
  List<int> ids = [];
  final _movieService = MovieService();

  @override
  void initState() {
    setState(() {
      ids = _movieService.getOnePageMovies();
    });
    super.initState();
  }

  double get itemWidth {
    final screenWidth = MediaQuery.of(context).size.width;
    final columns = max(2, screenWidth / 300);
    return (screenWidth - 15) / columns;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalNavigationBar(title: "Movies"),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 15),
        child: Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(), // 禁止 GridView 自滚动
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ((MediaQuery.of(context).size.width - 15) /
                        (itemWidth + 10))
                    .round(), // 动态列数
                childAspectRatio: 4 / 3,
              ),
              itemCount: ids.length,
              itemBuilder: (context, index) {
                return VideoCard(
                  itemWidth: itemWidth + 10,
                  itemHeight: itemWidth * 9 / 16 + 30,
                  movieId: ids[index],
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
