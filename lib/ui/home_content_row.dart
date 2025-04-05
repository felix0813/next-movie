import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import 'video_card.dart';

class HomeContentRow extends StatefulWidget {
  final String title;
  final List<int> movies;
  final void Function(int id)onMovieDelete;
  const HomeContentRow({super.key, required this.title, required this.movies, required this.onMovieDelete});

  @override
  HomeContentRowState createState() => HomeContentRowState();
}

class HomeContentRowState extends State<HomeContentRow> {
  late ScrollController _scrollController;
  bool _showLeftButton = false;
  bool _showRightButton = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
  }

  void _handleScroll() {
    final offset = _scrollController.offset;
    final maxOffset = _scrollController.position.maxScrollExtent;

    setState(() {
      _showLeftButton = offset > 0;
      _showRightButton = offset < maxOffset;
    });
  }

  void _scrollLeft(itemWidth) {
    double multi = 5;
    if (Platform.isAndroid || Platform.isIOS) {
      multi = 1.5;
    }
    _scrollController
        .animateTo(
      _scrollController.offset - itemWidth * multi,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      // 移除错误的 completion 参数
    )
        .then((_) {
      // 动画完成后更新按钮状态
      setState(() {
        _showLeftButton = _scrollController.offset > 0;
        _showRightButton = _scrollController.offset <
            _scrollController.position.maxScrollExtent;
      });
    });
  }

  void _scrollRight(itemWidth) {
    double multi = 5;
    if (Platform.isAndroid || Platform.isIOS) {
      multi = 1.5;
    }
    _scrollController
        .animateTo(
      _scrollController.offset + itemWidth * multi,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    )
        .then((_) {
      setState(() {
        _showLeftButton = _scrollController.offset > 0;
        _showRightButton = _scrollController.offset <
            _scrollController.position.maxScrollExtent;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) {
      return Container();
    }
    double itemWidth =
        max((MediaQuery.of(context).size.width - 20) / 5 - 20, 80);
    double itemHeight = itemWidth / 16 * 9;
    return Column(
      children: [
        // 标题栏容器（改为Row布局）
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // 关键：设置主轴对齐方式
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey,
                ),
              ),
            ),
            buildScrollBtn(itemWidth),
          ],
        ),
        // 内容容器
        buildList(itemHeight, itemWidth),
      ],
    );
  }

  SizedBox buildList(double itemHeight, double itemWidth) {
    return SizedBox(
      height: itemHeight * 2 / 3 + 30, // 包含间距
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: widget.movies.length, // 确保足够多的item
              itemBuilder: (context, index) => VideoCard(
                key: Key(widget.movies[index].toString()),
                movieId: widget.movies[index],
                itemWidth: itemWidth * 2 / 3 + 10,
                itemHeight: itemHeight * 2 / 3 + 30,
                canBeSelected: false,
                onDelete: () {
                  setState(() {});
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding buildScrollBtn(double itemWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(TDIcons.arrow_left),
            onPressed: _showLeftButton
                ? () {
                    _scrollLeft(itemWidth);
                  }
                : null,
            tooltip: 'scroll left',
          ),
          IconButton(
            icon: const Icon(TDIcons.arrow_right),
            onPressed: _showRightButton
                ? () {
                    _scrollRight(itemWidth);
                  }
                : null,
            tooltip: 'scroll right',
          ),
        ],
      ),
    );
  }
}
