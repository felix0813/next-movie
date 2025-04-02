import 'dart:math';

import 'package:flutter/material.dart';
import 'package:next_movie/service/movie_service/movie_service.dart';
import 'package:next_movie/ui/global_navigation_bar.dart';
import 'package:next_movie/ui/radio_dialog.dart';
import 'package:next_movie/ui/video_card.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import 'package:next_movie/model/sort_by.dart';

class VideoListPage extends StatefulWidget {
  const VideoListPage({super.key});

  @override
  VideoListPageState createState() => VideoListPageState();
}

class VideoListPageState extends State<VideoListPage> {
  int page = 0;
  List<int> ids = [];
  String orderBy = SortBy.recorded;
  String order = SortOrder.descending;
  final _movieService = MovieService();
  Set<int> selectedMovie = {};
  bool selecting = false;

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
        appBar: GlobalNavigationBar(
          title: "Movies",
          onMovieUpdate: () {
            setState(() {
              ids = _movieService.getOnePageMovies(
                  page: page, orderBy: orderBy, order: order);
            });
          },
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.only(left: 15),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${page * 100 + 1}-${min(count, page * 100 + 100)} of $count",
                  style: TextStyle(fontSize: 20),
                ),
                IconButton(
                    onPressed: page == 0 ? null : lastPage,
                    icon: Icon(TDIcons.arrow_left)),
                IconButton(
                    onPressed: page * 100 + 100 >= count ? null : nextPage,
                    icon: Icon(TDIcons.arrow_right)),
                IconButton(
                    tooltip: "sort",
                    icon: Icon(Icons.sort),
                    onPressed: onSortPressed)
              ],
            ),
            buildGridView(context),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${page * 100 + 1}-${min(count, page * 100 + 100)} of $count",
                  style: TextStyle(fontSize: 20),
                ),
                IconButton(
                    onPressed: page == 0 ? null : lastPage,
                    icon: Icon(TDIcons.arrow_left)),
                IconButton(
                    onPressed: page * 100 + 100 >= count ? null : nextPage,
                    icon: Icon(TDIcons.arrow_right))
              ],
            ),
          ]),
        ));
  }

  GridView buildGridView(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(), // 禁止 GridView 自滚动
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            ((MediaQuery.of(context).size.width - 15) / (itemWidth + 10))
                .round(), // 动态列数
        childAspectRatio: 4 / 3,
      ),
      itemCount: ids.length,
      itemBuilder: (context, index) {
        return VideoCard(
          key: Key(ids[index].toString()),
          itemWidth: itemWidth + 10,
          itemHeight: itemWidth * 9 / 16 + 30,
          movieId: ids[index],
          onSelect: (bool isSelected) {
            setState(() {
              if (isSelected) {
                selectedMovie.add(ids[index]);
              } else {
                selectedMovie.remove(ids[index]);
              }
            });
          },
          selecting: selecting,
          isSelected: selectedMovie.contains(ids[index]),
          startSelect: () {
            setState(() {
              selecting = true;
            });
          },
        );
      },
    );
  }

  nextPage() {
    final tmp = page;
    setState(() {
      page = page + 1;
      ids = _movieService.getOnePageMovies(
          page: tmp + 1, orderBy: orderBy, order: order);
    });
  }

  lastPage() {
    final tmp = page;
    setState(() {
      page = page - 1;
      ids = _movieService.getOnePageMovies(
          page: tmp - 1, orderBy: orderBy, order: order);
    });
  }

  onSortPressed() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SortMovieRadioDialog(
          options: [
            SortBy.recorded,
            SortBy.created,
            SortBy.star,
            SortBy.duration,
            SortBy.size,
            SortBy.wishDate,
            SortBy.likeDate,
          ],
          initValue: orderBy,
          order: order,
          onConfirm: (String? result, String? sortOrder) {
            if (result != null && sortOrder != null) {
              setState(() {
                orderBy = result;
                order = sortOrder;
                ids = _movieService.getOnePageMovies(
                    page: page, orderBy: result, order: sortOrder);
              });
            }
          },
        );
      },
    );
  }
}
