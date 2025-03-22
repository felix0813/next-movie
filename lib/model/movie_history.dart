class MovieHistory{
  late int id;                   //movie id
  late int lastProgress;         //last watching progress(in seconds)
  late List<String> watchDate;   //watching date
  late bool completed;           //whether the movie is watched to the end
  late List<int> watchDuration;  //watching duration(in seconds)

  MovieHistory({
    this.id = 0,
    this.lastProgress = 0,
    this.watchDate = const [],
    this.completed = false,
    this.watchDuration = const [],
  });
}