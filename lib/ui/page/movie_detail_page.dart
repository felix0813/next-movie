import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:next_movie/ui/global_navigation_bar.dart';
import 'package:next_movie/utils/app_path.dart';
import 'package:next_movie/utils/size.dart';
import 'package:next_movie/utils/time.dart';
import 'package:path/path.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
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
  String created = "";
  bool like = false;
  bool wish = false;

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
      created = movie.created ?? "";
      like = movie.likeDate != null;
      wish = movie.wishDate != null;
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
              padding: EdgeInsets.all(min(16.0, width*0.05)),
              child: Wrap(
                runSpacing: 16.0,
                children: [
                  // 视频缩略图
                  buildThumbnail(width),
                  SizedBox(width: 16),
                  // 文件名称和元数据
                  buildMetadata(),
                ],
              ),
            ),
            SizedBox(height: 16),
            // 工具栏部分
            Padding(
              padding: EdgeInsets.symmetric(horizontal: min(16.0, width*0.05)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      buildRate(context),
                      Row(
                        children: [
                          IconButton(
                            tooltip: "Like",
                            icon: Icon(
                              like ? Icons.favorite : Icons.favorite_border,
                              color: like ? Colors.pink : Colors.grey,
                            ),
                            onPressed: () {
                              if (_service.like(widget.movieId, !like)) {
                                setState(() {
                                  like = !like;
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Fail to like')),
                                );
                              }
                            },
                          ),
                          SizedBox(width: 16), // 添加间距
                          IconButton(
                            tooltip: "Add to watchlist",
                            icon: Icon(
                              wish
                                  ? Icons.watch_later
                                  : Icons.watch_later_outlined,
                              color: wish ? Colors.pink : Colors.grey,
                            ),
                            onPressed: () {
                              if (_service.wish(widget.movieId, !wish)) {
                                setState(() {
                                  wish = !wish;
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Fail to add to watchlist')),
                                );
                              }
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                  if (MediaQuery.of(context).size.width >= 500)
                    buildFunctionBtn(context,width),
                ],
              ),
            ),
            if (MediaQuery.of(context).size.width <= 500)
              buildFunctionBtn(context,width),
          ],
        ),
      ),
    );
  }

  TDRate buildRate(BuildContext context) {
    return TDRate(
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
        color: [Color(0xFFFFC51C), Color(0xFFE8E8E8)]);
  }

  Column buildMetadata() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          basenameWithoutExtension(title),
          softWrap: true,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          dirname(path),
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        SizedBox(height: 4),
        Text(
          secondsToDurationString(duration).concat(formatBytes(size), " | "),
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        SizedBox(height: 4),
        Text(
          "Recorded at ${recorded.toString().split(".")[0]}",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        SizedBox(height: 4),
        Text(
          "Created at ${created.split(".")[0]}",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  ClipRRect buildThumbnail(double width) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Image.file(
        File(thumbnailPath), // 从文件系统加载缩略图
        width: min(width * 0.75, 480),
        height: min(width * 0.75, 480) * 9 / 16,
        fit: BoxFit.cover,
      ),
    );
  }

  SizedBox buildFunctionBtn(BuildContext context,double width) {
    return SizedBox(
      width: min(280, width * 0.9), // 设置一个固定宽度，例如屏幕宽度的40%
      child: Wrap(
        spacing: 5.0, // 水平间距
        runSpacing: 4.0, // 垂直间距
        direction: Axis.horizontal,
        children: [
          IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: () {
              _launchVideo(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // todo 分享功能
            },
          ),
          IconButton(
            tooltip: "Rename",
            icon: Icon(Icons.edit),
            onPressed: () {
              // todo 编辑功能
            },
          ),
          IconButton(
            tooltip: "Generate thumbnail",
            icon: Icon(Icons.image),
            onPressed: () {
              // todo 添加图片功能（假设修改为添加图片）
            },
          ),
          IconButton(
            tooltip: "Add to category",
            icon: Icon(Icons.playlist_add),
            onPressed: () {
              // todo 添加分类功能
            },
          ),
          IconButton(
            tooltip: "Delete",
            icon: Icon(Icons.delete),
            onPressed: () {
              // todo 删除功能
            },
          ),
        ],
      ),
    );
  }
  void _launchVideo(BuildContext context) {
    final uri = Uri.file(path);
    canLaunchUrl(uri).then((valid) {
      if (valid) {
        launchUrl(uri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('无法打开视频')),
          );
        }
      }
    }).catchError((e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('无法打开视频:$e')),
        );
      }
    });
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
