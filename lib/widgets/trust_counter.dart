import 'package:flutter/material.dart';

class TrustCounter extends StatefulWidget {
  final TextEditingController controller;
  final double width;

  const TrustCounter({super.key, required this.controller, this.width = 150.0});

  @override
  // ignore: library_private_types_in_public_api
  _TrustCounterState createState() => _TrustCounterState();
}

class _TrustCounterState extends State<TrustCounter> {
  late int _counter;

  @override
  void initState() {
    super.initState();
    _counter = int.tryParse(widget.controller.text) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
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
            Text('$_counter', style: const TextStyle(fontSize: 20.0)),
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
