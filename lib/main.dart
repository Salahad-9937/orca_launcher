import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/models/editor_state.dart';
import 'core/models/directory_state.dart';
import 'core/services/file_service.dart';
import 'core/services/file_handler.dart';
import 'features/home/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => EditorState()),
        ChangeNotifierProvider(create: (context) => DirectoryState()),
        Provider(create: (context) => FileHandler(FileService())),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ORCA Input Generator',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
