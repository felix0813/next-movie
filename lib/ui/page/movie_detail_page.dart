import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:next_movie/ui/global_navigation_bar.dart';
import 'package:next_movie/utils/app_path.dart';
import 'package:next_movie/utils/size.dart';
import 'package:next_movie/utils/time.dart';
import 'package:path/path.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../model/movie.dart';
import '../../service/movie_service/movie_service.dart';

class MovieDetailPage extends StatefulWidget {
  const MovieDetailPage({super.key, required this.movieId});
  final int movieId;
  @override
  MovieDetailPageState createState() => MovieDetailPageState();
}

class MovieDetailPageState extends State<MovieDetailPage> {
  String thumbnailPath = ""; // 替换为实际的缩略图路径
  final _service = MovieService();
  String title = "";
  String path = "";
  int duration = 0;
  int size = 0;
  int star = 0;
  DateTime recorded = DateTime.now();

  @override
  void initState() {
    final movie = _service.getMovieById(widget.movieId)!;
    setState(() {
      title = movie.title;
      path = movie.path;
      duration = movie.duration;
      size = movie.size;
      recorded = movie.recorded!;
      star = movie.star ?? 0;
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
                        dirname(path),
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      SizedBox(height: 4),
                      Text(
                        secondsToDurationString(duration)
                            .concat(formatBytes(size), " | "),
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Recorded at ${recorded.toString().split(".")[0]}",
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
                  TDRate(
                      value: star.toDouble(),
                      onChange: (value) {
                        if (_service.star(widget.movieId, value.toInt())) {
                          setState(() {
                            star = value.toInt();
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Fail to star')),
                          );
                        }
                      },
                      placement: PlacementEnum.none,
                      color: [Color(0xFFFFC51C), Color(0xFFE8E8E8)]),
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

extension StringExtensions on String {
  String concat(String next, String separator) {
    return this + separator + next;
  }

  String concatWithoutEmpty(String next, String separator) {
    if (isEmpty) {
      return next;
    }
    if (next.isEmpty) {
      return this;
    }
    return this + separator + next;
  }
}
