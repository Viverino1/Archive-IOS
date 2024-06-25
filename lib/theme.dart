import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final TextStyle title = GoogleFonts.dmSerifDisplay(
    fontSize: 24,
    fontWeight: FontWeight.bold
);

final TextStyle subTitle = GoogleFonts.varelaRound(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white60,
);

final TextStyle smallTitle = GoogleFonts.varelaRound(
  fontSize: 16,
  fontWeight: FontWeight.bold,
);

CupertinoThemeData cupertinoDark = CupertinoThemeData(
  brightness: Brightness.dark,
  primaryColor: Color.fromARGB(255, 21, 97, 109),
  textTheme: CupertinoTextThemeData(
    tabLabelTextStyle: GoogleFonts.quicksand(
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
  ),
);

