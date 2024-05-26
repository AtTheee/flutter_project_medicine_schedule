import 'package:dory/components/dory_colors.dart';
import 'package:flutter/material.dart';

class DoryThemes {
  static ThemeData get lightTheme => ThemeData(
        primarySwatch: DoryColors.primaryMeterialColor,
        fontFamily: 'GmarketSansTTF',
        scaffoldBackgroundColor: Colors.white,
        splashColor: Colors.white, // floatingactionbutton 눌렀을 때
        textTheme: _textTheme,
        appBarTheme: _appBarTheme,
        brightness: Brightness.light, // 테마 설정
      );

  static ThemeData get darkTheme => ThemeData(
        primarySwatch: DoryColors.primaryMeterialColor,
        fontFamily: 'GmarketSansTTF',
        splashColor: Colors.white, // floatingactionbutton 눌렀을 때
        textTheme: _textTheme,
        brightness: Brightness.dark, // 테마 설정
      );

  static const AppBarTheme _appBarTheme = AppBarTheme(
    backgroundColor: Colors.white,
    iconTheme: IconThemeData(color: DoryColors.primaryColor),
    elevation: 0,
  );

  static const TextTheme _textTheme = TextTheme(
    headline4: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w400,
    ),
    subtitle1: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    subtitle2: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w300,
    ),
    bodyText1: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w300,
    ),
    bodyText2: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w300,
    ),
    button: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w300,
    ),
  );
}
