import 'package:flutter/material.dart';
import 'package:personaldb/constants/theme.dart';

class MyButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final Function()? onTap;
  final Color bgColor;
  final Color iconColor;

  const MyButton({
    Key? key,
    this.label,
    this.icon,
    required this.onTap,
    required this.bgColor,
    required this.iconColor,
  }) : assert(label != null || icon != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: key.toString(),
        child: Container(
          width: icon != null ? 60 : 120,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: bgColor),
          child: icon == null
              ? Text(label!, style: subHeadingStyle(color: iconColor))
              : Icon(icon, color: iconColor),
        ),
      ),
    );
  }
}
