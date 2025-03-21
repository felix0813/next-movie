import 'movie_history.dart';

class Movie {
  late int id;
  late String title;
  late String created;  //file created time
  late String recorded; //time when the movie was recorded
  late String path;     //file path
  late List<String> tags;
  late String cover;    //cover image path
  late MovieHistory history;
  late int star;        //rating
  late String source;   //source of the movie
  late List<String> comment;
  late int duration;    //movie duration(in seconds)
  late bool like;       //like or not
}