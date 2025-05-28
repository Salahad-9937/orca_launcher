import 'package:flutter/material.dart';
import 'file_menu.dart';
import 'run_menu.dart';
import 'help_menu.dart';

class AppMenuBar extends StatelessWidget {
  final String title;

  const AppMenuBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return MenuBar(children: [FileMenu(), RunMenu(), HelpMenu()]);
  }
}
