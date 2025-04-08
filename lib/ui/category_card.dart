import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:next_movie/model/category.dart';
import 'package:next_movie/ui/page/category_video_page.dart';
import 'package:next_movie/utils/app_path.dart';
import 'package:path/path.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../service/category_service/category_service.dart';

class CategoryCard extends StatefulWidget {
  const CategoryCard(
      {super.key,
      required this.itemWidth,
      required this.isSelected,
      required this.itemHeight,
      required this.categoryId,
      required this.onSelect,
      required this.selecting,
      required this.onUpdateUI});
  final double itemWidth;
  final double itemHeight;
  final int categoryId;
  final bool isSelected;
  final VoidCallback onUpdateUI;

  final Function(bool) onSelect;

  final bool selecting;
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
                  if (isCoverHovered) buildGrayCover(context),
                  if (isCoverHovered && !widget.selecting) buildBtnBar(context),
                  if (widget.isSelected) buildSelectBox(context)
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

  Positioned buildGrayCover(BuildContext context) {
    return Positioned.fill(
        child: GestureDetector(
      onTap: () {
        if (widget.selecting) {
          if (widget.selecting) {
            widget.onSelect(!widget.isSelected);
          }
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    CategoryVideoPage(categoryId: widget.categoryId)),
          );
        }
      },
      child: Material(
        color: Colors.black.withValues(alpha: 0.3), // 蒙层颜色和透明度
      ),
    ));
  }

  Positioned buildBtnBar(BuildContext context) {
    return Positioned(
        bottom: 5,
        right: 10,
        child: SizedBox(
          width: widget.itemWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              buildAddBtn(),
              buildMoreBtn(context),
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

  MouseRegion buildMoreBtn(BuildContext parentContext) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isMoreHovered = true),
      onExit: (_) => setState(() => isMoreHovered = false),
      child: PopupMenuButton(
          itemBuilder: (BuildContext context) {
            return [
              _buildMenuItem(context, Icons.check_box, "select", "select", () {
                widget.onSelect(true);
              }),
              _buildMenuItem(context, Icons.delete, "delete", "delete", () {
                showDialog(
                    context: parentContext,
                    builder: (BuildContext context) => AlertDialog(
                          title: Text("Delete Category"),
                          content: Text(
                              "The category with title '$title' will be removed,and the files of movies will remain."),
                          actions: [
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('Confirm'),
                              onPressed: () {
                                if (CategoryService()
                                    .removeCategory(widget.categoryId)) {
                                  widget.onUpdateUI();
                                }
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ));
              }),
              _buildMenuItem(context, Icons.edit, "edit", "edit", () {
                //todo
              })
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
  PopupMenuItem<String> _buildMenuItem(BuildContext context, IconData icon,
      String text, String value, VoidCallback onTap) {
    return PopupMenuItem(
      value: value,
      onTap: onTap,
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

  buildSelectBox(BuildContext context) {
    return Positioned(
        top: 0,
        right: 0,
        child: Checkbox(
            activeColor: Colors.blue,
            checkColor: Colors.white70,
            value: widget.isSelected,
            onChanged: onCheckBoxChange));
  }

  void onCheckBoxChange(isSelected) {
    if (isSelected != null) {
      widget.onSelect(isSelected);
    }
  }
}
