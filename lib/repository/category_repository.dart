import '../model/category.dart';
import '../objectbox/objectbox.dart';
import '../objectbox/objectbox.g.dart';

class CategoryRepository {
  final _box = ObjectBox.getBox<Category>();
  int addCategory(Category category) {
    return _box.put(category, mode: PutMode.insert);
  }

  bool removeCategory(int id) {
    return _box.remove(id);
  }

  int updateCategory(Category category) {
    return _box.put(category, mode: PutMode.update);
  }

  Category? getCategoryById(int id)=>_box.get(id);
}
