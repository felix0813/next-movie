import 'dart:io';

import 'package:flutter/material.dart';
import 'package:next_movie/service/category_service/category_service.dart';
import 'package:next_movie/service/movie_service/movie_service.dart';
import 'package:provider/provider.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../task/task_queue.dart';
import 'movie_extra_meta_form.dart';
import 'select_category_dialog.dart';

class SelectMovieNavigationBar extends StatelessWidget
    implements PreferredSizeWidget {
  final Set<int> selectedMovies;
  final Function() quitSelecting;
  final void Function()? removeMoviesFromCategory;
  final Function(List<int> movies) onDelete;
  const SelectMovieNavigationBar({
    super.key,
    required this.selectedMovies,
    required this.quitSelecting,
    this.removeMoviesFromCategory,
    required this.onDelete,
  });
  Future<MovieExtraMeta?> getExtraMeta(BuildContext context) {
    return showModalBottomSheet<MovieExtraMeta>(
      context: context,
      builder: (context) {
        return MovieExtraMetaForm();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(selectedMovies.length.toString()),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          quitSelecting();
        },
      ),
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.playlist_add_outlined),
          tooltip: 'add to category',
          onPressed: () {
            final categoryService = CategoryService();
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SelectCategoryDialog(
                      initValue: null,
                      onConfirm: (result) {
                        categoryService.addMovies(
                            result!, selectedMovies.toList());
                        quitSelecting();
                      },
                      options: categoryService.getAllCategories());
                });
          },
        ),
        if (removeMoviesFromCategory != null)
          IconButton(
            icon: Icon(Icons.playlist_remove_outlined),
            tooltip: 'remove from category',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Remove from category'),
                    content: Text(
                        'You will remove ${selectedMovies.length} movies from current category'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('cancel'),
                        onPressed: () {
                          Navigator.of(context).pop(); // 关闭对话框
                        },
                      ),
                      TextButton(
                        child: Text('confirm'),
                        onPressed: () {
                          removeMoviesFromCategory!();
                          Navigator.of(context).pop(); // 关闭对话框
                          quitSelecting();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        IconButton(
          icon: Icon(Icons.delete),
          tooltip: 'Delete',
          onPressed: () {
            if (selectedMovies.isEmpty) {
              TDToast.showWarning("Please select 1 movie at least",
                  context: context);
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Delete movies'),
                    content: Text(
                        'You will delete ${selectedMovies.length} movies, please choose how to delete.\nDelete file means delete the file in file system.\nDelete in database means delete the record in database of this software.'),
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
                          deleteMovieFile(context, selectedMovies);
                          Navigator.of(context).pop(); // 关闭对话框
                          quitSelecting();
                        },
                      ),
                      TextButton(
                        child: Text('Delete in database'),
                        onPressed: () {
                          deleteMovieInDB(context, selectedMovies);
                          Navigator.of(context).pop(); // 关闭对话框
                          quitSelecting();
                        },
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
      ],
    );
  }

  deleteMovieInDB(BuildContext parentContext, Set<int> movies) {
    final deleteMovies = MovieService(
            taskQueue: Provider.of<TaskQueue>(parentContext, listen: false))
        .deleteMovieAndThumbnail(movies.toList());
    if (deleteMovies.isNotEmpty) {
      onDelete(deleteMovies);
    }
  }

  deleteMovieFile(BuildContext parentContext, Set<int> movies) {
    final service = MovieService(
        taskQueue: Provider.of<TaskQueue>(parentContext, listen: false));
    Map<int, String> paths = {};
    for (var movieId in movies) {
      final movie = service.getMovieById(movieId);
      if (movie != null) {
        paths[movieId] = movie.path;
      }
    }
    final deleteMovies = service.deleteMovieAndThumbnail(movies.toList());
    for (var movieId in deleteMovies) {
      final path = paths[movieId]!;
      try {
        File file = File(path);
        if (file.existsSync()) {
          file.deleteSync();
          TDToast.showSuccess(
              context: parentContext, "The file $path has been deleted.");
        }
      } catch (e) {
        TDToast.showWarning(
            context: parentContext,
            "The file $path does not exist in file system.");
      }
    }
    onDelete(deleteMovies);
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class SelectCategoryNavigationBar extends StatelessWidget
    implements PreferredSizeWidget {
  final Set<int> selectedCategory;
  final Function() quitSelecting;
  final void Function(Set<int>) deleteCategory;
  const SelectCategoryNavigationBar({
    super.key,
    required this.selectedCategory,
    required this.quitSelecting,
    required this.deleteCategory,
  });
  Future<MovieExtraMeta?> getExtraMeta(BuildContext context) {
    return showModalBottomSheet<MovieExtraMeta>(
      context: context,
      builder: (context) {
        return MovieExtraMetaForm();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(selectedCategory.length.toString()),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          quitSelecting();
        },
      ),
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.delete),
          tooltip: 'Delete category',
          onPressed: () {
            if (selectedCategory.isEmpty) {
              TDToast.showWarning("Please select 1 category at least",
                  context: context);
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Delete categories'),
                    content: Text(
                        'You will delete ${selectedCategory.length} category, and this operation is irreversible.'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop(); // 关闭对话框
                        },
                      ),
                      TextButton(
                        child: Text('Delete'),
                        onPressed: () {
                            deleteCategory(selectedCategory);
                          Navigator.of(context).pop(); // 关闭对话框
                          quitSelecting();
                        },
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
