import 'dart:math';

import 'package:flutter/material.dart';
import 'package:next_movie/service/movie_service/movie_service.dart';
import 'package:next_movie/ui/global_navigation_bar.dart';
import 'package:next_movie/ui/video_card.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

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
    int count = _movieService.getTotalMovies();
    return Scaffold(
      appBar: GlobalNavigationBar(title: "Movies"),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${page * 100 + 1}-${min(count, page * 100 + 100)} of $count",
                  style: TextStyle(fontSize: 20),
                ),
                IconButton(
                    onPressed: page == 0
                        ? null
                        : () {
                            final tmp = page;
                            setState(() {
                              page = page - 1;
                              ids =
                                  _movieService.getOnePageMovies(page: tmp - 1);
                            });
                          },
                    icon: Icon(TDIcons.arrow_left)),
                IconButton(
                    onPressed: page * 100 + 100 >= count
                        ? null
                        : () {
                            final tmp = page;
                            setState(() {
                              page = page + 1;
                              ids =
                                  _movieService.getOnePageMovies(page: tmp + 1);
                            });
                          },
                    icon: Icon(TDIcons.arrow_right))
              ],
            ),
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
                  key:Key(ids[index].toString()),
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
