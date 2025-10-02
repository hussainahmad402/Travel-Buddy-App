import 'package:flutter/material.dart';

/// AppSizes for responsive dimensions using MediaQuery.
/// Use these helpers to make your UI adaptive across different screens.
class AppSizes {
  final BuildContext context;

  AppSizes(this.context);

  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

}
