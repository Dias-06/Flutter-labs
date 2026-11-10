import 'package:flutter/material.dart';
import 'api/fake_api.dart';
void main() {
  print('A');
  Future.delayed(const Duration(seconds: 2), () => print('B'));
  print('C');
  final api = FakeApi();
  api.fetchStudents().then((l) => print('${l.length} students'));
  api.fetchStudents();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
    ),
  );
}