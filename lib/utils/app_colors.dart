import 'package:flutter/material.dart';
import 'package:projet_sncf/extensions/color_extension.dart';

class AppColors {
  // Define all the colors used in the app

  // Primary color
  static final Color primary = Color(0xFF6E1E78);
  static final Color onPrimary = Color(0xFFDAD2FF);

  // Secondary color
  static final Color secondary = Color(0xFF91005B);
  static final secondaryColorButDarker = secondary.darken(30);
  static final Color secondaryColorButLight = Color(0xFFFFB9DD);
  static final Color onSecondary = Color(0xFFFFEAE3);

  // Tertiary color
  static final Color tertiary = Color(0xFF0088CE);
  static final Color onTertiary = Color(0xFFE6F4F1);

  static final Color notReallyDark = Color(0xFF1F1F1F);
  static final Color notReallyDark2 = Color(0xFF2F2F2F);

  // Define the color of the cards
  static final Color cardColor = secondaryColorButDarker;

  // Define the color of checkboxes
  static final Color checkboxSelectedFillColor = secondaryColorButLight;
  static final Color checkboxCheckColor = notReallyDark;

  // Define the color of the radio buttons
  static final Color radioSelectedFillColor = secondaryColorButLight;

  // Success color
  static final Color success = Color(0xFF82BE00);

  // Error color
  static final Color error = Color(0xFFD52B1E);
}
