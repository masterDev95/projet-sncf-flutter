import 'package:flutter/material.dart';
import 'package:projet_sncf/extensions/color_extension.dart';
import 'package:projet_sncf/utils/app_colors.dart';

class LogoRSA extends StatelessWidget {
  const LogoRSA({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.0),
          color: AppColors.onPrimary.setAlphaPercent(60),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 5.0,
          ),
          child: Image.asset(
            "assets/images/logo.png",
            height: 36,
          ),
        ),
      ),
    );
  }
}
