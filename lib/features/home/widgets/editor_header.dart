import 'package:flutter/material.dart';

class EditorHeader extends StatelessWidget {
  const EditorHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Редактор входного файла',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
