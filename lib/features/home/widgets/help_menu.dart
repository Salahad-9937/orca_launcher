import 'package:flutter/material.dart';

class HelpMenu extends StatelessWidget {
  const HelpMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return SubmenuButton(
      menuChildren: [
        MenuItemButton(
          onPressed: () {
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('О программе'),
                    content: const Text(
                      'Инструмент для создания входных файлов ORCA.\nВерсия 1.0.0',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('ОК'),
                      ),
                    ],
                  ),
            );
          },
          child: const Text('О программе'),
        ),
      ],
      child: const Text('Справка'),
    );
  }
}
