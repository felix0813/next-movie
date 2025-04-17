import 'package:flutter/material.dart';
import 'package:next_movie/ui/global_navigation_bar.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

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
              rightBtn: TDButton(text: 'Search',theme: TDButtonTheme.primary, onTap: () {
                search();
              },padding: EdgeInsets.only(left: 10.0,right: 10,top:5),),
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
        ],
      ),
    );
  }
  void search() {
    // todo 处理搜索逻辑
    print('Searching for "${_searchController.text}" in $_selectedType');
  }

  // 类型选择按钮
  Widget _buildTypeButton(String type, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
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
}
