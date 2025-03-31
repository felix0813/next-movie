import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:next_movie/model/category.dart';
import 'package:next_movie/service/movie_service/movie_service.dart';
import 'package:next_movie/utils/app_path.dart';
import 'package:path/path.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import 'package:next_movie/model/movie.dart';
import 'package:url_launcher/url_launcher.dart';

import '../service/category_service/category_service.dart';

class CategoryCard extends StatefulWidget {
  const CategoryCard(
      {super.key,
      required this.itemWidth,
      required this.itemHeight,
      required this.categoryId});
  final double itemWidth;
  final double itemHeight;
  final int categoryId;
  @override
  CategoryCardState createState() => CategoryCardState();
}

class CategoryCardState extends State<CategoryCard> {
  // 状态变量，记录每个图标的悬停状态
  bool isMoreHovered = false;
  bool isAddHovered = false;
  bool isCoverHovered = false;
  bool isPlayHovered = false;
  bool like = false;
  bool wish = false;
  int? star;
  final _service = CategoryService();
  String title = "";
  int? latestMovieId = 0;

  @override
  void initState() {
    Category? c = _service.getCategoryById(widget.categoryId);
    if (c == null) {
      return;
    } else {
      setState(() {
        star = c.star;
        title = c.name;
        latestMovieId = c.movies.isNotEmpty ? c.movies.last : 0;
      });
    }
    super.initState();
  }

  bool checkThumbnailExist() {
    final file = File(join(AppPaths.instance.appDocumentsDir, "next_movie",
        "poster", "$latestMovieId.jpg"));

    final result = file.existsSync();
    return result;
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
                  "poster", "$latestMovieId.jpg")),
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
                    Icons.video_collection,
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

  Positioned buildBtnBar() {
    return Positioned(
        bottom: 5,
        right: 10,
        child: SizedBox(
          width: widget.itemWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              buildAddBtn(),
              buildMoreBtn(),
            ],
          ),
        ));
  }

  MouseRegion buildAddBtn() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isAddHovered = true),
      onExit: (_) => setState(() => isAddHovered = false),
      child: GestureDetector(
          onTap: () {
            //todo
          },
          child: Container(
              margin: EdgeInsets.only(right: 5),
              decoration: BoxDecoration(
                color: isAddHovered ? Colors.grey[200] : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                TDIcons.add,
                color: isAddHovered ? Colors.pink : Colors.white70,
                size: min(20, widget.itemWidth / 5),
                //color: Colors.pink,
              ))),
    );
  }

  MouseRegion buildMoreBtn() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isMoreHovered = true),
      onExit: (_) => setState(() => isMoreHovered = false),
      child: PopupMenuButton(
        onSelected: (value){
          //todo
        },
          itemBuilder: (BuildContext context) {
            return [
              _buildMenuItem(context,Icons.check_box,"select","select"),
              _buildMenuItem(context,Icons.delete,"delete","delete"),
              _buildMenuItem(context,Icons.edit,"edit","edit")
            ];
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

  // 封装菜单项构建方法
  PopupMenuItem<String> _buildMenuItem(BuildContext context,IconData icon, String text, String value) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).iconTheme.color), // 图标
          SizedBox(width: 12), // 图标与文字间距
          Text(text, style: TextStyle(color: Colors.grey[600])), // 文字
        ],
      ),
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
