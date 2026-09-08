import 'package:flutter/material.dart';

extension Responsive on BuildContext {
  bool get isSmall => MediaQuery.of(this).size.width < 360;
  bool get isTablet => MediaQuery.of(this).size.width >= 600;
}