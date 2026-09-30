import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class StopwatchCard extends StatefulWidget {
  const StopwatchCard({super.key});

  @override
  State<StopwatchCard> createState() => _StopwatchCardState();
}

class _StopwatchCardState extends State<StopwatchCard> {
  int _seconds = 0;
  String get _formattedTime {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
  Timer? _timer;

  void _start(){
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }
  void _stop() {
    _timer?.cancel();
    _timer = null;
  }
  void _reset() {
    _stop();
    setState(() {
      _seconds = 0;
    });
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Card(child: Column(children: [
      Text(_formattedTime, style: Theme.of(context).textTheme.headlineMedium),
      Row(children: [FilledButton(onPressed: (){_start();}, child: Text("Start")),
      FilledButton(onPressed: _stop, child: Text("Stop")),
      FilledButton(onPressed: _reset, child: Text("Reset"))],)
      
    ],),);
  }
}
