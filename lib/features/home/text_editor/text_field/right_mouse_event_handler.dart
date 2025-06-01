import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Обработчик событий правого клика мыши для текстового поля.
/// Управляет контекстным меню с операциями копирования, вставки и вырезания.
class RightMouseEventHandler {
  final TextEditingController controller;
  final FocusNode focusNode;

  const RightMouseEventHandler({
    required this.controller,
    required this.focusNode,
  });

  /// Показывает контекстное меню при правом клике.
  /// [context] Контекст виджета.
  /// [globalPosition] Глобальная позиция клика.
  void showContextMenu(BuildContext context, Offset globalPosition) {
    // Фокусируемся на поле перед показом контекстного меню
    focusNode.requestFocus();

    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final selection = controller.selection;
    final hasSelection = selection.isValid && !selection.isCollapsed;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(globalPosition, globalPosition),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          enabled: hasSelection,
          onTap: () => _copyText(selection),
          child: const Text('Копировать'),
        ),
        PopupMenuItem(
          enabled: true,
          onTap: () => _pasteText(selection),
          child: const Text('Вставить'),
        ),
        PopupMenuItem(
          enabled: hasSelection,
          onTap: () => _cutText(selection),
          child: const Text('Вырезать'),
        ),
      ],
    );
  }

  /// Копирует выделенный текст в буфер обмена.
  /// [selection] Текущая выделенная область.
  void _copyText(TextSelection selection) {
    // Проверяем валидность выделения
    if (!selection.isValid || selection.isCollapsed) return;

    // Дополнительная проверка границ
    final start = selection.start.clamp(0, controller.text.length);
    final end = selection.end.clamp(0, controller.text.length);

    final selectedText = controller.text.substring(start, end);
    Clipboard.setData(ClipboardData(text: selectedText));
  }

  /// Вставляет текст из буфера обмена.
  /// [selection] Текущая выделенная область.
  Future<void> _pasteText(TextSelection selection) async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text != null) {
      final currentText = controller.text;

      // Проверяем валидность выделения
      int start = selection.isValid ? selection.start : controller.text.length;
      int end = selection.isValid ? selection.end : controller.text.length;

      // Дополнительная проверка границ
      start = start.clamp(0, currentText.length);
      end = end.clamp(0, currentText.length);

      final newText = currentText.replaceRange(start, end, clipboardData.text!);
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: start + clipboardData.text!.length,
        ),
      );
    }
  }

  /// Вырезает выделенный текст в буфер обмена.
  /// [selection] Текущая выделенная область.
  void _cutText(TextSelection selection) {
    // Проверяем валидность выделения
    if (!selection.isValid || selection.isCollapsed) return;

    // Дополнительная проверка границ
    final start = selection.start.clamp(0, controller.text.length);
    final end = selection.end.clamp(0, controller.text.length);

    final selectedText = controller.text.substring(start, end);
    Clipboard.setData(ClipboardData(text: selectedText));

    final currentText = controller.text;
    final newText = currentText.replaceRange(start, end, '');
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start),
    );
  }
}
