import 'dart:io';

import 'package:flutter/material.dart';
import 'package:next_movie/service/movie_service/movie_service.dart';
import 'package:next_movie/ui/home_content_row.dart';
import 'package:next_movie/ui/page/video_list_page.dart';
import 'package:path/path.dart';
import 'package:next_movie/utils/app_path.dart';
import '../global_navigation_bar.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final _movieService = MovieService();
  List<int> recentAdd = [];
  List<int> toWatch = [];
  List<int> favourite = [];
  List<int> history = [];
  int latest = 0;

  @override
  void initState() {
    getAllStatus();
    super.initState();
  }

  void getAllStatus() {
    setState(() {
      latest = _movieService.getLatestMovieId() ?? 0;
      recentAdd = _movieService.getRecentAddMovieInHome();
      toWatch = _movieService.getToWatchMovieInHome();
      favourite = _movieService.getFavoriteMovieInHome();
      history = _movieService.getRecentWatchMovie();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GlobalNavigationBar(
          title: "NextMovie",
        ),
        body: SingleChildScrollView(
            padding: EdgeInsets.only(
                left: 25, bottom: MediaQuery.of(context).size.height * 0.1),
            child: Column(children: [
              // 头部导航栏
              _buildHeaderRow(context),
              HomeContentRow(title: "New", movies: recentAdd),
              HomeContentRow(title: "ToWatch", movies: toWatch),
              HomeContentRow(title: "Like", movies: favourite),
              HomeContentRow(title: "History", movies: history),
            ])));
  }

  // 构建头部导航行
  Widget _buildHeaderRow(BuildContext context) {
    int latestId = _movieService.getLatestMovieId() ?? 0;
    double singleWidth = min(320, (MediaQuery.of(context).size.width - 35) / 2);
    double singleHeight = singleWidth * 9 / 16;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        // 设置水平方向起始对齐
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // 左侧视频入口 - 使用弹性布局适配不同宽度
          buildMovieEntrance(context, singleWidth, singleHeight, latestId),

          // 右侧分类入口 - 保持相同比例
          buildCategoryEntrance(singleWidth, singleHeight),
        ],
      ),
    );
  }

  Expanded buildMovieEntrance(BuildContext context, double singleWidth,
      double singleHeight, int latestId) {
    return Expanded(
      flex: 0, // 占据50%可用宽度
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VideoListPage()),
            ).then((_) => getAllStatus());
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Stack(
              children: [
                // 背景图使用占位符，实际使用时替换为真实图片
                buildCover(singleWidth, singleHeight),
                // 半透明蒙层
                buildGreyCover(singleWidth, singleHeight),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container buildGreyCover(double singleWidth, double singleHeight) {
    return Container(
      width: singleWidth,
      height: singleHeight,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.all(12.0),
      alignment: Alignment.center,
      child: Text(
        'Movie',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Container buildCover(double singleWidth, double singleHeight) {
    return Container(
      width: singleWidth,
      height: singleHeight,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.blue,
          image: latest != 0
              ? DecorationImage(
                  fit: BoxFit.cover,
                  image: FileImage(File(join(
                      AppPaths.instance.appDocumentsDir,
                      "next_movie",
                      "poster",
                      "$latest.jpg"))),
                )
              : null),
    );
  }

  SizedBox buildCategoryEntrance(double singleWidth, double singleHeight) {
    return SizedBox(
        width: singleWidth,
        height: singleHeight,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              //todo
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10.0),
              ),
              height: 150,
              padding: const EdgeInsets.all(12.0),
              alignment: Alignment.center,
              child: Text(
                'Category',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ));
  }
}
