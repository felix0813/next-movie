import 'dart:math';

import 'package:flutter/material.dart';
import 'package:next_movie/service/category_service/category_service.dart';
import 'package:next_movie/ui/global_navigation_bar.dart';
import 'package:next_movie/ui/select_navigation_bar.dart';

import '../video_card.dart';

class CategoryVideoPage extends StatefulWidget {
  final int categoryId;
  const CategoryVideoPage({super.key, required this.categoryId});

  @override
  CategoryVideoPageState createState() => CategoryVideoPageState();
}

class CategoryVideoPageState extends State<CategoryVideoPage> {
  final _categoryService = CategoryService();
  // final _movieService = MovieService();
  int page = 0;
  List<int> ids = [];
  Set<int> selectedMovie = {};
  bool selecting = false;

  @override
  void initState() {
    updateMovies();
    super.initState();
  }

  double get itemWidth {
    final screenWidth = MediaQuery.of(context).size.width;
    final columns = max(2, screenWidth / 150);
    return (screenWidth - 15) / columns;
  }

  void updateMovies() {
    setState(() {
      ids = _categoryService
          .getCategoryById(widget.categoryId)!
          .movies
          .reversed
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(),
        body: SingleChildScrollView(
          padding: EdgeInsets.only(left: 15),
          child: Column(children: [
            buildGridView(context),
          ]),
        ));
  }

  PreferredSizeWidget? buildAppBar() {
    return selecting
        ? SelectNavigationBar(
            selectedMovies: selectedMovie,
            removeMoviesFromCategory: () {
              if (_categoryService.removeMovies(
                  widget.categoryId, selectedMovie.toList())) {
                updateMovies();
              }
            },
            quitSelecting: () {
              setState(() {
                selectedMovie.clear();
                selecting = false;
              });
            })
        : GlobalNavigationBar(
            title: _categoryService.getCategoryById(widget.categoryId)!.name);
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
      itemBuilder: buildVideoCard,
    );
  }

  Widget? buildVideoCard(context, index) {
    return VideoCard(
      key: Key(ids[index].toString()),
      itemWidth: itemWidth + 10,
      itemHeight: itemWidth * 9 / 16 + 30,
      movieId: ids[index],
      categoryId: widget.categoryId,
      onRemoveFromCategory: (movie) {
        setState(() {
          ids.remove(movie);
        });
      },
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
  }
}
