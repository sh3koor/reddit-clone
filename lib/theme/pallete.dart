// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/enums/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';

// provide the theme
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});

class Pallete {
  // Colors
  static const blackColor = Color.fromRGBO(1, 1, 1, 1); // primary color
  static const greyColor = Color.fromRGBO(26, 39, 45, 1); // secondary color
  static const drawerColor = Color.fromRGBO(18, 18, 18, 1);
  static const whiteColor = Colors.white;
  static var redColor = Colors.red.shade500;
  static var blueColor = Colors.blue.shade300;

  // Themes
  static var darkModeAppTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: blackColor,
    cardColor: greyColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: drawerColor,
      iconTheme: IconThemeData(
        color: whiteColor,
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: drawerColor,
    ),
    primaryColor: redColor,
    backgroundColor:
        drawerColor, // will be used as alternative background color
  );

  static var lightModeAppTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: whiteColor,
    cardColor: greyColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: whiteColor,
      elevation: 0,
      iconTheme: IconThemeData(
        color: blackColor,
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: whiteColor,
    ),
    primaryColor: redColor,
    backgroundColor: whiteColor,
  );
}

class ThemeNotifier extends StateNotifier<ThemeData> {
  eThemeMode _mode;
  ThemeNotifier({
    // The default is dark
    eThemeMode mode = eThemeMode.dark,
  })  : _mode = mode,
        super(Pallete.darkModeAppTheme) {
    // This will be called whenever the ThemeNotifier is created
    // This to remeber the theme when the app is launched
    getTheme();
  }

  void getTheme() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    // theme is eThemeMode either dark or light
    final theme = pref.getString("theme");
    if (theme == "light") {
      _mode = eThemeMode.light;
      state = Pallete.lightModeAppTheme;
    } else {
      _mode = eThemeMode.dark;
      state = Pallete.darkModeAppTheme;
    }
  }

  eThemeMode get mode => _mode;

  void toggleTheme() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    if (_mode == eThemeMode.light) {
      _mode = eThemeMode.dark;
      state = Pallete.darkModeAppTheme;
      pref.setString("theme", "dark");
    } else {
      _mode = eThemeMode.light;
      state = Pallete.lightModeAppTheme;

      pref.setString("theme", "light");
    }
  }
}
