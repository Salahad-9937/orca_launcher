import 'package:flutter/material.dart';

/// Виджет для отображения колонки с номеров строк в текстовом редакторе.
/// [lineInfo] Список информации о строках (номер физической строки и количество визуальных строк).
/// [lineHeight] Высота одной строки.
/// [textStyle] Стиль текста для номеров строк.
/// [currentLine] Текущая визуальная строка для подсветки.
/// [controller] Контроллер текстового поля для управления выделением.
class LineNumberColumn extends StatelessWidget {
  final List<Map<String, dynamic>> lineInfo;
  final double lineHeight;
  final TextStyle textStyle;
  final int currentLine;
  final TextEditingController controller;

  const LineNumberColumn({
    super.key,
    required this.lineInfo,
    required this.lineHeight,
    required this.textStyle,
    required this.currentLine,
    required this.controller,
  });

  /// Возвращает диапазон строки для заданной позиции.
  /// [offset] Позиция в тексте.
  /// [text] Текст для анализа.
  TextRange _getLineRange(int offset, String text) {
    if (text.isEmpty) {
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

    return TextRange(start: start, end: end);
  }

  @override
  Widget build(BuildContext context) {
    int visualLineCounter = 0;

    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 40,
          color: Colors.grey[200],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children:
                lineInfo.expand((info) {
                  final physicalLine = info['physicalLine'] as int;
                  final visualLines = info['visualLines'] as int;
                  final List<Widget> widgets = [];

                  // Добавляем номер строки для первой визуальной строки
                  widgets.add(
                    GestureDetector(
                      onTap: () {
                        // Выделяем строку при клике по номеру
                        final text = controller.text;
                        final lines = text.isEmpty ? [''] : text.split('\n');
                        int charCount = 0;

                        // Находим начало и конец строки
                        for (int i = 0; i < physicalLine - 1; i++) {
                          charCount += lines[i].length + 1;
                        }
                        final lineRange = _getLineRange(charCount, text);
                        controller.selection = TextSelection(
                          baseOffset: lineRange.start,
                          extentOffset: lineRange.end,
                        );
                      },
                      child: SizedBox(
                        height: lineHeight,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              '$physicalLine',
                              style: textStyle.copyWith(
                                color:
                                    visualLineCounter + 1 <= currentLine &&
                                            currentLine <=
                                                visualLineCounter + visualLines
                                        ? Colors.black
                                        : Colors.grey,
                                fontWeight:
                                    visualLineCounter + 1 <= currentLine &&
                                            currentLine <=
                                                visualLineCounter + visualLines
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );

                  // Добавляем пустое пространство для остальных визуальных строк
                  for (int i = 1; i < visualLines; i++) {
                    widgets.add(
                      SizedBox(
                        height: lineHeight,
                        child:
                            Container(), // Пустой контейнер для визуальных строк
                      ),
                    );
                  }

                  visualLineCounter += visualLines;
                  return widgets;
                }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
