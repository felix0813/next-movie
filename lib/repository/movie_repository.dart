import 'package:next_movie/model/movie.dart';
import 'package:next_movie/model/sort_by.dart';
import 'package:next_movie/objectbox/objectbox.dart';
import 'package:next_movie/objectbox/objectbox.g.dart';

class MovieRepository {
  final _movieBox = ObjectBox.getBox<Movie>();

  List<int> deleteMovie(List<int> ids) {
    List<int> fail = List.empty(growable: true);
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

  List<int> getRecentIds() => (_movieBox
          .query(Movie_.likeDate.isNull().and(Movie_.wishDate.isNull()))
          .order(Movie_.recorded, flags: Order.descending)
          .build()
        ..limit = 20)
      .findIds();

  List<Movie> getFavoriteMovie() => (_movieBox
          .query(Movie_.likeDate.notNull())
          .order(Movie_.likeDate, flags: Order.descending)
          .build()
        ..limit = 20)
      .find();
  List<int> getFavouriteIds() => (_movieBox
          .query(Movie_.likeDate.notNull().and(Movie_.wishDate.isNull()))
          .order(Movie_.likeDate, flags: Order.descending)
          .build()
        ..limit = 20)
      .findIds();
  List<Movie> getToWatchMovie() => (_movieBox
          .query(Movie_.wishDate.notNull())
          .order(Movie_.wishDate, flags: Order.descending)
          .build()
        ..limit = 20)
      .find();
  List<int> getToWatchMovieIds() => (_movieBox
          .query(Movie_.wishDate.notNull())
          .order(Movie_.wishDate, flags: Order.descending)
          .build()
        ..limit = 20)
      .findIds();
  List<int> getOnePageVideos(int page, String orderBy, String sortOrder) {
    final order = sortOrder == SortOrder.descending ? Order.descending : 0;
    switch (orderBy) {
      case SortBy.recorded:
        return (_movieBox.query().order(Movie_.recorded, flags: order).build()
              ..offset = 100 * page
              ..limit = 100)
            .findIds();
      case SortBy.size:
        return (_movieBox.query().order(Movie_.size, flags: order).build()
              ..offset = 100 * page
              ..limit = 100)
            .findIds();
      case SortBy.duration:
        return (_movieBox.query().order(Movie_.duration, flags: order).build()
              ..offset = 100 * page
              ..limit = 100)
            .findIds();
      case SortBy.likeDate:
        return (_movieBox
                .query()
                .order(Movie_.likeDate, flags: order & Order.nullsLast)
                .build()
              ..offset = 100 * page
              ..limit = 100)
            .findIds();
      case SortBy.wishDate:
        return (_movieBox
                .query()
                .order(Movie_.wishDate, flags: order & Order.nullsLast)
                .build()
              ..offset = 100 * page
              ..limit = 100)
            .findIds();
      case SortBy.star:
        return (_movieBox
                .query()
                .order(Movie_.star, flags: order & Order.nullsLast)
                .build()
              ..offset = 100 * page
              ..limit = 100)
            .findIds();
      case SortBy.created:
        return (_movieBox
                .query()
                .order(Movie_.created, flags: order & Order.nullsLast)
                .build()
              ..offset = 100 * page
              ..limit = 100)
            .findIds();
      default:
        return (_movieBox
                .query()
                .order(Movie_.recorded, flags: Order.descending)
                .build()
              ..offset = 100 * page
              ..limit = 100)
            .findIds();
    }
  }

  List<Movie> getRecentWatchMovie() {
    return [];
  }

  Movie? getMovieById(int id) => _movieBox.get(id);

  int getTotalCount() => _movieBox.count();

  Movie? getLatestMovie() => _movieBox
      .query()
      .order(Movie_.recorded, flags: Order.descending)
      .build()
      .findFirst();

  int storeMovie(Movie movie) => _movieBox.put(movie, mode: PutMode.update);
}
