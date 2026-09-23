import 'package:flutter/material.dart';
import 'package:week2_lab/data.dart';
import 'package:week2_lab/info_row.dart';
import 'package:week2_lab/profile_header.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(title: const Text("My profile")),
      body: Column(children: [
        ProfileHeader(name: "Dias", university: "KBtu"),
        for(final fact in facts)
          InfoRow(label: fact.label, value: fact.value)
      ],))
    );
  }
}


