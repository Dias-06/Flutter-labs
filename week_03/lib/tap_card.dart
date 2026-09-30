import 'package:flutter/material.dart';

class TapCard extends StatefulWidget {
  const TapCard({super.key});

  @override
  State<TapCard> createState() => _TapCardState();
}

class _TapCardState extends State<TapCard> {
  int _taps = 0; // Наше единственное состояние

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          setState(() {
            _taps++;
          });
        },
          onLongPress: () async { // Помечаем функцию как асинхронную
            // 1. Показываем диалог и ждем (await) его результат
            final bool? shouldReset = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Reset the count?'), // Заголовок из задания
                  actions: [
                    // 3. Кнопка Cancel
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false); // Закрываем диалог и возвращаем false
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(onPressed: (){
                      Navigator.of(context).pop(true);
                    }, child: const Text("Reset"))

                  ],
                );
              },
            );

            // 5. Проверяем, что ответил диалог.
            // Если shouldReset равен true, нужно внутри setState обнулить _taps[cite: 2]
            if (shouldReset == true) {
              setState(() {
                _taps = 0;
              });

            }
          },
        child: ListTile(
          title: const Text('Tap this card'),
          trailing: Text('$_taps'),
        ),
      ),
    );
  }
}
