import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:next_movie/service/movie_service/movie_service.dart';
import 'package:next_movie/utils/app_path.dart';
import 'package:path/path.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import 'package:next_movie/model/movie.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoCard extends StatefulWidget {
  const VideoCard(
      {super.key,
      required this.itemWidth,
      required this.itemHeight,
      required this.movieId});
  final double itemWidth;
  final double itemHeight;
  final int movieId;
  @override
  VideoCardState createState() => VideoCardState();
}

class VideoCardState extends State<VideoCard> {
  // 状态变量，记录每个图标的悬停状态
  bool isMoreHovered = false;
  bool isHeartHovered = false;
  bool isWishHovered = false;
  bool isCoverHovered = false;
  bool isPlayHovered = false;
  bool like = false;
  bool wish = false;
  int? star;
  final _service = MovieService();
  String path = "";
  String title = "";

  @override
  void initState() {
    Movie? m = _service.getMovieById(widget.movieId);
    if (m == null) {
      return;
    } else {
      setState(() {
        like = m.likeDate != null;
        wish = m.wishDate != null;
        path = m.path;
        star = m.star;
        title = m.title;
      });
    }
    super.initState();
  }

  bool checkThumbnailExist() {
    final file = File(join(AppPaths.instance.appDocumentsDir, "next_movie",
        "poster", "${widget.movieId}.jpg"));

    final result = file.existsSync();
    return result;
  }

  Future<void> _launchVideo(BuildContext context) async {
    final uri = Uri.file(path);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('无法打开视频')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: widget.itemWidth,
        height: widget.itemHeight,
        child: Column(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              opaque: false,
              onEnter: (_) => setState(() => isCoverHovered = true),
              onExit: (_) => setState(() => isCoverHovered = false),
              child: Stack(
                children: [
                  buildCoverContainer(),
                  buildRate(),
                  if (isCoverHovered) buildGrayCover(),
                  if (isCoverHovered) buildPlayBtn(context),
                  if (isCoverHovered) buildBtnBar()
                ],
              ),
            ),
            buildMovieTitle(),
          ],
        ));
  }

  Container buildCoverContainer() {
    return Container(
        height: widget.itemHeight - 30,
        width: widget.itemWidth,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: buildCover());
  }

  Positioned buildRate() {
    return Positioned(
        top: 2,
        right: 10,
        child: Text(
          star == null ? "" : "$star.0",
          style: TextStyle(
              color: Colors.pink,
              fontSize: max(10, (widget.itemHeight - 30) * 10 / 45)),
        ));
  }

  ClipRRect buildCover() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: checkThumbnailExist()
          ? Image.file(
              File(join(AppPaths.instance.appDocumentsDir, "next_movie",
                  "poster", "${widget.movieId}.jpg")),
              fit: BoxFit.cover,
              errorBuilder: (context, widget, error) {
                return const Icon(Icons.error, color: Colors.red);
              },
            )
          : Stack(
              children: [
                Container(
                  color: Colors.blue, // 蓝色背景
                ),
                Center(
                  child: Icon(
                    Icons.video_file,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
    );
  }

  Positioned buildGrayCover() {
    return Positioned.fill(
        child: GestureDetector(
      onTap: () {
        print("image");
        //todo
      },
      child: Material(
        color: Colors.black.withValues(alpha: 0.3), // 蒙层颜色和透明度
      ),
    ));
  }

  Positioned buildPlayBtn(BuildContext context) {
    return Positioned(
        left: (widget.itemWidth - 10 - (widget.itemHeight - 40) / 4 - 20) / 2,
        right: (widget.itemWidth - 10 - (widget.itemHeight - 40) / 4 - 20) / 2,
        bottom: 20,
        top: 20,
        child: SizedBox(
            height: (widget.itemHeight - 40) / 4,
            width: (widget.itemHeight - 40) / 4,
            child: GestureDetector(
                child: MouseRegion(
                  onEnter: (_) => setState(() => isPlayHovered = true),
                  onExit: (_) => setState(() => isPlayHovered = false),
                  cursor: SystemMouseCursors.click,
                  child: Icon(
                    size: min(40, widget.itemWidth / 5),
                    TDIcons.play_circle,
                    color: isPlayHovered ? Colors.blue : Colors.white70,
                  ),
                ),
                onTap: () {
                  _launchVideo(context);
                })));
  }

  Positioned buildBtnBar() {
    return Positioned(
        bottom: 0,
        child: SizedBox(
          width: widget.itemWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildLikeBtn(),
              buildWishBtn(),
              buildMoreBtn(),
            ],
          ),
        ));
  }

  MouseRegion buildLikeBtn() {
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => isHeartHovered = true),
        onExit: (_) => setState(() => isHeartHovered = false),
        child: GestureDetector(
            onTap: () {
              if (_service.like(widget.movieId, !like)) {
                setState(() {
                  like = !like;
                });
              }
            },
            child: Container(
                decoration: BoxDecoration(
                  color: isHeartHovered ? Colors.grey[200] : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  TDIcons.heart,
                  color: like || isHeartHovered ? Colors.pink : Colors.white70,
                  size: min(20, widget.itemWidth / 5),
                ))));
  }

  MouseRegion buildWishBtn() {
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => isWishHovered = true),
        onExit: (_) => setState(() => isWishHovered = false),
        child: GestureDetector(
            onTap: () {
              if (_service.wish(widget.movieId, !wish)) {
                setState(() {
                  wish = !wish;
                });
              }
            },
            child: Container(
                decoration: BoxDecoration(
                  color: isWishHovered ? Colors.grey[200] : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  TDIcons.play_circle_stroke_add,
                  color: wish || isWishHovered ? Colors.pink : Colors.white70,
                  size: min(20, widget.itemWidth / 5),
                ))));
  }

  MouseRegion buildMoreBtn() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isMoreHovered = true),
      onExit: (_) => setState(() => isMoreHovered = false),
      child: GestureDetector(
          onTap: () {
            //todo
          },
          child: Container(
              decoration: BoxDecoration(
                color: isMoreHovered ? Colors.grey[200] : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                TDIcons.more,
                color: isMoreHovered ? Colors.pink : Colors.white70,
                size: min(20, widget.itemWidth / 5),
                //color: Colors.pink,
              ))),
    );
  }

  SizedBox buildMovieTitle() {
    return SizedBox(
      width: widget.itemWidth,
      height: 25,
      child: Text(
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16),
        title,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        maxLines: 1,
      ),
    );
  }
}
