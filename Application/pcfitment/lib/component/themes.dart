import 'package:flutter/material.dart';
import 'package:pcfitment/component/color_confing.dart';

class ThemeClass {
  static ThemeData lightTheme = ThemeData(
    //primaryColor: ThemeData.light().scaffoldBackgroundColor,

    colorScheme: const ColorScheme.light().copyWith(
        primary: ColorConfing.lightPrimaryColor,
        secondary: ColorConfing.secondaryColor),

    scaffoldBackgroundColor: Colors.white,

    cardColor: Colors.white,

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        /*// Set red button color
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            // Determine text color based on the theme brightness
            if (states.contains(MaterialState.disabled)) {
              return Colors.grey; // Use grey color when button is disabled
            }
            return Colors
                .black; // Use white color for text in enabled state (light mode)
          },
        ),*/
      ),
    ),

    textTheme: const TextTheme(
      labelMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
      bodyMedium: TextStyle(color: Colors.black),
      bodySmall: TextStyle(color: Colors.black),
      bodyLarge: TextStyle(color: Colors.black),
    ),

    drawerTheme: const DrawerThemeData(
      backgroundColor: Colors.white,
      elevation: 4, // Set elevation for the drawer in light mode
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
    ),

    tabBarTheme: const TabBarTheme(
      labelColor: Colors.black, // First item text color
      unselectedLabelColor: Colors.white, // Other items text color
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
            width: 4,
            color: Colors.black), // Indicator line color and thickness
      ),
    ),

    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: Colors.black),
      // Customize label color for light theme
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
            color: Colors
                .black), // Customize border color for disabled state in light theme
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    //primaryColor: ThemeData.dark().scaffoldBackgroundColor,

    colorScheme: const ColorScheme.dark().copyWith(
      primary: ColorConfing.darkPrimaryColor,
    ),

    scaffoldBackgroundColor: Colors.black,

    cardColor: Colors.black,

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        /*// Set red button color
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            // Determine text color based on the theme brightness
            if (states.contains(MaterialState.disabled)) {
              return Colors.grey; // Use grey color when button is disabled
            }
            return Colors
                .white; // Use black color for text in enabled state (dark mode)
          },
        ),*/
      ),
    ),

    textTheme: const TextTheme(
      labelMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      bodyMedium: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Colors.white),
      bodyLarge: TextStyle(color: Colors.white),
    ),

    drawerTheme: DrawerThemeData(
      backgroundColor: Colors.grey[700],
      elevation: 4,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
    ),

    tabBarTheme: const TabBarTheme(
      labelColor: Colors.white, // First item text color
      unselectedLabelColor: Colors.black, // Other items text color
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
            width: 4,
            color: Colors.white), // Indicator line color and thickness
      ),
    ),

    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: Colors.white),
      // Customize label color for dark theme
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
            color: Colors
                .white), // Customize border color for disabled state in dark theme
      ),
    ),
  );
}
