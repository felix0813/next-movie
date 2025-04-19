import 'dart:math';

import 'package:flutter/material.dart';
import 'package:next_movie/service/category_service/category_service.dart';
import 'package:next_movie/ui/global_navigation_bar.dart';
import 'package:next_movie/ui/select_navigation_bar.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../model/sort_by.dart';
import '../../service/movie_service/movie_service.dart';
import '../category_card.dart';
import '../radio_dialog.dart';
import '../video_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
  });
  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = 'Movie'; // 默认选择类型
  final FocusNode _focusNode = FocusNode();
  bool selecting = false;
  Set<int> selected = {};
  String sortBy = SortBy.created;
  String order = SortOrder.descending;
  List<int> ids = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !selecting
          ? GlobalNavigationBar(
              title: "Search",
              showSetting: true,
              showSearch: false,
            )
          : (_selectedType == "Movie"
              ? SelectMovieNavigationBar(
                  selectedMovies: selected,
                  quitSelecting: () {
                    setState(() {
                      selecting = false;
                      selected = {};
                    });
                  },
                  onDelete: (movies) {
                    setState(() {
                      ids = ids.where((e) => !movies.contains(e)).toList();
                    });
                  })
              : SelectCategoryNavigationBar(
                  quitSelecting: () {
                    setState(() {
                      selecting = false;
                      selected = {};
                    });
                  },
                  selectedCategory: selected,
                  deleteCategory: (categories) {
                    List delete = List.empty(growable: true);
                    for (int i in categories) {
                      if (CategoryService().removeCategory(i)) {
                        delete.add(i);
                      }
                    }
                    setState(() {
                      ids = ids
                          .where((element) => !delete.contains(element))
                          .toList();
                    });
                  },
                )),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSearchBar(),
            SizedBox(height: 20),
            buildGridView(context)
          ],
        ),
      ),
    );
  }

  // 搜索栏组件
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: TDInput(
              leftIcon: Icon(TDIcons.search),
              type: TDInputType.cardStyle,
              needClear: true,
              clearBtnColor: Colors.blue,
              backgroundColor: Colors.white,
              focusNode: _focusNode,
              hintText: 'Search',
              inputAction: TextInputAction.search,
              controller: _searchController,
              onSubmitted: (value) {
                search();
              },
              rightBtn: TDButton(
                text: 'Search',
                theme: TDButtonTheme.primary,
                onTap: () {
                  search();
                },
                padding: EdgeInsets.only(left: 10.0, right: 10, top: 5),
              ),
            ),
          ),
          SizedBox(width: 16.0),
          // 类型选择器
          Row(
            children: [
              _buildTypeButton('Movie', _selectedType == 'Movie'),
              _buildTypeButton('Category', _selectedType == 'Category'),
            ],
          ),
          IconButton(
              tooltip: "sort", icon: Icon(Icons.sort), onPressed: onSortPressed)
        ],
      ),
    );
  }

  void search() {
    if (_searchController.text.isEmpty) {
      setState(() {
        ids = [];
      });
    } else {
      setState(() {
        if (_selectedType == 'Movie') {
          ids = MovieService()
              .searchMovies(_searchController.text, sortBy, order);
        }
        if (_selectedType == 'Category') {
          ids = CategoryService()
              .searchCategory(_searchController.text, sortBy, order);
        }
      });
    }
  }

  // 类型选择按钮
  Widget _buildTypeButton(String type, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selecting = false;
          selected = {};
          _selectedType = type;
          sortBy = SortBy.created;
          if (_searchController.text.trim().isNotEmpty) {
            if (type == 'Movie') {
              ids = MovieService()
                  .searchMovies(_searchController.text, SortBy.created, order);
            }
            if (type == 'Category') {
              ids = CategoryService().searchCategory(
                  _searchController.text, SortBy.created, order);
            }
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.transparent,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          type,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.grey[600],
            fontSize: 14.0,
          ),
        ),
      ),
    );
  }

  double get itemWidth {
    final screenWidth = MediaQuery.of(context).size.width;
    final columns = max(2, screenWidth / 300);
    return (screenWidth - 15) / columns;
  }

  GridView buildGridView(BuildContext context) {
    if (_selectedType == 'Movie') {
      return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(), // 禁止 GridView 自滚动
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:
              ((MediaQuery.of(context).size.width - 15) / (itemWidth + 10))
                  .round(), // 动态列数
          childAspectRatio: 5 / 4,
        ),
        itemCount: ids.length,
        itemBuilder: (context, index) {
          return VideoCard(
            key: Key(ids[index].toString()),
            itemWidth: itemWidth + 10,
            itemHeight: itemWidth * 9 / 16 + 30,
            movieId: ids[index],
            onDelete: () {
              setState(() {
                ids = [...ids.sublist(0, index), ...ids.sublist(index + 1)];
              });
            },
            onSelect: (bool isSelected) {
              setState(() {
                if (isSelected) {
                  selected.add(ids[index]);
                } else {
                  selected.remove(ids[index]);
                }
              });
            },
            selecting: selecting,
            isSelected: selected.contains(ids[index]),
            startSelect: () {
              setState(() {
                selecting = true;
              });
            },
          );
        },
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(), // 禁止 GridView 自滚动
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            ((MediaQuery.of(context).size.width - 15) / (itemWidth + 10))
                .round(), // 动态列数
        childAspectRatio: 5 / 4,
      ),
      itemCount: ids.length,
      itemBuilder: (context, index) {
        return CategoryCard(
          key: Key(ids[index].toString()),
          itemWidth: itemWidth + 10,
          itemHeight: itemWidth * 9 / 16 + 30,
          categoryId: ids[index],
          isSelected: selected.contains(ids[index]),
          selecting: selecting,
          onSelect: (bool isSelected) {
            setState(() {
              selecting = true;
              if (isSelected) {
                selected.add(ids[index]);
              } else {
                selected.remove(ids[index]);
              }
            });
          },
          onUpdateUI: () => setState(() {
            ids = CategoryService()
                .searchCategory(_searchController.text, sortBy, order);
          }),
        );
      },
    );
  }

  onSortPressed() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SortMovieRadioDialog(
          options: _selectedType == 'Movie'
              ? [
                  SortBy.recorded,
                  SortBy.created,
                  SortBy.star,
                  SortBy.duration,
                  SortBy.size,
                  SortBy.wishDate,
                  SortBy.likeDate,
                ]
              : [SortBy.created, SortBy.title],
          initValue: sortBy,
          order: order,
          onConfirm: (String? result, String? sortOrder) {
            if (result != null &&
                sortOrder != null &&
                (result != sortBy || order != sortOrder)) {
              setState(() {
                sortBy = result;
                order = sortOrder;
                if (_selectedType == 'Movie') {
                  ids = MovieService()
                      .searchMovies(_searchController.text, sortBy, order);
                }
                if (_selectedType == 'Category') {
                  ids = CategoryService()
                      .searchCategory(_searchController.text, sortBy, order);
                }
              });
            }
          },
        );
      },
    );
  }
}
