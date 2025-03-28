import 'package:next_movie/model/category.dart';
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
}
