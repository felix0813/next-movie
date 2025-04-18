import 'dart:math';

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

  List<Movie> getAllMovie() => _movieBox.getAll();

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
        if (order == Order.descending) {
          final int likedCount =
              _movieBox.query(Movie_.likeDate.notNull()).build().count();
          if (likedCount >= 100 * page + 100) {
            //获取到的都是喜欢的视频
            return (_movieBox
                    .query(Movie_.likeDate.notNull())
                    .order(Movie_.likeDate, flags: order)
                    .build()
                  ..offset = 100 * page
                  ..limit = 100)
                .findIds();
          } else {
            //都是不喜欢的或者部分是不喜欢的
            return ([
              ...(_movieBox
                      .query(Movie_.likeDate.notNull())
                      .order(Movie_.likeDate, flags: order)
                      .build()
                    ..offset = 100 * page
                    ..limit = 100)
                  .findIds(),
              ...((_movieBox
                      .query(Movie_.likeDate.isNull())
                      .order(Movie_.id)
                      .build()
                    ..offset = max(100 * page - likedCount, 0)
                    ..limit = 100)
                  .findIds())
            ]).sublist(0, 100);
          }
        } else {
          return (_movieBox
                  .query()
                  .order(Movie_.likeDate, flags: Order.nullsLast)
                  .build()
                ..offset = 100 * page
                ..limit = 100)
              .findIds();
        }

      case SortBy.wishDate:
        if (order == Order.descending) {
          final int wishCount =
              _movieBox.query(Movie_.wishDate.notNull()).build().count();
          if (wishCount >= 100 * page + 100) {
            //获取到的都是喜欢的视频
            return (_movieBox
                    .query(Movie_.wishDate.notNull())
                    .order(Movie_.wishDate, flags: order)
                    .build()
                  ..offset = 100 * page
                  ..limit = 100)
                .findIds();
          } else {
            //都是不喜欢的或者部分是不喜欢的
            return ([
              ...(_movieBox
                      .query(Movie_.wishDate.notNull())
                      .order(Movie_.wishDate, flags: order)
                      .build()
                    ..offset = 100 * page
                    ..limit = 100)
                  .findIds(),
              ...((_movieBox
                      .query(Movie_.wishDate.isNull())
                      .order(Movie_.id)
                      .build()
                    ..offset = max(100 * page - wishCount, 0)
                    ..limit = 100)
                  .findIds())
            ]).sublist(0, 100);
          }
        } else {
          return (_movieBox
                  .query()
                  .order(Movie_.wishDate, flags: Order.nullsLast)
                  .build()
                ..offset = 100 * page
                ..limit = 100)
              .findIds();
        }
      case SortBy.star:
        if (order == Order.descending) {
          final int starCount =
              _movieBox.query(Movie_.star.notNull()).build().count();
          if (starCount >= 100 * page + 100) {
            //获取到的都是喜欢的视频
            return (_movieBox
                    .query(Movie_.star.notNull())
                    .order(Movie_.star, flags: order)
                    .build()
                  ..offset = 100 * page
                  ..limit = 100)
                .findIds();
          } else {
            //都是不喜欢的或者部分是不喜欢的
            return ([
              ...(_movieBox
                      .query(Movie_.star.notNull())
                      .order(Movie_.star, flags: order)
                      .build()
                    ..offset = 100 * page
                    ..limit = 100)
                  .findIds(),
              ...((_movieBox
                      .query(Movie_.star.isNull())
                      .order(Movie_.id)
                      .build()
                    ..offset = max(100 * page - starCount, 0)
                    ..limit = 100)
                  .findIds())
            ]).sublist(0, 100);
          }
        } else {
          return (_movieBox
                  .query()
                  .order(Movie_.star, flags: Order.nullsLast)
                  .build()
                ..offset = 100 * page
                ..limit = 100)
              .findIds();
        }
      case SortBy.created:
        return (_movieBox
                .query()
                .order(Movie_.created, flags: order | Order.nullsLast)
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

  bool checkMovieNameValid(String name) {
    final query = _movieBox.query(Movie_.title.equals(name)).build()..limit = 1;
    final result = query.count();
    query.close();
    return result == 0;
  }

  int getTotalCount() => _movieBox.count();

  Movie? getLatestMovie() => _movieBox
      .query()
      .order(Movie_.recorded, flags: Order.descending)
      .build()
      .findFirst();

  int storeMovie(Movie movie) => _movieBox.put(movie, mode: PutMode.update);

  List<int> searchMovie(String keyword, String sortBy, String order) {
    final flag = order == SortOrder.descending ? Order.descending : 0;
    switch (sortBy) {
      case SortBy.recorded:
        return (_movieBox
                .query(Movie_.title
                    .contains(keyword, caseSensitive: false)
                    .or(Movie_.source.contains(keyword, caseSensitive: false)))
                .order(Movie_.recorded, flags: flag)
                .build())
            .findIds();
      case SortBy.size:
        return (_movieBox
                .query(Movie_.title
                    .contains(keyword, caseSensitive: false)
                    .or(Movie_.source.contains(keyword, caseSensitive: false)))
                .order(Movie_.size, flags: flag)
                .build())
            .findIds();
      case SortBy.duration:
        return (_movieBox
                .query(Movie_.title
                    .contains(keyword, caseSensitive: false)
                    .or(Movie_.source.contains(keyword, caseSensitive: false)))
                .order(Movie_.duration, flags: flag)
                .build())
            .findIds();
      case SortBy.likeDate:
        if (flag == Order.descending) {
          return [
            ..._movieBox
                .query(Movie_.likeDate.notNull().and(Movie_.title
                    .contains(keyword, caseSensitive: false)
                    .or(Movie_.source.contains(keyword, caseSensitive: false))))
                .order(Movie_.likeDate, flags: flag)
                .build()
                .findIds(),
            ..._movieBox
                .query(Movie_.likeDate.isNull().and(Movie_.title
                    .contains(keyword, caseSensitive: false)
                    .or(Movie_.source.contains(keyword, caseSensitive: false))))
                .build()
                .findIds()
          ];
        } else {
          return (_movieBox
                  .query(Movie_.likeDate.isNull().and(Movie_.title
                      .contains(keyword, caseSensitive: false)
                      .or(Movie_.source
                          .contains(keyword, caseSensitive: false))))
                  .order(Movie_.likeDate, flags: Order.nullsLast)
                  .build())
              .findIds();
        }

      case SortBy.wishDate:
        if (flag == Order.descending) {
          return [
            ..._movieBox
                .query(Movie_.wishDate.notNull().and(Movie_.title
                    .contains(keyword, caseSensitive: false)
                    .or(Movie_.source.contains(keyword, caseSensitive: false))))
                .order(Movie_.wishDate, flags: flag)
                .build()
                .findIds(),
            ..._movieBox
                .query(Movie_.wishDate.isNull().and(Movie_.title
                    .contains(keyword, caseSensitive: false)
                    .or(Movie_.source.contains(keyword, caseSensitive: false))))
                .build()
                .findIds()
          ];
        } else {
          return (_movieBox
                  .query(Movie_.likeDate.isNull().and(Movie_.title
                      .contains(keyword, caseSensitive: false)
                      .or(Movie_.source
                          .contains(keyword, caseSensitive: false))))
                  .order(Movie_.wishDate, flags: Order.nullsLast)
                  .build())
              .findIds();
        }
      case SortBy.star:
        if (flag == Order.descending) {
          return [
            ..._movieBox
                .query(Movie_.star.notNull().and(Movie_.title
                    .contains(keyword, caseSensitive: false)
                    .or(Movie_.source.contains(keyword, caseSensitive: false))))
                .order(Movie_.star, flags: flag)
                .build()
                .findIds(),
            ..._movieBox
                .query(Movie_.star.isNull().and(Movie_.title
                    .contains(keyword, caseSensitive: false)
                    .or(Movie_.source.contains(keyword, caseSensitive: false))))
                .build()
                .findIds()
          ];
        } else {
          return (_movieBox
                  .query(Movie_.title
                      .contains(keyword, caseSensitive: false)
                      .or(Movie_.source
                          .contains(keyword, caseSensitive: false)))
                  .order(Movie_.star, flags: Order.nullsLast)
                  .build())
              .findIds();
        }
      case SortBy.created:
        return (_movieBox
                .query(Movie_.title
                    .contains(keyword, caseSensitive: false)
                    .or(Movie_.source.contains(keyword, caseSensitive: false)))
                .order(Movie_.created, flags: flag | Order.nullsLast)
                .build())
            .findIds();
      default:
        return (_movieBox
                .query(Movie_.title
                    .contains(keyword, caseSensitive: false)
                    .or(Movie_.source.contains(keyword, caseSensitive: false)))
                .order(Movie_.recorded, flags: Order.descending)
                .build())
            .findIds();
    }
  }
}
