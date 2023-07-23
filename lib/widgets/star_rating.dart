import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class StarRating extends StatelessWidget {
  final double initialValue;
  final ValueChanged<double> onChanged;
  final double itemSize;
  final Color? fillColor;
  final Icon? icon;
  final bool isReadOnly;

  StarRating({
    required this.onChanged,
    this.initialValue = 0,
    this.itemSize = 40.0,
    this.fillColor,
    this.icon,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: initialValue,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
      itemBuilder: (context, _) => icon ?? Icon(
        Icons.star,
        color: fillColor ?? Colors.amber,
      ),
      itemSize: itemSize,
      onRatingUpdate: isReadOnly ? (_) {} : onChanged, // Change this line
      ignoreGestures: isReadOnly, // Add this line
    );
  }
}
