// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

/// Класс для обработки событий мыши в текстовом поле.
/// [controller] Контроллер текстового поля.
/// [focusNode] Нода фокуса для управления фокусом.
/// [scrollToCursor] Функция для прокрутки к позиции курсора.
/// [style] Стиль текста для синхронизации с TextPainter.
/// [verticalScrollController] Контроллер вертикальной прокрутки для учёта смещения.
class MouseEventHandler {
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(int) scrollToCursor;
  final TextStyle? style;
  final ScrollController verticalScrollController;
  DateTime? _lastTapTime;
  Offset? _lastTapPosition;
  int _tapCount = 0;
  static const _tapTimeout = Duration(milliseconds: 300);
  static const _tapProximityThreshold = 20.0;

  MouseEventHandler({
    required this.controller,
    required this.focusNode,
    required this.scrollToCursor,
    required this.style,
    required this.verticalScrollController,
  });

  /// Обрабатывает событие нажатия мыши (тап).
  void handleTap(
    TapDownDetails details,
    BuildContext context, {
    bool isDoubleTap = false,
  }) {
    print(
      'handleTap: Получен ${isDoubleTap ? "двойной" : "одиночный"} тап в позиции ${details.globalPosition}',
    );
    focusNode.requestFocus();
    _updateSelection(details, context, isDoubleTap: isDoubleTap);
  }

  /// Обрабатывает начало перетаскивания мыши.
  void handleDragStart(DragStartDetails details, BuildContext context) {
    print(
      'handleDragStart: Начало перетаскивания в позиции ${details.globalPosition}',
    );
    focusNode.requestFocus();
    _updateSelection(details, context, isDragStart: true);
  }

  /// Обрабатывает событие перетаскивания мыши для выделения текста.
  void handleDragUpdate(DragUpdateDetails details, BuildContext context) {
    print(
      'handleDragUpdate: Обновление перетаскивания в позиции ${details.globalPosition}',
    );
    _updateSelection(details, context);
  }

  /// Обновляет выделение текста на основе позиции мыши.
  /// [details] Детали события (TapDownDetails, DragStartDetails или DragUpdateDetails).
  /// [context] Контекст для получения RenderBox.
  /// [isDoubleTap] Флаг, указывающий на двойной тап.
  /// [isDragStart] Флаг, указывающий на начало перетаскивания.
  void _updateSelection(
    dynamic details,
    BuildContext context, {
    bool isDoubleTap = false,
    bool isDragStart = false,
  }) {
    print(
      '_updateSelection: Начало обработки события, isDoubleTap=$isDoubleTap, isDragStart=$isDragStart',
    );
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      print('_updateSelection: RenderBox не найден, обработка прервана');
      return;
    }

    final localPosition = renderBox.globalToLocal(details.globalPosition);
    print('_updateSelection: Локальная позиция курсора: $localPosition');
    final text = controller.text.isEmpty ? ' ' : controller.text;
    final effectiveStyle =
        style?.copyWith(overflow: TextOverflow.visible, color: Colors.black) ??
        const TextStyle(overflow: TextOverflow.visible, color: Colors.black);

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: effectiveStyle),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: renderBox.size.width);

    // Корректировка позиции с учётом прокрутки
    final verticalScrollOffset =
        verticalScrollController.hasClients
            ? verticalScrollController.position.pixels
            : 0.0;
    final adjustedPosition = Offset(
      localPosition.dx,
      localPosition.dy + verticalScrollOffset,
    );
    print('_updateSelection: Скорректированная позиция: $adjustedPosition');

    final offset = textPainter.getPositionForOffset(adjustedPosition);
    int newOffset = offset.offset.clamp(0, controller.text.length);
    print('_updateSelection: Вычисленный offset: $newOffset');

    if (details is TapDownDetails) {
      final now = DateTime.now();
      print(
        '_updateSelection: Текущее время: $now, последний тап: $_lastTapTime',
      );

      // Проверка на последовательные тапы
      bool isWithinTapWindow =
          _lastTapTime != null &&
          now.difference(_lastTapTime!) <= _tapTimeout &&
          _lastTapPosition != null &&
          (localPosition - _lastTapPosition!).distance <=
              _tapProximityThreshold;

      if (isDoubleTap && isWithinTapWindow) {
        // Тройной тап: выделение строки
        print('_updateSelection: Обработка тройного тапа');
        _tapCount = 3;
        final lineRange = _getLineRange(newOffset, text);
        controller.selection = TextSelection(
          baseOffset: lineRange.start,
          extentOffset: lineRange.end,
        );
        newOffset = lineRange.end;
        print(
          '_updateSelection: Выделена строка, диапазон: ${lineRange.start}-${lineRange.end}',
        );
      } else if (isDoubleTap) {
        // Двойной тап: выделение слова
        print('_updateSelection: Обработка двойного тапа');
        _tapCount = 2;
        final wordRange = _getWordRange(newOffset, text);
        controller.selection = TextSelection(
          baseOffset: wordRange.start,
          extentOffset: wordRange.end,
        );
        newOffset = wordRange.end;
        print(
          '_updateSelection: Выделено слово, диапазон: ${wordRange.start}-${wordRange.end}',
        );
      } else if (isWithinTapWindow && _tapCount == 2) {
        // Тройной тап после двойного
        print('_updateSelection: Обработка тройного тапа после двойного');
        _tapCount = 3;
        final lineRange = _getLineRange(newOffset, text);
        controller.selection = TextSelection(
          baseOffset: lineRange.start,
          extentOffset: lineRange.end,
        );
        newOffset = lineRange.end;
        print(
          '_updateSelection: Выделена строка, диапазон: ${lineRange.start}-${lineRange.end}',
        );
      } else {
        // Одиночный тап: установка курсора
        print('_updateSelection: Обработка одиночного тапа');
        _tapCount = 1;
        controller.selection = TextSelection.collapsed(offset: newOffset);
        print('_updateSelection: Курсор установлен на позицию: $newOffset');
      }

      _lastTapTime = now;
      _lastTapPosition = localPosition;
      print(
        '_updateSelection: Обновлены _lastTapTime: $_lastTapTime, _lastTapPosition: $_lastTapPosition',
      );
    } else if (details is DragStartDetails || isDragStart) {
      // Начало перетаскивания: установка начальной точки выделения
      print(
        '_updateSelection: Начало перетаскивания, установка начальной точки',
      );
      controller.selection = TextSelection.collapsed(offset: newOffset);
      _tapCount = 0; // Сбрасываем счётчик тапов
      print('_updateSelection: Сброс _tapCount, курсор на $newOffset');
    } else if (details is DragUpdateDetails) {
      // Перетаскивание: обновление выделения от начальной точки
      print('_updateSelection: Обновление перетаскивания');
      final currentSelection = controller.selection;
      controller.selection = TextSelection(
        baseOffset:
            currentSelection.baseOffset >= 0
                ? currentSelection.baseOffset
                : newOffset,
        extentOffset: newOffset,
      );
      print(
        '_updateSelection: Обновлено выделение, baseOffset: ${controller.selection.baseOffset}, extentOffset: $newOffset',
      );
    }

    print('_updateSelection: Прокрутка к позиции курсора: $newOffset');
    scrollToCursor(newOffset);
  }

  /// Возвращает диапазон слова для заданной позиции.
  /// [offset] Позиция курсора.
  /// [text] Текст для анализа.
  TextRange _getWordRange(int offset, String text) {
    print('_getWordRange: Вычисление диапазона слова для offset: $offset');
    if (text.isEmpty) {
      print('_getWordRange: Текст пуст, возвращён диапазон 0-0');
      return const TextRange(start: 0, end: 0);
    }

    // Находим начало слова
    int start = offset;
    while (start > 0 && !_isWordBoundary(text[start - 1])) {
      start--;
    }

    // Находим конец слова
    int end = offset;
    while (end < text.length && !_isWordBoundary(text[end])) {
      end++;
    }

    print('_getWordRange: Диапазон слова: $start-$end');
    return TextRange(start: start, end: end);
  }

  /// Возвращает диапазон строки для заданной позиции.
  /// [offset] Позиция курсора.
  /// [text] Текст для анализа.
  TextRange _getLineRange(int offset, String text) {
    print('_getLineRange: Вычисление диапазона строки для offset: $offset');
    if (text.isEmpty) {
      print('_getLineRange: Текст пуст, возвращён диапазон 0-0');
      return const TextRange(start: 0, end: 0);
    }

    // Находим начало строки
    int start = offset;
    while (start > 0 && text[start - 1] != '\n') {
      start--;
    }

    // Находим конец строки
    int end = offset;
    while (end < text.length && text[end] != '\n') {
      end++;
    }

    print('_getLineRange: Диапазон строки: $start-$end');
    return TextRange(start: start, end: end);
  }

  /// Проверяет, является ли символ границей слова.
  bool _isWordBoundary(String char) {
    final isBoundary = RegExp(r'[\s,.!?;:]').hasMatch(char);
    print(
      '_isWordBoundary: Символ "$char" ${isBoundary ? "является" : "не является"} границей слова',
    );
    return isBoundary;
  }
}
