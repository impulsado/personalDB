import 'package:flutter/material.dart';
import 'package:personaldb/constants/theme.dart';

class MyButton extends StatelessWidget {
  final String label;
  final Function()? onTap;
  final Color bgColor;
  final Color iconColor;

  const MyButton({
    Key? key,
    required this.label,
    required this.onTap,
    required this.bgColor,
    required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: key.toString(),
        child: Container(
          width: 120,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: bgColor),
          child: Text(label, style: subHeadingStyle(color: iconColor),),
        ),
      ),
    );
  }
}
