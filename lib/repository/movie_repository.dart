import '../model/movie.dart';
import '../objectbox/objectbox.dart';
import '../objectbox/objectbox.g.dart';

class MovieRepository {
  final _movieBox = ObjectBox.getBox<Movie>();

  List<int> deleteMovie(List<int> ids) {
    List<int> fail = List.empty();
    for (int id in ids) {
      if (!_movieBox.remove(id)) {
        fail.add(id);
      }
    }
    return fail;
  }

  List<Movie> getRecentAddMovie() =>
      (_movieBox.query().order(Movie_.recorded, flags: Order.descending).build()
            ..limit = 20)
          .find();

  List<Movie> getFavoriteMovie() => (_movieBox
          .query(Movie_.likeDate.notNull())
          .order(Movie_.likeDate, flags: Order.descending)
          .build()
        ..limit = 20)
      .find();

  List<Movie> getToWatchMovie() => (_movieBox
          .query(Movie_.wishDate.notNull())
          .order(Movie_.wishDate, flags: Order.descending)
          .build()
        ..limit = 20)
      .find();

  List<Movie> getRecentWatchMovie() {
    return [];
  }

  Movie? getMovieById(int id) => _movieBox.get(id);

  Movie? getLatestMovie() => _movieBox
      .query()
      .order(Movie_.recorded, flags: Order.descending)
      .build()
      .findFirst();
}
