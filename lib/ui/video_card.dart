import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:next_movie/model/movie.dart';
import 'package:next_movie/service/category_service/category_service.dart';
import 'package:next_movie/service/movie_service/movie_service.dart';
import 'package:next_movie/ui/page/movie_detail_page.dart';
import 'package:next_movie/utils/app_path.dart';
import 'package:next_movie/utils/time.dart';
import 'package:next_movie/utils/size.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../task/task_queue.dart';
import 'select_category_dialog.dart';

class VideoCard extends StatefulWidget {
  const VideoCard({
    super.key,
    required this.itemWidth,
    required this.itemHeight,
    required this.movieId,
    this.categoryId,
    this.onRemoveFromCategory,
    this.onSelect,
    this.selecting = false,
    this.isSelected = false,
    this.startSelect,
    this.canBeSelected = true,
    required this.onDelete,
  });
  final double itemWidth;
  final double itemHeight;
  final int movieId;
  final int? categoryId;
  final void Function(int)? onRemoveFromCategory;
  final Function(bool)? onSelect;
  final bool selecting;
  final bool isSelected;
  final Function()? startSelect;
  final bool canBeSelected;
  final void Function() onDelete;
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
                  if (isCoverHovered && !widget.selecting)
                    buildPlayBtn(context),
                  if (isCoverHovered && !widget.selecting) buildBtnBar(context),
                  if (widget.selecting) buildSelectBox(context)
                ],
              ),
            ),
            buildMovieTitle(),
          ],
        ));
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
    if (widget.onSelect != null && isSelected != null) {
      widget.onSelect!(isSelected);
    }
  }

  SizedBox buildCoverContainer() {
    return SizedBox(
        height: widget.itemHeight - 30,
        width: widget.itemWidth,
        child: Container(
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
            child: buildCover()));
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
              errorBuilder: (context, widget, error) =>
                  const Icon(Icons.error, color: Colors.red))
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

  Positioned buildGrayCover(BuildContext context) {
    return Positioned.fill(
        child: GestureDetector(
      onTap: () => onCoverTap(context),
      child: Material(
        color: Colors.black.withValues(alpha: 0.3), // 蒙层颜色和透明度
      ),
    ));
  }

  void onCoverTap(BuildContext context) {
    if (widget.selecting && widget.onSelect != null) {
      widget.onSelect!(!widget.isSelected);
    } else {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MovieDetailPage(
                movieId: widget.movieId,
              )));
    }
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

  Positioned buildBtnBar(BuildContext context) {
    return Positioned(
        bottom: 0,
        child: SizedBox(
          width: widget.itemWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildLikeBtn(),
              buildWishBtn(),
              buildMoreBtn(context),
            ],
          ),
        ));
  }

  Tooltip buildLikeBtn() {
    return Tooltip(
        message: "Like",
        child: MouseRegion(
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
                      color: isHeartHovered
                          ? Colors.grey[200]
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      TDIcons.heart,
                      color:
                          like || isHeartHovered ? Colors.pink : Colors.white70,
                      size: min(20, widget.itemWidth / 5),
                    )))));
  }

  Tooltip buildWishBtn() {
    return Tooltip(
        message: "Add to watchlist",
        child: MouseRegion(
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
                    color:
                        isWishHovered ? Colors.grey[200] : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.watch_later,
                    color: wish || isWishHovered ? Colors.pink : Colors.white70,
                    size: min(20, widget.itemWidth / 5),
                  )),
            )));
  }

  MouseRegion buildMoreBtn(BuildContext parentContext) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isMoreHovered = true),
      onExit: (_) => setState(() => isMoreHovered = false),
      child: PopupMenuButton(
          itemBuilder: (BuildContext context) {
            return [
              _buildMenuItem(context, Icons.playlist_add_outlined,
                  "add to category", "category", () {
                final categoryService = CategoryService();
                showDialog(
                    context: parentContext,
                    builder: (BuildContext context) {
                      return SelectCategoryDialog(
                          initValue: null,
                          onConfirm: (result) {
                            categoryService
                                .addMovies(result!, [widget.movieId]);
                          },
                          options: categoryService.getAllCategories());
                    });
              }),
              if (widget.categoryId != null &&
                  widget.onRemoveFromCategory != null)
                _buildMenuItem(context, Icons.playlist_remove,
                    "remove from category", "remove", () {
                  final categoryService = CategoryService();
                  if (categoryService
                      .removeMovies(widget.categoryId!, [widget.movieId])) {
                    widget.onRemoveFromCategory!(widget.movieId);
                  }
                }),
              if (widget.canBeSelected)
                _buildMenuItem(context, Icons.check_box, "select", "select",
                    () {
                  if (widget.startSelect != null && widget.onSelect != null) {
                    widget.startSelect!();
                    widget.onSelect!(true);
                  }
                }),
              _buildMenuItem(context, Icons.delete, "delete", "delete", () {
                final movie = _service.getMovieById(widget.movieId);
                if (movie != null) {
                  showDialog(
                    context: parentContext,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Delete movie'),
                        content: Text(
                            'You will delete ${movie.path}, please choose how to delete.\nDelete file means delete the file in file system.\nDelete in database means delete the record in database of this software.'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop(); // 关闭对话框
                            },
                          ),
                          TextButton(
                            child: Text('Delete file'),
                            onPressed: () {
                              deleteMovieFile(parentContext, movie.path);
                              Navigator.of(context).pop(); // 关闭对话框
                            },
                          ),
                          TextButton(
                            child: Text('Delete in database'),
                            onPressed: () {
                              deleteMovieInDB(parentContext);
                              Navigator.of(context).pop(); // 关闭对话框
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              }),
              _buildMenuItem(context, Icons.edit, "rename", "rename", () {
                _showRenameDialog(parentContext);
              }),
              _buildMenuItem(
                  context, Icons.image, "generate thumbnail", "thumbnail", () {
                final service = MovieService(
                    taskQueue:
                        Provider.of<TaskQueue>(parentContext, listen: false));
                service.generateThumbnail(widget.movieId);
              }),
              _buildMenuItem(context, Icons.info, "check metadata", "metadata",
                  () {
                final movie = _service.getMovieById(widget.movieId);
                if (movie != null) {
                  showDialog(
                    context: parentContext,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(movie.title),
                        content: Column(
                            spacing: 8,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SelectableText("Path: ${movie.path}"),
                              if (movie.created != null)
                                SelectableText(
                                    "Created: ${movie.created!.split(".")[0]}"),
                              SelectableText(
                                  "Recorded: ${movie.recorded.toString().split(".")[0]}"),
                              SelectableText(
                                  "Duration: ${secondsToDurationString(movie.duration)}"),
                              SelectableText("Size: ${formatBytes(movie.size)}")
                            ]),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop(); // 关闭对话框
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
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

  void _showRenameDialog(BuildContext parentContext) {
    // 创建一个 TextEditingController 来获取输入框的值
    TextEditingController textController =
        TextEditingController(text: basenameWithoutExtension(title));

    // 弹出对话框
    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rename Movie'),
          content: Column(
            children: [
              Text("Rename movie will rename the source file of this movie."),
              TextField(
                controller: textController,
                decoration: InputDecoration(labelText: 'New name'),
              )
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                // 关闭对话框
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                // 获取输入框的值
                String newName = textController.text.trim();

                // 调用外部传入的回调函数
                if (newName.isNotEmpty) {
                  if (_service.renameMovie(
                      widget.movieId, "$newName${extension(title)}")) {
                    // 关闭对话框
                    Navigator.of(context).pop();
                    setState(() {
                      title = "$newName${extension(title)}";
                    });
                  } else {
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      SnackBar(
                          content:
                              Text('Rename fail, please check the file path.')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(content: Text('New name cannot be blank')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  deleteMovieInDB(BuildContext parentContext) {
    MovieService(
                taskQueue: Provider.of<TaskQueue>(parentContext, listen: false))
            .deleteMovieAndThumbnail([widget.movieId]).contains(widget.movieId)
        ? widget.onDelete()
        : null;
  }

  deleteMovieFile(BuildContext parentContext, String path) {
    if (MovieService(
            taskQueue: Provider.of<TaskQueue>(parentContext, listen: false))
        .deleteMovieAndThumbnail([widget.movieId]).contains(widget.movieId)) {
      widget.onDelete();
      try {
        File file = File(path);
        if (file.existsSync()) {
          file.deleteSync();
          TDToast.showSuccess(
              context: parentContext, "The file has been deleted.");
        }
      } catch (e) {
        TDToast.showWarning(
            context: parentContext, "The file does not exist in file system.");
      }
    }
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

  PopupMenuItem<String> _buildMenuItem(BuildContext context, IconData icon,
      String text, String value, VoidCallback onTap) {
    return PopupMenuItem(
      onTap: onTap,
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
}
