import 'package:flutter/material.dart';

/// Виджет для отображения колонки с номеров строк в текстовом редакторе.
/// [lineInfo] Список информации о строках (номер физической строки и количество визуальных строк).
/// [lineHeight] Высота одной строки.
/// [textStyle] Стиль текста для номеров строк.
/// [currentLine] Текущая визуальная строка для подсветки.
class LineNumberColumn extends StatelessWidget {
  final List<Map<String, dynamic>> lineInfo;
  final double lineHeight;
  final TextStyle textStyle;
  final int currentLine;

  const LineNumberColumn({
    super.key,
    required this.lineInfo,
    required this.lineHeight,
    required this.textStyle,
    required this.currentLine,
  });

  @override
  Widget build(BuildContext context) {
    int visualLineCounter = 0;

    return Column(
      children: [
        const SizedBox(height: 4),
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
                    SizedBox(
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
      ],
    );
  }
}
