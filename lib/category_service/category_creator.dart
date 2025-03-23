import 'package:next_movie/model/category.dart';

import '../objectbox/objectbox_provider.dart';

class CategoryCreator {
  late final ObjectBoxProvider? objectBoxProvider;
  final _category = Category();
  void setMeta(String name, String? description) {
    _category.name = name;
    _category.description = description;
  }

  bool create() {
    if (_category.name.isEmpty) {
      throw Exception("Category name cannot be empty");
    }
    if (objectBoxProvider == null) {
      throw Exception("ObjectBoxProvider is not initialized");
    }
    _category.created = DateTime.now().toLocal().toString().split(".")[0];
    return objectBoxProvider!.getBox<Category>().put(_category) != 0;
  }

  CategoryCreator({required this.objectBoxProvider});
}
