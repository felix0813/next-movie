import 'package:objectbox/objectbox.dart';

import 'movie_history.dart';

@Entity()
class Movie {
  @Id()
  late int id;
  late String title;
  late int duration; //movie duration(in seconds)
  late int size; //file size(in bytes)
  late String path; //file path
  late List<String> tags;
  late List<String> cover; //cover image path
  late List<String> comment;
  MovieHistory? history;
  int? star; //rating
  String? source; //source of the movie
  String? created; //file created time
  DateTime? recorded; //time when the movie was recorded
  DateTime? likeDate; //like or not
  DateTime? wishDate; //to watch


  Movie({
    this.id=0,
    required this.title,
    required this.path,
    this.duration = 0,
    this.size = 0,
    this.tags = const [],
    this.cover = const [], // 假设 MovieHistory 有一个无参构造函数
    this.comment = const [],
    this.source,
    this.star,
    this.created,
    this.likeDate,
    this.wishDate
  });

  @override
  String toString() {
    return "Movie:{ title:$title path:$path duration:$duration s size:$size byte}\n";
  }
}
