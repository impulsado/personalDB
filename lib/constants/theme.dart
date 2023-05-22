import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Themes {
  static final light = ThemeData(
    primaryColor: Colors.white,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(background: Colors.white, surface: Colors.white,),
  );
}

TextStyle subHeadingStyle({required Color color}) {
  return GoogleFonts.lato(
      textStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color,
      )
  );
}

TextStyle headingStyle({required Color color}) {
  return GoogleFonts.lato(
      textStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: color,
      )
  );
}
