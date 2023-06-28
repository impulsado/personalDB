import 'package:flutter/material.dart';

class TrustCounter extends StatefulWidget {
  final TextEditingController controller;
  final double width; // Añade este campo para configurar el ancho

  TrustCounter({required this.controller, this.width = 150.0});

  @override
  _TrustCounterState createState() => _TrustCounterState();
}

class _TrustCounterState extends State<TrustCounter> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width, // Usa el ancho especificado
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _counter--;
                  widget.controller.text = _counter.toString();
                });
              },
              icon: const Icon(Icons.remove),
              color: Colors.black,
            ),
            Text('$_counter', style: TextStyle(fontSize: 20.0)),
            IconButton(
              onPressed: () {
                setState(() {
                  _counter++;
                  widget.controller.text = _counter.toString();
                });
              },
              icon: const Icon(Icons.add),
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}