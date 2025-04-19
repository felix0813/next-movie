import 'package:next_movie/model/category.dart';
import 'package:next_movie/model/sort_by.dart';
import 'package:next_movie/objectbox/objectbox.dart';
import 'package:next_movie/objectbox/objectbox.g.dart';

class CategoryRepository {
  final _box = ObjectBox.getBox<Category>();
  int addCategory(Category category) =>
      _box.put(category, mode: PutMode.insert);

  bool removeCategory(int id) => _box.remove(id);

  int updateCategory(Category category) =>
      _box.put(category, mode: PutMode.update);

  Category? getCategoryById(int id) => _box.get(id);

  List<int> getOnePageCategories(int page, String sortBy, String order) {
    int flag = order == SortOrder.descending ? Order.descending : 0;
    switch (sortBy) {
      case SortBy.created:
        return (_box.query().order(Category_.created, flags: flag).build()
              ..offset = 100 * page
              ..limit = 100)
            .findIds();
      case SortBy.title:
        return (_box.query().order(Category_.name, flags: flag).build()
              ..offset = 100 * page
              ..limit = 100)
            .findIds();
      default:
        return (_box.query().order(Category_.created, flags: flag).build()
              ..offset = 100 * page
              ..limit = 100)
            .findIds();
    }
  }

  List<int> search(String keyword, String sortBy, String order) {
    int flag = order == SortOrder.descending ? Order.descending : 0;
    switch (sortBy) {
      case SortBy.created:
        return (_box
                .query(Category_.name.contains(keyword).or(Category_.description
                    .contains(keyword, caseSensitive: false)))
                .order(Category_.created, flags: flag)
                .build())
            .findIds();
      case SortBy.title:
        return (_box
                .query(Category_.name.contains(keyword).or(Category_.description
                    .contains(keyword, caseSensitive: false)))
                .order(Category_.name, flags: flag)
                .build())
            .findIds();
      default:
        return (_box
                .query(Category_.name.contains(keyword).or(Category_.description
                    .contains(keyword, caseSensitive: false)))
                .order(Category_.created, flags: flag)
                .build())
            .findIds();
    }
  }

  int getTotalCategories() => _box.count();

  List<Category> getAllCategories() => _box.getAll();

  int removeMovies(int category, List<int> movies) {
    final newCategory = _box.get(category);
    if (newCategory != null) {
      newCategory.movies =
          newCategory.movies.where((item) => !movies.contains(item)).toList();
      return _box.put(newCategory);
    }
    return 0;
  }
}
