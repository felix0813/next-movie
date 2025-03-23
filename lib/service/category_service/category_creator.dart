import 'package:next_movie/model/category.dart';

import 'package:next_movie/provider/objectbox_provider.dart';

import 'package:next_movie/objectbox/objectbox.g.dart';

class CategoryCreator {
  late final ObjectBoxProvider? objectBoxProvider;
  final _category = Category();
  void setMeta(String name, String? description) {
    _category.name = name;
    _category.description = description;
  }

  bool create() {
    Box box=objectBoxProvider!.getBox<Category>();
    if (_category.name.isEmpty) {
      throw Exception("Category name cannot be empty");
    }
    if (objectBoxProvider == null) {
      throw Exception("ObjectBoxProvider is not initialized");
    }
    if(box.query(Category_.name.equals(_category.name)).build().find().isNotEmpty){
      throw Exception("Category name already exists");
    }
    _category.created = DateTime.now().toLocal().toString().split(".")[0];
    return box.put(_category) != 0;
  }

  CategoryCreator({required this.objectBoxProvider});
}
