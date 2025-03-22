import 'package:objectbox/objectbox.dart';

import 'movie_history.dart';

@Entity()
class Movie {
  @Id()
  late int id;
  late String title;
  String? created; //file created time
  String? recorded; //time when the movie was recorded
  late String path; //file path
  late List<String> tags;
  late List<String> cover; //cover image path
  MovieHistory? history;
  int? star; //rating
  String? source; //source of the movie
  late List<String> comment;
  late int duration; //movie duration(in seconds)
  late bool like; //like or not
  late int size; //file size(in bytes)

  Movie({
    this.id = 0,
    required this.title,
    required this.path,
    this.tags = const [],
    this.cover = const [], // 假设 MovieHistory 有一个无参构造函数
    this.comment = const [],
    this.duration = 0,
    this.like = false,
    this.size = 0,
  });

  @override
  String toString() {
    return "Movie:{ title:$title path:$path duration:$duration s size:$size byte}\n";
  }
}
