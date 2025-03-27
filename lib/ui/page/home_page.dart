import 'package:flutter/material.dart';
import 'package:next_movie/service/movie_service/movie_service.dart';
import 'package:next_movie/ui/home_content_row.dart';
import '../global_navigation_bar.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final _movieService=MovieService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GlobalNavigationBar(
          title: "NextMovie",
        ),
        body: SingleChildScrollView(
            padding: EdgeInsets.only(left: 25,bottom: MediaQuery.of(context).size.height*0.1),
            child: Column(children: [
              // 头部导航栏
              _buildHeaderRow(),
              HomeContentRow(title: "New",movies: _movieService.getRecentAddMovieInHome()),
              HomeContentRow(title: "ToWatch", movies: _movieService.getToWatchMovieInHome()),
              HomeContentRow(title: "Like", movies: _movieService.getFavoriteMovieInHome()),
              HomeContentRow(title: "History", movies: _movieService.getRecentWatchMovie()),
            ])));
  }

  // 构建头部导航行
  Widget _buildHeaderRow() {
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
          Expanded(
            flex: 0, // 占据50%可用宽度
            child: GestureDetector(
              onTap: () {
                //todo
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Stack(
                  children: [
                    // 背景图使用占位符，实际使用时替换为真实图片
                    Container(
                      width: singleWidth,
                      height: singleHeight,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                              'https://picsum.photos/300/150?random=1',
                            ),
                          )),
                    ),
                    // 半透明蒙层
                    Container(
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
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 右侧分类入口 - 保持相同比例
          SizedBox(
            width: singleWidth,
            height: singleHeight,
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
          ),
        ],
      ),
    );
  }
}
