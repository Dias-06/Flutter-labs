import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TwoWayCounter extends StatefulWidget {
  const TwoWayCounter({super.key});

  @override
  State<TwoWayCounter> createState() => _TwoWayCounterState();
}

class _TwoWayCounterState extends State<TwoWayCounter> {
  int _count = 0;
  bool _saving = false;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        OutlinedButton(onPressed: _count == 0 ? null : (){
          setState(() {
            _count--;
          });
        }
        , child: const Text("-")),
        Padding(padding: const EdgeInsets.all(16.0), child: Text("$_count") ,),
        FilledButton(onPressed: (){setState(() {
          _count++;
        });}, child: const Text("+"))
      ],),
      FilledButton(onPressed: _saving == true ? null : () async {
        setState(() {
          _saving = true;
        });
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;
        setState(() {
          _saving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
      },
          child: _saving == true ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(),) : Text("Save"))
    ],);
  }
}
