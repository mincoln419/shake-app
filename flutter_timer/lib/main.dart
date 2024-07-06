import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Timer'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
    );
  }
}

/*
├── lib
|   ├── timer
│   │   ├── bloc
│   │   │   └── timer_bloc.dart
|   |   |   └── timer_event.dart
|   |   |   └── timer_state.dart
│   │   └── view
│   │   |   ├── timer_page.dart
│   │   ├── timer.dart
│   ├── app.dart
│   ├── ticker.dart
│   └── main.dart
├── pubspec.lock
├── pubspec.yaml

 */
