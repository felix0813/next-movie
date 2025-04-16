import 'dart:core';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:next_movie/ui/global_navigation_bar.dart';
import 'package:next_movie/ui/input_dialog.dart';
import 'package:next_movie/utils/app_path.dart';
import 'package:next_movie/utils/size.dart';
import 'package:next_movie/utils/time.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../service/category_service/category_service.dart';
import '../../service/movie_service/movie_service.dart';
import '../../task/task_queue.dart';
import '../select_category_dialog.dart';

class MovieDetailPage extends StatefulWidget {
  const MovieDetailPage(
      {super.key, required this.movieId, required this.onMetaUpdate});
  final int movieId;
  final Function() onMetaUpdate;
  @override
  MovieDetailPageState createState() => MovieDetailPageState();
}

Color generateRandomColor() {
  final Random random = Random();
  Color newColor = Color.fromARGB(
    255,
    random.nextInt(256),
    random.nextInt(256),
    random.nextInt(256),
  );
  return newColor;
}

final colors = List.generate(10, (_) => generateRandomColor());

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
  String source = "";
  List<String> tags = [];

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
      tags = movie.tags;
      source = movie.source ?? '';
      thumbnailPath = checkThumbnailExist()
          ? join(AppPaths.instance.appDocumentsDir, "next_movie", "poster",
              "${widget.movieId}.jpg")
          : "";
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
              padding: EdgeInsets.all(min(16.0, width * 0.05)),
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
              padding:
                  EdgeInsets.symmetric(horizontal: min(16.0, width * 0.05)),
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
                                widget.onMetaUpdate();
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
                                widget.onMetaUpdate();
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
                    buildFunctionBtn(context, width),
                ],
              ),
            ),
            if (MediaQuery.of(context).size.width <= 500)
              buildFunctionBtn(context, width),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Wrap(
                spacing: 8,
                children: [
                  ...List.generate(tags.length, buildTag),
                  if (tags.isNotEmpty) SizedBox(width: 8), // 添加一些间距
                  ElevatedButton(
                    onPressed: () => _addTag(context),
                    child: Text('Add'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildTag(index) => TDTag(
        key: Key(tags[index]),
        tags[index],
        style: TDTagStyle(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.only(top: 8, left: 10),
        forceVerticalCenter: true,
        backgroundColor: colors[index % 10],
        overflow: TextOverflow.ellipsis,
        needCloseIcon: true,
        shape: TDTagShape.round,
        onCloseTap: () {
          final newTags = tags.where((t) => t != tags[index]).toList();
          if (_service.updateTags(widget.movieId, newTags)) {
            setState(() {
              tags.removeAt(index);
            });
          }
        },
      );

  TDRate buildRate(BuildContext context) {
    return TDRate(
        value: star.toDouble(),
        onChange: (value) {
          if (_service.star(widget.movieId, value.toInt())) {
            widget.onMetaUpdate();
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
        if (source.isNotEmpty)
          Container(
            padding: EdgeInsets.only(top: 4),
            child: SelectableText(
              "Download from $source",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          )
      ],
    );
  }

  buildThumbnail(double width) {
    return checkThumbnailExist()
        ? ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.file(
              File(thumbnailPath), // 从文件系统加载缩略图
              width: min(width * 0.75, 480),
              height: min(width * 0.75, 480) * 9 / 16,
              fit: BoxFit.cover,
            ),
          )
        : Stack(
            children: [
              Container(
                width: min(width * 0.75, 480),
                height: min(width * 0.75, 480) * 9 / 16,
                decoration: BoxDecoration(
                  color: Colors.blue, // 蓝色背景
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: Icon(
                    Icons.video_file,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
  }

  SizedBox buildFunctionBtn(BuildContext context, double width) {
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
            icon: Icon(Icons.edit_road),
            tooltip: "Edit source",
            onPressed: () {
              SingleInputDialog.show(
                      context: context, title: "Edit source", maxLength: 200)
                  .then((result) {
                if (result != null) {
                  if (_service.addSource(widget.movieId, result)) {
                    setState(() {
                      source = result;
                    });
                  } else {
                    if (context.mounted) {
                      TDToast.showText("Edit source error.",
                          context: context,
                          constraints: BoxConstraints(maxWidth: 150));
                    }
                  }
                }
              });
            },
          ),
          IconButton(
            tooltip: "Rename",
            icon: Icon(Icons.edit),
            onPressed: () {
              _showRenameDialog(context);
            },
          ),
          IconButton(
            tooltip: "Generate thumbnail",
            icon: Icon(Icons.image),
            onPressed: () {
              final service = MovieService(
                  taskQueue: Provider.of<TaskQueue>(context, listen: false));
              service.generateThumbnail(widget.movieId);
              Future.delayed(const Duration(seconds: 2)).then((_) {
                setState(() {
                  checkThumbnailExist()
                      ? join(AppPaths.instance.appDocumentsDir, "next_movie",
                          "poster", "${widget.movieId}.jpg")
                      : "";
                });
              });
            },
          ),
          IconButton(
            tooltip: "Add to category",
            icon: Icon(Icons.playlist_add),
            onPressed: () {
              final categoryService = CategoryService();
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SelectCategoryDialog(
                        initValue: null,
                        onConfirm: (result) {
                          categoryService.addMovies(result!, [widget.movieId]);
                        },
                        options: categoryService.getAllCategories());
                  });
            },
          ),
          IconButton(
            tooltip: "Delete",
            icon: Icon(Icons.delete),
            onPressed: () {
              onDelete(context);
            },
          ),
        ],
      ),
    );
  }

  void _addTag(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add tag'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'input tag',
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                String newTag = controller.text.trim();
                if (newTag.isNotEmpty && !tags.contains(newTag)) {
                  if (_service.updateTags(widget.movieId, [...tags, newTag])) {
                    setState(() {
                      tags.add(newTag);
                    });
                  }
                  controller.clear();
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
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
          content: SizedBox(
            height: 200,
            child: Column(
              children: [
                Text("Rename movie will rename the source file of this movie."),
                TextField(
                  controller: textController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(labelText: 'New name'),
                )
              ],
            ),
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
                    widget.onMetaUpdate();
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

  onDelete(BuildContext parentContext) {
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
                  Navigator.of(context).pop(); // 关闭对话框
                  deleteMovieFile(parentContext, movie.path);
                },
              ),
              TextButton(
                child: Text('Delete in database'),
                onPressed: () {
                  Navigator.of(context).pop(); // 关闭对话框
                  deleteMovieInDB(parentContext);
                },
              ),
            ],
          );
        },
      );
    }
  }

  bool checkThumbnailExist() {
    final file = File(join(AppPaths.instance.appDocumentsDir, "next_movie",
        "poster", "${widget.movieId}.jpg"));

    final result = file.existsSync();
    return result;
  }

  deleteMovieInDB(BuildContext parentContext) {
    MovieService(
                taskQueue: Provider.of<TaskQueue>(parentContext, listen: false))
            .deleteMovieAndThumbnail([widget.movieId]).contains(widget.movieId)
        ? Navigator.pop(parentContext, "delete")
        : null;
  }

  deleteMovieFile(BuildContext parentContext, String path) {
    if (MovieService(
            taskQueue: Provider.of<TaskQueue>(parentContext, listen: false))
        .deleteMovieAndThumbnail([widget.movieId]).contains(widget.movieId)) {
      try {
        File file = File(path);
        if (file.existsSync()) {
          file.deleteSync();
          TDToast.showText(
              context: parentContext,
              "The file has been deleted.",
              constraints: BoxConstraints(maxWidth: 300));
        }
      } catch (e) {
        TDToast.showText(
            context: parentContext,
            "The file does not exist in file system.",
            constraints: BoxConstraints(maxWidth: 300));
      }
      Navigator.pop(parentContext, "delete");
    }
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
