import 'package:next_movie/model/category.dart';


import 'package:next_movie/objectbox/objectbox.g.dart';

import 'package:next_movie/objectbox/objectbox.dart';

class CategoryCreator {
  final box=ObjectBox.getBox<Category>();
  final _category = Category();
  void setMeta(String name, String? description) {
    _category.name = name;
    _category.description = description;
  }

  bool create() {
    if (_category.name.isEmpty) {
      throw Exception("Category name cannot be empty");
    }
    if(box.query(Category_.name.equals(_category.name)).build().find().isNotEmpty){
      throw Exception("Category name already exists");
    }
    _category.created = DateTime.now().toLocal().toString().split(".")[0];
    return box.put(_category) != 0;
  }
}
