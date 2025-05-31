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
/// [showBackButton] Флаг, определяющий, показывать ли кнопку "Назад".
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
  final bool showBackButton;
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
    this.showBackButton = true,
    this.isCollapsible = false,
  });

  @override
  FileSystemEntityListState createState() => FileSystemEntityListState();
}

/// Состояние виджета, управляющее загрузкой и отображением списка файлов и директорий.
/// [_scrollController] Контроллер прокрутки списка.
/// [_items] Список отображаемых элементов (файлов и директорий) с их глубиной.
/// [_isLoading] Флаг состояния загрузки.
/// [_hasMore] Флаг наличия дополнительных элементов для загрузки.
/// [_page] Текущая страница для пагинации.
/// [_pageSize] Количество элементов на странице.
/// [_expandedDirectories] Множество развернутых директорий.
class FileSystemEntityListState extends State<FileSystemEntityList> {
  final ScrollController _scrollController = ScrollController();
  final List<_TreeItem> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 0;
  static const int _pageSize = 50;
  final Set<String> _expandedDirectories = {};

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
      _items.clear();
      _expandedDirectories.clear();
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
    try {
      final newEntities = await FileUtils.getDirectoryContents(
        widget.currentPath,
        isFilePicker: widget.isFilePicker,
        showHidden: widget.showHidden,
        searchQuery: widget.searchQuery,
        page: _page,
        pageSize: _pageSize,
        allowedExtensions: widget.allowedExtensions,
      );
      if (mounted) {
        setState(() {
          _items.addAll(newEntities.map((e) => _TreeItem(entity: e, depth: 0)));
          _page++;
          _hasMore = newEntities.length == _pageSize;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Переключает состояние сворачивания/разворачивания директории.
  Future<void> _toggleDirectory(String path) async {
    if (!widget.isCollapsible) {
      widget.onPathSelected(path);
      return;
    }

    setState(() {
      if (_expandedDirectories.contains(path)) {
        _expandedDirectories.remove(path);
        _items.removeWhere(
          (item) =>
              item.entity.path.startsWith('$path${Platform.pathSeparator}') &&
              item.entity.path != path,
        );
      } else {
        _expandedDirectories.add(path);
        _loadSubdirectory(path);
      }
    });
  }

  /// Загружает содержимое поддиректории и добавляет её элементы в список.
  Future<void> _loadSubdirectory(String path) async {
    try {
      final entities = await FileUtils.getDirectoryContents(
        path,
        isFilePicker: widget.isFilePicker,
        showHidden: widget.showHidden,
        searchQuery: widget.searchQuery,
        page: 0,
        pageSize: _pageSize,
        allowedExtensions: widget.allowedExtensions,
      );
      if (mounted) {
        setState(() {
          final insertIndex =
              _items.indexWhere((item) => item.entity.path == path) + 1;
          final parentDepth =
              _items.firstWhere((item) => item.entity.path == path).depth;
          _items.insertAll(
            insertIndex,
            entities.map((e) => _TreeItem(entity: e, depth: parentDepth + 1)),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _expandedDirectories.remove(path);
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount:
          _items.length +
          (widget.showBackButton ? 1 : 0) +
          (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (widget.showBackButton && index == 0) {
          return ListTile(
            leading: const Icon(Icons.arrow_back),
            title: const Text('Назад'),
            onTap: widget.onNavigateBack,
          );
        }
        if (_isLoading &&
            index == _items.length + (widget.showBackButton ? 1 : 0)) {
          return const Center(child: CircularProgressIndicator());
        }
        final itemIndex = index - (widget.showBackButton ? 1 : 0);
        final item = _items[itemIndex];
        final entity = item.entity;
        final isDirectory = entity is Directory;
        final isExpanded = _expandedDirectories.contains(entity.path);

        return Padding(
          padding: EdgeInsets.only(left: 16.0 * item.depth),
          child: ListTile(
            leading: Icon(
              isDirectory
                  ? (isExpanded ? Icons.folder_open : Icons.folder)
                  : Icons.file_open,
            ),
            title: Text(p.basename(entity.path)),
            trailing:
                widget.isCollapsible && isDirectory
                    ? Icon(isExpanded ? Icons.expand_less : Icons.expand_more)
                    : null,
            onTap: () {
              if (isDirectory) {
                _toggleDirectory(entity.path);
              } else {
                widget.onPathSelected(entity.path);
              }
            },
          ),
        );
      },
    );
  }
}

/// Класс для представления элемента дерева с глубиной вложенности.
/// [entity] Файл или директория.
/// [depth] Глубина вложенности для отступов.
class _TreeItem {
  final FileSystemEntity entity;
  final int depth;

  _TreeItem({required this.entity, required this.depth});
}
