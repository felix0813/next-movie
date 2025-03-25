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

  List<Movie> getRecentAddMovie() {
    final query = _movieBox
        .query()
        .order(Movie_.recorded, flags: Order.descending)
        .build();
    query.limit = 20;
    return query.find();
  }

  List<Movie> getFavoriteMovie() {
    final query = _movieBox
        .query(Movie_.likeDate.notNull())
        .order(Movie_.likeDate, flags: Order.descending)
        .build();
    query.limit = 20;
    return query.find();
  }

  List<Movie> getToWatchMovie() {
    final query = _movieBox
        .query(Movie_.wishDate.notNull())
        .order(Movie_.wishDate, flags: Order.descending)
        .build();
    query.limit = 20;
    return query.find();
  }

  List<Movie> getRecentWatchMovie() {
    return [];
  }

  Movie? getMovieById(int id) {
    return _movieBox.get(id);
  }
}
