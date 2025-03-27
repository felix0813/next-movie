import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import 'package:next_movie/model/movie.dart';

class VideoCard extends StatefulWidget {
  const VideoCard(
      {super.key,
      required this.index,
      required this.itemWidth,
      required this.itemHeight,
      required this.movie});
  final int index;
  final double itemWidth;
  final double itemHeight;
  final Movie movie;
  @override
  VideoCardState createState() => VideoCardState();
}

class VideoCardState extends State<VideoCard> {
  // 状态变量，记录每个图标的悬停状态
  bool isMoreHovered = false;
  bool isHeartHovered = false;
  bool isPlayHovered = false;
  bool isCoverHovered = false;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: widget.itemWidth,
        height: widget.itemHeight,
        child: Column(
          children: [
            MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => isCoverHovered = true),
                onExit: (_) => setState(() => isCoverHovered = false),
                child: GestureDetector(
                  onTap: () {
                    //todo
                  },
                  child: Stack(
                    children: [
                      Container(
                          height: widget.itemHeight - 30,
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
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              'https://picsum.photos/300/150?random=${widget.index}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, widget, error) {
                                return const Icon(Icons.error,
                                    color: Colors.red);
                              },
                            ),
                          )),
                      Positioned(
                          top: 2,
                          right: 10,
                          child: Text(
                            widget.movie.star == null
                                ? ""
                                : "${widget.movie.star}.0",
                            style: TextStyle(
                                color: Colors.pink,
                                fontSize: max(
                                    10, (widget.itemHeight - 30) * 10 / 45)),
                          )),
                      if (isCoverHovered)
                        Positioned.fill(
                          child: Material(
                            color: Colors.black.withValues(alpha: 0.3), // 蒙层颜色和透明度
                          ),
                        ),
                      if (isCoverHovered)
                        Positioned(
                            bottom: 0,
                            child: SizedBox(
                                width: widget.itemWidth,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        onEnter: (_) => setState(
                                            () => isHeartHovered = true),
                                        onExit: (_) => setState(
                                            () => isHeartHovered = false),
                                        child: GestureDetector(
                                            onTap: () {
                                              //todo
                                            },
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  color: isHeartHovered
                                                      ? Colors.grey[200]
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Icon(
                                                  TDIcons.heart,
                                                  color:
                                                      widget.movie.likeDate !=
                                                                  null ||
                                                              isHeartHovered
                                                          ? Colors.pink
                                                          : Colors.white70,
                                                  size: min(
                                                      24, widget.itemWidth / 5),
                                                )))),
                                    MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        onEnter: (_) => setState(
                                            () => isPlayHovered = true),
                                        onExit: (_) => setState(
                                            () => isPlayHovered = false),
                                        child: GestureDetector(
                                            onTap: () {
                                              //todo
                                            },
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  color: isPlayHovered
                                                      ? Colors.grey[200]
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Icon(
                                                  TDIcons
                                                      .play_circle_stroke_add,
                                                  color:
                                                      widget.movie.wishDate !=
                                                                  null ||
                                                              isPlayHovered
                                                          ? Colors.pink
                                                          : Colors.white70,
                                                  size: min(
                                                      24, widget.itemWidth / 5),
                                                )))),
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      onEnter: (_) =>
                                          setState(() => isMoreHovered = true),
                                      onExit: (_) =>
                                          setState(() => isMoreHovered = false),
                                      child: GestureDetector(
                                          onTap: () {
                                            //todo
                                          },
                                          child: Container(
                                              decoration: BoxDecoration(
                                                color: isMoreHovered
                                                    ? Colors.grey[200]
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Icon(
                                                TDIcons.more,
                                                color: isMoreHovered
                                                    ? Colors.pink
                                                    : Colors.white70,
                                                size: min(
                                                    24, widget.itemWidth / 5),
                                                //color: Colors.pink,
                                              ))),
                                    ),
                                  ],
                                )))
                    ],
                  ),
                )),
            SizedBox(
              width: widget.itemWidth,
              height: 25,
              child: Text(
                style: TextStyle(fontSize: 16),
                widget.movie.title,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                maxLines: 1,
              ),
            ),
          ],
        ));
  }
}
