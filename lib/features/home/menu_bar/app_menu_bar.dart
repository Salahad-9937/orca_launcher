import 'package:flutter/material.dart';
import 'file_menu.dart';
import 'run_menu.dart';
import 'help_menu.dart';
import 'view_menu.dart';

/// Виджет панели меню приложения.
class AppMenuBar extends StatelessWidget {
  const AppMenuBar({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuBar(children: [FileMenu(), ViewMenu(), RunMenu(), HelpMenu()]);
  }
}
