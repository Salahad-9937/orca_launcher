import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import '../../core/utils/file_utils.dart';

/// Виджет для отображения списка файлов и директорий в текущей папке.
/// [currentPath] Текущий путь в файловой системе.
/// [isFilePicker] Флаг, указывающий, выбираются ли файлы или директории.
/// [showHidden] Показывать ли скрытые файлы.
/// [searchQuery] Поисковый запрос для фильтрации.
/// [onPathSelected] Коллбэк, вызываемый при выборе пути.
/// [onNavigateBack] Коллбэк для перехода в родительскую директорию.
/// [allowedExtensions] Список разрешённых расширений файлов.
/// [refreshKey] Ключ для принудительного обновления списка.
/// [isCollapsible] Флаг, включающий поддержку сворачивания директорий.
class FileSystemEntityList extends StatefulWidget {
  final String currentPath;
  final bool isFilePicker;
  final bool showHidden;
  final String searchQuery;
  final Function(String) onPathSelected;
  final VoidCallback onNavigateBack;
  final List<String>? allowedExtensions;
  final Object? refreshKey;
  final bool isCollapsible;

  const FileSystemEntityList({
    super.key,
    required this.currentPath,
    required this.isFilePicker,
    required this.showHidden,
    required this.searchQuery,
    required this.onPathSelected,
    required this.onNavigateBack,
    this.allowedExtensions,
    this.refreshKey,
    this.isCollapsible = false,
  });

  @override
  FileSystemEntityListState createState() => FileSystemEntityListState();
}

/// Состояние виджета, управляющее загрузкой и отображением списка файлов и директорий.
/// [_scrollController] Контроллер прокрутки списка.
/// [_entities] Список отображаемых файлов и директорий.
/// [_isLoading] Флаг состояния загрузки.
/// [_hasMore] Флаг наличия дополнительных элементов для загрузки.
/// [_page] Текущая страница для пагинации.
/// [_pageSize] Количество элементов на странице.
/// [_expandedDirectories] Множество развернутых директорий.
class FileSystemEntityListState extends State<FileSystemEntityList> {
  final ScrollController _scrollController = ScrollController();
  final List<FileSystemEntity> _entities = [];
  final Set<String> _expandedDirectories = {};
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
        oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.allowedExtensions != widget.allowedExtensions ||
        oldWidget.refreshKey != widget.refreshKey) {
      _page = 0;
      _entities.clear();
      _hasMore = true;
      _loadMoreEntities();
    }
  }

  /// Загружает дополнительные файлы и директории для отображения.
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
      allowedExtensions: widget.allowedExtensions,
    );
    setState(() {
      _entities.addAll(newEntities);
      _page++;
      _hasMore = newEntities.length == _pageSize;
      _isLoading = false;
    });
  }

  /// Переключает состояние сворачивания/разворачивания директории.
  void _toggleDirectory(String path) {
    setState(() {
      if (_expandedDirectories.contains(path)) {
        _expandedDirectories.remove(path);
      } else {
        _expandedDirectories.add(path);
      }
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
            final isDirectory = entity is Directory;
            final isExpanded = _expandedDirectories.contains(entity.path);

            return Column(
              children: [
                ListTile(
                  leading: Icon(
                    isDirectory
                        ? (isExpanded ? Icons.folder_open : Icons.folder)
                        : Icons.file_open,
                  ),
                  title: Text(p.basename(entity.path)),
                  trailing:
                      widget.isCollapsible && isDirectory
                          ? Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                          )
                          : null,
                  onTap: () {
                    if (isDirectory && widget.isCollapsible) {
                      _toggleDirectory(entity.path);
                    } else {
                      widget.onPathSelected(entity.path);
                    }
                  },
                ),
                if (isDirectory && isExpanded && widget.isCollapsible)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: FileSystemEntityList(
                      currentPath: entity.path,
                      isFilePicker: widget.isFilePicker,
                      showHidden: widget.showHidden,
                      searchQuery: widget.searchQuery,
                      onPathSelected: widget.onPathSelected,
                      onNavigateBack: () {},
                      allowedExtensions: widget.allowedExtensions,
                      isCollapsible: true,
                    ),
                  ),
              ],
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
