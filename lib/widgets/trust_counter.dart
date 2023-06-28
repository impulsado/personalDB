import 'package:flutter/material.dart';

class TrustCounter extends StatefulWidget {
  final TextEditingController controller;

  TrustCounter({required this.controller});

  @override
  _TrustCounterState createState() => _TrustCounterState();
}

class _TrustCounterState extends State<TrustCounter> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionButton(
          heroTag: "decreaseTrustButton",  // añade un heroTag único
          onPressed: () {
            setState(() {
              _counter--;
              widget.controller.text = _counter.toString();
            });
          },
          child: const Icon(Icons.remove),
        ),
        Text('$_counter'),
        FloatingActionButton(
          heroTag: "increaseTrustButton",  // añade un heroTag único
          onPressed: () {
            setState(() {
              _counter++;
              widget.controller.text = _counter.toString();
            });
          },
          child: const Icon(Icons.add),
        ),
      ],
    );
  }
}