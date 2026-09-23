import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget{
  final String name;
  final String university;
  const ProfileHeader({super.key, required this.name, required this.university});
  @override
  Widget build(BuildContext context) {
    return Column(children:
    [Image.asset('assets/images/photo.jpg'),
      Text(name),
      Text(university,
        style: const TextStyle(fontFamily: 'Cabin'))],);
  }
}