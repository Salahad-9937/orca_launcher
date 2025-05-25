import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../../utils/file_utils.dart';

class FileSystemEntityList extends StatefulWidget {
  final String currentPath;
  final bool isFilePicker;
  final bool showHidden;
  final String searchQuery;
  final Function(String) onPathSelected;
  final VoidCallback onNavigateBack;

  const FileSystemEntityList({
    super.key,
    required this.currentPath,
    required this.isFilePicker,
    required this.showHidden,
    required this.searchQuery,
    required this.onPathSelected,
    required this.onNavigateBack,
  });

  @override
  FileSystemEntityListState createState() => FileSystemEntityListState();
}

class FileSystemEntityListState extends State<FileSystemEntityList> {
  final ScrollController _scrollController = ScrollController();
  final List<FileSystemEntity> _entities = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 0;
  static const int _pageSize = 50;

  @override
  void initState() {
    super.initState();
    _loadMoreEntities();
    _scrollController.addListener(() {
      if (_scrollController.position.extentAfter < 200 &&
          !_isLoading &&
          _hasMore) {
        _loadMoreEntities();
      }
    });
  }

  @override
  void didUpdateWidget(FileSystemEntityList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPath != widget.currentPath ||
        oldWidget.showHidden != widget.showHidden ||
        oldWidget.searchQuery != widget.searchQuery) {
      _page = 0;
      _entities.clear();
      _hasMore = true;
      _loadMoreEntities();
    }
  }

  Future<void> _loadMoreEntities() async {
    if (_isLoading || !_hasMore) return;
    setState(() {
      _isLoading = true;
    });
    final newEntities = await FileUtils.getDirectoryContents(
      widget.currentPath,
      isFilePicker: widget.isFilePicker,
      showHidden: widget.showHidden,
      searchQuery: widget.searchQuery,
      page: _page,
      pageSize: _pageSize,
    );
    setState(() {
      _entities.addAll(newEntities);
      _page++;
      _hasMore = newEntities.length == _pageSize;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (index == 0) {
              return ListTile(
                leading: const Icon(Icons.arrow_back),
                title: const Text('Назад'),
                onTap: widget.onNavigateBack,
              );
            }
            final entity = _entities[index - 1];
            return ListTile(
              leading: Icon(entity is File ? Icons.file_open : Icons.folder),
              title: Text(p.basename(entity.path)),
              onTap: () {
                widget.onPathSelected(entity.path);
              },
            );
          }, childCount: _entities.length + 1),
        ),
        if (_isLoading)
          const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
