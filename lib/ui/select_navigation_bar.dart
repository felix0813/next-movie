import 'package:flutter/material.dart';
import 'package:next_movie/service/category_service/category_service.dart';
import 'package:next_movie/service/movie_service/movie_service.dart';
import 'select_category_dialog.dart';
import 'movie_extra_meta_form.dart';

class SelectNavigationBar extends StatelessWidget
    implements PreferredSizeWidget {
  final Set<int> selectedMovies;
  final Function() quitSelecting;
  final void Function()? removeMoviesFromCategory;
  const SelectNavigationBar({
    super.key,
    required this.selectedMovies,
    required this.quitSelecting,
    this.removeMoviesFromCategory,
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
            //todo
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
