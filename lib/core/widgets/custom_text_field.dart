import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller; // Контроллер для управления текстом
  final FocusNode? focusNode; // Нода фокуса для управления фокусом
  final InputDecoration?
  decoration; // Декорация поля ввода (рамка, подсказки и т.д.)
  final TextStyle? style; // Стиль текста в поле
  final bool autofocus; // Автофокус при загрузке
  final TextInputType? keyboardType; // Тип клавиатуры (например, multiline)
  final TextInputAction?
  textInputAction; // Действие кнопки на клавиатуре (например, "Готово")
  final ValueChanged<String>? onChanged; // Коллбэк при изменении текста
  final int? maxLines; // Максимальное количество строк
  final ScrollPhysics? scrollPhysics; // Физика прокрутки
  final TextAlignVertical?
  textAlignVertical; // Вертикальное выравнивание текста

  const CustomTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.decoration,
    this.style,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.maxLines,
    this.scrollPhysics,
    this.textAlignVertical,
  });

  @override
  CustomTextFieldState createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _effectiveController;
  late FocusNode _effectiveFocusNode;
  late ScrollController _scrollController;
  final _startKey = GlobalKey(); // Ключ для начала текста
  final _endKey = GlobalKey(); // Ключ для конца текста

  @override
  void initState() {
    super.initState();
    // Используем переданный контроллер или создаём новый
    _effectiveController = widget.controller ?? TextEditingController();
    // Используем переданную ноду фокуса или создаём новую
    _effectiveFocusNode = widget.focusNode ?? FocusNode();
    // Создаём контроллер прокрутки
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    // Уничтожаем только если они не были переданы извне
    if (widget.controller == null) {
      _effectiveController.dispose();
    }
    if (widget.focusNode == null) {
      _effectiveFocusNode.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  // Прокрутка к позиции курсора
  void _scrollToCursor(int cursorPosition) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Даём время на рендеринг
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;

        final isStart = cursorPosition == 0;
        final key = isStart ? _startKey : _endKey;

        if (key.currentContext == null) {
          return;
        }

        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: isStart ? 0.0 : 1.0, // 0.0 для начала, 1.0 для конца
        );
      });
    });
  }

  // Метод для обработки нажатий клавиш
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final text = _effectiveController.text;
    final selection = _effectiveController.selection;
    int offset = selection.baseOffset;

    // Проверка на валидность позиции курсора
    if (offset < 0 || offset > text.length) {
      offset = text.isEmpty ? 0 : text.length;
      _effectiveController.selection = TextSelection.collapsed(offset: offset);
      _scrollToCursor(offset); // Прокрутка при коррекции позиции
      return KeyEventResult.handled;
    }

    final lines = text.isEmpty ? [''] : text.split('\n');
    int charCount = 0;
    int currentLineIndex = 0;

    // Находим текущую строку и её начальную позицию
    for (int i = 0; i < lines.length; i++) {
      if (charCount + lines[i].length + 1 > offset) {
        currentLineIndex = i;
        break;
      }
      charCount += lines[i].length + 1; // +1 для символа новой строки
    }

    // Проверяем, зажат ли Shift (левый или правый)
    final bool isShiftPressed =
        HardwareKeyboard.instance.logicalKeysPressed.contains(
          LogicalKeyboardKey.shiftLeft,
        ) ||
        HardwareKeyboard.instance.logicalKeysPressed.contains(
          LogicalKeyboardKey.shiftRight,
        );

    // Отладочный вывод для отслеживания нажатий

    // Проверяем, зажат ли Shift для выделения текста
    final int anchor = selection.baseOffset; // Точка начала выделения

    // Обработка Home и Numpad 7 (Home)
    if (event.logicalKey == LogicalKeyboardKey.home ||
        event.logicalKey == LogicalKeyboardKey.numpad7) {
      final newOffset = charCount; // Начало текущей строки
      _effectiveController.selection =
          isShiftPressed
              ? TextSelection(baseOffset: anchor, extentOffset: newOffset)
              : TextSelection.collapsed(offset: newOffset);
      return KeyEventResult.handled;
    }
    // Обработка End и Numpad 1 (End)
    else if (event.logicalKey == LogicalKeyboardKey.end ||
        event.logicalKey == LogicalKeyboardKey.numpad1) {
      final newOffset =
          charCount + lines[currentLineIndex].length; // Конец текущей строки
      _effectiveController.selection =
          isShiftPressed
              ? TextSelection(baseOffset: anchor, extentOffset: newOffset)
              : TextSelection.collapsed(offset: newOffset);
      return KeyEventResult.handled;
    }
    // Обработка PageUp и Numpad 9 (PageUp)
    else if (event.logicalKey == LogicalKeyboardKey.pageUp ||
        event.logicalKey == LogicalKeyboardKey.numpad9) {
      const newOffset = 0; // Начало текста
      _effectiveController.selection =
          isShiftPressed
              ? TextSelection(baseOffset: anchor, extentOffset: newOffset)
              : TextSelection.collapsed(offset: newOffset);
      _scrollToCursor(newOffset); // Прокрутка к началу текста
      return KeyEventResult.handled;
    }
    // Обработка PageDown и Numpad 3 (PageDown)
    else if (event.logicalKey == LogicalKeyboardKey.pageDown ||
        event.logicalKey == LogicalKeyboardKey.numpad3) {
      final newOffset = text.length; // Конец текста
      _effectiveController.selection =
          isShiftPressed
              ? TextSelection(baseOffset: anchor, extentOffset: newOffset)
              : TextSelection.collapsed(offset: newOffset);
      _scrollToCursor(newOffset); // Прокрутка к концу текста
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: _handleKeyEvent, // Перехватываем события клавиш
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              TextField(
                controller: _effectiveController,
                focusNode: _effectiveFocusNode,
                decoration: widget.decoration,
                style: widget.style,
                autofocus: widget.autofocus,
                keyboardType: widget.keyboardType ?? TextInputType.multiline,
                textInputAction: widget.textInputAction,
                onChanged: widget.onChanged,
                maxLines: widget.maxLines,
                scrollPhysics: widget.scrollPhysics,
                textAlignVertical: widget.textAlignVertical,
                scrollController: _scrollController,
              ),
              // Невидимый виджет для начала текста
              Positioned(
                left: 0,
                top: 0,
                child: SizedBox(key: _startKey, width: 0, height: 0),
              ),
              // Невидимый виджет для конца текста
              Positioned(
                left: 0,
                top: constraints.maxHeight,
                child: SizedBox(key: _endKey, width: 0, height: 0),
              ),
            ],
          );
        },
      ),
    );
  }
}
