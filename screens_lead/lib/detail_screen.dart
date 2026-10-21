import 'package:flutter/material.dart';
import 'routes.dart';
import 'students.dart';
import 'edit_screen.dart';


class DetailScreen extends StatefulWidget {
  final Student student;

  const DetailScreen({
    super.key,
    required this.student,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Student _student = widget.student;

  Future<void> _edit() async {
    final name = await Navigator.of(context).pushNamed<String>(Routes.edit, arguments: _student);
    // final name = await Navigator.of(context).push<String>(
    //   MaterialPageRoute(builder: (_) => EditScreen(student: _student)),
    // );

    if (name == null || !mounted) return;

    setState(() {
      _student = _student.copyWith(name: name);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_student.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _edit,
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.school),
            title: Text(_student.group),
          ),
          ListTile(
            leading: const Icon(Icons.mail),
            title: Text(_student.email),
          ),
        ],
      ),
    );
  }
}