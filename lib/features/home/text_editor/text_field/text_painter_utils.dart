import 'package:flutter/material.dart';

/// Утилиты для работы с TextPainter.
class TextPainterUtils {
  /// Создаёт TextPainter для вычисления размеров текста.
  /// [text] Текст для рендеринга.
  /// [style] Стиль текста.
  static TextPainter createTextPainter({
    required String text,
    TextStyle? style,
  }) {
    final effectiveText = text.isEmpty ? ' ' : text;
    final effectiveStyle =
        style?.copyWith(overflow: TextOverflow.visible, color: Colors.black) ??
        const TextStyle(overflow: TextOverflow.visible, color: Colors.black);

    final textPainter = TextPainter(
      text: TextSpan(text: effectiveText, style: effectiveStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    return textPainter;
  }
}
