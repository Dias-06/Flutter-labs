import 'package:flutter/material.dart';
import 'package:screens_lead/routes.dart';
import 'detail_screen.dart';
import 'students.dart'; // Импортируем наш массив студентов

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
      ),
      body: ListView.builder(
        itemCount: students.length, // Указываем общее количество элементов
        itemBuilder: (context, index) {
          final s = students[index]; // Берем студента по индексу

          return ListTile(
            leading: CircleAvatar(
              child: Text(s.name[0]), // Первая буква имени
            ),
            title: Text(s.name), // Имя
            subtitle: Text(s.group), // Группа
            trailing: const Icon(Icons.chevron_right), // Иконка стрелочки
            onTap: () {
              Navigator.of(context).pushNamed(
                Routes.student,
                arguments: s,
              );
            },
          );
        },
      ),
    );
  }
}
