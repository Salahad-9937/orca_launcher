import 'package:flutter/material.dart';

/// Виджет для отображения колонки с номерами строк в текстовом редакторе.
/// [lineCount] - количество строк для отображения.
/// [lineHeight] - высота одной строки, для синхронизации с текстовым полем.
/// [textStyle] - стиль текста для номеров строк.
class LineNumberColumn extends StatelessWidget {
  final int lineCount;
  final double lineHeight;
  final TextStyle textStyle;

  const LineNumberColumn({
    super.key,
    required this.lineCount,
    required this.lineHeight,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 4),
        Container(
          width: 40,
          color: Colors.grey[200],
          child: Column(
            children: List.generate(
              lineCount,
              (index) => SizedBox(
                height: lineHeight,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      '${index + 1}',
                      style: textStyle.copyWith(color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
