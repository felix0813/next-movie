import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:next_movie/ui/global_navigation_bar.dart';
import 'package:next_movie/utils/app_path.dart';
import 'package:path/path.dart';

import '../../service/movie_service/movie_service.dart';

class MovieDetailPage extends StatefulWidget {
  const MovieDetailPage({super.key, required this.movieId});
  final int movieId;
  @override
  MovieDetailPageState createState() => MovieDetailPageState();
}

class MovieDetailPageState extends State<MovieDetailPage> {
  String thumbnailPath = ""; // 替换为实际的缩略图路径
  String title = '';
  String metadata = '2023 | 120 mins | Action, Adventure';
  final _service = MovieService();
  @override
  void initState() {
    final movie = _service.getMovieById(widget.movieId)!;
    setState(() {
      title = movie.title;
      thumbnailPath = join(AppPaths.instance.appDocumentsDir, "next_movie",
          "poster", "${widget.movieId}.jpg");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: GlobalNavigationBar(title: "Movie Detail"),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 视频缩略图和元数据部分
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                children: [
                  // 视频缩略图
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(
                      File(thumbnailPath), // 从文件系统加载缩略图
                      width: min(width * 0.75, 480),
                      height: min(width * 0.75, 480) * 9 / 16,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 16),
                  // 文件名称和元数据
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        basenameWithoutExtension(title),
                        softWrap: true,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        metadata,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // 工具栏部分
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 打分组件
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange),
                      SizedBox(width: 4),
                      Text('8.5'),
                    ],
                  ),
                  // 其他操作选项
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.share),
                        onPressed: () {
                          // 分享功能
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.download),
                        onPressed: () {
                          // 下载功能
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // 删除功能
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // 其他内容可以继续添加在这里
          ],
        ),
      ),
    );
  }
}
