import 'package:flutter/material.dart';
import 'package:next_movie/service/category_service/category_service.dart';
import 'package:next_movie/ui/global_navigation_bar.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../model/sort_by.dart';
import '../../service/movie_service/movie_service.dart';
import '../radio_dialog.dart';

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
  String sortBy = SortBy.created;
  String order = SortOrder.descending;
  List<int> ids = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalNavigationBar(
        title: "Search",
        showSetting: true,
        showSearch: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSearchBar(),
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

  void search() {}

  // 类型选择按钮
  Widget _buildTypeButton(String type, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          sortBy = SortBy.created;
          if (type == 'Movie') {
            ids = MovieService()
                .searchMovies(_searchController.text, SortBy.created, order);
          }
          if (type == 'Category') {
            ids = CategoryService()
                .searchCategory(_searchController.text, SortBy.created, order);
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
