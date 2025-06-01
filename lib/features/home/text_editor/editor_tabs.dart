import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/editor_state.dart';

/// Виджет системы вкладок для отображения открытых файлов
class EditorTabs extends StatelessWidget {
  const EditorTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final editorState = Provider.of<EditorState>(context);

    if (!editorState.hasOpenFiles) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    editorState.openFiles.asMap().entries.map((entry) {
                      final index = entry.key;
                      final file = entry.value;
                      final isActive = index == editorState.activeTabIndex;

                      return _buildTab(
                        context,
                        file,
                        index,
                        isActive,
                        editorState,
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    TabFile file,
    int index,
    bool isActive,
    EditorState editorState,
  ) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        border: Border(
          right: BorderSide(color: Colors.grey.shade300),
          top:
              isActive
                  ? const BorderSide(color: Colors.blue, width: 2)
                  : BorderSide.none,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => editorState.setActiveTab(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    file.isModified ? '${file.fileName}*' : file.fileName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isActive ? FontWeight.w500 : FontWeight.normal,
                      color: isActive ? Colors.black : Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                _buildCloseButton(context, index, editorState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton(
    BuildContext context,
    int index,
    EditorState editorState,
  ) {
    return SizedBox(
      width: 16,
      height: 16,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _closeTab(context, index, editorState),
          borderRadius: BorderRadius.circular(8),
          child: Icon(Icons.close, size: 14, color: Colors.grey.shade600),
        ),
      ),
    );
  }

  void _closeTab(BuildContext context, int index, EditorState editorState) {
    final file = editorState.openFiles[index];

    if (file.isModified) {
      // Показываем диалог подтверждения для измененного файла
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Сохранить изменения?'),
              content: Text(
                'Файл "${file.fileName}" содержит несохраненные изменения. '
                'Сохранить перед закрытием?',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    editorState.closeFile(index);
                  },
                  child: const Text('Не сохранять'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // TODO: Реализовать сохранение файла
                    // Пока просто закрываем
                    editorState.closeFile(index);
                  },
                  child: const Text('Сохранить'),
                ),
              ],
            ),
      );
    } else {
      editorState.closeFile(index);
    }
  }
}
