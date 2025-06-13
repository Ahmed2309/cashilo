import 'package:flutter/material.dart';

class AppColors {
  // Light mode colors
  static const background = Color(0xFFF9F9F9);
  static const primaryText = Color(0xFF333333);
  static const headline = Color(0xFF1E2A38);
  static const primary = Color(0xFF00B8D9);
  static const secondary = Color(0xFF36B37E);
  static const warning = Color(0xFFFFAB00);
  static const error = Color(0xFFFF5630);
  static const card = Color(0xFFECECEC);
}

const List<String> supportedLanguages = [
  'English',
  'Arabic',
  'French',
];

const List<String> supportedCurrencies = [
  'USD',
  'EUR',
  'SAR',
  'EGP',
];

const List<Color> incomeCategoryColors = [
  AppColors.secondary,
  Colors.green,
  Colors.blue,
  Colors.orange,
  Colors.teal,
  Colors.purple,
  Colors.indigo,
  AppColors.primary,
  Colors.brown,
];

const List<Color> expenseCategoryColors = [
  AppColors.error,
  Colors.redAccent,
  Colors.orange,
  Colors.purple,
  Colors.amber,
  Colors.indigo,
  Colors.cyan,
  Colors.brown,
  Colors.pink,
  Colors.lime,
  Colors.deepOrange,
  Colors.deepPurple,
  Colors.blue, // strong blue
  Colors.green, // strong green
  Colors.teal, // strong teal
  Colors.purple, // strong purple
  AppColors.primary,
  AppColors.secondary,
];
