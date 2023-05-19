import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Themes {
  static final light = ThemeData(
    primaryColor: Colors.white,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(background: Colors.white, surface: Colors.white,),
  );
}

TextStyle get subHeadingStyle {
  return GoogleFonts.lato(
    textStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Colors.black,
    )
  );
}

TextStyle get headingStyle {
  return GoogleFonts.lato(
      textStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      )
  );
}
