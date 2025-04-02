import 'package:flutter/material.dart';
import 'package:next_movie/service/category_service/category_service.dart';
import 'package:next_movie/service/movie_service/movie_service.dart';
import 'package:next_movie/ui/select_category_dialog.dart';
import 'movie_extra_meta_form.dart';

class SelectNavigationBar extends StatelessWidget
    implements PreferredSizeWidget {
  final Set<int> selectedMovies;
  final Function() quitSelecting;
  const SelectNavigationBar({
    super.key,
    required this.selectedMovies,
    required this.quitSelecting,
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
