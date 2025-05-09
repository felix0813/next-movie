import 'package:logging/logging.dart';
import 'package:next_movie/model/category.dart';
import 'package:next_movie/repository/category_repository.dart';
import 'package:next_movie/service/movie_service/error_task.dart';
import 'package:next_movie/task/task_queue.dart';

class CategoryService {
  final _repository = CategoryRepository();
  final TaskQueue? _taskQueue;
  static final _logger = Logger("CategoryService");

  CategoryService({TaskQueue? taskQueue}) : _taskQueue = taskQueue;

  bool create(String name, String? description) {
    if (name.isEmpty) {
      ErrorTask(
              taskId: "Add new category $name fail",
              message: 'Category name cannot be empty',
              taskQueue: _taskQueue!)
          .run();
    }
    final category = Category(
        name: name,
        description: description,
        created: DateTime.now().toLocal());

    if (_repository.addCategory(category) == 0) {
      throw Exception("Category name already exists");
    }
    return true;
  }

  bool removeCategory(int id) => _repository.removeCategory(id);

  bool renameCategory(int id, String name) {
    final category = _repository.getCategoryById(id);
    if (category != null) {
      category.name = name;
      try {
        return _repository.updateCategory(category) == id;
      } catch (e) {
        _logger.severe("Rename fail:$e");
        return false;
      }
    }
    return false;
  }

  bool addMovies(int id, List<int> movies) {
    final category = _repository.getCategoryById(id);
    if (category != null) {
      List<int> result = List.empty(growable: true);
      result.addAll(category.movies);
      result.addAll(movies);
      result = [
        ...{...result}
      ];
      category.movies = result;
      return _repository.updateCategory(category) == id;
    }

    return false;
  }

  List<int> getOnePageCategories(int page, String sortBy, String order) =>
      _repository.getOnePageCategories(page, sortBy, order);

  int getTotalCategories() => _repository.getTotalCategories();

  Category? getCategoryById(int id) => _repository.getCategoryById(id);

  List<Category> getAllCategories() => _repository.getAllCategories();

  bool removeMovies(int category, List<int> movies) =>
      _repository.removeMovies(category, movies) == category;

  List<int> searchCategory(String keyword, String sortBy, String order) =>
      _repository.search(keyword, sortBy, order);
}
