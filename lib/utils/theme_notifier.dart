import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  MaterialColor _primaryColor = Colors.yellow; // default kuning

  MaterialColor get primaryColor => _primaryColor;

  ThemeData getTheme() {
    return ThemeData(
      primarySwatch: _primaryColor,
      primaryColor: _primaryColor,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: _primaryColor,
      ).copyWith(primary: _primaryColor, secondary: _primaryColor),
      scaffoldBackgroundColor: _primaryColor.shade50,
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _primaryColor.shade50,
        border: const OutlineInputBorder(),
      ),
    );
  }

  void setTheme(MaterialColor color) {
    _primaryColor = color;
    notifyListeners();
  }

  static Map<String, MaterialColor> colorOptions = {
    'Kuning': Colors.yellow,
    'Hijau': Colors.green,
    'Ungu': Colors.purple,
    'Biru Muda': Colors.blueGrey,
    'Coklat Susu': Colors.brown,
    'Biru Pastel': Colors.lightBlue,
    'Merah Muda': Colors.pink,
    'Abu Muda': Colors.grey,
    'Biru Toska': Colors.teal,
    'Oranye Lembut': Colors.orange,
    'Merah Marun': Colors.red,
  };
}
