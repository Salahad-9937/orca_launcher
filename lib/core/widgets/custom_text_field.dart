import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final TextStyle? style;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final int? maxLines;
  final ScrollPhysics? scrollPhysics;
  final TextAlignVertical? textAlignVertical;

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

  @override
  void initState() {
    super.initState();
    _effectiveController = widget.controller ?? TextEditingController();
    _effectiveFocusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _effectiveController.dispose();
    }
    if (widget.focusNode == null) {
      _effectiveFocusNode.dispose();
    }
    super.dispose();
  }

  void _handleKeyEvent(LogicalKeyboardKey key) {
    if (!_effectiveFocusNode.hasFocus) return;

    final text = _effectiveController.text;
    final selection = _effectiveController.selection;
    final lines = text.isEmpty ? [''] : text.split('\n');
    int currentLineIndex = 0;
    int charCount = 0;

    // Находим текущую строку
    for (int i = 0; i < lines.length; i++) {
      if (charCount + lines[i].length >= selection.baseOffset) {
        currentLineIndex = i;
        break;
      }
      charCount += lines[i].length + 1;
    }

    if (key == LogicalKeyboardKey.home) {
      final startOfLine = charCount;
      _effectiveController.selection = TextSelection.collapsed(
        offset: startOfLine,
      );
    } else if (key == LogicalKeyboardKey.end) {
      final endOfLine = charCount + lines[currentLineIndex].length;
      _effectiveController.selection = TextSelection.collapsed(
        offset: endOfLine,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.home): const HomeIntent(),
        LogicalKeySet(LogicalKeyboardKey.end): const EndIntent(),
      },
      child: Actions(
        actions: {
          HomeIntent: CallbackAction<HomeIntent>(
            onInvoke: (intent) {
              _handleKeyEvent(LogicalKeyboardKey.home);
              return null;
            },
          ),
          EndIntent: CallbackAction<EndIntent>(
            onInvoke: (intent) {
              _handleKeyEvent(LogicalKeyboardKey.end);
              return null;
            },
          ),
        },
        child: TextField(
          controller: _effectiveController,
          focusNode: _effectiveFocusNode,
          decoration: widget.decoration,
          style: widget.style,
          autofocus: widget.autofocus,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          maxLines: widget.maxLines,
          scrollPhysics: widget.scrollPhysics,
          textAlignVertical: widget.textAlignVertical,
        ),
      ),
    );
  }
}

class HomeIntent extends Intent {
  const HomeIntent();
}

class EndIntent extends Intent {
  const EndIntent();
}
