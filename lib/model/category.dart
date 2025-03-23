
import 'package:objectbox/objectbox.dart';

@Entity()
class Category {
  @Id()
  late int id;
  late String name;
  late String created;
  late List<int> movies;
  int? star;
  String? description;


  Category({
    this.id = 0,
    this.name='',
    this.created='',
    movies = const [],
    this.description,
  });

  @override
  String toString() {
    return "Category:{ name:$name count:${movies.length}}\n";
  }
}
